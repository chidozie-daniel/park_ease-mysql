// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: json['id'] as String,
  userId: json['userId'] as String,
  parkingLotId: json['parkingLotId'] as String,
  parkingSlotId: json['parkingSlotId'] as String?,
  vehicleId: json['vehicleId'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  discountAmount: (json['discountAmount'] as num?)?.toDouble(),
  status:
      $enumDecodeNullable(_$BookingStatusEnumMap, json['status']) ??
      BookingStatus.pending,
  qrCode: json['qrCode'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'parkingLotId': instance.parkingLotId,
  'parkingSlotId': instance.parkingSlotId,
  'vehicleId': instance.vehicleId,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'totalAmount': instance.totalAmount,
  'discountAmount': instance.discountAmount,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'qrCode': instance.qrCode,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.checkedIn: 'checkedIn',
  BookingStatus.checkedOut: 'checkedOut',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.noShow: 'noShow',
};
