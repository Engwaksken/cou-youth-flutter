import '../core/api/api_client.dart';
class DonationCheckoutService {
  DonationCheckoutService(this.api); final ApiClient api;
  Future<dynamic> campaigns() => api.get('/donation-campaigns');
  Future<dynamic> gateways() => api.get('/payment-gateways');
  Future<dynamic> donate({int? campaignId, required int gatewayId, required double amount, String currency='UGX', String? name, String? email, String? phone, bool anonymous=false}) => api.post('/donations', {
    if(campaignId!=null)'campaign_id':campaignId,'payment_gateway_id':gatewayId,'amount':amount,'currency':currency,'is_anonymous':anonymous,
    if(name!=null)'donor_name':name,if(email!=null)'donor_email':email,if(phone!=null)'donor_phone':phone,
  });
}
