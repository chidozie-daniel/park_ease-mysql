import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../models/parking_lot.dart';
import '../../services/api_service.dart';
import '../../services/parking_service.dart';
import '../../widgets/loading_indicator.dart';

class NavigateParkingScreen extends StatefulWidget {
  final String parkingLotId;

  const NavigateParkingScreen({super.key, required this.parkingLotId});

  @override
  State<NavigateParkingScreen> createState() => _NavigateParkingScreenState();
}

class _NavigateParkingScreenState extends State<NavigateParkingScreen> {
  final _parking = ParkingService();
  final _mapController = MapController();
  late Future<ParkingLot> _lot;
  ll.LatLng? _userLocation;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _lot = _parking.getParkingLot(widget.parkingLotId);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _locateMe(ParkingLot lot) async {
    setState(() => _isLocating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Turn on location services to show your position.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Allow location access to show your position.');
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final current = ll.LatLng(position.latitude, position.longitude);
      setState(() => _userLocation = current);
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: [current, ll.LatLng(lot.latitude, lot.longitude)],
          padding: const EdgeInsets.all(72),
          maxZoom: 15,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is StateError
                ? error.message
                : 'Could not get your location. Check location permissions.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _copyDirections(ParkingLot lot) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '${lot.name}\n${lot.address}\n'
            '${lot.latitude}, ${lot.longitude}',
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address and coordinates copied for your maps app.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ParkingLot>(
      future: _lot,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: const Text('Navigate to Parking')),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: LoadingIndicator())
              : snapshot.hasError
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ApiService.describeError(snapshot.error!),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: () => setState(
                            () => _lot = _parking.getParkingLot(
                              widget.parkingLotId,
                            ),
                          ),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _navigationView(snapshot.data!),
        );
      },
    );
  }

  Widget _navigationView(ParkingLot lot) {
    final destination = ll.LatLng(lot.latitude, lot.longitude);
    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: destination, initialZoom: 14),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.park_ease_application',
              ),
              if (_userLocation != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_userLocation!, destination],
                      color: const Color(0xFF126E63),
                      strokeWidth: 4,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: destination,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.local_parking_rounded,
                      color: Color(0xFF126E63),
                      size: 40,
                    ),
                  ),
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  lot.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(lot.address),
                const SizedBox(height: 12),
                const Text(
                  'Turn-by-turn directions are provided by your installed maps app.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _copyDirections(lot),
                        icon: const Icon(Icons.directions_rounded),
                        label: const Text('Directions'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLocating ? null : () => _locateMe(lot),
                        icon: _isLocating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location_rounded),
                        label: const Text('Show My Location'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
