part of 'main.models.dart';

class ReviewStatsModel {
  final int totalReviews;
  final double ratingAverage;
  final double positiveVibesPercentage;
  final double positiveVibesTrendPercentage;
  final double avgResponseHours;
  final int responseTargetDifferenceMinutes;
  final int pendingCount;

  ReviewStatsModel({
    required this.totalReviews,
    required this.ratingAverage,
    required this.positiveVibesPercentage,
    required this.positiveVibesTrendPercentage,
    required this.avgResponseHours,
    required this.responseTargetDifferenceMinutes,
    required this.pendingCount,
  });

  factory ReviewStatsModel.fromJson(Map<String, dynamic> json) {
    return ReviewStatsModel(
      totalReviews: json['total_reviews'] as int? ?? 0,
      ratingAverage: (json['rating_average'] as num?)?.toDouble() ?? 0.0,
      positiveVibesPercentage: (json['positive_vibes_percentage'] as num?)?.toDouble() ?? 0.0,
      positiveVibesTrendPercentage: (json['positive_vibes_trend_percentage'] as num?)?.toDouble() ?? 0.0,
      avgResponseHours: (json['avg_response_hours'] as num?)?.toDouble() ?? 0.0,
      responseTargetDifferenceMinutes: json['response_target_difference_minutes'] is num 
          ? (json['response_target_difference_minutes'] as num).toInt() 
          : int.tryParse(json['response_target_difference_minutes']?.toString() ?? '') ?? 0,
      pendingCount: json['pending_count'] is num 
          ? (json['pending_count'] as num).toInt() 
          : int.tryParse(json['pending_count']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_reviews': totalReviews,
      'rating_average': ratingAverage,
      'positive_vibes_percentage': positiveVibesPercentage,
      'positive_vibes_trend_percentage': positiveVibesTrendPercentage,
      'avg_response_hours': avgResponseHours,
      'response_target_difference_minutes': responseTargetDifferenceMinutes,
      'pending_count': pendingCount,
    };
  }
}
