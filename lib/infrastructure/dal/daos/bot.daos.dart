part of 'main.daos.dart';

class BotDao extends ApiService {
  static BotDao get use => BotDao();
  // Get bot status
  Future<Response<BotModel>> getStatus() async {
    return await getRequest<BotModel>(
      '/api/reviews/bot/status', // Ganti dengan endpoint yang sesuai jika berbeda
      decoder: (data) {
        print(
          'BotDao.getStatus: decoder received data of type ${data.runtimeType}: $data',
        );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            print('BotDao.getStatus: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          final botData = decoded['data'] as Map?;
          if (botData != null) {
            return BotModel.fromJson(Map<String, dynamic>.from(botData));
          }
        }
        return BotModel.fromJson({});
      },
    );
  }

  Future<Response<BotLogModel>> getLogs() async {
    return await getRequest<BotLogModel>(
      '/api/reviews/bot/logs',
      decoder: (data) {
        print(
          'BotDao.getLogs: decoder received data of type ${data.runtimeType}: $data',
        );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            print('BotDao.getLogs: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          final botLogData = decoded['data'] as Map?;
          if (botLogData != null) {
            return BotLogModel.fromJson(Map<String, dynamic>.from(botLogData));
          }
        }
        return BotLogModel.fromJson({});
      },
    );
  }
}
