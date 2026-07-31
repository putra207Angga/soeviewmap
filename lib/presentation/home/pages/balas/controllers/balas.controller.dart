part of '../../main.pages.dart';

class BalasLogModel {
  final String id;
  final String date;
  final String reviewerName;
  final double rating;
  final String reviewText;
  final adminReply = ''.obs;
  final status = 'pending'.obs;

  BalasLogModel({
    required this.id,
    required this.date,
    required this.reviewerName,
    required this.rating,
    required this.reviewText,
    String initialReply = '',
    String initialStatus = 'pending',
  }) {
    adminReply.value = initialReply;
    status.value = initialStatus;
  }
}

class BalasController extends GetxController {
  final selectedMonth = 'Juli 2026'.obs;
  final isExporting = false.obs;
  final isLoading = true.obs;

  // Reactive list of reply logs
  final replyLogs = <BalasLogModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchReplyLogs();
  }

  Future<void> fetchReplyLogs({bool showSnackbar = false}) async {
    isLoading.value = true;
    try {
      final response = await ReviewDao.use.getReviews(status: 'replied');
      if (response.statusCode == 200 && response.body != null) {
        final List<dom.ReviewModel> apiReviews = response.body!.items;
        final mapped = apiReviews.map((item) {
          return BalasLogModel(
            id: item.id.toString(),
            date: _formatDateTime(item.createdAt),
            reviewerName: item.reviewerName,
            rating: item.rating.toDouble(),
            reviewText: item.comment,
            initialReply: item.replyText,
            initialStatus: (item.replyText.isNotEmpty) ? 'terkirim' : 'pending',
          );
        }).toList();
        replyLogs.assignAll(mapped);
        
        // Dynamically select the first available month if any
        final months = availableMonths;
        if (months.isNotEmpty) {
          if (!months.contains(selectedMonth.value)) {
            selectedMonth.value = months.first;
          }
        }

        if (showSnackbar) {
          Get.snackbar(
            'Refresh Sukses',
            'Log balasan berhasil diperbarui dari server.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.isDarkMode
                ? const Color(0xFF1E222B)
                : Colors.white.withOpacity(0.95),
            colorText: Get.isDarkMode ? Colors.white : Colors.black,
            borderWidth: 1,
            borderColor: Get.isDarkMode
                ? const Color(0xFF2E3440)
                : Colors.grey.shade200,
          );
        }
      } else {
        _loadMockLogs();
      }
    } catch (e) {
      print('BalasController fetchReplyLogs error: $e');
      _loadMockLogs();
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _loadMockLogs() {
    replyLogs.assignAll([
      BalasLogModel(
        id: '1',
        date: '28 Jul 2026',
        reviewerName: 'Nia utami',
        rating: 5.0,
        reviewText: 'Adik saya melahirkan diruang bersalin, dokter dan bidannya telaten dan ramah. S...',
        initialReply: 'Yth. Bapak/Ibu Nia utami,',
        initialStatus: 'terkirim',
      ),
      BalasLogModel(
        id: '2',
        date: '28 Jul 2026',
        reviewerName: 'Meinar Eka',
        rating: 5.0,
        reviewText: 'Istri saya dirawat di ruang bersalin, selama dirawat disini pelayanannya baik, ...',
        initialReply: 'Yth. Bapak/Ibu Meinar Eka,',
        initialStatus: 'terkirim',
      ),
      BalasLogModel(
        id: '3',
        date: '27 Jul 2026',
        reviewerName: 'Erick Bsett',
        rating: 5.0,
        reviewText: 'Pelayanan Dokter dan Bidan "Dokter kandungan dan bidannya sangat ramah, s...',
        initialReply: 'Yth. Bapak/Ibu Erick Bsett,',
        initialStatus: 'terkirim',
      ),
      BalasLogModel(
        id: '4',
        date: '27 Jul 2026',
        reviewerName: 'Amelia Vieta',
        rating: 5.0,
        reviewText: 'Pelayanan baik dan telaten',
        initialReply: 'Yth. Bapak/Ibu Amelia Vieta,',
        initialStatus: 'terkirim',
      ),
      BalasLogModel(
        id: '5',
        date: '27 Jul 2026',
        reviewerName: 'nurul yaqinbinahmad',
        rating: 5.0,
        reviewText: 'Fasilitas bersih dan lengkap, pelayanan ramah.',
        initialReply: 'Yth. Bapak/Ibu nurul yaqinbinahmad,',
        initialStatus: 'terkirim',
      ),
      BalasLogModel(
        id: '6',
        date: '15 Okt 2023',
        reviewerName: 'Mega Puspita',
        rating: 1.0,
        reviewText: 'Jadwal dokter tidak sesuai jam praktek yang tertera di website.',
        initialReply: '',
        initialStatus: 'pending',
      ),
    ]);

    // Force select July 2026 as it matches mock data
    final months = availableMonths;
    if (months.contains('Juli 2026')) {
      selectedMonth.value = 'Juli 2026';
    } else if (months.isNotEmpty) {
      selectedMonth.value = months.first;
    }
  }

  List<String> get availableMonths {
    final months = <String>{};
    for (final log in replyLogs) {
      final parts = log.date.split(' ');
      if (parts.length >= 3) {
        final logMonthAbbr = parts[1];
        final logYear = parts[2];
        final fullName = _getFullMonthName(logMonthAbbr);
        months.add('$fullName $logYear');
      }
    }
    final list = months.toList();
    list.sort((a, b) {
      try {
        final aParts = a.split(' ');
        final bParts = b.split(' ');
        final aYear = int.parse(aParts[1]);
        final bYear = int.parse(bParts[1]);
        if (aYear != bYear) {
          return bYear.compareTo(aYear);
        }
        final aMonthIdx = _getMonthIndex(aParts[0]);
        final bMonthIdx = _getMonthIndex(bParts[0]);
        return bMonthIdx.compareTo(aMonthIdx);
      } catch (e) {
        return 0;
      }
    });
    if (list.isEmpty) {
      return ['Juli 2026', 'Oktober 2023'];
    }
    return list;
  }

  String _getFullMonthName(String abbr) {
    switch (abbr.toLowerCase()) {
      case 'jan': return 'Januari';
      case 'feb': return 'Februari';
      case 'mar': return 'Maret';
      case 'apr': return 'April';
      case 'mei': return 'Mei';
      case 'jun': return 'Juni';
      case 'jul': return 'Juli';
      case 'ags': return 'Agustus';
      case 'sep': return 'September';
      case 'okt': return 'Oktober';
      case 'nov': return 'November';
      case 'des': return 'Desember';
      default: return abbr;
    }
  }

  int _getMonthIndex(String name) {
    switch (name.toLowerCase()) {
      case 'januari': case 'jan': return 1;
      case 'februari': case 'feb': return 2;
      case 'maret': case 'mar': return 3;
      case 'april': case 'apr': return 4;
      case 'mei': case 'may': return 5;
      case 'juni': case 'jun': return 6;
      case 'juli': case 'jul': return 7;
      case 'agustus': case 'ags': case 'agu': return 8;
      case 'september': case 'sep': return 9;
      case 'oktober': case 'okt': return 10;
      case 'november': case 'nov': return 11;
      case 'desember': case 'des': return 12;
      default: return 0;
    }
  }

  List<BalasLogModel> get filteredReplyLogs {
    if (selectedMonth.value.isEmpty) {
      return replyLogs;
    }
    return replyLogs.where((log) {
      final parts = log.date.split(' ');
      if (parts.length < 3) return false;
      final logMonthName = parts[1].toLowerCase();
      final logYear = parts[2];
      
      final monthParts = selectedMonth.value.split(' ');
      if (monthParts.length < 2) return false;
      final selectedMonthName = monthParts[0].toLowerCase();
      final selectedYear = monthParts[1];
      
      if (logYear != selectedYear) return false;
      
      final monthMap = {
        'jan': ['jan', 'januari', 'january'],
        'feb': ['feb', 'februari', 'february'],
        'mar': ['mar', 'maret', 'march'],
        'apr': ['apr', 'april'],
        'mei': ['mei', 'may'],
        'jun': ['jun', 'juni', 'june'],
        'jul': ['jul', 'juli', 'july'],
        'ags': ['ags', 'agu', 'agustus', 'august'],
        'sep': ['sep', 'september'],
        'okt': ['okt', 'oktober', 'october'],
        'nov': ['nov', 'november'],
        'des': ['des', 'desember', 'december'],
      };
      
      final matchedList = monthMap[logMonthName] ?? [logMonthName];
      return matchedList.contains(selectedMonthName);
    }).toList();
  }

  Future<void> exportPdfReport() async {
    if (isExporting.value) return;

    isExporting.value = true;

    try {
      final pdf = pw.Document();
      final items = filteredReplyLogs;

      final primaryColor = PdfColor.fromHex('#6366F1'); // Indigo
      final darkColor = PdfColor.fromHex('#1E222B');
      final greyColor = PdfColor.fromHex('#9CA3AF');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RSUD dr. Soebandi - Pusat Balasan',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      pw.Text(
                        'Laporan Audit Log Balasan Google Maps Review',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: greyColor,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Periode: ${selectedMonth.value}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            
            // Stats summary row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Ulasan Periode Ini: ${items.length}',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Terkirim: ${items.where((i) => i.status.value == 'terkirim').length} | Pending: ${items.where((i) => i.status.value != 'terkirim').length}',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // Table of logs
            pw.TableHelper.fromTextArray(
              headers: ['Tanggal', 'User Pengguna', 'Rating', 'Ulasan Pengguna', 'Balasan Admin', 'Status'],
              data: List<List<String>>.generate(items.length, (index) {
                final item = items[index];
                return [
                  item.date,
                  item.reviewerName,
                  '${item.rating.toInt()}★',
                  item.reviewText,
                  item.adminReply.value.isEmpty ? 'Belum ditanggapi' : item.adminReply.value,
                  item.status.value.toUpperCase(),
                ];
              }),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              headerDecoration: pw.BoxDecoration(
                color: primaryColor,
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 8,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                2: pw.Alignment.center,
                5: pw.Alignment.center,
              },
            ),
          ],
        ),
      );

      // Write to Downloads directory
      String downloadsDir = '.';
      if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '';
        if (userProfile.isNotEmpty) {
          downloadsDir = '$userProfile\\Downloads';
        }
      }
      
      final fileName = 'Laporan_Log_Balasan_${selectedMonth.value.replaceAll(' ', '_')}.pdf';
      final file = File('$downloadsDir\\$fileName');
      await file.writeAsBytes(await pdf.save());

      Get.snackbar(
        'Export Berhasil',
        'Laporan log balasan berhasil disimpan ke folder Downloads:\n$fileName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF1E222B)
            : Colors.white.withOpacity(0.95),
        colorText: Get.isDarkMode ? Colors.white : Colors.black,
        borderWidth: 1,
        borderColor: Get.isDarkMode
            ? const Color(0xFF2E3440)
            : Colors.grey.shade200,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      print('Export PDF Error: $e');
      Get.snackbar(
        'Export Gagal',
        'Terjadi kesalahan saat menyimpan PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
    } finally {
      isExporting.value = false;
    }
  }

  void changeMonth(String month) {
    selectedMonth.value = month;
  }

  void updateAdminReply(String logId, String newReply) {
    final idx = replyLogs.indexWhere((l) => l.id == logId);
    if (idx != -1) {
      replyLogs[idx].adminReply.value = newReply;
      replyLogs[idx].status.value = newReply.trim().isEmpty
          ? 'pending'
          : 'terkirim';
      replyLogs.refresh();
    }
  }

  void deleteReply(String logId) {
    final idx = replyLogs.indexWhere((l) => l.id == logId);
    if (idx != -1) {
      replyLogs[idx].adminReply.value = '';
      replyLogs[idx].status.value = 'pending';
      replyLogs.refresh();
    }
  }
}


