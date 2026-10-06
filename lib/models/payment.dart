import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

enum PaymentMethod { creditCard, debitCard, upi, wallet, netBanking, cash }

extension PaymentMethodExtension on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.netBanking:
        return 'Net Banking';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }
}

enum PaymentStatus { pending, completed, failed, refunded }

extension PaymentStatusExtension on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}

@JsonSerializable()
class Payment {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String transactionId;
  final DateTime paidAt;
  final String? gatewayResponse;

  const Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    required this.transactionId,
    required this.paidAt,
    this.gatewayResponse,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> json() => _$PaymentToJson(this);
}