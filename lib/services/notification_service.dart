import 'package:cou_youth_mobile/core/api/api_client.dart';

class NotificationService {
  NotificationService(this.apiClient);

  final ApiClient apiClient;

  Future<List<Map<String, dynamic>>> list() async {
    final response = await apiClient.get('/notifications');
    final data = response['data'];

    final List<dynamic> rows;
    if (data is List) {
      rows = data;
    } else if (data is Map && data['data'] is List) {
      rows = data['data'] as List;
    } else {
      return <Map<String, dynamic>>[];
    }

    return rows.whereType<Map>().map((item) {
      final receipt = Map<String, dynamic>.from(item);
      final notificationRaw = receipt['notification'];
      final notification = notificationRaw is Map
          ? Map<String, dynamic>.from(notificationRaw)
          : const <String, dynamic>{};

      return <String, dynamic>{
        ...receipt,
        'receipt_id': receipt['id'],
        'title': notification['title'] ?? receipt['title'],
        'message': notification['body'] ??
            notification['message'] ??
            receipt['message'] ??
            receipt['body'],
        'action_url': notification['action_url'] ?? receipt['action_url'],
        'channel': notification['channel'] ?? receipt['channel'],
      };
    }).toList();
  }

  Future<Map<String, dynamic>> markAsRead(int receiptId) async {
    return apiClient.post(
      '/notifications/$receiptId/read',
      <String, dynamic>{},
    );
  }
}
