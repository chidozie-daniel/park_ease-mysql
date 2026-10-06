import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: Color(0xFF126E63),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotification(
            const Icon(Icons.local_parking_rounded),
            'Booking Confirmed',
            'Your booking at City Center Parking is confirmed.',
            '2 hours ago',
            true,
          ),
          const SizedBox(height: 12),
          _buildNotification(
            const Icon(Icons.payment_rounded),
            'Payment Received',
            'Payment of Rs 200 received for booking #BK123.',
            '5 hours ago',
            true,
          ),
          const SizedBox(height: 12),
          _buildNotification(
            const Icon(Icons.local_offer_rounded),
            'Special Offer',
            'Get 20% off on your next parking booking!',
            '1 day ago',
            false,
          ),
          const SizedBox(height: 12),
          _buildNotification(
            const Icon(Icons.access_time_rounded),
            'Reminder',
            'Your parking session ends in 30 minutes.',
            '2 days ago',
            false,
          ),
          const SizedBox(height: 12),
          _buildNotification(
            const Icon(Icons.info_rounded),
            'System Update',
            'Park Ease app has been updated with new features.',
            '3 days ago',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotification(
    Widget icon,
    String title,
    String body,
    String time,
    bool isRead,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFF3F3F7),
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
        trailing: !isRead
            ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF126E63),
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {},
      ),
    );
  }
}