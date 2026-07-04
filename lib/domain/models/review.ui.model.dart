part of 'main.models.dart';

class ReviewUiModel {
  final String id;
  final String reviewId;
  final String reviewerName;
  final String reviewerAvatar;
  final double rating;
  final String comment;
  final String date;
  final String locationName;
  final String sentiment;
  final List<String> tags;
  final RxString replyText = ''.obs;

  ReviewUiModel({
    required this.id,
    required this.reviewId,
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

  factory ReviewUiModel.formReviewModel({
    required ReviewModel data,
    String? selectedLocation,
  }) {
    return ReviewUiModel(
      id: data.id.toString(),
      reviewId: data.reviewId,
      reviewerName: data.reviewerName,
      reviewerAvatar:
          'https://api.dicebear.com/7.x/pixel-art/png?seed=${data.reviewerName}', // todo: provide actual avatar URL if available
      rating: data.rating.toDouble(),
      comment: data.comment,
      date: _formatDateTime(data.createdAt),
      locationName:
          selectedLocation ??
          'RSUD dr. Soebandi', // todo: provide actual location name if available
      sentiment: data.sentiment,
      tags: data.keywords,
      initialReply: data.replyText,
    );
  }

  static String _formatDateTime(DateTime dt) {
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
}
