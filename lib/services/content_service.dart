import '../core/api/api_client.dart';
import '../core/api/api_config.dart';

class ContentService {
  ContentService({ApiClient? api}) : api = api ?? ApiConfig.client;

  final ApiClient api;

  Future<List<Map<String, dynamic>>> list({
    String? type,
    String? query,
    int perPage = 30,
  }) async {
    final params = <String, String>{
      'per_page': perPage.clamp(1, 50).toString(),
      if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
    };

    final path = Uri(
      path: '/content',
      queryParameters: params,
    ).toString();

    final response = await api.get(path);
    final raw = response['data'];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (raw is Map && raw['data'] is List) {
      return (raw['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> show(int id) async {
    final response = await api.get('/content/$id');
    final data = response['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return response;
  }
}
