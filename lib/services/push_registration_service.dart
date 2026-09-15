import '../core/api/api_client.dart';
import '../core/config/app_config.dart';

/// Backend registration boundary for FCM/APNs tokens.
/// Obtain the platform token using firebase_messaging in the host Flutter app,
/// then pass it to [registerToken]. Firebase server credentials stay on Laravel.
class PushRegistrationService {
  PushRegistrationService([ApiClient? api]) : _api = api ?? ApiClient(baseUrl: AppConfig.apiBaseUrl);
  final ApiClient _api;

  Future<void> registerToken({
    required String token,
    required String platform,
  }) async {
    await _api.post('/devices', {
      'token': token,
      'platform': platform,
      'provider': 'fcm',
    });
  }
}
