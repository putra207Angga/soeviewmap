part of 'main.daos.dart';

class ReviewDao {
  // Get reviews list
  static Future<Response<List<ReviewModel>>> getReviews({
    String? status,
    String? timeRange,
    int? rating,
    String? sentiment,
    int? limit,
  }) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    if (timeRange != null) query['time_range'] = timeRange;
    if (rating != null) query['rating'] = rating.toString();
    if (sentiment != null) query['sentiment'] = sentiment;
    if (limit != null) query['limit'] = limit.toString();

    return await ApiService.to.getRequest<List<ReviewModel>>(
      '/api/reviews',
      query: query.isNotEmpty ? query : null,
      decoder: (data) {
        print('ReviewDao.getReviews: decoder received data of type ${data.runtimeType}: $data');
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            print('ReviewDao.getReviews: jsonDecode error: $e');
          }
        }
        if (decoded is List) {
          return decoded
              .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
        if (decoded is Map) {
          final listData = decoded['data'] as List?;
          if (listData != null) {
            return listData
                .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList();
          }
        }
        return [];
      },
    );
  }

  // Get reviews statistics
  static Future<Response<ReviewStatsModel>> getStats() async {
    return await ApiService.to.getRequest<ReviewStatsModel>(
      '/api/reviews/stats',
      decoder: (data) {
        print('ReviewDao.getStats: decoder received data of type ${data.runtimeType}: $data');
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            print('ReviewDao.getStats: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          final statsData = decoded['data'] as Map?;
          if (statsData != null) {
            return ReviewStatsModel.fromJson(Map<String, dynamic>.from(statsData));
          }
        }
        return ReviewStatsModel.fromJson({});
      },
    );
  }

  // Get sentiment analysis
  static Future<Response<SentimentAnalysisModel>> getSentimentAnalysis() async {
    return await ApiService.to.getRequest<SentimentAnalysisModel>(
      '/api/reviews/sentiment-analysis',
      decoder: (data) {
        print('ReviewDao.getSentimentAnalysis: decoder received data of type ${data.runtimeType}: $data');
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            print('ReviewDao.getSentimentAnalysis: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          final analysisData = decoded['data'] as Map?;
          if (analysisData != null) {
            return SentimentAnalysisModel.fromJson(Map<String, dynamic>.from(analysisData));
          }
        }
        return SentimentAnalysisModel.fromJson({});
      },
    );
  }
}
