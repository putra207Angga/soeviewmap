part of '../../main.pages.dart';

class ReviewController extends GetxController {
  // Reactive list of reviews
  final reviews = <ReviewUiModel>[].obs;

  // Active Filters
  final selectedStatus = 'All'.obs; // 'All', 'Pending', 'Replied'
  final selectedTimeRange = 'Last 30 Days'.obs;
  final selectedRating = 'All Ratings'.obs;

  // Pagination State
  final currentPage = 1.obs;
  final pageSize =
      20.obs; // Showing 5 items per page for better pagination demonstration

  final isLoading = true.obs;

  // Stats State
  final stats = Rxn<dom.ReviewStatsModel>();

  // Pagination Meta State
  final meta = Rxn<dom.MetaModel>();

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
    ever(currentPage, (_) {
      fetchReviews();
    });
  }

  Future<void> fetchStats() async {
    try {
      final response = await ReviewDao.use.getStats();
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

      // 2. Map timeRange: 'Last 7 Days' -> '7_days', 'Last 30 Days' -> '30_days', 'All Time' -> null (omitted to fetch all-time)
      String? apiTimeRange;
      if (selectedTimeRange.value == 'Last 7 Days') {
        apiTimeRange = '7_days';
      } else if (selectedTimeRange.value == 'Last 30 Days') {
        apiTimeRange = '30_days';
      } else if (selectedTimeRange.value == 'All Time') {
        apiTimeRange = null;
      }

      // 3. Map rating: '5 Stars' -> 5, etc., 'All Ratings' -> null
      int? apiRating;
      if (selectedRating.value != 'All Ratings') {
        final stars = selectedRating.value.split(' ').first;
        apiRating = int.tryParse(stars);
      }

      final response = await ReviewDao.use.getReviews(
        status: apiStatus,
        timeRange: apiTimeRange,
        rating: apiRating,
        page: currentPage.value,
        pageSize: pageSize.value,
      );

      if (response.statusCode == 200 && response.body != null) {
        meta.value = response.body!.meta;
        if (meta.value != null) {
          if (meta.value!.totalPages > 0 &&
              currentPage.value > meta.value!.totalPages) {
            currentPage.value = meta.value!.totalPages;
          } else if (meta.value!.totalPages == 0) {
            currentPage.value = 1;
          }
        }
        final List<dom.ReviewModel> apiReviews = response.body!.items;
        final mappedReviews = apiReviews.map((item) {
          return ReviewUiModel.formReviewModel(
            data: item,
            selectedLocation: 'RSUD dr. Soebandi',
          );
        }).toList();
        reviews.assignAll(mappedReviews);
        print(
          'ReviewController fetchReviews: reviews.length = ${reviews.length}, total = ${meta.value?.totalItems}',
        );
      }
    } catch (e) {
      print('ReviewController fetchReviews error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Filtered reviews list is returned directly from the API result
  List<ReviewUiModel> get filteredReviews => reviews;

  // Since server handles pagination, the list returned contains only current page reviews.
  List<ReviewUiModel> get paginatedReviews => filteredReviews;

  // Pagination calculations using server metadata
  int get totalReviewsCount => meta.value?.totalItems ?? filteredReviews.length;
  int get totalPages => meta.value?.totalPages ?? 1;

  int get startEntry {
    if (meta.value != null) {
      final m = meta.value!;
      return m.totalItems == 0 ? 0 : (m.currentPage - 1) * m.pageSize + 1;
    }
    return filteredReviews.isEmpty
        ? 0
        : (currentPage.value - 1) * pageSize.value + 1;
  }

  int get endEntry {
    if (meta.value != null) {
      final m = meta.value!;
      final calculated = m.currentPage * m.pageSize;
      return calculated > m.totalItems ? m.totalItems : calculated;
    }
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
    if (stats.value != null) return stats.value!.pendingCount;
    return reviews.where((r) => r.replyText.value.isEmpty).length;
  }

  String get avgResponseTime {
    if (stats.value != null) {
      return '${stats.value!.avgResponseHours} ${"hours_short".tr}';
    }
    return '2.4 ${"hours_short".tr}';
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
