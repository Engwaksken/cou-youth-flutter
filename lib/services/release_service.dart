import 'dart:convert';
import 'package:http/http.dart' as http;

class ReleaseInfo {
  final String version;
  final String build;
  final String minimumMobileVersion;
  final String? maintenanceMessage;

  const ReleaseInfo({
    required this.version,
    required this.build,
    required this.minimumMobileVersion,
    this.maintenanceMessage,
  });

  factory ReleaseInfo.fromJson(Map<String, dynamic> json) => ReleaseInfo(
        version: '${json['version'] ?? ''}',
        build: '${json['build'] ?? ''}',
        minimumMobileVersion: '${json['minimum_mobile_version'] ?? ''}',
        maintenanceMessage: json['maintenance_message']?.toString(),
      );
}

class ReleaseService {
  final String baseUrl;
  const ReleaseService(this.baseUrl);

  Future<ReleaseInfo> fetch() async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/release'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Release information is temporarily unavailable.');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return ReleaseInfo.fromJson(body['data'] as Map<String, dynamic>);
  }
}
