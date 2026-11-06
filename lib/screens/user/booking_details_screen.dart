import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../models/booking.dart';
import '../../services/api_service.dart';
import '../../services/booking_service.dart';
import '../../utils/utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/loading_indicator.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final _service = BookingService();
  late Future<Booking> _booking;

  @override
  void initState() {
    super.initState();
    _booking = _service.getBooking(widget.bookingId);
  }

  Future<void> _copyBooking(Booking booking) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            'Park Ease booking ${booking.id}\n'
            'Parking lot: ${booking.parkingLotId}\n'
            'Start: ${booking.startTime.toLocal()}\n'
            'End: ${booking.endTime.toLocal()}',
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Booking details copied.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        actions: [
          IconButton(
            tooltip: 'Copy booking details',
            icon: const Icon(Icons.share_rounded),
            onPressed: () async {
              final booking = await _booking;
              if (mounted) await _copyBooking(booking);
            },
          ),
        ],
      ),
      body: FutureBuilder<Booking>(
        future: _booking,
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
                    TextButton(
                      onPressed: () => setState(
                        () => _booking = _service.getBooking(widget.bookingId),
                      ),
                      child: const Text('Try again'),
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

  Widget _details(Booking booking) {
    final isActive = booking.status == BookingStatus.checkedIn;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.local_parking_rounded,
                  size: 56,
                  color: Color(0xFF126E63),
                ),
                const SizedBox(height: 12),
                Text(
                  booking.status.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF126E63),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Divider(height: 32),
                _row('Booking ID', booking.id),
                _row('Parking Lot', booking.parkingLotId),
                if (booking.parkingSlotId != null)
                  _row('Slot', booking.parkingSlotId!),
                _row('Vehicle', booking.vehicleId),
                _row('Start', _formatDateTime(booking.startTime)),
                _row('End', _formatDateTime(booking.endTime)),
                _row('Duration', AppHelpers.formatDuration(booking.duration)),
                _row('Total', AppHelpers.formatPrice(booking.totalAmount)),
                if (booking.qrCode?.isNotEmpty ?? false) ...[
                  const Divider(height: 28),
                  const Text(
                    'Check-in code',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(booking.qrCode!),
                  const SizedBox(height: 4),
                  const Text(
                    'Show this code to parking staff when you arrive.',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (isActive)
          AppButton(
            label: 'Navigate to Parking',
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.navigateParking,
              arguments: {'parkingLotId': booking.parkingLotId},
            ),
          ),
        if (booking.status == BookingStatus.pending ||
            booking.status == BookingStatus.confirmed) ...[
          AppButton(
            label: 'Navigate to Parking',
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.navigateParking,
              arguments: {'parkingLotId': booking.parkingLotId},
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.payment,
              arguments: {
                'bookingId': booking.id,
                'amount': booking.totalAmount,
              },
            ),
            child: const Text('Go to Payment'),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.myBookings,
            (route) => route.settings.name == AppRoutes.home,
          ),
          child: const Text('Back to My Bookings'),
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 12),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
