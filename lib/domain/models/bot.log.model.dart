part of 'main.models.dart';

class BotLogModel {
  final String timestamp;
  final String level;
  final String message;

  BotLogModel({
    required this.timestamp,
    required this.level,
    required this.message,
  });

  factory BotLogModel.fromJson(Map<String, dynamic> json) {
    return BotLogModel(
      timestamp: json['timestamp'] as String? ?? '',
      level: json['level'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'level': level,
      'message': message,
    };
  }
}
