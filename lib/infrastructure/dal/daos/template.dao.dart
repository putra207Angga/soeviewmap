part of 'main.daos.dart';

class TemplateDao extends ApiService {
  static TemplateDao get use => TemplateDao();
  // Get review templates
  Future<Response<List<ReviewTemplateModel>>> getTemplates() async {
    return await getRequest<List<ReviewTemplateModel>>(
      '/api/reviews/templates',
      decoder: (data) {
        print(
          'TemplateDao.getTemplates: decoder received data of type ${data.runtimeType}: $data',
        );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            print('TemplateDao.getTemplates: jsonDecode error: $e');
          }
        }
        if (decoded is List) {
          return decoded
              .map(
                (e) => ReviewTemplateModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
        }
        if (decoded is Map) {
          final listData = decoded['data'] as List?;
          if (listData != null) {
            return listData
                .map(
                  (e) => ReviewTemplateModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList();
          }
        }
        return [];
      },
    );
  }

  // Save review template (POST)
  Future<Response<Map<String, dynamic>>> saveTemplate({
    required int rating,
    required String templateText,
  }) async {
    final body = {'rating': rating, 'template_text': templateText};
    return await postRequest<Map<String, dynamic>>(
      '/api/reviews/templates',
      body,
    );
  }

  // Update review template (PUT)
  Future<Response<Map<String, dynamic>>> updateTemplate({
    required int rating,
    required String templateText,
  }) async {
    final body = {'template_text': templateText};
    final query = {'rating': rating.toString()};
    return await putRequest<Map<String, dynamic>>(
      '/api/reviews/templates',
      body,
      query: query,
    );
  }

  // Delete review template (DELETE)
  Future<Response<Map<String, dynamic>>> deleteTemplate({
    required int rating,
  }) async {
    final query = {'rating': rating.toString()};
    return await deleteRequest<Map<String, dynamic>>(
      '/api/reviews/templates',
      query: query,
    );
  }
}
