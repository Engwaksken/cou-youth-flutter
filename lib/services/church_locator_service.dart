import 'package:cou_youth_mobile/core/api/api_client.dart';

class ChurchLocatorService {
  ChurchLocatorService(this.api);

  final ApiClient api;

  Future<List<Map<String, dynamic>>> search(String query) async {
    final response = await api.get(
      '/church-locator?q=${Uri.encodeQueryComponent(query.trim())}',
    );

    final data = response['data'];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return <Map<String, dynamic>>[];
  }
}
