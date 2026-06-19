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
  final pageSize =
      5.obs; // Showing 5 items per page for better pagination demonstration

  final isLoading = false.obs;

  // Stats State
  final stats = Rxn<dom.ReviewStatsModel>();

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
    fetchStats();

    // Auto re-fetch when filters change
    ever(selectedStatus, (_) {
      fetchReviews();
      fetchStats();
    });
    ever(selectedTimeRange, (_) {
      fetchReviews();
      fetchStats();
    });
    ever(selectedRating, (_) {
      fetchReviews();
      fetchStats();
    });
  }

  Future<void> fetchStats() async {
    try {
      final response = await ReviewDao.getStats();
      if (response.statusCode == 200 && response.body != null) {
        stats.value = response.body;
      }
    } catch (e) {
      print('ReviewController fetchStats error: $e');
    }
  }

  Future<void> fetchReviews() async {
    isLoading.value = true;
    try {
      // 1. Map status: 'Pending' -> 'pending', 'Replied' -> 'replied', 'All' -> null
      String? apiStatus;
      if (selectedStatus.value == 'Pending') {
        apiStatus = 'pending';
      } else if (selectedStatus.value == 'Replied') {
        apiStatus = 'replied';
      }

      // 2. Map timeRange: 'Last 7 Days' -> '7_days', 'Last 30 Days' -> '30_days', 'All Time' -> 'all_time'
      String? apiTimeRange;
      if (selectedTimeRange.value == 'Last 7 Days') {
        apiTimeRange = '7_days';
      } else if (selectedTimeRange.value == 'Last 30 Days') {
        apiTimeRange = '30_days';
      } else if (selectedTimeRange.value == 'All Time') {
        apiTimeRange = 'all_time';
      }

      // 3. Map rating: '5 Stars' -> 5, etc., 'All Ratings' -> null
      int? apiRating;
      if (selectedRating.value != 'All Ratings') {
        final stars = selectedRating.value.split(' ').first;
        apiRating = int.tryParse(stars);
      }

      final response = await ReviewDao.getReviews(
        status: apiStatus,
        timeRange: apiTimeRange,
        rating: apiRating,
      );

      if (response.statusCode == 200 && response.body != null) {
        final List<dom.ReviewModel> apiReviews = response.body!;
        final mappedReviews = apiReviews.map((item) {
          return ReviewModel(
            id: item.id.toString(),
            reviewerName: item.reviewerName,
            reviewerAvatar:
                'https://api.dicebear.com/7.x/pixel-art/png?seed=${item.reviewerName}',
            rating: item.rating.toDouble(),
            comment: item.comment,
            date: _formatDateTime(item.createdAt),
            locationName: 'Poliklinik Spesialis',
            sentiment: item.sentiment.toLowerCase(),
            tags: item.keywords.map((k) => '#$k').toList(),
            initialReply: item.replyText,
          );
        }).toList();
        reviews.assignAll(mappedReviews);
        print(
          'ReviewController fetchReviews: reviews.length = ${reviews.length}',
        );
      }
    } catch (e) {
      print('ReviewController fetchReviews error: $e');
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
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  // Filtered reviews list is returned directly from the API result
  List<ReviewModel> get filteredReviews => reviews;

  // Slice list for pagination
  List<ReviewModel> get paginatedReviews {
    final filtered = filteredReviews;
    final start = (currentPage.value - 1) * pageSize.value;
    if (start >= filtered.length) {
      return [];
    }
    final end = start + pageSize.value;
    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
  }

  // Pagination calculations
  int get totalReviewsCount => filteredReviews.length;
  int get totalPages => (filteredReviews.length / pageSize.value).ceil();
  int get startEntry => filteredReviews.isEmpty
      ? 0
      : (currentPage.value - 1) * pageSize.value + 1;
  int get endEntry {
    final calculated = currentPage.value * pageSize.value;
    return calculated > filteredReviews.length
        ? filteredReviews.length
        : calculated;
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
    if (stats.value != null) {
      return stats.value!.positiveVibesPercentage;
    }
    if (reviews.isEmpty) return 0.0;
    final pos = reviews
        .where((r) => r.sentiment.toLowerCase() == 'positive')
        .length;
    return double.parse(((pos / reviews.length) * 100).toStringAsFixed(1));
  }

  int get pendingReviewsCount {
    return reviews.where((r) => r.replyText.value.isEmpty).length;
  }

  String get avgResponseTime {
    if (stats.value != null) {
      return '${stats.value!.responseRatePercentage}%';
    }
    return '2.4 hrs';
  }

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
