import '../core/api/api_client.dart';
import '../core/api/api_config.dart';

class DonationCheckoutService {
  DonationCheckoutService({ApiClient? api}) : api = api ?? ApiConfig.client;

  final ApiClient api;

  Future<List<Map<String, dynamic>>> campaigns() async {
    final response = await api.get('/donation-campaigns');
    final raw = response['data'];

    if (raw is Map && raw['data'] is List) {
      return (raw['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return const <Map<String, dynamic>>[];
  }

  Future<List<Map<String, dynamic>>> gateways() async {
    final response = await api.get('/payment-gateways');
    final raw = response['data'];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return const <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> donate({
    int? campaignId,
    required int gatewayId,
    required double amount,
    String currency = 'UGX',
    String? name,
    String? email,
    String? phone,
    bool anonymous = false,
  }) {
    return api.post('/donations', {
      if (campaignId != null) 'campaign_id': campaignId,
      'payment_gateway_id': gatewayId,
      'amount': amount,
      'currency': currency,
      'is_anonymous': anonymous,
      if (name != null && name.trim().isNotEmpty) 'donor_name': name.trim(),
      if (email != null && email.trim().isNotEmpty) 'donor_email': email.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'donor_phone': phone.trim(),
    });
  }
}
