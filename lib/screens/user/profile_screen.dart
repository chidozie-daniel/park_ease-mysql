import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.editProfile),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9894BD).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: user?.name != null && user!.name.isNotEmpty
                      ? Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF9894BD),
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : const Icon(
                          Icons.person_outlined,
                          size: 48,
                          color: Color(0xFF9894BD),
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'User',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
                if (user?.phone != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    user!.phone!,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildMenuCard(
            context,
            icon: const Icon(Icons.receipt_long_outlined),
            label: 'My Bookings',
            onTap: () => Navigator.pushNamed(context, AppRoutes.myBookings),
          ),
          _buildMenuCard(
            context,
            icon: const Icon(Icons.local_parking_outlined),
            label: 'My Vehicles',
            onTap: () => Navigator.pushNamed(context, AppRoutes.myVehicles),
          ),
          _buildMenuCard(
            context,
            icon: const Icon(Icons.payment_outlined),
            label: 'Payments',
            onTap: () => Navigator.pushNamed(context, AppRoutes.payment),
          ),
          _buildMenuCard(
            context,
            icon: const Icon(Icons.notifications_outlined),
            label: 'Notifications',
            onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          _buildMenuCard(
            context,
            icon: const Icon(Icons.history_outlined),
            label: 'Booking History',
            onTap: () => Navigator.pushNamed(context, AppRoutes.bookingHistory),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Logout',
            isSecondary: true,
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.welcome,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
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
        leading: icon,
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF6B7280),
        ),
        onTap: onTap,
      ),
    );
  }
}
