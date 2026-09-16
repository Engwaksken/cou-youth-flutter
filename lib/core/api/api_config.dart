import 'api_client.dart';
import '../config/app_config.dart';

class ApiConfig {
  ApiConfig._();

  static final ApiClient client = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
  );
}
