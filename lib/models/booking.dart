import 'package:json_annotation/json_annotation.dart';
part 'booking.g.dart';

enum BookingStatus { pending, confirmed, checkedIn, checkedOut, cancelled, noShow }

extension BookingStatusExtension on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.checkedIn:
        return 'Checked In';
      case BookingStatus.checkedOut:
        return 'Checked Out';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.noShow:
        return 'No Show';
    }
  }
}

@JsonSerializable()
class Booking {
  final String id;
  final String userId;
  final String parkingLotId;
  final String? parkingSlotId;
  final String vehicleId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalAmount;
  final double? discountAmount;
  final BookingStatus status;
  final String? qrCode;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.parkingLotId,
    this.parkingSlotId,
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    this.discountAmount,
    this.status = BookingStatus.pending,
    this.qrCode,
    required this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
  Map<String, dynamic> json() => _$BookingToJson(this);

  Duration get duration => endTime.difference(startTime);
}