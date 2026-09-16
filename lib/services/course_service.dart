import 'package:cou_youth_mobile/core/api/api_client.dart';

class CourseService {
  CourseService(this.api);

  final ApiClient api;

  Future<List<Map<String, dynamic>>> list() async {
    final response = await api.get('/courses');
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

  Future<Map<String, dynamic>> show(int id) async {
    return api.get('/courses/$id');
  }

  Future<Map<String, dynamic>> enrol(int id) async {
    return api.post('/courses/$id/enrol', <String, dynamic>{});
  }

  Future<Map<String, dynamic>> completeLesson(int id) async {
    return api.post('/lessons/$id/complete', <String, dynamic>{});
  }
}
