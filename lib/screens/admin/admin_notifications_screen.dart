import 'package:flutter/material.dart';

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationCard(
            const Icon(Icons.campaign_rounded),
            'Maintenance Notice',
            'City Center Parking will be under maintenance on 20 Sep 2026.',
            '1 hour ago',
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            const Icon(Icons.local_offer_rounded),
            'Promotional Offer',
            '20% off on all weekend bookings this month.',
            '3 hours ago',
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            const Icon(Icons.info_rounded),
            'System Update',
            'New features have been added to the app.',
            '1 day ago',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Widget icon, String title, String body, String time) {
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF126E63).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
        title: Text(
          title,
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
            Text(
              body,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                color: Color(0xFF9894BD),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF6B7280)),
          onPressed: () {},
        ),
      ),
    );
  }
}