import 'package:flutter/material.dart';

class ParkingDetailsScreen extends StatelessWidget {
  final String parkingLotId;

  const ParkingDetailsScreen({super.key, required this.parkingLotId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: SweepGradient(
                    colors: [
                      Color(0xFFDEDCEC),
                      Color(0xFFF3F3F7),
                      Color(0xFFC8C7DF),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_parking_rounded,
                    size: 80,
                    color: Color(0xFF126E63),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 16,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      const Text(
                        'City Center Parking',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF126E63).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Open',
                          style: TextStyle(
                            color: Color(0xFF126E63),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF6B7280)),
                      const Expanded(
                        child: Text(
                          '123 Main Street, Downtown, City',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      const Icon(Icons.access_time_outlined, size: 16, color: Color(0xFF6B7280)),
                      const Expanded(
                        child: Text(
                          'Open 24/7',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Row(
                    spacing: 16,
                    children: [
                      _InfoItem(icon: Icons.local_parking_outlined, label: '120 Spots'),
                      _InfoItem(icon: Icons.electric_meter_outlined, label: 'EV Charging'),
                      _InfoItem(icon: Icons.accessible_rounded, label: 'Handicap'),
                    ],
                  ),
                  const Divider(),
                  const Text(
                    'Pricing',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Row(
                    spacing: 8,
                    children: [
                      Text(
                        'Rs 50',
                        style: TextStyle(
                          color: Color(0xFF126E63),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '/hr',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Daily: Rs 400',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                  const Divider(),
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildAmenity('CCTV'),
                      _buildAmenity('Guard'),
                      _buildAmenity('Well Lit'),
                      _buildAmenity('Gate Access'),
                      _buildAmenity('Wheelchair'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/select-slot'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF126E63),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Select Slot',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenity(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData? icon;
  final String label;

  const _InfoItem({this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon ?? Icons.local_parking_outlined, size: 24, color: const Color(0xFF126E63)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}