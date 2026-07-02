part of 'main.services.dart';

class ApiService extends GetConnect implements GetxService {
  static ApiService get to => Get.find<ApiService>();

  ApiService() {
    _initializeHttpClient();
  }

  void _initializeHttpClient() {
    if (Get.isRegistered<ConfigEnvironments>()) {
      httpClient.baseUrl = ConfigEnvironments.to.environments.url;
      ever(
        ConfigEnvironments.to._currentEnvironments,
        (envs) => httpClient.baseUrl = envs.url,
      );
    }
    httpClient.timeout = const Duration(seconds: 15);
    httpClient.addAuthenticator<dynamic>((request) {
      if (Get.isRegistered<SecureStorageServices>()) {
        final token = SecureStorageServices.to.read('token') ?? '';
        if (token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
      return request;
    });
  }

  // GET Request
  Future<Response<T>> getRequest<T>(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
  }) async {
    try {
      // print('ApiService: Sending GET request to: ${httpClient.baseUrl}$url');
      final response = await get<T>(
        url,
        headers: headers,
        query: query,
        decoder: decoder,
      );
      // print(
      //   'ApiService: GET Response status: ${response.statusCode}, body: ${response.body}',
      // );
      return response;
    } catch (e) {
      // print('ApiService: GET Request failed with exception: $e');
      return Response<T>(statusCode: 500, statusText: e.toString());
    }
  }

  // POST Request
  Future<Response<T>> postRequest<T>(
    String url,
    dynamic body, {
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
  }) async {
    try {
      // print(
      //   'ApiService: Sending POST request to: ${httpClient.baseUrl}$url, body: $body',
      // );
      final response = await post<T>(
        url,
        body,
        headers: headers,
        query: query,
        decoder: decoder,
      );
      // print(
      //   'ApiService: POST Response status: ${response.statusCode}, body: ${response.body}',
      // );
      return response;
    } catch (e) {
      // print('ApiService: POST Request failed with exception: $e');
      return Response<T>(statusCode: 500, statusText: e.toString());
    }
  }

  // PUT Request
  Future<Response<T>> putRequest<T>(
    String url,
    dynamic body, {
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
  }) async {
    try {
      final response = await put<T>(
        url,
        body,
        headers: headers,
        query: query,
        decoder: decoder,
      );
      return response;
    } catch (e) {
      return Response<T>(statusCode: 500, statusText: e.toString());
    }
  }

  // PATCH Request
  Future<Response<T>> patchRequest<T>(
    String url,
    dynamic body, {
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
  }) async {
    try {
      // print(
      //   'ApiService: Sending PATCH request to: ${httpClient.baseUrl}$url, body: $body',
      // );
      final response = await patch<T>(
        url,
        body,
        headers: headers,
        query: query,
        decoder: decoder,
      );
      // print(
      //   'ApiService: PATCH Response status: ${response.statusCode}, body: ${response.body}',
      // );
      return response;
    } catch (e) {
      // print('ApiService: PATCH Request failed with exception: $e');
      return Response<T>(statusCode: 500, statusText: e.toString());
    }
  }

  // DELETE Request
  Future<Response<T>> deleteRequest<T>(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
  }) async {
    try {
      final response = await delete<T>(
        url,
        headers: headers,
        query: query,
        decoder: decoder,
      );
      return response;
    } catch (e) {
      return Response<T>(statusCode: 500, statusText: e.toString());
    }
  }
}
