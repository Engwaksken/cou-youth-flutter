import '../core/api/api_client.dart';
class NotificationPreferencesService {
  NotificationPreferencesService(this.api); final ApiClient api;
  Future<dynamic> load() => api.get('/notification-preferences');
  Future<dynamic> update(Map<String,dynamic> values) => api.put('/notification-preferences', values);
}
