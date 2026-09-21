import 'dart:convert';

import 'package:cou_youth_mobile/core/api/api_client.dart';
import 'package:cou_youth_mobile/services/donation_checkout_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('DonationCheckoutService', () {
    test('loads paginated campaigns from Laravel API response', () async {
      final client = ApiClient(
        baseUrl: 'https://example.test/api/v1',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/v1/donation-campaigns');

          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'data': [
                  {'id': 7, 'title': 'Youth Mission'},
                ],
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final service = DonationCheckoutService(api: client);
      final campaigns = await service.campaigns();

      expect(campaigns, hasLength(1));
      expect(campaigns.first['id'], 7);
      expect(campaigns.first['title'], 'Youth Mission');
    });

    test('loads enabled payment gateways', () async {
      final client = ApiClient(
        baseUrl: 'https://example.test/api/v1',
        client: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': 2,
                  'name': 'MTN Mobile Money',
                  'provider': 'mtn_momo',
                  'currency': 'UGX',
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );

      final gateways = await DonationCheckoutService(api: client).gateways();

      expect(gateways, hasLength(1));
      expect(gateways.first['provider'], 'mtn_momo');
    });

    test('sends the donation payload expected by Laravel', () async {
      late Map<String, dynamic> sentBody;

      final client = ApiClient(
        baseUrl: 'https://example.test/api/v1',
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/v1/donations');
          sentBody = Map<String, dynamic>.from(jsonDecode(request.body) as Map);

          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'donation': {'id': 19, 'status': 'pending'},
                'payment': {'status': 'pending'},
              },
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final response = await DonationCheckoutService(api: client).donate(
        campaignId: 5,
        gatewayId: 2,
        amount: 25000,
        name: 'Youth Member',
        email: 'youth@example.com',
        phone: '0772123456',
      );

      expect(sentBody['campaign_id'], 5);
      expect(sentBody['payment_gateway_id'], 2);
      expect(sentBody['amount'], 25000);
      expect(sentBody['currency'], 'UGX');
      expect(sentBody['donor_phone'], '0772123456');
      expect(response['data']['donation']['id'], 19);
    });

    test('unwraps donation status and verification payloads', () async {
      var requestCount = 0;
      final client = ApiClient(
        baseUrl: 'https://example.test/api/v1',
        client: MockClient((request) async {
          requestCount++;
          final isVerify = request.url.path.endsWith('/verify');

          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': 19,
                'status': isVerify ? 'successful' : 'pending',
                'receipt_number': isVerify ? 'COU-RCP-TEST' : null,
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final service = DonationCheckoutService(api: client);
      final status = await service.donationStatus(19);
      final verified = await service.verifyDonation(19);

      expect(status['status'], 'pending');
      expect(verified['status'], 'successful');
      expect(verified['receipt_number'], 'COU-RCP-TEST');
      expect(requestCount, 2);
    });

    test('loads a successful donation receipt', () async {
      final client = ApiClient(
        baseUrl: 'https://example.test/api/v1',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/v1/donations/19/receipt');

          return http.Response(
            jsonEncode({
              'receipt_number': 'COU-RCP-TEST',
              'reference': 'reference-19',
              'amount': '25000.00',
              'currency': 'UGX',
              'donor_name': 'Youth Member',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final receipt = await DonationCheckoutService(api: client).receipt(19);

      expect(receipt['receipt_number'], 'COU-RCP-TEST');
      expect(receipt['currency'], 'UGX');
      expect(receipt['amount'], '25000.00');
    });
  });
}
