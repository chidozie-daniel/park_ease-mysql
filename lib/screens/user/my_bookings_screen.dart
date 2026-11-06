import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../models/booking.dart';
import '../../services/api_service.dart';
import '../../services/booking_service.dart';
import '../../utils/utils.dart';
import '../../widgets/loading_indicator.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _service = BookingService();
  List<Booking> _bookings = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bookings = await _service.getMyBookings();
      if (mounted) setState(() => _bookings = bookings);
    } catch (error) {
      if (mounted) setState(() => _error = ApiService.describeError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeStatus(
    Booking booking,
    Future<Booking> Function(String) action,
    String successMessage,
  ) async {
    try {
      await action(booking.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
      await _loadBookings();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ApiService.describeError(error))));
    }
  }

  Future<void> _confirmAction(
    Booking booking, {
    required String title,
    required String message,
    required String confirmLabel,
    required Future<Booking> Function(String) action,
    required String successMessage,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep booking'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _changeStatus(booking, action, successMessage);
    }
  }

  Future<void> _checkIn(Booking booking) async {
    final code = booking.qrCode;
    if (code == null || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This booking has no check-in code.')),
      );
      return;
    }
    await _changeStatus(
      booking,
      (id) => _service.checkIn(id, code),
      'Check-in complete.',
    );
  }

  List<Booking> _forTab(int tab) {
    return _bookings.where((booking) {
      switch (tab) {
        case 0:
          return booking.status == BookingStatus.checkedIn;
        case 1:
          return booking.status == BookingStatus.pending ||
              booking.status == BookingStatus.confirmed;
        default:
          return booking.status == BookingStatus.checkedOut ||
              booking.status == BookingStatus.cancelled ||
              booking.status == BookingStatus.noShow;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: LoadingIndicator())
            : _error != null
            ? _empty(
                'Could not load your bookings.\n$_error',
                retry: _loadBookings,
              )
            : TabBarView(
                children: [_bookingList(0), _bookingList(1), _bookingList(2)],
              ),
      ),
    );
  }

  Widget _bookingList(int tab) {
    final bookings = _forTab(tab);
    if (bookings.isEmpty) {
      return _empty(
        tab == 0
            ? 'You have no active parking sessions.'
            : tab == 1
            ? 'You have no upcoming bookings.'
            : 'Your completed and cancelled bookings will appear here.',
        retry: _loadBookings,
        showFindParking: tab != 2,
      );
    }
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _BookingCard(
          booking: bookings[index],
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.bookingDetails,
            arguments: {'bookingId': bookings[index].id},
          ),
          onCheckIn: () => _checkIn(bookings[index]),
          onCheckOut: () => _confirmAction(
            bookings[index],
            title: 'Check out?',
            message: 'End this parking session now?',
            confirmLabel: 'Check Out',
            action: _service.checkOut,
            successMessage: 'You have checked out.',
          ),
          onCancel: () => _confirmAction(
            bookings[index],
            title: 'Cancel booking?',
            message: 'This will release the reserved parking space.',
            confirmLabel: 'Cancel Booking',
            action: _service.cancelBooking,
            successMessage: 'Booking cancelled.',
          ),
          onNavigate: () => Navigator.pushNamed(
            context,
            AppRoutes.navigateParking,
            arguments: {'parkingLotId': bookings[index].parkingLotId},
          ),
        ),
      ),
    );
  }

  Widget _empty(
    String message, {
    required Future<void> Function() retry,
    bool showFindParking = false,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        const Icon(
          Icons.receipt_long_outlined,
          size: 64,
          color: Colors.black38,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(message, textAlign: TextAlign.center),
        ),
        if (showFindParking) ...[
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.searchParking),
              child: const Text('Find Parking'),
            ),
          ),
        ],
        TextButton(onPressed: retry, child: const Text('Refresh')),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onCancel;
  final VoidCallback onNavigate;

  const _BookingCard({
    required this.booking,
    required this.onTap,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onCancel,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isCheckedIn = booking.status == BookingStatus.checkedIn;
    final isUpcoming =
        booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.confirmed;
    final color = isCheckedIn
        ? const Color(0xFF126E63)
        : isUpcoming
        ? Colors.blue
        : Colors.grey;

    return Card(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Parking booking',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(booking.status.label),
                    backgroundColor: color.withValues(alpha: 0.12),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              Text(
                'Lot ${booking.parkingLotId}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (booking.parkingSlotId != null)
                Text('Slot ${booking.parkingSlotId}'),
              const SizedBox(height: 8),
              Text(
                '${_formatDate(booking.startTime)} – ${_formatDate(booking.endTime)}',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${AppHelpers.formatPrice(booking.totalAmount)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (isUpcoming || isCheckedIn) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (isUpcoming)
                      OutlinedButton(
                        onPressed: onNavigate,
                        child: const Text('Navigate'),
                      ),
                    if (isUpcoming)
                      OutlinedButton(
                        onPressed: onCheckIn,
                        child: const Text('Check In'),
                      ),
                    if (isCheckedIn)
                      ElevatedButton(
                        onPressed: onCheckOut,
                        child: const Text('Check Out'),
                      ),
                    if (isUpcoming)
                      TextButton(
                        onPressed: onCancel,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    return '${local.day}/${local.month}/${local.year} $hour:$minute $period';
  }
}
