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
  final selectedMonth = 'Oktober 2023'.obs;
  final isExporting = false.obs;
  final isLoading = false.obs;

  // Reactive list of reply logs
  final replyLogs = <BalasLogModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchReplyLogs();
  }

  Future<void> fetchReplyLogs() async {
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
        date: '24 Okt 2023',
        reviewerName: 'Ahmad Subagyo',
        rating: 5.0,
        reviewText: 'Pelayanan poli jantung sangat memuaskan, dokter ramah.',
        initialReply:
            'Terima kasih atas apresiasinya, Ahmad. Kami akan terus meningkatkan layanan.',
        initialStatus: 'terkirim',
      ),
      BalasLogModel(
        id: '2',
        date: '23 Okt 2023',
        reviewerName: 'Siti Aminah',
        rating: 2.0,
        reviewText: 'Antrian farmasi terlalu panjang, mohon diperbaiki.',
        initialReply:
            'Mohon maaf atas ketidaknyamanannya. Kami sedang mengevaluasi sistem antrian.',
        initialStatus: 'pending',
      ),
      BalasLogModel(
        id: '3',
        date: '22 Okt 2023',
        reviewerName: 'Budi Santoso',
        rating: 4.0,
        reviewText: 'Dokternya ramah sekali, terima kasih.',
        initialReply:
            'Sama-sama Bapak Budi, senang bisa membantu proses pemulihan Anda.',
        initialStatus: 'terkirim',
      ),
      BalasLogModel(
        id: '4',
        date: '20 Okt 2023',
        reviewerName: 'Dewi Lestari',
        rating: 5.0,
        reviewText: 'Sangat puas dengan penanganan cepat di IGD RSUD Soebandi.',
        initialReply:
            'Terima kasih Ibu Dewi, keselamatan pasien adalah prioritas utama kami.',
        initialStatus: 'terkirim',
      ),
      BalasLogModel(
        id: '5',
        date: '18 Okt 2023',
        reviewerName: 'Joko Widodo',
        rating: 3.0,
        reviewText:
            'Fasilitas parkir cukup luas tapi petunjuk jalurnya kurang jelas.',
        initialReply: '',
        initialStatus: 'pending',
      ),
      BalasLogModel(
        id: '6',
        date: '15 Okt 2023',
        reviewerName: 'Mega Puspita',
        rating: 1.0,
        reviewText:
            'Jadwal dokter tidak sesuai jam praktek yang tertera di website.',
        initialReply: '',
        initialStatus: 'pending',
      ),
    ]);
  }

  Future<void> exportPdfReport() async {
    if (isExporting.value) return;

    isExporting.value = true;

    // Simulate generation delay
    await Future.delayed(const Duration(milliseconds: 1500));

    isExporting.value = false;

    Get.snackbar(
      'Export Berhasil',
      'Laporan log balasan untuk bulan ${selectedMonth.value} berhasil diunduh sebagai PDF.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.isDarkMode
          ? const Color(0xFF1E222B)
          : Colors.white.withOpacity(0.95),
      colorText: Get.isDarkMode ? Colors.white : Colors.black,
      borderWidth: 1,
      borderColor: Get.isDarkMode
          ? const Color(0xFF2E3440)
          : Colors.grey.shade200,
      duration: const Duration(seconds: 3),
    );
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
