import 'package:cou_youth_mobile/core/api/api_client.dart';

class EventService {
  EventService(this.apiClient);

  final ApiClient apiClient;

  Future<List<Map<String, dynamic>>> list() async {
    final response = await apiClient.get('/events');
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

  Future<Map<String, dynamic>> show(int id) async {
    return apiClient.get('/events/$id');
  }

  Future<Map<String, dynamic>> register(int eventId) async {
    return apiClient.post('/events/$eventId/register', <String, dynamic>{});
  }
}
