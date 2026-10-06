import 'package:flutter/material.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHistoryCard(context, 'Completed', 'City Center Parking', 'Slot A12', '14 Sep 2026', 'Rs 200', Colors.green),
          const SizedBox(height: 12),
          _buildHistoryCard(context, 'Completed', 'Metro Mall Parking', 'Slot B5', '12 Sep 2026', 'Rs 240', Colors.green),
          const SizedBox(height: 12),
          _buildHistoryCard(context, 'Cancelled', 'Riverside Parking', 'Slot D8', '10 Sep 2026', 'Rs 0', Colors.red),
          const SizedBox(height: 12),
          _buildHistoryCard(context, 'Completed', 'Main Street Parking', 'Slot C3', '8 Sep 2026', 'Rs 100', Colors.green),
          const SizedBox(height: 12),
          _buildHistoryCard(context, 'No Show', 'Grand Plaza Parking', 'Slot E2', '5 Sep 2026', 'Rs 50', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, String status, String parking, String slot, String date, String amount, Color statusColor) {
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
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.local_parking_rounded, color: statusColor, size: 28),
        ),
        title: Text(
          parking,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Slot $slot'),
            Text(
              date,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          spacing: 6,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Color(0xFF126E63),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        onTap: () => Navigator.pushNamed(context, '/booking-details'),
      ),
    );
  }
}