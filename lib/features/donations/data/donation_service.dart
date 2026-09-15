import '../../../core/api/api_client.dart';

class DonationService {
  DonationService(this.api);
  final ApiClient api;

  Future<List<dynamic>> campaigns() async {
    final response = await api.get('/api/v1/donation-campaigns');
    return response['data']['data'] as List<dynamic>;
  }

  Future<List<dynamic>> gateways() async {
    final response = await api.get('/api/v1/payment-gateways');
    return response['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> donate({
    int? campaignId,
    required int gatewayId,
    required double amount,
    String currency = 'UGX',
    bool anonymous = false,
  }) async {
    final response = await api.post('/api/v1/donations', {
      'campaign_id': campaignId,
      'payment_gateway_id': gatewayId,
      'amount': amount,
      'currency': currency,
      'is_anonymous': anonymous,
    });
    return Map<String, dynamic>.from(response['data']);
  }
}
