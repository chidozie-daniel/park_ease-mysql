import '../config/api_config.dart';
import '../models/parking_lot.dart';
import '../models/user.dart';
import 'api_service.dart';

class AdminService {
  final _api = ApiService();

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _api.get(ApiConfig.adminDashboard);
    return response['data'] as Map<String, dynamic>;
  }

  Future<List<User>> getUsers() async {
    final response = await _api.get(ApiConfig.adminUsers);
    final rows = response['data'] as List<dynamic>? ?? const [];
    return rows
        .map((row) => User.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    await _api.post(ApiConfig.adminUsers, data);
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _api.put('${ApiConfig.adminUsers}/$id', data);
  }

  Future<void> deleteUser(String id) async {
    await _api.delete('${ApiConfig.adminUsers}/$id');
  }

  Future<List<ParkingLot>> getParkingLots() async {
    final response = await _api.get(ApiConfig.adminParkingLots);
    final rows = response['data'] as List<dynamic>? ?? const [];
    return rows
        .map((row) => ParkingLot.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<ParkingLot> createParkingLot(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.adminParkingLots, data);
    return ParkingLot.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<ParkingLot> updateParkingLot(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _api.put('${ApiConfig.adminParkingLots}/$id', data);
    return ParkingLot.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteParkingLot(String id) async {
    await _api.delete('${ApiConfig.adminParkingLots}/$id');
  }

  Future<List<Map<String, dynamic>>> getBookings() async {
    final response = await _api.get(ApiConfig.adminBookings);
    final rows = response['data'] as List<dynamic>? ?? const [];
    return rows.cast<Map<String, dynamic>>();
  }

  Future<void> updateBookingStatus(String id, String status) async {
    await _api.put('${ApiConfig.adminBookings}/$id/status', {'status': status});
  }

  Future<void> sendNotification({
    required String title,
    required String body,
  }) async {
    await _api.post('/api/v1/admin/notifications', {
      'title': title,
      'body': body,
    });
  }
}
