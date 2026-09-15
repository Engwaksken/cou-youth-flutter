import 'package:cou_youth_mobile/core/api/api_client.dart';

class NotificationService {
  NotificationService(this.apiClient);

  final ApiClient apiClient;

  Future<List<dynamic>> list() async {
    final response = await apiClient.get('/api/v1/notifications');

    final data = response['data'];

    if (data is List) {
      return data;
    }

    return <dynamic>[];
  }

  Future<Map<String, dynamic>> markAsRead(int id) async {
    return apiClient.post(
      '/api/v1/notifications/$id/read',
      <String, dynamic>{},
    );
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    return apiClient.post(
      '/api/v1/notifications/read-all',
      <String, dynamic>{},
    );
  }
}