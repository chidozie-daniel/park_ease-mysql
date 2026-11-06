import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../services/admin_service.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/utils.dart';
import '../../widgets/loading_indicator.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = AdminService();
  late Future<Map<String, dynamic>> _dashboard;

  @override
  void initState() {
    super.initState();
    _dashboard = _service.getDashboard();
  }

  void _reload() => setState(() => _dashboard = _service.getDashboard());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ApiService.describeError(snapshot.error!),
                      textAlign: TextAlign.center,
                    ),
                    TextButton(onPressed: _reload, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Dashboard Overview',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Users',
                      '${data['totalUsers'] ?? 0}',
                      Icons.people_rounded,
                      const Color(0xFF126E63),
                    ),
                  ),
                  Expanded(
                    child: _buildStatCard(
                      'Active Bookings',
                      '${data['activeBookings'] ?? 0}',
                      Icons.local_parking_rounded,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Parking Lots',
                      '${data['totalLots'] ?? 0}',
                      Icons.local_hotel_rounded,
                      Colors.amber,
                    ),
                  ),
                  Expanded(
                    child: _buildStatCard(
                      'Revenue',
                      AppHelpers.formatPrice(
                        (data['totalRevenue'] as num?)?.toDouble() ?? 0,
                      ),
                      Icons.attach_money_rounded,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _buildActionTile(
                context,
                icon: Icons.people_rounded,
                title: 'Manage Users',
                subtitle: 'View and manage user accounts',
                route: AppRoutes.manageUsers,
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                context,
                icon: Icons.local_parking_rounded,
                title: 'Manage Parking Lots',
                subtitle: 'Add, edit, or remove parking lots',
                route: AppRoutes.manageParkingLots,
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                context,
                icon: Icons.receipt_long_rounded,
                title: 'Manage Bookings',
                subtitle: 'View and manage all bookings',
                route: AppRoutes.manageBookings,
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                context,
                icon: Icons.bar_chart_rounded,
                title: 'Reports & Analytics',
                subtitle: 'View detailed reports',
                route: AppRoutes.reportsAnalytics,
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                context,
                icon: Icons.notifications_rounded,
                title: 'Admin Notifications',
                subtitle: 'Send notifications to users',
                route: AppRoutes.adminNotifications,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AuthService>().logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcome,
        (route) => false,
      );
    }
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
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
    required String route,
  }) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF126E63).withValues(alpha: 0.12),
          child: Icon(icon, color: const Color(0xFF126E63)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
