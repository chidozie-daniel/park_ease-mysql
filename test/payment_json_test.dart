import 'package:flutter_test/flutter_test.dart';

import 'package:park_ease_application/models/payment.dart';

Map<String, dynamic> paymentJson({
  String status = 'pending',
  String? transactionId,
  String? paidAt,
  Object? gatewayResponse,
}) =>
    {
      'id': 'p1',
      'bookingId': 'b1',
      'userId': 'u1',
      'amount': 200.0,
      'method': 'credit_card',
      'status': status,
      'transactionId': transactionId,
      'paidAt': paidAt,
      'gatewayResponse': gatewayResponse,
    };

void main() {
  group('Payment JSON contract', () {
    test('parses pending payment with null transaction and paidAt', () {
      final payment = Payment.fromJson(paymentJson());

      expect(payment.status, PaymentStatus.pending);
      expect(payment.transactionId, isNull);
      expect(payment.paidAt, isNull);
      expect(payment.gatewayResponse, isNull);
    });

    test('parses gateway response object returned by the server', () {
      final payment = Payment.fromJson(
        paymentJson(gatewayResponse: {
          'status': 'requires_action',
          'paymentMethod': 'pm_1',
        }),
      );

      expect(payment.gatewayResponse?['status'], 'requires_action');
      expect(payment.gatewayResponse?['paymentMethod'], 'pm_1');
    });

    test('parses gateway response stored as a JSON string', () {
      final payment = Payment.fromJson(
        paymentJson(gatewayResponse: '{"error":"card_declined"}'),
      );

      expect(payment.gatewayResponse?['error'], 'card_declined');
    });

    test('parses completed payment timestamp', () {
      final payment = Payment.fromJson(
        paymentJson(
          status: 'completed',
          transactionId: 'txn_1',
          paidAt: '2026-11-26T10:00:00',
        ),
      );

      expect(payment.transactionId, 'txn_1');
      expect(payment.paidAt, DateTime(2026, 11, 26, 10));
      expect(payment.json()['paidAt'], '2026-11-26T10:00:00.000');
    });
  });
}
