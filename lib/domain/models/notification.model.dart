part of 'main.models.dart';

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String? status;
  final String? reviewerName;
  final int? rating;
  final String? url;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.status,
    this.reviewerName,
    this.rating,
    this.url,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final isReadRaw = json['is_read'];
    final isReadParsed = isReadRaw == true || 
                        isReadRaw == 1 || 
                        isReadRaw?.toString().toLowerCase() == 'true' || 
                        isReadRaw?.toString() == '1';

    return NotificationModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      status: json['status'] as String?,
      reviewerName: json['reviewer_name'] as String?,
      rating: json['rating'] is num ? (json['rating'] as num).toInt() : int.tryParse(json['rating']?.toString() ?? ''),
      url: json['url'] as String?,
      isRead: isReadParsed,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'status': status,
      'reviewer_name': reviewerName,
      'rating': rating,
      'url': url,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PushSubscriptionKeys {
  final String p256dh;
  final String auth;

  PushSubscriptionKeys({required this.p256dh, required this.auth});

  Map<String, dynamic> toJson() {
    return {
      'p256dh': p256dh,
      'auth': auth,
    };
  }
}

class PushSubscriptionCreate {
  final String endpoint;
  final PushSubscriptionKeys keys;

  PushSubscriptionCreate({required this.endpoint, required this.keys});

  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'keys': keys.toJson(),
    };
  }
}
