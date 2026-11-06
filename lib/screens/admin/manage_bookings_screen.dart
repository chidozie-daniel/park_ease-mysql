import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/admin_service.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicator.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  final _service = AdminService();
  late Future<List<Map<String, dynamic>>> _bookings;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _bookings = _service.getBookings();
  }

  Future<void> _refresh() async {
    final request = _service.getBookings();
    setState(() => _bookings = request);
    await request;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }
          if (snapshot.hasError) {
            return _message(
              ApiService.describeError(snapshot.error!),
              action: TextButton(
                onPressed: _refresh,
                child: const Text('Retry'),
              ),
            );
          }
          final all = snapshot.data ?? const <Map<String, dynamic>>[];
          final rows = all.where((booking) {
            final status = booking['status'] as String? ?? '';
            return switch (_filter) {
              'Upcoming' => status == 'pending' || status == 'confirmed',
              'Active' => status == 'checked_in',
              'History' =>
                status == 'checked_out' ||
                    status == 'cancelled' ||
                    status == 'no_show',
              _ => true,
            };
          }).toList();
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    for (final filter in [
                      'All',
                      'Upcoming',
                      'Active',
                      'History',
                    ])
                      ChoiceChip(
                        label: Text(filter),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (rows.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No bookings in this category.',
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  for (final booking in rows)
                    Card(
                      color: Colors.white,
                      child: ListTile(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.adminBookingDetails,
                          arguments: {'bookingId': booking['id']},
                        ),
                        leading: const CircleAvatar(
                          child: Icon(Icons.receipt_long_rounded),
                        ),
                        title: Text(
                          booking['userName'] as String? ?? 'Customer',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${booking['lotName'] ?? 'Parking lot'}\n'
                          '${_date(booking['startTime'])}',
                        ),
                        isThreeLine: true,
                        trailing: Chip(
                          label: Text(
                            _label(booking['status'] as String? ?? ''),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _message(String text, {Widget? action}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 12), action],
          ],
        ),
      ),
    );
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

  String _date(Object? value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return 'Date unavailable';
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
