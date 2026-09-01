part of 'main.daos.dart';

class ReviewDao extends ApiService {
  static ReviewDao get use => ReviewDao();
  // Get reviews list
  Future<Response<ApiResponseList<ReviewModel>>> getReviews({
    String? status,
    String? timeRange,
    int? rating,
    String? sentiment,
    String? dateFrom,
    String? dateTo,
    int? limit,
    int? page,
    int? pageSize,
  }) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    if (timeRange != null) query['time_range'] = timeRange;
    if (rating != null) query['rating'] = rating.toString();
    if (sentiment != null) query['sentiment'] = sentiment;
    if (dateFrom != null) query['date_from'] = dateFrom;
    if (dateTo != null) query['date_to'] = dateTo;
    if (limit != null) query['limit'] = limit.toString();
    if (page != null) query['page'] = page.toString();
    if (pageSize != null) query['page_size'] = pageSize.toString();

    return await getRequest<ApiResponseList<ReviewModel>>(
      '/api/reviews',
      query: query.isNotEmpty ? query : null,
      decoder: (data) {
        // print(
        //   'ReviewDao.getReviews: decoder received data of type ${data.runtimeType}: $data',
        // );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            // print('ReviewDao.getReviews: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          return ApiResponseList<ReviewModel>.fromJson(
            Map<String, dynamic>.from(decoded),
            (itemJson) => ReviewModel.fromJson(itemJson),
          );
        }
        if (decoded is List) {
          final items = decoded
              .map(
                (e) =>
                    ReviewModel.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList();
          return ApiResponseList<ReviewModel>(
            success: true,
            message: 'Successfully mapped raw list reviews',
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
        return ApiResponseList<ReviewModel>(
          success: false,
          message: 'Failed to decode reviews data',
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

  // Get reviews statistics
  Future<Response<ReviewStatsModel>> getStats() async {
    return await getRequest<ReviewStatsModel>(
      '/api/reviews/stats',
      decoder: (data) {
        // print(
        //   'ReviewDao.getStats: decoder received data of type ${data.runtimeType}: $data',
        // );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            // print('ReviewDao.getStats: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          final statsData = decoded['data'] as Map?;
          if (statsData != null) {
            return ReviewStatsModel.fromJson(
              Map<String, dynamic>.from(statsData),
            );
          }
        }
        return ReviewStatsModel.fromJson({});
      },
    );
  }

  // Get sentiment analysis
  Future<Response<SentimentAnalysisModel>> getSentimentAnalysis() async {
    return await getRequest<SentimentAnalysisModel>(
      '/api/reviews/sentiment-analysis',
      decoder: (data) {
        // print(
        //   'ReviewDao.getSentimentAnalysis: decoder received data of type ${data.runtimeType}: $data',
        // );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            // print('ReviewDao.getSentimentAnalysis: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          final analysisData = decoded['data'] as Map?;
          if (analysisData != null) {
            return SentimentAnalysisModel.fromJson(
              Map<String, dynamic>.from(analysisData),
            );
          }
        }
        return SentimentAnalysisModel.fromJson({});
      },
    );
  }

  // Send reply to a review (POST)
  Future<Response<Map<String, dynamic>>> replyToReview({
    required String reviewId,
    required String replyText,
  }) async {
    final body = {'reply_text': replyText};
    return await postRequest<Map<String, dynamic>>(
      '/api/reviews/$reviewId/reply',
      body,
    );
  }
}
