import 'package:flutter/material.dart';

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBookingCard(
            'BK001',
            'John Doe',
            'City Center Parking',
            'Today, 2:00 PM',
            'Active',
            Colors.green,
            () => Navigator.pushNamed(context, '/admin-booking-details'),
          ),
          const SizedBox(height: 12),
          _buildBookingCard(
            'BK002',
            'Jane Smith',
            'Metro Mall Parking',
            'Today, 5:00 PM',
            'Confirmed',
            Colors.blue,
            () => Navigator.pushNamed(context, '/admin-booking-details'),
          ),
          const SizedBox(height: 12),
          _buildBookingCard(
            'BK003',
            'Mike Johnson',
            'Main Street Parking',
            '14 Sep 2026',
            'Completed',
            Colors.grey,
            () => Navigator.pushNamed(context, '/admin-booking-details'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
    String id,
    String user,
    String parking,
    String time,
    String status,
    Color statusColor,
    VoidCallback onTap,
  ) {
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
            color: const Color(0xFF9894BD).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            id.replaceAll('BK', ''),
            style: const TextStyle(
              color: Color(0xFF9894BD),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(
          user,
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
            Text(parking),
            Text(
              time,
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
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B7280)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}