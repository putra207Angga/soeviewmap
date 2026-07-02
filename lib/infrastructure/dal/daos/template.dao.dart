part of 'main.daos.dart';

class TemplateDao extends ApiService {
  static TemplateDao get use => TemplateDao();
  // Get review templates
  Future<Response<ApiResponseList<ReviewTemplateModel>>> getTemplates() async {
    return await getRequest<ApiResponseList<ReviewTemplateModel>>(
      '/api/reviews/templates',
      decoder: (data) {
        // print(
        //   'TemplateDao.getTemplates: decoder received data of type ${data.runtimeType}: $data',
        // );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            // print('TemplateDao.getTemplates: jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          return ApiResponseList<ReviewTemplateModel>.fromJson(
            Map<String, dynamic>.from(decoded),
            (itemJson) => ReviewTemplateModel.fromJson(itemJson),
          );
        }
        if (decoded is List) {
          final items = decoded
              .map(
                (e) => ReviewTemplateModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
          return ApiResponseList<ReviewTemplateModel>(
            success: true,
            message: 'Successfully mapped raw list templates',
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
        return ApiResponseList<ReviewTemplateModel>(
          success: false,
          message: 'Failed to decode templates data',
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
    return await putRequest<Map<String, dynamic>>(
      '/api/reviews/templates/$rating',
      body,
    );
  }

  // Delete review template (DELETE)
  Future<Response<Map<String, dynamic>>> deleteTemplate({
    required int rating,
  }) async {
    return await deleteRequest<Map<String, dynamic>>(
      '/api/reviews/templates/$rating',
    );
  }
}
