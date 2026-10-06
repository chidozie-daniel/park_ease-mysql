import 'package:flutter/material.dart';

class ManageParkingLotsScreen extends StatelessWidget {
  const ManageParkingLotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Parking Lots'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.pushNamed(context, '/add-edit-parking-lot'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLotCard(context, 'City Center Parking', '120 Spots', 'Rs 50/hr', true),
          const SizedBox(height: 12),
          _buildLotCard(context, 'Metro Mall Parking', '80 Spots', 'Rs 60/hr', true),
          const SizedBox(height: 12),
          _buildLotCard(context, 'Main Street Parking', '60 Spots', 'Rs 40/hr', true),
          const SizedBox(height: 12),
          _buildLotCard(context, 'Riverside Parking', '50 Spots', 'Rs 45/hr', false),
        ],
      ),
    );
  }

  Widget _buildLotCard(BuildContext context, String name, String spots, String price, bool isActive) {
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
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF126E63).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.local_parking_rounded, color: Color(0xFF126E63), size: 28),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(spots),
            Text(
              price,
              style: const TextStyle(
                color: Color(0xFF126E63),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF6B7280)),
              onPressed: () {},
            ),
          ],
        ),
        onTap: () => Navigator.pushNamed(context, '/add-edit-parking-lot'),
      ),
    );
  }
}
