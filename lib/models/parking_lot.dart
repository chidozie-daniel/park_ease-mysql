import 'package:json_annotation/json_annotation.dart';

part 'parking_lot.g.dart';

enum ParkingLotType { indoor, outdoor, covered, underground }

extension ParkingLotTypeExtension on ParkingLotType {
  String get label {
    switch (this) {
      case ParkingLotType.indoor:
        return 'Indoor';
      case ParkingLotType.outdoor:
        return 'Outdoor';
      case ParkingLotType.covered:
        return 'Covered';
      case ParkingLotType.underground:
        return 'Underground';
    }
  }
}

enum ParkingStatus { available, full, closed }

extension ParkingStatusExtension on ParkingStatus {
  String get label {
    switch (this) {
      case ParkingStatus.available:
        return 'Available';
      case ParkingStatus.full:
        return 'Full';
      case ParkingStatus.closed:
        return 'Closed';
    }
  }
}

@JsonSerializable()
class ParkingLot {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final ParkingLotType type;
  final int totalSlots;
  final int availableSlots;
  final double hourlyRate;
  final double? dailyRate;
  final String? description;
  final List<String> amenities;
  final ParkingStatus status;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.totalSlots,
    required this.availableSlots,
    required this.hourlyRate,
    this.dailyRate,
    this.description,
    this.amenities = const [],
    this.status = ParkingStatus.available,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory ParkingLot.fromJson(Map<String, dynamic> json) =>
      _$ParkingLotFromJson(json);
  Map<String, dynamic> json() => _$ParkingLotToJson(this);

  double get occupancyRate =>
      totalSlots > 0 ? availableSlots / totalSlots : 0.0;
}