import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.data,
  });

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
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  String? authToken;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (authToken != null && authToken!.trim().isNotEmpty)
          'Authorization': 'Bearer ${authToken!.trim()}',
      };

  String _buildUrl(String path) {
    final cleanBaseUrl =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

    final cleanPath = path.startsWith('/') ? path : '/$path';

    return '$cleanBaseUrl$cleanPath';
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _client.get(
      Uri.parse(_buildUrl(path)),
      headers: _headers,
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      Uri.parse(_buildUrl(path)),
      headers: _headers,
      body: jsonEncode(body),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.put(
      Uri.parse(_buildUrl(path)),
      headers: _headers,
      body: jsonEncode(body),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.patch(
      Uri.parse(_buildUrl(path)),
      headers: _headers,
      body: jsonEncode(body),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final request = http.Request(
      'DELETE',
      Uri.parse(_buildUrl(path)),
    );

    request.headers.addAll(_headers);

    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.trim().isEmpty) {
      if (_isSuccessful(response.statusCode)) {
        return <String, dynamic>{};
      }

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
      data = <String, dynamic>{
        'data': decoded,
      };
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

  bool _isSuccessful(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  String _extractMessage(Map<String, dynamic> data) {
    final message = data['message'];

    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    final errors = data['errors'];

    if (errors is Map && errors.isNotEmpty) {
      final firstError = errors.values.first;

      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }

      if (firstError != null) {
        return firstError.toString();
      }
    }

    return 'Something went wrong. Please try again.';
  }

  void setAuthToken(String? token) {
    authToken = token;
  }

  void clearAuthToken() {
    authToken = null;
  }

  void dispose() {
    _client.close();
  }
}