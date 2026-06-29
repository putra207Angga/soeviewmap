part of 'main.models.dart';

class BotModel {
  final String botStatus;
  final DateTime lastCheckedAt;
  final String errorMessage;
  final int totalAutoReplied;

  BotModel({
    required this.botStatus,
    required this.lastCheckedAt,
    required this.errorMessage,
    required this.totalAutoReplied,
  });

  factory BotModel.fromJson(Map<String, dynamic> json) {
    return BotModel(
      botStatus: json['bot_status'] as String? ?? '',
      lastCheckedAt: json['last_checked_at'] != null
          ? DateTime.tryParse(json['last_checked_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      errorMessage: json['error_message'] as String? ?? '',
      totalAutoReplied: json['total_auto_replied'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bot_status': botStatus,
      'last_checked_at': lastCheckedAt.toIso8601String(),
      'error_message': errorMessage,
      'total_auto_replied': totalAutoReplied,
    };
  }
}
