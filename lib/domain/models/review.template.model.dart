part of 'main.models.dart';

class ReviewTemplateModel {
  final int id;
  final int rating;
  final String templateText;
  final DateTime updatedAt;

  ReviewTemplateModel({
    required this.id,
    required this.rating,
    required this.templateText,
    required this.updatedAt,
  });

  factory ReviewTemplateModel.fromJson(Map<String, dynamic> json) {
    return ReviewTemplateModel(
      id: json['id'] is num 
          ? (json['id'] as num).toInt() 
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      rating: json['rating'] is num 
          ? (json['rating'] as num).toInt() 
          : int.tryParse(json['rating']?.toString() ?? '') ?? 0,
      templateText: json['template_text'] as String? ?? '',
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'template_text': templateText,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
