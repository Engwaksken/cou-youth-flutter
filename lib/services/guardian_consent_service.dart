import '../core/api/api_client.dart';
import '../core/api/api_config.dart';

class GuardianConsentService {
  GuardianConsentService({ApiClient? api}) : api = api ?? ApiConfig.client;

  final ApiClient api;

  Future<Map<String, dynamic>> status() => api.get('/guardian-consent');

  Future<Map<String, dynamic>> submit({
    required String guardianName,
    required String relationship,
    required String guardianPhone,
    String? guardianEmail,
  }) {
    return api.post('/guardian-consent', {
      'guardian_name': guardianName.trim(),
      'relationship': relationship.trim(),
      'guardian_phone': guardianPhone.trim(),
      if (guardianEmail != null && guardianEmail.trim().isNotEmpty)
        'guardian_email': guardianEmail.trim(),
      'confirmed_by_guardian': true,
    });
  }
}
