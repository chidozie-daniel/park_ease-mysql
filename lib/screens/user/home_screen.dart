import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../models/parking_lot.dart';
import '../../services/api_service.dart';
import '../../services/parking_service.dart';
import '../../utils/utils.dart';
import '../../widgets/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _parking = ParkingService();
  late Future<List<ParkingLot>> _nearbyLots;

  @override
  void initState() {
    super.initState();
    _nearbyLots = _parking.getAllLots();
  }

  Future<void> _refresh() async {
    final request = _parking.getAllLots();
    setState(() => _nearbyLots = request);
    await request;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Park Ease'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSearchCard(context),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                spacing: 12,
                children: [
                  _buildAction(
                    context,
                    'My Bookings',
                    Icons.receipt_long_outlined,
                    () => Navigator.pushNamed(context, AppRoutes.myBookings),
                  ),
                  _buildAction(
                    context,
                    'Find Parking',
                    Icons.local_parking_outlined,
                    () => Navigator.pushNamed(context, AppRoutes.searchParking),
                  ),
                  _buildAction(
                    context,
                    'Scan to Park',
                    Icons.qr_code_scanner_outlined,
                    () => Navigator.pushNamed(context, AppRoutes.myBookings),
                  ),
                  _buildAction(
                    context,
                    'Offers',
                    Icons.local_offer_outlined,
                    () => _showOffers(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                spacing: 8,
                children: [
                  const Text(
                    'Nearby Areas',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.parkingResults),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF9894BD),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<ParkingLot>>(
                future: _nearbyLots,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: LoadingIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return _homeMessage(
                      ApiService.describeError(snapshot.error!),
                      action: TextButton(
                        onPressed: _refresh,
                        child: const Text('Retry'),
                      ),
                    );
                  }
                  final lots = snapshot.data ?? const <ParkingLot>[];
                  if (lots.isEmpty) {
                    return _homeMessage(
                      'No parking locations are listed yet.',
                      action: TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.searchParking,
                        ),
                        child: const Text('Search on map'),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final lot in lots.take(3)) ...[
                        _buildNearbyCard(context, lot),
                        if (lot != lots.take(3).last)
                          const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a vehicle',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addVehicle),
        backgroundColor: const Color(0xFF9894BD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Parking',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Search and book parking spots near you',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.searchParking),
              icon: const Icon(Icons.search_rounded),
              label: const Text('Search locations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9894BD),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeMessage(String message, {Widget? action}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            if (action != null) action,
          ],
        ),
      ),
    );
  }

  Widget _buildAction(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFF9894BD), size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyCard(BuildContext context, ParkingLot lot) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.parkingDetails,
          arguments: {'parkingLotId': lot.id},
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDECF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_parking_rounded,
                  color: Color(0xFF126E63),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lot.isBookable
                          ? '${lot.availableSlots} spots · ${AppHelpers.formatPrice(lot.hourlyRate)}/hr'
                          : 'Community parking · rate unavailable',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }

  void _showOffers(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offers'),
        content: const Text(
          'There are no active offers right now. Check back later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.searchParking);
            },
            child: const Text('Find Parking'),
          ),
        ],
      ),
    );
  }
}
