import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../core/auth/session_store.dart';

class AuthRecoveryService {
  AuthRecoveryService({
    ApiClient? api,
    SessionStore? sessionStore,
  })  : api = api ?? ApiConfig.client,
        sessionStore = sessionStore ?? SessionStore();

  final ApiClient api;
  final SessionStore sessionStore;

  Future<void> requestPasswordReset(String email) async {
    await api.post('/auth/password/request', {'email': email.trim()});
  }

  Future<void> resetPassword(
    String email,
    String code,
    String password,
  ) async {
    await api.post('/auth/password/reset', {
      'email': email.trim(),
      'code': code.trim(),
      'password': password,
      'password_confirmation': password,
    });
  }

  Future<void> requestOtp(String email) async {
    await api.post('/auth/otp/request', {'email': email.trim()});
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    final response = await api.post('/auth/otp/verify', {
      'email': email.trim(),
      'code': code.trim(),
    });

    final token = response['token'] ??
        (response['data'] is Map ? (response['data'] as Map)['token'] : null);

    if (token is String && token.trim().isNotEmpty) {
      api.setAuthToken(token);
      await sessionStore.saveToken(token);
    }

    return response;
  }

  Future<void> requestEmailVerification() async {
    await api.post('/auth/email/request', {});
  }

  Future<void> verifyEmail(String code) async {
    await api.post('/auth/email/verify', {'code': code.trim()});
  }
}
