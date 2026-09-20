import 'package:cou_youth_mobile/core/api/api_client.dart';
import 'package:cou_youth_mobile/core/auth/session_store.dart';

class AuthService {
  AuthService(this.api, this.sessionStore);

  final ApiClient api;
  final SessionStore sessionStore;

  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    String deviceName = 'mobile',
  }) async {
    final response = await api.post('/auth/login', {
      'email': email.trim(),
      'password': password,
      'device_name': deviceName,
    });

    await _persistToken(response['token']);
    return response;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String dateOfBirth,
    int? organisationUnitId,
    String? schoolInstitution,
    String? guardianName,
    String? guardianRelationship,
    String? guardianPhone,
    String? guardianEmail,
    bool guardianConfirmed = false,
  }) async {
    final response = await api.post('/register', {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'password_confirmation': password,
      'date_of_birth': dateOfBirth,
      if (organisationUnitId != null)
        'organisation_unit_id': organisationUnitId,
      if (schoolInstitution != null && schoolInstitution.trim().isNotEmpty)
        'school_institution': schoolInstitution.trim(),
      if (guardianName != null && guardianName.trim().isNotEmpty)
        'guardian_name': guardianName.trim(),
      if (guardianRelationship != null &&
          guardianRelationship.trim().isNotEmpty)
        'guardian_relationship': guardianRelationship.trim(),
      if (guardianPhone != null && guardianPhone.trim().isNotEmpty)
        'guardian_phone': guardianPhone.trim(),
      if (guardianEmail != null && guardianEmail.trim().isNotEmpty)
        'guardian_email': guardianEmail.trim(),
      if (guardianName != null || guardianRelationship != null || guardianPhone != null)
        'guardian_confirmed': guardianConfirmed,
    });

    final data = response['data'];
    if (data is Map && data['token'] is String && '${data['token']}'.trim().isNotEmpty) {
      await _persistToken(data['token']);
    }

    return response;
  }

  Future<Map<String, dynamic>> me() async {
    return api.get('/me');
  }

  Future<bool> restoreSession() async {
    final token = await sessionStore.readToken();

    if (token == null || token.trim().isEmpty) {
      api.clearAuthToken();
      return false;
    }

    api.setAuthToken(token);

    try {
      await me();
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await sessionStore.clear();
        api.clearAuthToken();
      }
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await api.post('/auth/logout', <String, dynamic>{});
    } finally {
      api.clearAuthToken();
      await sessionStore.clear();
    }
  }

  Future<void> _persistToken(dynamic token) async {
    if (token is! String || token.trim().isEmpty) {
      throw const ApiException(
        'Authentication succeeded but no access token was returned.',
      );
    }

    api.setAuthToken(token);
    await sessionStore.saveToken(token);
  }
}
