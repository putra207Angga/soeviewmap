part of 'main.models.dart';

class SentimentAnalysisModel {
  final String summaryStatus;
  final double overallPositivePercentage;
  final SentimentDetailModel positive;
  final SentimentDetailModel neutral;
  final SentimentDetailModel negative;
  final List<KeywordCountModel> topKeywords;

  SentimentAnalysisModel({
    required this.summaryStatus,
    required this.overallPositivePercentage,
    required this.positive,
    required this.neutral,
    required this.negative,
    required this.topKeywords,
  });

  factory SentimentAnalysisModel.fromJson(Map<String, dynamic> json) {
    return SentimentAnalysisModel(
      summaryStatus: json['summary_status'] as String? ?? 'Mid Vibe 😐',
      overallPositivePercentage: (json['overall_positive_percentage'] as num?)?.toDouble() ?? 0.0,
      positive: SentimentDetailModel.fromJson(json['positive'] as Map<String, dynamic>? ?? {}),
      neutral: SentimentDetailModel.fromJson(json['neutral'] as Map<String, dynamic>? ?? {}),
      negative: SentimentDetailModel.fromJson(json['negative'] as Map<String, dynamic>? ?? {}),
      topKeywords: json['top_keywords'] is List
          ? (json['top_keywords'] as List)
              .map((e) => KeywordCountModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary_status': summaryStatus,
      'overall_positive_percentage': overallPositivePercentage,
      'positive': positive.toJson(),
      'neutral': neutral.toJson(),
      'negative': negative.toJson(),
      'top_keywords': topKeywords.map((e) => e.toJson()).toList(),
    };
  }
}

class SentimentDetailModel {
  final int count;
  final double percentage;

  SentimentDetailModel({
    required this.count,
    required this.percentage,
  });

  factory SentimentDetailModel.fromJson(Map<String, dynamic> json) {
    return SentimentDetailModel(
      count: json['count'] is num 
          ? (json['count'] as num).toInt() 
          : int.tryParse(json['count']?.toString() ?? '') ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'percentage': percentage,
    };
  }
}

class KeywordCountModel {
  final String keyword;
  final int count;

  KeywordCountModel({
    required this.keyword,
    required this.count,
  });

  factory KeywordCountModel.fromJson(Map<String, dynamic> json) {
    return KeywordCountModel(
      keyword: json['keyword'] as String? ?? '',
      count: json['count'] is num 
          ? (json['count'] as num).toInt() 
          : int.tryParse(json['count']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'count': count,
    };
  }
}
