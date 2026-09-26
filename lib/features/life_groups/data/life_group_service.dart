import '../../../core/api/api_client.dart';

class LifeGroupService {
  LifeGroupService(this.api);
  final ApiClient api;
  Future<Map<String, dynamic>> list({int? organisationUnitId}) => api.get(
    '/api/v1/life-groups${organisationUnitId == null ? '' : '?organisation_unit_id=$organisationUnitId'}',
  );
  Future<Map<String, dynamic>> join(int id) =>
      api.post('/api/v1/life-groups/$id/join', {});
}
