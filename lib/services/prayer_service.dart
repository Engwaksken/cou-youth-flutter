import '../core/api/api_client.dart';
import '../core/api/api_config.dart';

class PrayerService {
  PrayerService({ApiClient? api}) : api = api ?? ApiConfig.client;

  final ApiClient api;

  Future<List<Map<String, dynamic>>> mine() async {
    final response = await api.get('/prayer-requests');
    final data = response['data'];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return const <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> submit({
    required String subject,
    required String message,
    String visibility = 'private',
    int? organisationUnitId,
  }) {
    return api.post('/prayer-requests', {
      'subject': subject.trim(),
      'message': message.trim(),
      'visibility': visibility,
      if (organisationUnitId != null)
        'organisation_unit_id': organisationUnitId,
    });
  }
}
