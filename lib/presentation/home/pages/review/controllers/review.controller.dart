part of '../../main.pages.dart';

class ReviewController extends GetxController {
  // Reactive list of reviews
  final reviews = <ReviewModel>[].obs;

  // Active Filters
  final selectedStatus = 'All'.obs; // 'All', 'Pending', 'Replied'
  final selectedTimeRange = 'Last 30 Days'.obs;
  final selectedRating = 'All Ratings'.obs;

  // Pagination State
  final currentPage = 1.obs;
  final pageSize = 5.obs; // Showing 5 items per page for better pagination demonstration

  @override
  void onInit() {
    super.onInit();
    _loadMockReviews();
  }

  void _loadMockReviews() {
    reviews.assignAll([
      ReviewModel(
        id: '8821',
        reviewerName: 'Agus Santoso',
        reviewerAvatar: 'https://api.dicebear.com/7.x/pixel-art/png?seed=Agus',
        rating: 5.0,
        comment: 'Pelayanan dokter sangat ramah dan penjelasannya sangat mudah dipahami. Terima kasih RSUD Soebandi!',
        date: 'Oct 24, 2023',
        locationName: 'Poliklinik Spesialis',
        sentiment: 'positive',
        tags: ['#dokterRamah', '#clearExplanation'],
        initialReply: 'Terima kasih atas ulasan positifnya, Bapak Agus. Kami akan selalu berusaha memberikan pelayanan medis terbaik.',
      ),
      ReviewModel(
        id: '9024',
        reviewerName: 'Lina Wijaya',
        reviewerAvatar: 'https://api.dicebear.com/7.x/pixel-art/png?seed=Lina',
        rating: 3.0,
        comment: 'Antrian pendaftaran sangat panjang dan panas. Mohon perbaikan sistem AC di ruang tunggu.',
        date: 'Oct 23, 2023',
        locationName: 'Kasir & Pendaftaran',
        sentiment: 'neutral',
        tags: ['#antreanLama', '#ACPanas'],
      ),
      ReviewModel(
        id: '8755',
        reviewerName: 'Budi Kusuma',
        reviewerAvatar: 'https://api.dicebear.com/7.x/pixel-art/png?seed=Budi',
        rating: 4.0,
        comment: 'Fasilitas parkir sudah jauh lebih baik dari sebelumnya. Tapi antrian apotek masih bisa ditingkatkan lagi.',
        date: 'Oct 22, 2023',
        locationName: 'Parkiran & Kantin',
        sentiment: 'positive',
        tags: ['#parkirLuas', '#apotekAntre'],
        initialReply: 'Terima kasih atas masukannya, Bapak Budi. Kami sedang merancang sistem digitalisasi antrean apotek.',
      ),
      ReviewModel(
        id: '9112',
        reviewerName: 'Rina Melati',
        reviewerAvatar: 'https://api.dicebear.com/7.x/pixel-art/png?seed=Rina',
        rating: 5.0,
        comment: 'Perawat di bangsal Melati sangat sigap dan ramah membantu ibu saya selama dirawat inap. Top!',
        date: 'Oct 22, 2023',
        locationName: 'Rawat Inap Dahlia',
        sentiment: 'positive',
        tags: ['#perawatSigap', '#dahliaWard'],
      ),
      ReviewModel(
        id: '9211',
        reviewerName: 'Doni Setiawan',
        reviewerAvatar: 'https://api.dicebear.com/7.x/pixel-art/png?seed=Doni',
        rating: 2.0,
        comment: 'Menebus obat BPJS lama sekali, harus menunggu sampai sore. Pelayanan petugas apotek ketus.',
        date: 'Oct 20, 2023',
        locationName: 'Farmasi / Apotek',
        sentiment: 'negative',
        tags: ['#slowBPJS', '#petugasKetus'],
      ),
      ReviewModel(
        id: '9301',
        reviewerName: 'Eka Putri',
        reviewerAvatar: 'https://api.dicebear.com/7.x/pixel-art/png?seed=Eka',
        rating: 5.0,
        comment: 'IGD sangat cepat menangani luka kecelakaan saya kemarin. Suster ramah dan tanggap.',
        date: 'Oct 19, 2023',
        locationName: 'IGD (Instalasi Gawat Darurat)',
        sentiment: 'positive',
        tags: ['#IGDGercep', '#susterRamah'],
        initialReply: 'Terima kasih atas apresiasinya, Kak Eka. Kami senang bisa membantu penanganan darurat dengan sigap.',
      ),
      ReviewModel(
        id: '9482',
        reviewerName: 'Farhan Maulana',
        reviewerAvatar: 'https://api.dicebear.com/7.x/pixel-art/png?seed=Farhan',
        rating: 4.0,
        comment: 'Dokter poliklinik gigi sangat teliti, kamarnya bersih. Pendaftarannya saja yang antri.',
        date: 'Oct 15, 2023',
        locationName: 'Poliklinik Spesialis',
        sentiment: 'positive',
        tags: ['#dokterGigi', '#poliBersih'],
      ),
      ReviewModel(
        id: '9512',
        reviewerName: 'Gita Lestari',
        reviewerAvatar: 'https://api.dicebear.com/7.x/pixel-art/png?seed=Gita',
        rating: 1.0,
        comment: 'Sangat kecewa dengan layanan kasir yang lamban. Uang kembalian kurang dan tidak ada maaf.',
        date: 'Oct 10, 2023',
        locationName: 'Kasir & Pendaftaran',
        sentiment: 'negative',
        tags: ['#kasirLamban', '#kembalianKurang'],
      ),
    ]);
  }

  // Filtered reviews list based on status, rating, time range
  List<ReviewModel> get filteredReviews {
    return reviews.where((review) {
      // 1. Status Filter
      if (selectedStatus.value == 'Pending' && review.replyText.value.isNotEmpty) {
        return false;
      }
      if (selectedStatus.value == 'Replied' && review.replyText.value.isEmpty) {
        return false;
      }

      // 2. Rating Filter
      if (selectedRating.value != 'All Ratings') {
        final starsCount = int.tryParse(selectedRating.value.split(' ').first) ?? 5;
        if (review.rating.toInt() != starsCount) {
          return false;
        }
      }

      // 3. Time Filter (simple mock mapping for demonstration)
      if (selectedTimeRange.value == 'Last 7 Days') {
        final day = int.tryParse(review.date.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        // Mock filter: show only dates >= 20
        if (day < 20) return false;
      }

      return true;
    }).toList();
  }

  // Slice list for pagination
  List<ReviewModel> get paginatedReviews {
    final filtered = filteredReviews;
    final start = (currentPage.value - 1) * pageSize.value;
    if (start >= filtered.length) {
      return [];
    }
    final end = start + pageSize.value;
    return filtered.sublist(start, end > filtered.length ? filtered.length : end);
  }

  // Pagination calculations
  int get totalReviewsCount => filteredReviews.length;
  int get totalPages => (filteredReviews.length / pageSize.value).ceil();
  int get startEntry => filteredReviews.isEmpty ? 0 : (currentPage.value - 1) * pageSize.value + 1;
  int get endEntry {
    final calculated = currentPage.value * pageSize.value;
    return calculated > filteredReviews.length ? filteredReviews.length : calculated;
  }

  // Actions
  void changePage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void filterStatus(String status) {
    selectedStatus.value = status;
    currentPage.value = 1; // Reset to page 1 on filter
  }

  void filterTimeRange(String range) {
    selectedTimeRange.value = range;
    currentPage.value = 1;
  }

  void filterRating(String rating) {
    selectedRating.value = rating;
    currentPage.value = 1;
  }

  // Bottom stats calculations
  double get positiveVibeRate {
    if (reviews.isEmpty) return 0.0;
    final pos = reviews.where((r) => r.sentiment == 'positive').length;
    return double.parse(((pos / reviews.length) * 100).toStringAsFixed(1));
  }

  int get pendingReviewsCount {
    return reviews.where((r) => r.replyText.value.isEmpty).length;
  }

  String get avgResponseTime => '2.4 hrs';

  void submitQuickReply(String reviewId, String reply) {
    final idx = reviews.indexWhere((r) => r.id == reviewId);
    if (idx != -1) {
      reviews[idx].replyText.value = reply;
      reviews.refresh();
    }
  }

  void deleteReply(String reviewId) {
    final idx = reviews.indexWhere((r) => r.id == reviewId);
    if (idx != -1) {
      reviews[idx].replyText.value = '';
      reviews.refresh();
    }
  }
}
