import 'package:flutter/material.dart';

class ParkingResultsScreen extends StatelessWidget {
  final String query;

  const ParkingResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(query.isEmpty ? 'Parking Results' : query),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildResultCard(context, 'City Center Parking', '120 Spots Available', '0.3km', 'Rs 50/hr'),
          const SizedBox(height: 12),
          _buildResultCard(context, 'Main Street Parking', '80 Spots Available', '0.5km', 'Rs 40/hr'),
          const SizedBox(height: 12),
          _buildResultCard(context, 'Metro Mall Parking', '70 Spots Available', '0.8km', 'Rs 60/hr'),
          const SizedBox(height: 12),
          _buildResultCard(context, 'Grand Plaza Parking', '90 Spots Available', '1.2km', 'Rs 55/hr'),
          const SizedBox(height: 12),
          _buildResultCard(context, 'Riverside Parking', '60 Spots Available', '1.5km', 'Rs 45/hr'),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, String name, String spots, String distance, String price) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const SweepGradient(
              colors: [
                Color(0xFFDEDCEC),
                Color(0xFFF3F3F7),
                Color(0xFFC8C7DF),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.local_parking_rounded, color: Color(0xFF126E63)),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          spots,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
        trailing: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              distance,
              style: const TextStyle(
                color: Color(0xFF9894BD),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                color: Color(0xFF126E63),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        onTap: () => Navigator.pushNamed(context, '/parking-details'),
      ),
    );
  }
}