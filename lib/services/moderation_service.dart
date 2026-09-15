import '../core/api/api_client.dart';
class ModerationService {
  ModerationService(this.api); final ApiClient api;
  Future<dynamic> report({required String type, required int id, required String reason, String? details}) => api.post('/moderation/reports', {'reportable_type':type,'reportable_id':id,'reason':reason,if(details!=null)'details':details});
  Future<dynamic> blocked() => api.get('/moderation/blocked');
  Future<dynamic> block(int userId,{String? reason}) => api.post('/moderation/users/$userId/block',{if(reason!=null)'reason':reason});
  Future<dynamic> unblock(int userId) => api.delete('/moderation/users/$userId/block');
}
