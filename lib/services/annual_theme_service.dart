import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../models/annual_theme_content.dart';

class AnnualThemeService {
  AnnualThemeService({
    ApiClient? api,
    FlutterSecureStorage? storage,
  })  : api = api ?? ApiConfig.client,
        storage = storage ?? const FlutterSecureStorage();

  static const _cacheKey = 'annual_theme_content_v1';

  final ApiClient api;
  final FlutterSecureStorage storage;

  Future<AnnualThemeContent> fetch({bool allowCachedFallback = true}) async {
    try {
      final response = await api.get('/annual-theme');
      final data = response['data'];

      if (data is! Map) {
        throw const ApiException('Annual theme data is unavailable.');
      }

      final content = AnnualThemeContent.fromJson(
        Map<String, dynamic>.from(data),
      );

      await storage.write(
        key: _cacheKey,
        value: jsonEncode(content.toJson()),
      );

      return content;
    } catch (_) {
      if (!allowCachedFallback) rethrow;

      final cached = await readCached();
      if (cached != null) return cached;

      rethrow;
    }
  }

  Future<AnnualThemeContent?> readCached() async {
    final raw = await storage.read(key: _cacheKey);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return AnnualThemeContent.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
