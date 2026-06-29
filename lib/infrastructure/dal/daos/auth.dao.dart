part of 'main.daos.dart';

class AuthDao extends ApiService {
  static AuthDao get use => AuthDao();
  // Login to the API
  Future<Response<Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    final body = {'username': username, 'password': password};
    return await postRequest<Map<String, dynamic>>('/api/login', body);
  }

  // Get current user profile
  Future<Response<UserProfile>> getProfile() async {
    return await getRequest<UserProfile>(
      '/api/me',
      decoder: (data) {
        print(
          'AuthDao: getProfile decoder received data of type ${data.runtimeType}: $data',
        );
        dynamic decoded = data;
        if (data is String) {
          try {
            decoded = jsonDecode(data);
          } catch (e) {
            print('AuthDao: getProfile jsonDecode error: $e');
          }
        }
        if (decoded is Map) {
          final profileData = decoded['data'] as Map?;
          if (profileData != null) {
            return UserProfile.fromJson(Map<String, dynamic>.from(profileData));
          }
        }
        return UserProfile.fromJson({});
      },
    );
  }

  // Check PIN
  static Future<Response<Map<String, dynamic>>> checkPin(String pin) async {
    final body = {'pin': pin};
    return await ApiService.to.postRequest<Map<String, dynamic>>(
      '/api/check-pin',
      body,
    );
  }
}
