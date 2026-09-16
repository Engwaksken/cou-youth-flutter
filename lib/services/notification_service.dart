import 'package:cou_youth_mobile/core/api/api_client.dart';

class NotificationService {
  NotificationService(this.apiClient);

  final ApiClient apiClient;

  Future<List<Map<String, dynamic>>> list() async {
    final response = await apiClient.get('/notifications');
    final data = response['data'];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> markAsRead(int receiptId) async {
    return apiClient.post(
      '/notifications/$receiptId/read',
      <String, dynamic>{},
    );
  }
}
