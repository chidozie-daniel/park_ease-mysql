// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: json['id'] as String,
  bookingId: json['bookingId'] as String,
  userId: json['userId'] as String,
  amount: (json['amount'] as num).toDouble(),
  method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
  status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
  transactionId: json['transactionId'] as String,
  paidAt: DateTime.parse(json['paidAt'] as String),
  gatewayResponse: json['gatewayResponse'] as String?,
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'bookingId': instance.bookingId,
  'userId': instance.userId,
  'amount': instance.amount,
  'method': _$PaymentMethodEnumMap[instance.method]!,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'transactionId': instance.transactionId,
  'paidAt': instance.paidAt.toIso8601String(),
  'gatewayResponse': instance.gatewayResponse,
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.creditCard: 'creditCard',
  PaymentMethod.debitCard: 'debitCard',
  PaymentMethod.upi: 'upi',
  PaymentMethod.wallet: 'wallet',
  PaymentMethod.netBanking: 'netBanking',
  PaymentMethod.cash: 'cash',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.completed: 'completed',
  PaymentStatus.failed: 'failed',
  PaymentStatus.refunded: 'refunded',
};
