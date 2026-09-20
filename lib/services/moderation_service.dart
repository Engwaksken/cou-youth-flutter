import '../core/api/api_client.dart';
import '../core/api/api_config.dart';

class ModerationService {
  ModerationService({ApiClient? api}) : api = api ?? ApiConfig.client;

  final ApiClient api;

  Future<Map<String, dynamic>> report({
    required String type,
    required int id,
    required String reason,
    String? details,
  }) {
    return api.post('/moderation/reports', {
      'reportable_type': type,
      'reportable_id': id,
      'reason': reason.trim(),
      if (details != null && details.trim().isNotEmpty)
        'details': details.trim(),
    });
  }

  Future<List<Map<String, dynamic>>> blocked() async {
    final response = await api.get('/moderation/blocked');
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

  Future<Map<String, dynamic>> block(int userId, {String? reason}) {
    return api.post('/moderation/users/$userId/block', {
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });
  }

  Future<Map<String, dynamic>> unblock(int userId) {
    return api.delete('/moderation/users/$userId/block');
  }
}
