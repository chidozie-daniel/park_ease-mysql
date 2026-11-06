import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicator.dart';

class AdminBookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const AdminBookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<AdminBookingDetailsScreen> createState() =>
      _AdminBookingDetailsScreenState();
}

class _AdminBookingDetailsScreenState extends State<AdminBookingDetailsScreen> {
  final _service = AdminService();
  late Future<Map<String, dynamic>> _booking;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _booking = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final bookings = await _service.getBookings();
    return bookings.firstWhere(
      (item) => item['id'] == widget.bookingId,
      orElse: () => throw ApiException('Booking not found.', 404),
    );
  }

  Future<void> _changeStatus(String status) async {
    final action = status == 'cancelled' ? 'cancel this booking' : 'check out';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm action'),
        content: Text('Are you sure you want to $action?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _updating = true);
    try {
      await _service.updateBookingStatus(widget.bookingId, status);
      if (mounted) setState(() => _booking = _load());
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ApiService.describeError(error))));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _booking,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _updating) {
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
                    TextButton(
                      onPressed: () => setState(() => _booking = _load()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _details(snapshot.data!);
        },
      ),
    );
  }

  Widget _details(Map<String, dynamic> booking) {
    final status = booking['status'] as String? ?? '';
    final canCancel = ['pending', 'confirmed', 'checked_in'].contains(status);
    final canCheckOut = status == 'checked_in';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  size: 56,
                  color: Color(0xFF126E63),
                ),
                const SizedBox(height: 12),
                Text(
                  'Booking ${booking['id']}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(height: 32),
                _row('Customer', booking['userName']),
                _row('Email', booking['userEmail']),
                _row('Parking Lot', booking['lotName']),
                _row('Slot', booking['parkingSlotId']),
                _row('Vehicle ID', booking['vehicleId']),
                _row('Start', _date(booking['startTime'])),
                _row('End', _date(booking['endTime'])),
                _row(
                  'Amount',
                  'Rs ${((booking['totalAmount'] as num?) ?? 0).toStringAsFixed(2)}',
                ),
                _row('Status', _label(status)),
              ],
            ),
          ),
        ),
        if (canCancel || canCheckOut) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              if (canCancel)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _changeStatus('cancelled'),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              if (canCancel && canCheckOut) const SizedBox(width: 12),
              if (canCheckOut)
                Expanded(
                  child: FilledButton(
                    onPressed: () => _changeStatus('checked_out'),
                    child: const Text('Check Out'),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _row(String label, Object? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value?.toString() ?? '—', textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  String _date(Object? value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return 'Unavailable';
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  String _label(String status) => switch (status) {
    'checked_in' => 'Checked In',
    'checked_out' => 'Checked Out',
    'no_show' => 'No Show',
    _ =>
      status.isEmpty
          ? 'Unknown'
          : '${status[0].toUpperCase()}${status.substring(1)}',
  };
}
