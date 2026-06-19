part of 'main.models.dart';

class ReviewStatsModel {
  final int totalReviews;
  final double ratingAverage;
  final double positiveVibesPercentage;
  final double responseRatePercentage;

  ReviewStatsModel({
    required this.totalReviews,
    required this.ratingAverage,
    required this.positiveVibesPercentage,
    required this.responseRatePercentage,
  });

  factory ReviewStatsModel.fromJson(Map<String, dynamic> json) {
    return ReviewStatsModel(
      totalReviews: json['total_reviews'] as int? ?? 0,
      ratingAverage: (json['rating_average'] as num?)?.toDouble() ?? 0.0,
      positiveVibesPercentage: (json['positive_vibes_percentage'] as num?)?.toDouble() ?? 0.0,
      responseRatePercentage: (json['response_rate_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_reviews': totalReviews,
      'rating_average': ratingAverage,
      'positive_vibes_percentage': positiveVibesPercentage,
      'response_rate_percentage': responseRatePercentage,
    };
  }
}
