import '../core/api/api_client.dart';
import '../core/api/api_config.dart';

class NotificationPreferencesService {
  NotificationPreferencesService({ApiClient? api})
    : api = api ?? ApiConfig.client;

  final ApiClient api;

  Future<Map<String, dynamic>> load() async {
    final response = await api.get('/notification-preferences');
    final data = response['preferences'] ?? response['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return response;
  }

  Future<Map<String, dynamic>> update(Map<String, dynamic> values) async {
    final response = await api.put('/notification-preferences', values);
    final data = response['preferences'] ?? response['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return response;
  }
}
