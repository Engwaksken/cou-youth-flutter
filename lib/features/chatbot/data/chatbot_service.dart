import '../../../core/api/api_client.dart';

class ChatbotService {
  ChatbotService(this.api);
  final ApiClient api;

  Future<String> send(String message) async {
    final response = await api.post('/api/v1/chatbot', {'message': message});
    return response['data']['reply'] as String;
  }
}
