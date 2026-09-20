import '../core/api/api_client.dart';
import '../core/api/api_config.dart';

class DeviceRegistrationService {
  DeviceRegistrationService({ApiClient? api}) : api = api ?? ApiConfig.client;

  final ApiClient api;

  Future<void> register({
    required String platform,
    required String pushToken,
    String? deviceName,
  }) async {
    await api.post('/devices', {
      'platform': platform,
      'push_token': pushToken.trim(),
      if (deviceName != null && deviceName.trim().isNotEmpty)
        'device_name': deviceName.trim(),
    });
  }

  Future<void> unregister(String pushToken) async {
    await api.delete('/devices', {
      'push_token': pushToken.trim(),
    });
  }
}
