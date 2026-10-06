import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Park Ease'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, '/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 412),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 180,
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
                child: Stack(
                  children: [
                    Positioned(
                      right: 24,
                      top: 20,
                      child: const Text(
                        'Find Parking',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      bottom: 20,
                      child: const Text(
                        'Search and book\nparking spots near you',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 24,
                      bottom: 20,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/search-parking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9894BD),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Search location'),
                      ),
                    ),
                  ],
                ),
              ),
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
                    () => Navigator.pushNamed(context, '/my-bookings'),
                  ),
                  _buildAction(
                    context,
                    'Find Parking',
                    Icons.local_parking_outlined,
                    () => Navigator.pushNamed(context, '/search-parking'),
                  ),
                  _buildAction(
                    context,
                    'Scan to Park',
                    Icons.qr_code_scanner_outlined,
                    () {},
                  ),
                  _buildAction(
                    context,
                    'Offers',
                    Icons.local_offer_outlined,
                    () {},
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
                    onPressed: () {},
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
              const SizedBox(height: 16),
              _buildNearbyCard('City Center', '120 Spots Available', '0.3km'),
              const SizedBox(height: 12),
              _buildNearbyCard('Main Street Parking', '80 Spots Available', '0.5km'),
              const SizedBox(height: 12),
              _buildNearbyCard('Metro Mall Parking', '70 Spots Available', '0.8km'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF9894BD),
        child: const Icon(Icons.add, color: Colors.white),
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
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: IconButton(
          onPressed: onTap,
          icon: Column(
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
    );
  }

  Widget _buildNearbyCard(String name, String spots, String distance) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const SweepGradient(
                colors: [
                  Color(0xFFDEDCEC),
                  Color(0xFFF3F3F7),
                  Color(0xFFC8C7DF),
                ],
              ),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          Expanded(
            child: Column(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  spots,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              distance,
              style: const TextStyle(
                color: Color(0xFF9894BD),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}