// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_lot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingLot _$ParkingLotFromJson(Map<String, dynamic> json) => ParkingLot(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  type: $enumDecode(_$ParkingLotTypeEnumMap, json['type']),
  totalSlots: (json['totalSlots'] as num).toInt(),
  availableSlots: (json['availableSlots'] as num).toInt(),
  hourlyRate: (json['hourlyRate'] as num).toDouble(),
  dailyRate: (json['dailyRate'] as num?)?.toDouble(),
  description: json['description'] as String?,
  amenities:
      (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  status:
      $enumDecodeNullable(_$ParkingStatusEnumMap, json['status']) ??
      ParkingStatus.available,
  imageUrl: json['imageUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ParkingLotToJson(ParkingLot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'type': _$ParkingLotTypeEnumMap[instance.type]!,
      'totalSlots': instance.totalSlots,
      'availableSlots': instance.availableSlots,
      'hourlyRate': instance.hourlyRate,
      'dailyRate': instance.dailyRate,
      'description': instance.description,
      'amenities': instance.amenities,
      'status': _$ParkingStatusEnumMap[instance.status]!,
      'imageUrl': instance.imageUrl,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ParkingLotTypeEnumMap = {
  ParkingLotType.indoor: 'indoor',
  ParkingLotType.outdoor: 'outdoor',
  ParkingLotType.covered: 'covered',
  ParkingLotType.underground: 'underground',
};

const _$ParkingStatusEnumMap = {
  ParkingStatus.available: 'available',
  ParkingStatus.full: 'full',
  ParkingStatus.closed: 'closed',
};
