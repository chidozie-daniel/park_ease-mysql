// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) => Vehicle(
  id: json['id'] as String,
  userId: json['userId'] as String,
  type: $enumDecode(_$VehicleTypeEnumMap, json['type']),
  brand: json['brand'] as String,
  model: json['model'] as String,
  color: json['color'] as String,
  licensePlate: json['licensePlate'] as String,
  isDefault: json['isDefault'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'type': _$VehicleTypeEnumMap[instance.type]!,
  'brand': instance.brand,
  'model': instance.model,
  'color': instance.color,
  'licensePlate': instance.licensePlate,
  'isDefault': instance.isDefault,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$VehicleTypeEnumMap = {
  VehicleType.car: 'car',
  VehicleType.bike: 'bike',
  VehicleType.scooter: 'scooter',
  VehicleType.truck: 'truck',
};
