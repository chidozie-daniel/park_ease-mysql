import 'package:json_annotation/json_annotation.dart';

part 'parking_slot.g.dart';

enum SlotStatus { available, occupied, reserved, maintenance }

extension SlotStatusExtension on SlotStatus {
  String get label {
    switch (this) {
      case SlotStatus.available:
        return 'Available';
      case SlotStatus.occupied:
        return 'Occupied';
      case SlotStatus.reserved:
        return 'Reserved';
      case SlotStatus.maintenance:
        return 'Maintenance';
    }
  }
}

enum SlotType { regular, ev, handicap, premium, motorcycle }

extension SlotTypeExtension on SlotType {
  String get label {
    switch (this) {
      case SlotType.regular:
        return 'Regular';
      case SlotType.ev:
        return 'EV Charging';
      case SlotType.handicap:
        return 'Handicap';
      case SlotType.premium:
        return 'Premium';
      case SlotType.motorcycle:
        return 'Motorcycle';
    }
  }
}

@JsonSerializable()
class ParkingSlot {
  final String id;
  final String parkingLotId;
  final String slotNumber;
  final SlotType type;
  final SlotStatus status;
  final double? priceMultiplier;
  final DateTime createdAt;

  const ParkingSlot({
    required this.id,
    required this.parkingLotId,
    required this.slotNumber,
    required this.type,
    required this.status,
    this.priceMultiplier,
    required this.createdAt,
  });

  factory ParkingSlot.fromJson(Map<String, dynamic> json) =>
      _$ParkingSlotFromJson(json);
  Map<String, dynamic> json() => _$ParkingSlotToJson(this);
}