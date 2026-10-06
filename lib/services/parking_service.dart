import 'api_service.dart';
import '../config/api_config.dart';
import '../models/parking_lot.dart';
import '../models/parking_slot.dart';

class ParkingService {
  static final ParkingService _instance = ParkingService._internal();
  factory ParkingService() => _instance;
  ParkingService._internal();

  final _api = ApiService();

  List<ParkingLot> _parseLots(Map<String, dynamic> response) {
    final list = response['data'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => ParkingLot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ParkingLot>> getNearbyParkingLots(
      double latitude, double longitude, double radiusKm) async {
    final uri = Uri.parse(ApiConfig.baseUrl).replace(
      path: ApiConfig.parkingSearch,
      queryParameters: {
        'lat': '$latitude',
        'lng': '$longitude',
        'radius': '$radiusKm',
      },
    );
    return _parseLots(await _api.getUri(uri));
  }

  Future<ParkingLot> getParkingLot(String id) async {
    final response = await _api.get('${ApiConfig.parkingLots}/$id');
    return ParkingLot.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<ParkingSlot>> getParkingSlots(String parkingLotId) async {
    final uri = Uri.parse(ApiConfig.baseUrl).replace(
      path: ApiConfig.parkingSlots,
      queryParameters: {'parkingLotId': parkingLotId},
    );
    return _parseSlots(await _api.getUri(uri));
  }

  List<ParkingSlot> _parseSlots(Map<String, dynamic> response) {
    final list = response['data'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => ParkingSlot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ParkingLot>> searchParking(String query) async {
    final uri = Uri.parse(ApiConfig.baseUrl).replace(
      path: ApiConfig.parkingSearch,
      queryParameters: {'q': query},
    );
    return _parseLots(await _api.getUri(uri));
  }

  Future<List<ParkingLot>> getAllLots() async {
    final response = await _api.get(ApiConfig.parkingSearch);
    return _parseLots(response);
  }
}