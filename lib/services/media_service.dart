import '../core/api/api_client.dart';
import '../core/api/api_config.dart';

class MediaService {
  MediaService({ApiClient? api}) : api = api ?? ApiConfig.client;

  final ApiClient api;

  Future<List<Map<String, dynamic>>> list({String? type}) async {
    final query = type == null || type.trim().isEmpty
        ? ''
        : '?type=${Uri.encodeQueryComponent(type.trim())}';

    final response = await api.get('/media$query');
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
}
