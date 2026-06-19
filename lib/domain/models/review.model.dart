part of 'main.models.dart';

class ReviewModel {
  final int id;
  final String reviewId;
  final String reviewerName;
  final int rating;
  final String comment;
  final String replyText;
  final String status;
  final String sentiment;
  final DateTime createdAt;
  final List<String> keywords;

  ReviewModel({
    required this.id,
    required this.reviewId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.replyText,
    required this.status,
    required this.sentiment,
    required this.createdAt,
    required this.keywords,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] is num 
          ? (json['id'] as num).toInt() 
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      reviewId: json['review_id'] as String? ?? '',
      reviewerName: json['reviewer_name'] as String? ?? '',
      rating: json['rating'] is num 
          ? (json['rating'] as num).toInt() 
          : int.tryParse(json['rating']?.toString() ?? '') ?? 0,
      comment: json['comment'] as String? ?? '',
      replyText: json['reply_text'] as String? ?? '',
      status: json['status'] as String? ?? '',
      sentiment: json['sentiment'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      keywords: json['keywords'] is List
          ? (json['keywords'] as List).map((e) => e.toString()).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'review_id': reviewId,
      'reviewer_name': reviewerName,
      'rating': rating,
      'comment': comment,
      'reply_text': replyText,
      'status': status,
      'sentiment': sentiment,
      'created_at': createdAt.toIso8601String(),
      'keywords': keywords,
    };
  }
}
