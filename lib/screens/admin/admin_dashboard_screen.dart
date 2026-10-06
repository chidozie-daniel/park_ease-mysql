import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _buildStatCard('Total Users', '1,254', Icons.people_rounded, const Color(0xFF126E63)),
              ),
              Expanded(
                child: _buildStatCard('Active Bookings', '87', Icons.local_parking_rounded, Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _buildStatCard('Parking Lots', '12', Icons.local_hotel_rounded, Colors.amber),
              ),
              Expanded(
                child: _buildStatCard('Revenue', 'Rs 45,200', Icons.attach_money_rounded, Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            context,
            icon: Icons.people_rounded,
            title: 'Manage Users',
            subtitle: 'View and manage user accounts',
            onTap: () => Navigator.pushNamed(context, '/manage-users'),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            icon: Icons.local_parking_rounded,
            title: 'Manage Parking Lots',
            subtitle: 'Add, edit, or remove parking lots',
            onTap: () => Navigator.pushNamed(context, '/manage-parking-lots'),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            icon: Icons.receipt_long_rounded,
            title: 'Manage Bookings',
            subtitle: 'View and manage all bookings',
            onTap: () => Navigator.pushNamed(context, '/manage-bookings'),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            icon: Icons.bar_chart_rounded,
            title: 'Reports & Analytics',
            subtitle: 'View detailed reports',
            onTap: () => Navigator.pushNamed(context, '/reports-analytics'),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            icon: Icons.notifications_rounded,
            title: 'Admin Notifications',
            subtitle: 'Send notifications to users',
            onTap: () => Navigator.pushNamed(context, '/admin-notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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
          child: Icon(icon, color: const Color(0xFF126E63)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B7280)),
        onTap: onTap,
      ),
    );
  }
}
