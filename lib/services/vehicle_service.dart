import 'api_service.dart';
import '../config/api_config.dart';
import '../models/vehicle.dart';

class VehicleService {
  static final VehicleService _instance = VehicleService._internal();
  factory VehicleService() => _instance;
  VehicleService._internal();

  final _api = ApiService();

  Future<List<Vehicle>> getMyVehicles() async {
    final response = await _api.get(ApiConfig.vehicles);
    final list = response['data'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Vehicle> addVehicle({
    required VehicleType type,
    required String brand,
    required String model,
    required String color,
    required String licensePlate,
    bool isDefault = false,
  }) async {
    final response = await _api.post(ApiConfig.vehicles, {
      'type': type.name,
      'brand': brand,
      'model': model,
      'color': color,
      'licensePlate': licensePlate,
      'isDefault': isDefault,
    });
    return Vehicle.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Vehicle> updateVehicle(String id, Map<String, dynamic> data) async {
    final response = await _api.put('${ApiConfig.vehicles}/$id', data);
    return Vehicle.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteVehicle(String id) async {
    await _api.delete('${ApiConfig.vehicles}/$id');
  }

  Future<void> setDefault(String id) async {
    await _api.put('${ApiConfig.vehicles}/$id/default', {});
  }
}