import '../core/api/api_client.dart';
import '../core/api/api_config.dart';

class LifeGroupService {
  LifeGroupService({ApiClient? api}) : api = api ?? ApiConfig.client;

  final ApiClient api;

  Future<List<Map<String, dynamic>>> list({int? organisationUnitId}) async {
    final query = organisationUnitId == null
        ? ''
        : '?organisation_unit_id=$organisationUnitId';
    final response = await api.get('/life-groups$query');
    final raw = response['data'];

    if (raw is Map && raw['data'] is List) {
      return (raw['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return const <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> join(int lifeGroupId) {
    return api.post('/life-groups/$lifeGroupId/join', <String, dynamic>{});
  }
}
