import 'api_service.dart';
import '../config/api_config.dart';
import '../models/booking.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final _api = ApiService();

  Future<Booking> createBooking({
    required String parkingLotId,
    String? parkingSlotId,
    required String vehicleId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final response = await _api.post(ApiConfig.bookings, {
      'parkingLotId': parkingLotId,
      'parkingSlotId': parkingSlotId,
      'vehicleId': vehicleId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    });
    return Booking.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Booking> getBooking(String id) async {
    final response = await _api.get('${ApiConfig.bookings}/$id');
    return Booking.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<Booking>> getMyBookings() async {
    final response = await _api.get(ApiConfig.bookingsHistory);
    final list = response['data'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Booking> cancelBooking(String id) async {
    final response = await _api.put('${ApiConfig.bookings}/$id/cancel', {});
    return Booking.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Booking> checkIn(String id, String qrCode) async {
    final response = await _api.post('${ApiConfig.bookings}/$id/checkin', {
      'qrCode': qrCode,
    });
    return Booking.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Booking> checkOut(String id) async {
    final response = await _api.post('${ApiConfig.bookings}/$id/checkout', {});
    return Booking.fromJson(response['data'] as Map<String, dynamic>);
  }
}