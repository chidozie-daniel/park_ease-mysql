import 'package:flutter_test/flutter_test.dart';

import 'package:park_ease_application/models/booking.dart';

Map<String, dynamic> bookingJson(String status) => {
  'id': 'b1',
  'userId': 'u1',
  'parkingLotId': 'l1',
  'parkingSlotId': null,
  'vehicleId': 'v1',
  'startTime': '2026-11-26T10:00:00',
  'endTime': '2026-11-26T12:00:00',
  'totalAmount': 100.0,
  'discountAmount': null,
  'status': status,
  'qrCode': null,
  'createdAt': '2026-11-26T09:00:00',
  'updatedAt': null,
};

Booking bookingWith(BookingStatus status) => Booking(
  id: 'b1',
  userId: 'u1',
  parkingLotId: 'l1',
  vehicleId: 'v1',
  startTime: DateTime(2026, 11, 26, 10),
  endTime: DateTime(2026, 11, 26, 12),
  totalAmount: 100.0,
  status: status,
  createdAt: DateTime(2026, 11, 26, 9),
);

void main() {
  const serverStatuses = <String, BookingStatus>{
    'pending': BookingStatus.pending,
    'confirmed': BookingStatus.confirmed,
    'checked_in': BookingStatus.checkedIn,
    'checked_out': BookingStatus.checkedOut,
    'cancelled': BookingStatus.cancelled,
    'no_show': BookingStatus.noShow,
  };

  group('Booking status JSON contract', () {
    test('decodes every snake_case status returned by the server', () {
      for (final entry in serverStatuses.entries) {
        expect(
          Booking.fromJson(bookingJson(entry.key)).status,
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('encodes every status back to snake_case', () {
      for (final entry in serverStatuses.entries) {
        expect(
          bookingWith(entry.value).json()['status'],
          entry.key,
          reason: entry.key,
        );
      }
    });
  });
}
