part of '../../main.pages.dart';

class ReviewModel {
  final String id;
  final String reviewerName;
  final String reviewerAvatar;
  final double rating;
  final String comment;
  final String date;
  final String locationName;
  final String sentiment; // 'positive' | 'neutral' | 'negative'
  final List<String> tags;
  var replyText = ''.obs;

  ReviewModel({
    required this.id,
    required this.reviewerName,
    required this.reviewerAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    required this.locationName,
    required this.sentiment,
    required this.tags,
    String initialReply = '',
  }) {
    replyText.value = initialReply;
  }
}

class MapLocationModel {
  final String name;
  final double dx; // relative X coordinate (0.0 to 1.0)
  final double dy; // relative Y coordinate (0.0 to 1.0)
  final String dominantSentiment;
  final int reviewCount;

  const MapLocationModel({
    required this.name,
    required this.dx,
    required this.dy,
    required this.dominantSentiment,
    required this.reviewCount,
  });
}

class DahsboardController extends GetxController {
  // Mock reviews for Google Maps (RS Soebandi Context)
  final reviews = <ReviewModel>[].obs;

  // Selected filters
  final selectedLocation = RxnString();
  final selectedSentiment =
      'All'.obs; // 'All', 'Positive', 'Neutral', 'Negative'
  final selectedRating = RxnInt();

  // AI Reply generator state
  final isGeneratingReply = false.obs;
  final generatedReply = ''.obs;

  // Locations coordinates map (aligned with actual buildings on the geographical static map of RSUD dr. Soebandi)
  final locations = <MapLocationModel>[
    const MapLocationModel(
      name: 'IGD (Instalasi Gawat Darurat)',
      dx: 0.53,
      dy: 0.46,
      dominantSentiment: 'positive',
      reviewCount: 24,
    ),
    const MapLocationModel(
      name: 'Farmasi / Apotek',
      dx: 0.56,
      dy: 0.54,
      dominantSentiment: 'negative',
      reviewCount: 42,
    ),
    const MapLocationModel(
      name: 'Poliklinik Spesialis',
      dx: 0.59,
      dy: 0.58,
      dominantSentiment: 'positive',
      reviewCount: 35,
    ),
    const MapLocationModel(
      name: 'Rawat Inap Dahlia',
      dx: 0.55,
      dy: 0.66,
      dominantSentiment: 'positive',
      reviewCount: 18,
    ),
    const MapLocationModel(
      name: 'Parkiran & Kantin',
      dx: 0.48,
      dy: 0.72,
      dominantSentiment: 'neutral',
      reviewCount: 15,
    ),
    const MapLocationModel(
      name: 'Kasir & Pendaftaran',
      dx: 0.54,
      dy: 0.50,
      dominantSentiment: 'negative',
      reviewCount: 29,
    ),
  ];

  final isLoading = false.obs;
  final stats = Rxn<ReviewStatsModel>();
  final sentimentAnalysis = Rxn<dom.SentimentAnalysisModel>();

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
    fetchStats();
    fetchSentimentAnalysis();

    // Auto re-fetch when filters change
    ever(selectedSentiment, (_) {
      fetchReviews();
      fetchStats();
      fetchSentimentAnalysis();
    });
    ever(selectedRating, (_) {
      fetchReviews();
      fetchStats();
      fetchSentimentAnalysis();
    });
    ever(selectedLocation, (_) {
      fetchReviews();
      fetchStats();
      fetchSentimentAnalysis();
    });
  }

  Future<void> fetchStats() async {
    try {
      final response = await ReviewDao.use.getStats();
      if (response.statusCode == 200 && response.body != null) {
        stats.value = response.body;
      }
    } catch (e) {
      print('DahsboardController fetchStats error: $e');
    }
  }

  Future<void> fetchSentimentAnalysis() async {
    try {
      final response = await ReviewDao.use.getSentimentAnalysis();
      if (response.statusCode == 200 && response.body != null) {
        sentimentAnalysis.value = response.body;
      }
    } catch (e) {
      print('DahsboardController fetchSentimentAnalysis error: $e');
    }
  }

  Future<void> fetchReviews() async {
    isLoading.value = true;
    try {
      String? apiSentiment;
      if (selectedSentiment.value != 'All') {
        apiSentiment = selectedSentiment.value.toUpperCase();
      }

      final response = await ReviewDao.use.getReviews(
        limit: 5,
        timeRange: '7_days',
        sentiment: apiSentiment,
        rating: selectedRating.value?.toInt(),
      );

      print(
        'DahsboardController fetchReviews: reviews.length = ${response.statusCode}\n${response.request?.url}',
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
            locationName: selectedLocation.value ?? 'Poliklinik Spesialis',
            sentiment: item.sentiment.toLowerCase(),
            tags: item.keywords.map((k) => '#$k').toList(),
            initialReply: item.replyText,
          );
        }).toList();
        reviews.assignAll(mappedReviews);
      }
    } catch (e) {
      print('DahsboardController fetchReviews error: $e');
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

  // Filtered reviews list
  List<ReviewModel> get filteredReviews {
    return reviews.where((review) {
      // Location Filter
      if (selectedLocation.value != null &&
          review.locationName != selectedLocation.value) {
        return false;
      }
      // Sentiment Filter
      if (selectedSentiment.value != 'All') {
        final sentimentLower = review.sentiment.toLowerCase();
        if (selectedSentiment.value == 'Positive' &&
            sentimentLower != 'positive')
          return false;
        if (selectedSentiment.value == 'Neutral' && sentimentLower != 'neutral')
          return false;
        if (selectedSentiment.value == 'Negative' &&
            sentimentLower != 'negative')
          return false;
      }
      // Rating Filter
      if (selectedRating.value != null &&
          review.rating != selectedRating.value) {
        return false;
      }
      return true;
    }).toList();
  }

  // Statistics Computations
  double get averageRating {
    if (stats.value != null) return stats.value!.ratingAverage;
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return double.parse((total / reviews.length).toStringAsFixed(1));
  }

  int get totalReviewsCount => stats.value?.totalReviews ?? reviews.length;

  double get positivePercentage {
    if (sentimentAnalysis.value != null)
      return sentimentAnalysis.value!.overallPositivePercentage;
    if (stats.value != null) return stats.value!.positiveVibesPercentage;
    if (reviews.isEmpty) return 0.0;
    final posCount = reviews.where((r) => r.sentiment == 'positive').length;
    return double.parse(((posCount / reviews.length) * 100).toStringAsFixed(0));
  }

  double get responseRate {
    if (stats.value != null) return stats.value!.responseRatePercentage;
    if (reviews.isEmpty) return 0.0;
    final answered = reviews.where((r) => r.replyText.value.isNotEmpty).length;
    return double.parse(((answered / reviews.length) * 100).toStringAsFixed(0));
  }

  // Toggle or Set Filters
  void filterByLocation(String? locName) {
    if (selectedLocation.value == locName) {
      selectedLocation.value = null; // Toggle off
    } else {
      selectedLocation.value = locName;
    }
  }

  void filterBySentiment(String sentiment) {
    selectedSentiment.value = sentiment;
  }

  void filterByRating(double? rating) {
    if (selectedRating.value == rating) {
      selectedRating.value = null; // Toggle off
    } else {
      selectedRating.value = (rating ?? 0.0).toInt();
    }
  }

  void resetFilters() {
    selectedLocation.value = null;
    selectedSentiment.value = 'All';
    selectedRating.value = null;
  }

  // AI Reply Simulation
  Future<void> generateAiReply(ReviewModel review, String tone) async {
    isGeneratingReply.value = true;
    generatedReply.value = '';

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final name = review.reviewerName.split(' ').first;

    if (tone == 'Gen Z Slang') {
      if (review.sentiment == 'positive') {
        generatedReply.value =
            'Aura +9999 buat Kak $name! 🚀 Thank you udh spil review kece ini, no cap pelayanan gercep emang prioritas kita. Stay healthy and keep vibing! 🔥✨';
      } else if (review.sentiment == 'negative') {
        generatedReply.value =
            'Waduh, bad vibe bgt ya Kak $name. Mimin minta maaf bgt, ini bener-bener L service. Kita bakal lakuin vibe check menyeluruh ke unit ${review.locationName} biar langsung digas perbaikan. Makasih kritiknya, real no clickbait! 🙏😭';
      } else {
        generatedReply.value =
            'Vibe check aman, makasih masukkannya Kak $name! Layanan di ${review.locationName} bakal kita poles lagi biar makin naik kasta. Senggol dong! ⚡';
      }
    } else if (tone == 'Professional') {
      if (review.sentiment == 'positive') {
        generatedReply.value =
            'Yth. Kakak $name, terima kasih atas ulasan positif dan kepercayaan Anda pada layanan RS Soebandi khususnya di ${review.locationName}. Kami senantiasa berkomitmen menjaga kualitas pelayanan terbaik.';
      } else if (review.sentiment == 'negative') {
        generatedReply.value =
            'Yth. Bapak/Ibu $name, kami menyampaikan permohonan maaf mendalam terkait pengalaman kurang memuaskan Anda di area ${review.locationName}. Masukan Anda mengenai kendala tersebut telah kami koordinasikan dengan tim manajemen untuk evaluasi dan perbaikan segera.';
      } else {
        generatedReply.value =
            'Yth. Kakak $name, terima kasih atas masukan obyektif yang diberikan untuk unit pelayanan ${review.locationName}. Hal ini menjadi catatan kami dalam meningkatkan efisiensi operasional harian.';
      }
    } else if (tone == 'Friendly') {
      if (review.sentiment == 'positive') {
        generatedReply.value =
            'Halo Kak $name! 😊 Seneng banget denger pelayanan kami memuaskan. Makasih banyak ya review bintang 5-nya, sukses bikin tim kami tambah semangat hari ini. Sehat selalu ya Kak!';
      } else if (review.sentiment == 'negative') {
        generatedReply.value =
            'Halo Kak $name, duh maaf banget ya udah bikin Kakak kecewa pas berkunjung ke ${review.locationName}. Masalah ini langsung mimin catat buat bahan evaluasi tim. Semoga kunjungan berikutnya bisa lebih baik ya Kak. Makasih masukannya!';
      } else {
        generatedReply.value =
            'Halo Kak $name, makasih ya atas ulasannya! Masukan Kakak berguna banget biar kami bisa terus berkembang. Ditunggu kunjungan berikutnya dengan pelayanan yang lebih baik!';
      }
    } else {
      // Concise
      generatedReply.value =
          'Terima kasih atas ulasan dan sarannya Kak $name. Kami akan segera mengevaluasi layanan di ${review.locationName}.';
    }

    isGeneratingReply.value = false;
  }

  void submitReply(String reviewId, String reply) {
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
