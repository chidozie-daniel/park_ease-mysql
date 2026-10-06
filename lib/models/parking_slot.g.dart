// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingSlot _$ParkingSlotFromJson(Map<String, dynamic> json) => ParkingSlot(
  id: json['id'] as String,
  parkingLotId: json['parkingLotId'] as String,
  slotNumber: json['slotNumber'] as String,
  type: $enumDecode(_$SlotTypeEnumMap, json['type']),
  status: $enumDecode(_$SlotStatusEnumMap, json['status']),
  priceMultiplier: (json['priceMultiplier'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ParkingSlotToJson(ParkingSlot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parkingLotId': instance.parkingLotId,
      'slotNumber': instance.slotNumber,
      'type': _$SlotTypeEnumMap[instance.type]!,
      'status': _$SlotStatusEnumMap[instance.status]!,
      'priceMultiplier': instance.priceMultiplier,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$SlotTypeEnumMap = {
  SlotType.regular: 'regular',
  SlotType.ev: 'ev',
  SlotType.handicap: 'handicap',
  SlotType.premium: 'premium',
  SlotType.motorcycle: 'motorcycle',
};

const _$SlotStatusEnumMap = {
  SlotStatus.available: 'available',
  SlotStatus.occupied: 'occupied',
  SlotStatus.reserved: 'reserved',
  SlotStatus.maintenance: 'maintenance',
};
