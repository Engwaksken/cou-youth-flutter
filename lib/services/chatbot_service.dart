import '../core/api/api_client.dart';
import '../core/api/api_config.dart';

class ChatbotService {
  ChatbotService({ApiClient? api}) : api = api ?? ApiConfig.client;

  final ApiClient api;

  Future<String> ask(String message) async {
    final response = await api.post('/chatbot', {
      'message': message.trim(),
    });

    final data = response['data'];
    if (data is Map && data['reply'] is String) {
      return (data['reply'] as String).trim();
    }

    throw const ApiException(
      'The assistant did not return a response. Please try again.',
    );
  }
}
