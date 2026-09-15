import '../../../core/api/api_client.dart';
class RegistrationService { RegistrationService(this.api); final ApiClient api;
  Future<Map<String,dynamic>> register(Map<String,dynamic> payload) async => api.post('/api/v1/register', payload);
  Future<List<dynamic>> organisationUnits({String? type,int? parentId}) async { final q=<String>[]; if(type!=null)q.add('type=$type'); if(parentId!=null)q.add('parent_id=$parentId'); final result=await api.get('/api/v1/organisation-units${q.isEmpty?'':'?${q.join('&')}'}'); return result['data'] as List<dynamic>; }
}
