import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final String bookingId;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
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
              spacing: 12,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Rs ${amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF126E63),
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Divider(),
                _buildRow('Booking ID', bookingId),
                _buildRow('Parking Lot', 'City Center Parking'),
                _buildRow('Slot', 'A12'),
                _buildRow('Duration', '4 hours'),
                _buildRow('Hourly Rate', 'Rs 50/hr'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select Payment Method',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethod(
            context,
            icon: const Icon(Icons.credit_card_rounded),
            label: 'Credit / Debit Card',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildPaymentMethod(
            context,
            icon: const Icon(Icons.qr_code_rounded),
            label: 'UPI',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildPaymentMethod(
            context,
            icon: const Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildPaymentMethod(
            context,
            icon: const Icon(Icons.payments_rounded),
            label: 'Net Banking',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildPaymentMethod(
            context,
            icon: const Icon(Icons.local_atm_rounded),
            label: 'Cash',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      spacing: 8,
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

  Widget _buildPaymentMethod(
    BuildContext context, {
    required Widget icon,
    required String label,
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
        leading: icon,
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B7280)),
        onTap: onTap,
      ),
    );
  }
}