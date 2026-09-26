import '../core/api/api_client.dart';
import '../core/api/api_config.dart';

class DonationCheckoutService {
  DonationCheckoutService({ApiClient? api}) : api = api ?? ApiConfig.client;

  final ApiClient api;

  List<Map<String, dynamic>> _extractList(
    Map<String, dynamic> response, {
    List<String> nestedKeys = const [],
  }) {
    dynamic raw = response['data'] ?? response;

    if (raw is Map) {
      for (final key in nestedKeys) {
        final candidate = raw[key];
        if (candidate is List) {
          raw = candidate;
          break;
        }
      }

      if (raw is Map && raw['data'] is List) {
        raw = raw['data'];
      }
    }

    if (raw is! List) return const <Map<String, dynamic>>[];

    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<List<Map<String, dynamic>>> campaigns() async {
    final response = await api.get('/donation-campaigns');
    return _extractList(response, nestedKeys: const ['campaigns']);
  }

  Future<List<Map<String, dynamic>>> gateways() async {
    final response = await api.get('/payment-gateways');
    return _extractList(
      response,
      nestedKeys: const ['gateways', 'payment_gateways'],
    );
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
      if (email != null && email.trim().isNotEmpty)
        'donor_email': email.trim(),
      if (phone != null && phone.trim().isNotEmpty)
        'donor_phone': phone.trim(),
    });
  }

  Future<Map<String, dynamic>> donationStatus(int donationId) async {
    final response = await api.get('/donations/$donationId');
    final raw = response['data'];

    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);

    return const <String, dynamic>{};
  }

  Future<Map<String, dynamic>> verifyDonation(int donationId) async {
    final response = await api.post('/donations/$donationId/verify', const {});
    final raw = response['data'];

    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);

    return const <String, dynamic>{};
  }

  Future<Map<String, dynamic>> receipt(int donationId) async {
    final response = await api.get('/donations/$donationId/receipt');
    return Map<String, dynamic>.from(response);
  }
}
