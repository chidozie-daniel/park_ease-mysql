import 'api_service.dart';
import '../config/api_config.dart';
import '../models/payment.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final _api = ApiService();

  Future<Payment> processPayment({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
    String? gatewayToken,
  }) async {
    final response = await _api.post(ApiConfig.payments, {
      'bookingId': bookingId,
      'amount': amount,
      'method': method.name,
      'gatewayToken': gatewayToken,
    });
    return Payment.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<Payment>> getPaymentHistory() async {
    final response = await _api.get(ApiConfig.paymentsHistory);
    final list = response['data'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => Payment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Payment> getPayment(String id) async {
    final response = await _api.get('${ApiConfig.payments}/$id');
    return Payment.fromJson(response['data'] as Map<String, dynamic>);
  }
}