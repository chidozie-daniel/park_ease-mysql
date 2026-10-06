import 'package:flutter/material.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveTab(),
            _buildUpcomingTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBookingCard(
          'Active',
          'City Center Parking',
          'Slot A12',
          'Today, 2:00 PM - 6:00 PM',
          'Rs 200',
          Colors.green,
          onNavigate: () {},
          onCheckOut: () {},
        ),
      ],
    );
  }

  Widget _buildUpcomingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBookingCard(
          'Upcoming',
          'Metro Mall Parking',
          'Slot B5',
          'Tomorrow, 10:00 AM - 2:00 PM',
          'Rs 240',
          Colors.blue,
          onCancel: () {},
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBookingCard(
          'Completed',
          'City Center Parking',
          'Slot A12',
          '14 Sep 2026',
          'Rs 200',
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildBookingCard(
          'Cancelled',
          'Riverside Parking',
          'Slot D8',
          '13 Sep 2026',
          'Rs 0',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildBookingCard(
    String status,
    String parking,
    String slot,
    String time,
    String amount,
    Color statusColor, {
    VoidCallback? onNavigate,
    VoidCallback? onCheckOut,
    VoidCallback? onCancel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        children: [
          ListTile(
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
            subtitle: Text(
              'Slot $slot',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.access_time_outlined, size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Color(0xFF126E63),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (onNavigate != null || onCheckOut != null || onCancel != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (onNavigate != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onNavigate,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF126E63)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Navigate'),
                      ),
                    ),
                  if (onNavigate != null && onCheckOut != null)
                    const SizedBox(width: 8),
                  if (onCheckOut != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onCheckOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF126E63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Check Out'),
                      ),
                    ),
                  if (onCheckOut != null && onCancel != null)
                    const SizedBox(width: 8),
                  if (onCancel != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
