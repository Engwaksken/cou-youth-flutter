import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../services/connectivity_service.dart';
import '../../services/offline_cache_service.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.data});

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? client,
    ConnectivityService? connectivity,
    OfflineCacheService? cache,
  })  : _client = client ?? http.Client(),
        _connectivity = connectivity,
        _cache = cache;

  final String baseUrl;
  final http.Client _client;
  final ConnectivityService? _connectivity;
  final OfflineCacheService? _cache;

  String? authToken;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (authToken != null && authToken!.trim().isNotEmpty)
          'Authorization': 'Bearer ${authToken!.trim()}',
      };

  String _buildUrl(String path) {
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$cleanBaseUrl$cleanPath';
  }

  Future<Map<String, dynamic>> get(String path) async {
    final connectivity = _connectivity;
    final cache = _cache;

    if (connectivity != null && !await connectivity.isOnline) {
      final cached = await cache?.read(path);
      if (cached != null) return cached;
      throw const ApiException(
        'You are offline. Connect to mobile data or Wi-Fi and try again.',
      );
    }

    try {
      final response = await _client
          .get(Uri.parse(_buildUrl(path)), headers: _headers)
          .timeout(const Duration(seconds: 20));
      final decoded = _decode(response);
      await cache?.write(path, decoded);
      return decoded;
    } on TimeoutException {
      final cached = await cache?.read(path);
      if (cached != null) return cached;
      throw const ApiException(
        'The connection timed out. Check your internet connection and try again.',
      );
    } on http.ClientException {
      final cached = await cache?.read(path);
      if (cached != null) return cached;
      throw const ApiException(
        'No internet connection is available. Connect to mobile data or Wi-Fi.',
      );
    }
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    await _requireOnline();
    final response = await _client
        .post(
          Uri.parse(_buildUrl(path)),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
    return _decode(response);
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    await _requireOnline();
    final response = await _client
        .put(
          Uri.parse(_buildUrl(path)),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
    return _decode(response);
  }

  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    await _requireOnline();
    final response = await _client
        .patch(
          Uri.parse(_buildUrl(path)),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
    return _decode(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    await _requireOnline();
    final request = http.Request('DELETE', Uri.parse(_buildUrl(path)));
    request.headers.addAll(_headers);
    if (body != null) request.body = jsonEncode(body);

    final streamedResponse = await _client.send(request).timeout(
          const Duration(seconds: 30),
        );
    final response = await http.Response.fromStream(streamedResponse);
    return _decode(response);
  }

  Future<void> _requireOnline() async {
    final connectivity = _connectivity;
    if (connectivity == null) return;

    if (!await connectivity.isOnline) {
      throw const ApiException(
        'This action needs internet access. Connect to mobile data or Wi-Fi and try again.',
      );
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.trim().isEmpty) {
      if (_isSuccessful(response.statusCode)) return <String, dynamic>{};
      throw ApiException(
        'Something went wrong. Please try again.',
        statusCode: response.statusCode,
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw ApiException(
        'The server returned an invalid response.',
        statusCode: response.statusCode,
      );
    }

    final Map<String, dynamic> data;
    if (decoded is Map<String, dynamic>) {
      data = decoded;
    } else if (decoded is Map) {
      data = Map<String, dynamic>.from(decoded);
    } else {
      data = <String, dynamic>{'data': decoded};
    }

    if (!_isSuccessful(response.statusCode)) {
      throw ApiException(
        _extractMessage(data),
        statusCode: response.statusCode,
        data: data,
      );
    }

    return data;
  }

  bool _isSuccessful(int statusCode) => statusCode >= 200 && statusCode < 300;

  String _extractMessage(Map<String, dynamic> data) {
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) return message;

    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
      if (firstError != null) return firstError.toString();
    }

    return 'Something went wrong. Please try again.';
  }

  void setAuthToken(String? token) => authToken = token;
  void clearAuthToken() => authToken = null;
  void dispose() => _client.close();
}
