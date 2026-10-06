import 'package:flutter/material.dart';

import '../../widgets/app_button.dart';

class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF126E63).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_parking_rounded,
                    size: 40,
                    color: Color(0xFF126E63),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Booking Confirmed',
                  style: TextStyle(
                    color: Color(0xFF126E63),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Divider(height: 32),
                _buildRow('Booking ID', bookingId),
                const SizedBox(height: 12),
                _buildRow('Parking Lot', 'City Center Parking'),
                const SizedBox(height: 12),
                _buildRow('Slot Number', 'A12'),
                const SizedBox(height: 12),
                _buildRow('Vehicle', 'Toyota Camry (ABC123)'),
                const SizedBox(height: 12),
                _buildRow('Date', '15 Sep 2026'),
                const SizedBox(height: 12),
                _buildRow('Entry Time', '2:00 PM'),
                const SizedBox(height: 12),
                _buildRow('Exit Time', '6:00 PM'),
                const SizedBox(height: 12),
                _buildRow('Duration', '4 hours'),
                const SizedBox(height: 12),
                _buildRow('Hourly Rate', 'Rs 50/hr'),
                const SizedBox(height: 12),
                _buildRow('Total Amount', 'Rs 200'),
                const Divider(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF126E63).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Color(0xFF126E63),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Navigate to Parking',
            onPressed: () => Navigator.pushNamed(context, '/navigate-parking'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              side: const BorderSide(color: Color(0xFF9894BD)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Share Booking'),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
