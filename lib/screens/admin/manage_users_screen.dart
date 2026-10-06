import 'package:flutter/material.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
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
          _buildUserCard('John Doe', 'john@email.com', '+1 234 567 890', 'User', true),
          const SizedBox(height: 12),
          _buildUserCard('Jane Smith', 'jane@email.com', '+1 234 567 891', 'User', true),
          const SizedBox(height: 12),
          _buildUserCard('Mike Johnson', 'mike@email.com', '+1 234 567 892', 'User', false),
          const SizedBox(height: 12),
          _buildUserCard('Sarah Williams', 'sarah@email.com', '+1 234 567 893', 'Admin', true),
        ],
      ),
    );
  }

  Widget _buildUserCard(String name, String email, String phone, String role, bool isActive) {
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
            name[0].toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF9894BD),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(
          name,
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
            Text(email),
            Text(phone),
          ],
        ),
        trailing: Column(
          spacing: 6,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: role == 'Admin'
                    ? const Color(0xFF126E63).withValues(alpha: 0.12)
                    : const Color(0xFF9894BD).withValues(alpha: 0.12),
              ),
              child: Text(
                role,
                style: TextStyle(
                  color: role == 'Admin' ? const Color(0xFF126E63) : const Color(0xFF9894BD),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}