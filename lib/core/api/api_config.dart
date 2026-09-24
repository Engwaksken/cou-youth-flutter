import 'api_client.dart';
import '../config/app_config.dart';
import '../../services/connectivity_service.dart';
import '../../services/offline_cache_service.dart';

class ApiConfig {
  ApiConfig._();

  static final ApiClient client = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    connectivity: ConnectivityService.instance,
    cache: OfflineCacheService.instance,
  );
}
