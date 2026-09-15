import '../core/api/api_client.dart';
class CertificateService { CertificateService(this.api); final ApiClient api; Future<dynamic> list() => api.get('/certificates'); Future<dynamic> show(int id)=>api.get('/certificates/$id'); }
