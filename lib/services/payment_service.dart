import '../core/api/api_client.dart';
class PaymentService { PaymentService(this.api); final ApiClient api; Future<dynamic> gateways()=>api.get('/payment-gateways'); Future<dynamic> receipt(int donationId)=>api.get('/donations/$donationId/receipt'); }
