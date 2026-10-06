import 'package:flutter/material.dart';

// AppButton available if needed

class AdminBookingDetailsScreen extends StatelessWidget {
  final String bookingId;

  const AdminBookingDetailsScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
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
                    Icons.receipt_long_rounded,
                    size: 40,
                    color: Color(0xFF126E63),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Booking Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Divider(height: 32),
                _buildRow('Booking ID', bookingId),
                const SizedBox(height: 12),
                _buildRow('User', 'John Doe'),
                const SizedBox(height: 12),
                _buildRow('Email', 'john@email.com'),
                const SizedBox(height: 12),
                _buildRow('Parking Lot', 'City Center Parking'),
                const SizedBox(height: 12),
                _buildRow('Slot', 'A12'),
                const SizedBox(height: 12),
                _buildRow('Vehicle', 'Toyota Camry (ABC 1234)'),
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
                const SizedBox(height: 12),
                _buildRow('Payment Method', 'Credit Card'),
                const SizedBox(height: 12),
                _buildRow('Status', 'Active'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF126E63),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Check Out'),
                ),
              ),
            ],
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
