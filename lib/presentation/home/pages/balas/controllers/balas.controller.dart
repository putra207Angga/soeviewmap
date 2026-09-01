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
  static String get _currentMonthString {
    final now = DateTime.now();
    final monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${monthNames[now.month - 1]} ${now.year}';
  }

  late final selectedMonth = _currentMonthString.obs;
  final isExporting = false.obs;
  final isLoading = true.obs;
  final isBackgroundLoading = false.obs;

  // Pagination State
  final currentPage = 1.obs;
  final pageSize = 5.obs;

  // Token to prevent stale background fetches when filter changes
  int _currentFetchToken = 0;

  final ScrollController scrollController = ScrollController();

  // Reactive list of reply logs
  final replyLogs = <BalasLogModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    selectedMonth.value = _currentMonthString;
    fetchReplyLogs();

    // Auto re-fetch saat filter bulan di UI diubah oleh pengguna
    ever(selectedMonth, (_) {
      currentPage.value = 1;
      fetchReplyLogs();
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void changeMonth(String month) {
    selectedMonth.value = month;
    currentPage.value = 1;
  }

  String? get currentMonthDateFrom {
    final selected = selectedMonth.value;
    if (selected.isEmpty) return null;
    final parts = selected.split(' ');
    if (parts.length < 2) return null;
    final monthIdx = _getMonthIndex(parts[0]);
    final year = int.tryParse(parts[1]);
    if (monthIdx <= 0 || year == null) return null;

    final firstDay = DateTime(year, monthIdx, 1);
    final mStr = firstDay.month.toString().padLeft(2, '0');
    final dStr = firstDay.day.toString().padLeft(2, '0');
    return '${firstDay.year}-$mStr-$dStr';
  }

  String? get currentMonthDateTo {
    final selected = selectedMonth.value;
    if (selected.isEmpty) return null;
    final parts = selected.split(' ');
    if (parts.length < 2) return null;
    final monthIdx = _getMonthIndex(parts[0]);
    final year = int.tryParse(parts[1]);
    if (monthIdx <= 0 || year == null) return null;

    final lastDay = DateTime(year, monthIdx + 1, 0);
    final mStr = lastDay.month.toString().padLeft(2, '0');
    final dStr = lastDay.day.toString().padLeft(2, '0');
    return '${lastDay.year}-$mStr-$dStr';
  }

  Future<void> fetchReplyLogs({bool showSnackbar = false}) async {
    final fetchToken = ++_currentFetchToken;
    isLoading.value = true;
    isBackgroundLoading.value = false;
    currentPage.value = 1;

    try {
      final dateFrom = currentMonthDateFrom;
      final dateTo = currentMonthDateTo;

      int page = 1;
      const int pageFetchSize = 20;
      bool hasMorePages = true;

      // 1. Fetch halaman pertama dengan parameter date_from dan date_to sesuai spesifikasi OpenAPI
      var firstResponse = await ReviewDao.use.getReviews(
        dateFrom: dateFrom,
        dateTo: dateTo,
        page: page,
        pageSize: pageFetchSize,
      );

      // Fallback: Jika request dengan date_from & date_to spesifik tidak mengembalikan data,
      // coba ambil tanpa filter date_from/date_to agar _filterLogsByMonth di sisi klien dapat menyaring ulasan.
      if ((firstResponse.statusCode != 200 ||
              firstResponse.body == null ||
              firstResponse.body!.items.isEmpty) &&
          (dateFrom != null || dateTo != null)) {
        final fallbackResponse = await ReviewDao.use.getReviews(
          page: page,
          pageSize: pageFetchSize,
        );
        if (fallbackResponse.statusCode == 200 &&
            fallbackResponse.body != null &&
            fallbackResponse.body!.items.isNotEmpty) {
          firstResponse = fallbackResponse;
        }
      }

      if (fetchToken != _currentFetchToken) return;

      final List<BalasLogModel> initialBatch = [];

      if (firstResponse.statusCode == 200 && firstResponse.body != null) {
        final List<dom.ReviewModel> apiReviews = firstResponse.body!.items;
        final meta = firstResponse.body!.meta;

        if (apiReviews.isNotEmpty) {
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
          initialBatch.addAll(mapped);
        }

        // Hentikan pemuatan jika data kosong (totalItems/totalPages <= 0) atau halaman pertama sudah mencakup seluruh data (page >= meta.totalPages)
        if (meta.totalItems <= 0 ||
            meta.totalPages <= 0 ||
            page >= meta.totalPages ||
            apiReviews.isEmpty ||
            initialBatch.length >= meta.totalItems) {
          hasMorePages = false;
        } else {
          page++;
        }
      } else {
        hasMorePages = false;
      }

      // Langsung tampilkan ulasan pertama ke UI!
      replyLogs.assignAll(initialBatch);
      isLoading.value = false;

      // 2. Jika masih ada halaman berikutnya (page < meta.totalPages dan totalItems > loaded), teruskan ambil data di background
      if (hasMorePages) {
        isBackgroundLoading.value = true;
        final existingIds = initialBatch.map((e) => e.id).toSet();

        while (hasMorePages) {
          if (fetchToken != _currentFetchToken) {
            isBackgroundLoading.value = false;
            return;
          }

          final response = await ReviewDao.use.getReviews(
            dateFrom: dateFrom,
            dateTo: dateTo,
            page: page,
            pageSize: pageFetchSize,
          );

          if (fetchToken != _currentFetchToken) {
            isBackgroundLoading.value = false;
            return;
          }

          if (response.statusCode == 200 && response.body != null) {
            final List<dom.ReviewModel> apiReviews = response.body!.items;
            final meta = response.body!.meta;

            if (apiReviews.isNotEmpty) {
              final newMapped = <BalasLogModel>[];
              for (final item in apiReviews) {
                final idStr = item.id.toString();
                if (!existingIds.contains(idStr)) {
                  existingIds.add(idStr);
                  newMapped.add(
                    BalasLogModel(
                      id: idStr,
                      date: _formatDateTime(item.createdAt),
                      reviewerName: item.reviewerName,
                      rating: item.rating.toDouble(),
                      reviewText: item.comment,
                      initialReply: item.replyText,
                      initialStatus: (item.replyText.isNotEmpty)
                          ? 'terkirim'
                          : 'pending',
                    ),
                  );
                }
              }

              if (newMapped.isEmpty) {
                hasMorePages = false;
              } else {
                replyLogs.addAll(newMapped);
              }
            } else {
              hasMorePages = false;
            }

            // Batas pemuatan data: Hentikan secara eksplisit jika page >= meta.totalPages, totalItems <= 0, atau replyLogs mencapai meta.totalItems
            if (meta.totalItems <= 0 ||
                meta.totalPages <= 0 ||
                page >= meta.totalPages ||
                replyLogs.length >= meta.totalItems ||
                apiReviews.length < pageFetchSize) {
              hasMorePages = false;
            } else {
              page++;
            }
          } else {
            hasMorePages = false;
          }
        }

        isBackgroundLoading.value = false;
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
    } catch (e) {
      print('BalasController fetchReplyLogs error: $e');
    } finally {
      if (fetchToken == _currentFetchToken) {
        if (selectedMonth.value.isEmpty) {
          selectedMonth.value = _currentMonthString;
        }
        isLoading.value = false;
        isBackgroundLoading.value = false;
      }
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

  List<String> get availableMonths {
    final monthsSet = <String>{};
    final now = DateTime.now();

    // 1. Generate past 6 months dynamically starting from current date
    for (int i = 0; i < 6; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthName = _getFullMonthNameByMonthIndex(date.month);
      monthsSet.add('$monthName ${date.year}');
    }

    // 2. Add any extra months present in existing replyLogs
    for (final log in replyLogs) {
      final parts = log.date.split(' ');
      if (parts.length >= 3) {
        final logMonthAbbr = parts[1];
        final logYear = parts[2];
        final fullName = _getFullMonthName(logMonthAbbr);
        monthsSet.add('$fullName $logYear');
      }
    }

    final list = monthsSet.toList();
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

    return list;
  }

  String _getFullMonthNameByMonthIndex(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return '';
    }
  }

  String _getFullMonthName(String abbr) {
    switch (abbr.toLowerCase()) {
      case 'jan':
        return 'Januari';
      case 'feb':
        return 'Februari';
      case 'mar':
        return 'Maret';
      case 'apr':
        return 'April';
      case 'mei':
        return 'Mei';
      case 'jun':
        return 'Juni';
      case 'jul':
        return 'Juli';
      case 'ags':
        return 'Agustus';
      case 'sep':
        return 'September';
      case 'okt':
        return 'Oktober';
      case 'nov':
        return 'November';
      case 'des':
        return 'Desember';
      default:
        return abbr;
    }
  }

  int _getMonthIndex(String name) {
    switch (name.toLowerCase()) {
      case 'januari':
      case 'jan':
        return 1;
      case 'februari':
      case 'feb':
        return 2;
      case 'maret':
      case 'mar':
        return 3;
      case 'april':
      case 'apr':
        return 4;
      case 'mei':
      case 'may':
        return 5;
      case 'juni':
      case 'jun':
        return 6;
      case 'juli':
      case 'jul':
        return 7;
      case 'agustus':
      case 'ags':
      case 'agu':
        return 8;
      case 'september':
      case 'sep':
        return 9;
      case 'oktober':
      case 'okt':
        return 10;
      case 'november':
      case 'nov':
        return 11;
      case 'desember':
      case 'des':
        return 12;
      default:
        return 0;
    }
  }

  List<BalasLogModel> get filteredReplyLogs =>
      _filterLogsByMonth(replyLogs, selectedMonth.value);

  // Pagination calculations
  int get totalLogsCount => filteredReplyLogs.length;
  int get totalPages {
    final count = totalLogsCount;
    if (count == 0) return 1;
    return (count / pageSize.value).ceil();
  }

  int get startEntry {
    if (filteredReplyLogs.isEmpty) return 0;
    return (currentPage.value - 1) * pageSize.value + 1;
  }

  int get endEntry {
    final calculated = currentPage.value * pageSize.value;
    return calculated > filteredReplyLogs.length
        ? filteredReplyLogs.length
        : calculated;
  }

  List<BalasLogModel> get paginatedReplyLogs {
    final logs = filteredReplyLogs;
    final start = (currentPage.value - 1) * pageSize.value;
    if (start >= logs.length) return [];
    final end = (start + pageSize.value).clamp(0, logs.length);
    return logs.sublist(start, end);
  }

  void changePage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  List<BalasLogModel> _filterLogsByMonth(
    List<BalasLogModel> logs,
    String selected,
  ) {
    if (selected.isEmpty) {
      return logs;
    }
    return logs.where((log) {
      final parts = log.date.split(' ');
      if (parts.length < 3) return false;
      final logMonthName = parts[1].toLowerCase();
      final logYear = parts[2];

      final monthParts = selected.split(' ');
      if (monthParts.length < 2) return true;
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

  void _showExportProgressDialog(int count, String month) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Get.isDarkMode ? const Color(0xFF1E222B) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sedang Mengekspor Laporan PDF',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Get.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mengolah $count ulasan untuk periode $month...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode
                        ? const Color(0xFF13151A)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sync_rounded, size: 14, color: Color(0xFF6366F1)),
                      SizedBox(width: 6),
                      Text(
                        'Mohon tunggu sebentar, berkas akan otomatis terunduh',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> exportPdfReport() async {
    if (isExporting.value) return;

    if (isLoading.value || isBackgroundLoading.value) {
      Get.snackbar(
        'Proses Memuat Data',
        'Data ulasan sedang dimuat lengkap dari server. Mohon tunggu hingga seluruh data selesai dimuat sebelum mengekspor PDF.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF1E222B)
            : Colors.white.withOpacity(0.95),
        colorText: Get.isDarkMode ? Colors.white : Colors.black,
        icon: const Icon(Icons.hourglass_top_rounded, color: Colors.amber),
        borderWidth: 1,
        borderColor: Get.isDarkMode
            ? const Color(0xFF2E3440)
            : Colors.grey.shade200,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    isExporting.value = true;
    // Yield ke Flutter UI event loop agar indikator loading langsung di-render tanpa macet (ceket)
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // 1. Gunakan data ulasan yang sudah diambil dari memori (tanpa get ulang ke server)
      final items = filteredReplyLogs;
      if (items.isEmpty) {
        Get.snackbar(
          'Export Dibatalkan',
          'Tidak ada data ulasan untuk diekspor pada bulan yang dipilih.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.isDarkMode
              ? const Color(0xFF1E222B)
              : Colors.white.withOpacity(0.95),
          colorText: Get.isDarkMode ? Colors.white : Colors.black,
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
        );
        return;
      }

      // Tampilkan Dialog Progress Interaktif agar Pengguna Tahu Proses Berjalan Aktif
      _showExportProgressDialog(items.length, selectedMonth.value);
      await Future.delayed(const Duration(milliseconds: 150));

      // 2. Load logos asynchronously on main thread
      Uint8List? logoJemberBytes;
      try {
        final ByteData logoData = await rootBundle.load(
          'assets/images/logo_jember.png',
        );
        logoJemberBytes = logoData.buffer.asUint8List(
          logoData.offsetInBytes,
          logoData.lengthInBytes,
        );
      } catch (e) {
        print('Error loading Jember logo for PDF: $e');
      }

      Uint8List? logoSoebandiBytes;
      try {
        final ByteData logoData = await rootBundle.load(
          'assets/images/logo_soebandi.png',
        );
        logoSoebandiBytes = logoData.buffer.asUint8List(
          logoData.offsetInBytes,
          logoData.lengthInBytes,
        );
      } catch (e) {
        print('Error loading Soebandi logo for PDF: $e');
      }

      // 3. Prepare serializable item data
      final preparedItems = items.map((item) {
        return PdfExportItemData(
          date: _cleanPdfText(item.date),
          reviewerName: _cleanPdfText(item.reviewerName),
          rating: '${item.rating.toInt()} / 5',
          reviewText: item.reviewText.isEmpty
              ? '-'
              : _cleanPdfText(item.reviewText),
          adminReply: item.adminReply.value.isEmpty
              ? 'Belum ditanggapi'
              : _cleanPdfText(item.adminReply.value),
          status: _cleanPdfText(item.status.value.toUpperCase()),
        );
      }).toList();

      final taskParams = PdfExportTaskParams(
        items: preparedItems,
        selectedMonth: selectedMonth.value,
        logoJemberBytes: logoJemberBytes,
        logoSoebandiBytes: logoSoebandiBytes,
      );

      // Yield UI event loop agar dialog progress dapat di-paint sebelum proses berat
      await Future.delayed(const Duration(milliseconds: 100));

      // 4. Generate PDF bytes secara langsung (aman untuk Web dan Desktop)
      final Uint8List pdfBytes = await _generatePdfBytesInIsolate(taskParams);

      final fileName =
          'Laporan_Log_Balasan_${selectedMonth.value.replaceAll(' ', '_')}.pdf';
      await saveAndDownloadFile(pdfBytes, fileName);

      // Tutup dialog progress
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Export Berhasil',
        'Laporan log balasan berhasil disimpan ke folder Downloads:\n$fileName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF1E222B)
            : Colors.white.withOpacity(0.95),
        colorText: Get.isDarkMode ? Colors.white : Colors.black,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
        borderWidth: 1,
        borderColor: Get.isDarkMode
            ? const Color(0xFF2E3440)
            : Colors.grey.shade200,
        duration: const Duration(seconds: 5),
      );
    } catch (e, stack) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      print('Export PDF Error: $e\n$stack');
      Get.snackbar(
        'Export Gagal',
        'Terjadi kesalahan saat menyimpan PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 6),
      );
    } finally {
      isExporting.value = false;
    }
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

  String _cleanPdfText(String input) {
    if (input.isEmpty) return input;
    String text = input
        .replaceAll('📞', '')
        .replaceAll('✉️', '')
        .replaceAll('✉', '')
        .replaceAll('📍', '')
        .replaceAll('★', ' Bintang')
        .replaceAll('⭐', ' Bintang')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('‘', "'")
        .replaceAll('’', "'")
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('…', '...')
        .replaceAll('•', '-')
        .replaceAll('\u00A0', ' ');

    final StringBuffer buffer = StringBuffer();
    for (final char in text.runes) {
      if ((char >= 32 && char <= 126) || char == 10 || char == 13) {
        buffer.writeCharCode(char);
      } else if (char >= 160 && char <= 255) {
        buffer.writeCharCode(char);
      }
    }
    final result = buffer.toString().trim();
    return result.isEmpty ? '-' : result;
  }
}

class PdfExportItemData {
  final String date;
  final String reviewerName;
  final String rating;
  final String reviewText;
  final String adminReply;
  final String status;

  PdfExportItemData({
    required this.date,
    required this.reviewerName,
    required this.rating,
    required this.reviewText,
    required this.adminReply,
    required this.status,
  });
}

class PdfExportTaskParams {
  final List<PdfExportItemData> items;
  final String selectedMonth;
  final Uint8List? logoJemberBytes;
  final Uint8List? logoSoebandiBytes;

  PdfExportTaskParams({
    required this.items,
    required this.selectedMonth,
    this.logoJemberBytes,
    this.logoSoebandiBytes,
  });
}

Future<Uint8List> _generatePdfBytesInIsolate(PdfExportTaskParams params) async {
  final pdf = pw.Document();

  pw.Widget logoJemberWidget;
  if (params.logoJemberBytes != null && params.logoJemberBytes!.isNotEmpty) {
    final pw.MemoryImage logoImage = pw.MemoryImage(params.logoJemberBytes!);
    logoJemberWidget = pw.Image(
      logoImage,
      width: 45,
      height: 55,
      fit: pw.BoxFit.contain,
    );
  } else {
    logoJemberWidget = pw.SizedBox(width: 45, height: 55);
  }

  pw.Widget logoSoebandiWidget;
  if (params.logoSoebandiBytes != null && params.logoSoebandiBytes!.isNotEmpty) {
    final pw.MemoryImage logoImage = pw.MemoryImage(params.logoSoebandiBytes!);
    logoSoebandiWidget = pw.Image(
      logoImage,
      width: 45,
      height: 55,
      fit: pw.BoxFit.contain,
    );
  } else {
    logoSoebandiWidget = pw.SizedBox(width: 45, height: 55);
  }

  final primaryColor = PdfColor.fromHex('#6366F1');
  final darkColor = PdfColor.fromHex('#1E222B');
  final greyColor = PdfColor.fromHex('#9CA3AF');

  final items = params.items;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      maxPages: 200,
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Text(
          'Halaman ${context.pageNumber} dari ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        ),
      ),
      build: (context) => [
        // 1. Kop Surat (Official Indonesian Letterhead replica)
        pw.Column(
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                logoJemberWidget,
                pw.SizedBox(width: 14),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        'PEMERINTAH KABUPATEN JEMBER',
                        style: pw.TextStyle(
                          fontSize: 11.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'DINAS KESEHATAN, PENGENDALIAN PENDUDUK',
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'DAN KELUARGA BERENCANA',
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'RUMAH SAKIT DAERAH dr.SOEBANDI',
                        style: pw.TextStyle(
                          fontSize: 13.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'Jl. dr.Soebandi 124 telp. 0331-487441-422404 pswt 138 Fax. 487564',
                        style: const pw.TextStyle(
                          fontSize: 7.5,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'JEMBER 68111',
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 14),
                logoSoebandiWidget,
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Container(height: 2.2, color: PdfColors.black),
          ],
        ),
        pw.SizedBox(height: 16),

        // 2. Document Title
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                'LAPORAN AUDIT LOG BALASAN',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: darkColor,
                ),
              ),
              pw.Text(
                'Google Maps Review - Periode ${params.selectedMonth}',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: greyColor,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),

        // 3. Stats Summary Cards Row
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TOTAL ULASAN',
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${items.length} Review',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: darkColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#E6F4EA'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TERKIRIM',
                      style: pw.TextStyle(
                        fontSize: 7,
                        color: PdfColor.fromHex('#137333'),
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${items.where((i) => i.status == 'TERKIRIM').length} Dibalas',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#137333'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#FCE8E6'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PENDING',
                      style: pw.TextStyle(
                        fontSize: 7,
                        color: PdfColor.fromHex('#C5221F'),
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${items.where((i) => i.status != 'TERKIRIM').length} Ulasan',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#C5221F'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 16),

        // 4. Table of logs
        pw.TableHelper.fromTextArray(
          headers: [
            'Tanggal',
            'User Pengguna',
            'Rating',
            'Ulasan Pengguna',
            'Balasan Admin',
            'Status',
          ],
          data: List<List<String>>.generate(items.length, (index) {
            final item = items[index];
            final cleanRev = item.reviewText;
            final cleanReply = item.adminReply;
            return [
              item.date,
              item.reviewerName,
              item.rating,
              cleanRev.length > 250
                  ? '${cleanRev.substring(0, 250)}...'
                  : cleanRev,
              cleanReply.length > 300
                  ? '${cleanReply.substring(0, 300)}...'
                  : cleanReply,
              item.status,
            ];
          }),
          columnWidths: {
            0: const pw.FixedColumnWidth(60), // Tanggal
            1: const pw.FixedColumnWidth(80), // User Pengguna
            2: const pw.FixedColumnWidth(48), // Rating
            3: const pw.FlexColumnWidth(2.5), // Ulasan Pengguna
            4: const pw.FlexColumnWidth(3.5), // Balasan Admin
            5: const pw.FixedColumnWidth(55), // Status
          },
          headerStyle: pw.TextStyle(
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
            fontSize: 8.5,
          ),
          headerDecoration: pw.BoxDecoration(color: primaryColor),
          cellStyle: const pw.TextStyle(fontSize: 7.5),
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 8,
          ),
          cellAlignment: pw.Alignment.topLeft,
          cellAlignments: {
            0: pw.Alignment.topLeft,
            1: pw.Alignment.topLeft,
            2: pw.Alignment.topCenter,
            3: pw.Alignment.topLeft,
            4: pw.Alignment.topLeft,
            5: pw.Alignment.topCenter,
          },
          border: pw.TableBorder(
            horizontalInside: const pw.BorderSide(
              color: PdfColors.grey200,
              width: 0.5,
            ),
            verticalInside: pw.BorderSide.none,
            bottom: const pw.BorderSide(
              color: PdfColors.grey300,
              width: 0.5,
            ),
            top: pw.BorderSide.none,
            left: pw.BorderSide.none,
            right: pw.BorderSide.none,
          ),
        ),
      ],
    ),
  );

  return pdf.save();
}
