import '../core/api/api_client.dart';
class AuthRecoveryService {
  AuthRecoveryService(this.api); final ApiClient api;
  Future<void> requestPasswordReset(String email) async => api.post('/auth/password/request', {'email': email});
  Future<void> resetPassword(String email,String code,String password) async => api.post('/auth/password/reset', {'email':email,'code':code,'password':password,'password_confirmation':password});
  Future<void> requestOtp(String email) async => api.post('/auth/otp/request', {'email':email});
  Future<Map<String,dynamic>> verifyOtp(String email,String code) async => await api.post('/auth/otp/verify', {'email':email,'code':code}) as Map<String,dynamic>;
  Future<void> requestEmailVerification() async => api.post('/auth/email/request', {});
  Future<void> verifyEmail(String code) async => api.post('/auth/email/verify', {'code':code});
}
