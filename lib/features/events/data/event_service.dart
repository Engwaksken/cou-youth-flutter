import 'package:cou_youth_mobile/core/api/api_client.dart';

class EventService {
  EventService(this.apiClient);

  final ApiClient apiClient;

  Future<List<dynamic>> list() async {
    final response = await apiClient.get('/api/v1/events');

    final data = response['data'];

    if (data is List) {
      return data;
    }

    return <dynamic>[];
  }

  Future<Map<String, dynamic>> show(int id) async {
    return apiClient.get('/api/v1/events/$id');
  }

  Future<Map<String, dynamic>> register(int eventId) async {
    return apiClient.post(
      '/api/v1/events/$eventId/register',
      <String, dynamic>{},
    );
  }
}