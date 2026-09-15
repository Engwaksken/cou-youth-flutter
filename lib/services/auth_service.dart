import 'package:cou_youth_mobile/core/api/api_client.dart';
import 'package:cou_youth_mobile/core/auth/session_store.dart';

class AuthService {
  AuthService(this.api, this.sessionStore);

  final ApiClient api;
  final SessionStore sessionStore;

  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    String deviceName = 'mobile',
  }) async {
    final response = await api.post('/auth/login', {
      'email': email.trim(),
      'password': password,
      'device_name': deviceName,
    });

    final token = response['token'];

    if (token is! String || token.trim().isEmpty) {
      throw const ApiException('Login succeeded but no access token was returned.');
    }

    api.setAuthToken(token);
    await sessionStore.saveToken(token);

    return response;
  }

  Future<Map<String, dynamic>> me() async {
    return api.get('/me');
  }

  Future<bool> restoreSession() async {
    final token = await sessionStore.readToken();

    if (token == null || token.trim().isEmpty) {
      api.clearAuthToken();
      return false;
    }

    api.setAuthToken(token);

    try {
      await me();
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await sessionStore.clear();
        api.clearAuthToken();
      }
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await api.post('/auth/logout', <String, dynamic>{});
    } finally {
      api.clearAuthToken();
      await sessionStore.clear();
    }
  }
}
