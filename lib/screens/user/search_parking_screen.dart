import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../app/routes.dart';
import '../../models/parking_lot.dart';
import '../../services/api_service.dart';
import '../../services/parking_service.dart';
import '../../utils/utils.dart';
import '../../widgets/loading_indicator.dart';

class SearchParkingScreen extends StatefulWidget {
  const SearchParkingScreen({super.key});

  @override
  State<SearchParkingScreen> createState() => _SearchParkingScreenState();
}

class _SearchParkingScreenState extends State<SearchParkingScreen> {
  static const Color _accent = Color(0xFF9894BD);
  static const double _defaultZoom = 14.0;

  final _parking = ParkingService();
  final _controller = TextEditingController();
  final _mapController = MapController();

  List<ParkingLot> _results = const [];
  bool _loading = false;
  bool _hasSearched = false;
  String? _error;
  ll.LatLng? _myLocation;
  final _distance = ll.Distance();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _controller.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    if (mounted) setState(() => _loading = value);
  }

  Future<void> _determinePosition() async {
    final position = await _getCurrentPosition();
    if (position == null || !mounted) return;

    setState(() {
      _myLocation = ll.LatLng(position.latitude, position.longitude);
    });

    if (!mounted) return;
    final query = _controller.text.trim();
    if (query.isEmpty) {
      _searchNearby(_myLocation!.latitude, _myLocation!.longitude);
    } else {
      _mapController.move(_myLocation!, _defaultZoom);
    }
  }

  Future<Position?> _getCurrentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission denied. Enable it in settings to show '
              'nearby parking on the map.',
            ),
          ),
        );
      }
      return null;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Enable them to show nearby parking.',
            ),
          ),
        );
      }
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    FocusScope.of(context).unfocus();

    if (_myLocation case final ll.LatLng pos) {
      _searchNearby(pos.latitude, pos.longitude);
    } else if (query.isNotEmpty) {
      _searchByText(query);
    } else {
      _loadAll();
    }
  }

  Future<void> _searchNearby(double latitude, double longitude) async {
    _setLoading(true);
    _error = null;
    try {
      final lots = await _parking.getNearbyParkingLots(latitude, longitude, 10);
      if (!mounted) return;
      setState(() {
        _results = lots;
        _hasSearched = true;
        _loading = false;
      });
      _fitBounds(lots);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _hasSearched = true;
        _loading = false;
        _error = ApiService.describeError(e);
      });
    }
  }

  Future<void> _searchByText(String query) async {
    _setLoading(true);
    _error = null;
    try {
      final lots = await _parking.searchParking(query);
      if (!mounted) return;
      setState(() {
        _results = lots;
        _hasSearched = true;
        _loading = false;
      });
      _fitBounds(lots);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _hasSearched = true;
        _loading = false;
        _error = ApiService.describeError(e);
      });
    }
  }

  Future<void> _loadAll() async {
    _setLoading(true);
    _error = null;
    try {
      final lots = await _parking.getAllLots();
      if (!mounted) return;
      setState(() {
        _results = lots;
        _hasSearched = false;
        _loading = false;
      });
      _fitBounds(lots);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _hasSearched = true;
        _loading = false;
        _error = ApiService.describeError(e);
      });
    }
  }

  void _fitBounds(List<ParkingLot> lots) {
    if (lots.isEmpty) {
      if (_myLocation != null) _mapController.move(_myLocation!, _defaultZoom);
      return;
    }
    final points = <ll.LatLng>[...lots.map(_latLng)];
    if (_myLocation != null) points.add(_myLocation!);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(64),
        maxZoom: _defaultZoom,
        minZoom: 4,
      ),
    );
  }

  ll.LatLng _latLng(ParkingLot lot) =>
      ll.LatLng(lot.latitude, lot.longitude);

  String _formattedDistance(ParkingLot lot) {
    final me = _myLocation;
    if (me == null) return '';
    final km = _distance.as(ll.LengthUnit.Kilometer, me, _latLng(lot));
    return AppHelpers.formatDistance(km);
  }

  void _pickLot(ParkingLot lot) {
    Navigator.pushNamed(
      context,
      AppRoutes.parkingDetails,
      arguments: {'parkingLotId': lot.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          if (_loading) const Positioned.fill(child: LoadingIndicator()),
          _buildSearchBar(),
          _buildMyLocationButton(),
          _buildResultsSheet(),
          if (_error != null && _results.isEmpty)
            _ErrorBanner(message: _error!),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final center = _myLocation ?? const ll.LatLng(6.5053, 3.3792);
    final markers = <Marker>[
      if (_myLocation != null)
        Marker(
          point: _myLocation!,
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: const Icon(Icons.my_location, size: 28, color: Colors.blue),
        ),
      for (final lot in _results)
        Marker(
          point: _latLng(lot),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () => _pickLot(lot),
            child: Icon(
              Icons.local_parking_rounded,
              size: 28,
              color: lot.status == ParkingStatus.available
                  ? const Color(0xFF126E63)
                  : Colors.redAccent,
            ),
          ),
        ),
    ];

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: _defaultZoom,
        minZoom: 4,
        maxZoom: 18,
        onTap: (_, lla) => FocusScope.of(context).unfocus(),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        RichAttributionWidget(
          alignment: AttributionAlignment.bottomRight,
          attributions: [
            TextSourceAttribution(
              '© OpenStreetMap contributors',
            ),
          ],
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent, width: 2),
            ),
            prefixIcon:
                const Icon(Icons.search_rounded, color: _accent, size: 22),
            suffixIcon: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: _accent,
                      strokeWidth: 2.5,
                    ),
                  )
                : null,
            hintText: 'Search location',
            hintStyle: const TextStyle(color: _accent, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildMyLocationButton() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        heroTag: 'myLocation',
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF126E63),
        onPressed: _determinePosition,
        child: const Icon(Icons.my_location_rounded),
      ),
    );
  }

  Widget _buildResultsSheet() {
    final shown = _results;

    Widget child;
    if (shown.isEmpty) {
      if (_loading) {
        child = const Center(child: LoadingIndicator());
      } else if (_hasSearched) {
        child = _centeredMessage(
          Icons.location_off_rounded,
          'No parking spots matched "${_controller.text.trim()}"',
        );
      } else if (_error != null) {
        child = _centeredMessage(Icons.cloud_off_rounded, _error!);
      } else {
        child = _centeredMessage(
          Icons.search_rounded,
          'Search for parking spots near you',
        );
      }
    } else {
      child = ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: shown.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _LotCard(
          lot: shown[index],
          distance: _formattedDistance(shown[index]),
          onTap: () => _pickLot(shown[index]),
        ),
      );
    }

    return Align(
      alignment: Alignment.bottomLeft,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 412, maxHeight: 280),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _centeredMessage(IconData icon, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 14),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 86,
          left: 16,
          right: 16,
        ),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          color: Colors.red[50],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              message,
              style: TextStyle(color: Colors.red[900]),
            ),
          ),
        ),
      ),
    );
  }
}

class _LotCard extends StatelessWidget {
  final ParkingLot lot;
  final String distance;
  final VoidCallback onTap;

  const _LotCard({
    required this.lot,
    required this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lot.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (distance.isNotEmpty)
                    Text(
                      distance,
                      style:
                          const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                lot.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.local_parking_rounded,
                    size: 16,
                    color: lot.availableSlots > 0
                        ? const Color(0xFF126E63)
                        : Colors.redAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${lot.availableSlots} of ${lot.totalSlots} spots',
                    style: TextStyle(
                      color: lot.availableSlots > 0
                          ? const Color(0xFF126E63)
                          : Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${AppHelpers.formatPrice(lot.hourlyRate)}/hr',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
