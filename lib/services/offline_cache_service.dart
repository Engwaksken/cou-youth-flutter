import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OfflineCacheService {
  OfflineCacheService._();

  static final OfflineCacheService instance = OfflineCacheService._();

  static const List<String> _cacheablePrefixes = [
    '/branding',
    '/content',
    '/events',
    '/courses',
    '/media',
    '/church-locator',
    '/donation-campaigns',
    '/payment-gateways',
  ];

  bool canCache(String path) {
    return _cacheablePrefixes.any((prefix) => path.startsWith(prefix));
  }

  Future<void> write(String path, Map<String, dynamic> response) async {
    if (!canCache(path)) return;

    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'cached_at': DateTime.now().toIso8601String(),
      'response': response,
    };

    await prefs.setString(_key(path), jsonEncode(payload));
  }

  Future<Map<String, dynamic>?> read(String path) async {
    if (!canCache(path)) return null;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(path));
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final wrapper = Map<String, dynamic>.from(decoded);
      final response = wrapper['response'];
      if (response is! Map) return null;

      return <String, dynamic>{
        ...Map<String, dynamic>.from(response),
        '_offline': true,
        '_cached_at': wrapper['cached_at'],
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('cou_cache_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  String _key(String path) {
    final encoded = base64Url.encode(utf8.encode(path));
    return 'cou_cache_$encoded';
  }
}
