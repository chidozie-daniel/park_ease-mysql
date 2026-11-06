import 'package:flutter/material.dart';

import '../../models/payment.dart';
import '../../services/api_service.dart';
import '../../services/payment_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/loading_indicator.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _service = PaymentService();
  PaymentMethod _method = PaymentMethod.creditCard;
  bool _isPaying = false;
  String? _error;
  Payment? _result;
  late Future<List<Payment>> _history;

  @override
  void initState() {
    super.initState();
    _history = _service.getPaymentHistory();
  }

  Future<void> _pay() async {
    setState(() {
      _isPaying = true;
      _error = null;
    });
    try {
      final payment = await _service.processPayment(
        bookingId: widget.bookingId,
        amount: widget.amount,
        method: _method,
      );
      if (mounted) setState(() => _result = payment);
    } catch (error) {
      if (mounted) setState(() => _error = ApiService.describeError(error));
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bookingId.isEmpty) return _paymentHistory();
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('Amount due'),
                  const SizedBox(height: 8),
                  Text(
                    'Rs ${widget.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF126E63),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Booking ${widget.bookingId}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select Payment Method',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final method in PaymentMethod.values)
            Card(
              color: Colors.white,
              child: RadioListTile<PaymentMethod>(
                value: method,
                groupValue: _method,
                onChanged: _result == null
                    ? (value) => setState(() => _method = value!)
                    : null,
                title: Text(method.label),
                secondary: Icon(_iconFor(method)),
              ),
            ),
          if (_method != PaymentMethod.cash)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Card and online payments require a configured payment gateway. '
                'You can submit a request, but it will remain pending until the gateway is connected.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          if (_result case final payment?)
            Card(
              color: payment.status == PaymentStatus.completed
                  ? Colors.green.shade50
                  : Colors.amber.shade50,
              child: ListTile(
                leading: Icon(
                  payment.status == PaymentStatus.completed
                      ? Icons.check_circle_outline
                      : Icons.hourglass_top_rounded,
                ),
                title: Text('Payment ${payment.status.label.toLowerCase()}'),
                subtitle: Text('Transaction ${payment.transactionId}'),
              ),
            )
          else
            AppButton(
              label: 'Pay Rs ${widget.amount.toStringAsFixed(2)}',
              isLoading: _isPaying,
              onPressed: _pay,
              backgroundColor: const Color(0xFF126E63),
            ),
        ],
      ),
    );
  }

  Widget _paymentHistory() {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: FutureBuilder<List<Payment>>(
        future: _history,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  ApiService.describeError(snapshot.error!),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final payments = snapshot.data ?? const [];
          if (payments.isEmpty) {
            return const Center(child: Text('No payments yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: Text('Rs ${payment.amount.toStringAsFixed(2)}'),
                  subtitle: Text(
                    '${payment.method.label} · booking ${payment.bookingId}',
                  ),
                  trailing: Text(payment.status.label),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconFor(PaymentMethod method) => switch (method) {
    PaymentMethod.creditCard ||
    PaymentMethod.debitCard => Icons.credit_card_rounded,
    PaymentMethod.upi => Icons.qr_code_rounded,
    PaymentMethod.wallet => Icons.account_balance_wallet_rounded,
    PaymentMethod.netBanking => Icons.account_balance_rounded,
    PaymentMethod.cash => Icons.payments_rounded,
  };
}
