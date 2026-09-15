class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://youth.churchofuganda.org/api/v1',
  );

  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );

  static const bool enableDebugLogs = bool.fromEnvironment(
    'ENABLE_DEBUG_LOGS',
    defaultValue: false,
  );

  static bool get isProduction => environment == 'production';
}
