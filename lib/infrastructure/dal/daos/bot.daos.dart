part of 'main.daos.dart';

class BotDao extends ApiService {
  static BotDao get use => BotDao();
  // Get bot status
  Future<Response<BotModel>> getStatus() async {
    return await getRequest<BotModel>(
      '/api/reviews/bot/status', // Ganti dengan endpoint yang sesuai jika berbeda
      decoder: (data) {
        // print(
        //   'BotDao.getStatus: decoder received data of type ${data.runtimeType}: $data',
        // );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            // print('BotDao.getStatus: jsonDecode error: $e');
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

  Future<Response<ApiResponseList<BotLogModel>>> getLogs({
    int limit = 50,
  }) async {
    return await getRequest<ApiResponseList<BotLogModel>>(
      '/api/reviews/bot/logs',
      query: {'limit': limit.toString()},
      decoder: (data) {
        // print(
        //   'BotDao.getLogs: decoder received data of type ${data.runtimeType}: $data',
        // );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            // print('BotDao.getLogs: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          return ApiResponseList<BotLogModel>.fromJson(
            Map<String, dynamic>.from(decoded),
            (itemJson) => BotLogModel.fromJson(itemJson),
          );
        }
        if (decoded is List) {
          final items = decoded
              .map(
                (e) =>
                    BotLogModel.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList();
          return ApiResponseList<BotLogModel>(
            success: true,
            message: 'Successfully mapped raw list logs',
            code: 200,
            items: items,
            meta: MetaModel(
              currentPage: 1,
              pageSize: items.length,
              totalItems: items.length,
              totalPages: 1,
            ),
          );
        }
        return ApiResponseList<BotLogModel>(
          success: false,
          message: 'Failed to decode bot logs data',
          code: 500,
          items: [],
          meta: MetaModel(
            currentPage: 1,
            pageSize: 20,
            totalItems: 0,
            totalPages: 0,
          ),
        );
      },
    );
  }
}
