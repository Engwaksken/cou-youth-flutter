import '../core/api/api_client.dart';

class QuizService {
  QuizService(this.api);
  final ApiClient api;
  Future<dynamic> show(int quizId) => api.get('/quizzes/$quizId');
  Future<dynamic> submit(int quizId, Map<String, dynamic> answers) =>
      api.post('/quizzes/$quizId/submit', {'answers': answers});
}
