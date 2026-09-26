import '../core/api/api_client.dart';
import '../core/api/api_config.dart';

class CertificateService {
  CertificateService({ApiClient? api}) : api = api ?? ApiConfig.client;

  final ApiClient api;

  Future<List<Map<String, dynamic>>> list() async {
    final response = await api.get('/certificates');
    final data = response['data'];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> show(int id) async {
    final response = await api.get('/certificates/$id');
    final data = response['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return response;
  }
}
