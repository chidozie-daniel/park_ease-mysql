import 'package:json_annotation/json_annotation.dart';

part 'vehicle.g.dart';

enum VehicleType { car, bike, scooter, truck }

extension VehicleTypeExtension on VehicleType {
  String get label {
    switch (this) {
      case VehicleType.car:
        return 'Car';
      case VehicleType.bike:
        return 'Bike';
      case VehicleType.scooter:
        return 'Scooter';
      case VehicleType.truck:
        return 'Truck';
    }
  }
}

@JsonSerializable()
class Vehicle {
  final String id;
  final String userId;
  final VehicleType type;
  final String brand;
  final String model;
  final String color;
  final String licensePlate;
  final bool isDefault;
  final DateTime createdAt;

  const Vehicle({
    required this.id,
    required this.userId,
    required this.type,
    required this.brand,
    required this.model,
    required this.color,
    required this.licensePlate,
    this.isDefault = false,
    required this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
  Map<String, dynamic> json() => _$VehicleToJson(this);

  Vehicle copyWith({
    String? id,
    String? userId,
    VehicleType? type,
    String? brand,
    String? model,
    String? color,
    String? licensePlate,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}