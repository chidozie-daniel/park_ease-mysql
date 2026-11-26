import 'package:material_ui/material_ui.dart';

import '../../app/routes.dart';
import '../../services/booking_service.dart';
import '../../services/parking_service.dart';
import '../../utils/utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../models/booking.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String bookingId;

  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final _bookingService = BookingService();
  final _parkingService = ParkingService();

  late Future<_ConfirmationDetails> _details = _load();

  Future<_ConfirmationDetails> _load() async {
    final booking = await _bookingService.getBooking(widget.bookingId);
    var lotName = 'Parking lot';
    var slotNumber = 'Not selected';

    try {
      final lot = await _parkingService.getParkingLot(booking.parkingLotId);
      lotName = lot.name;
      if (booking.parkingSlotId != null) {
        final slots = await _parkingService.getParkingSlots(lot.id);
        for (final slot in slots) {
          if (slot.id == booking.parkingSlotId) {
            slotNumber = slot.slotNumber;
            break;
          }
        }
      }
    } catch (_) {}

    return _ConfirmationDetails(
      booking: booking,
      lotName: lotName,
      slotNumber: slotNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 412),
                    child: FutureBuilder<_ConfirmationDetails>(
                      future: _details,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LoadingIndicator();
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return _buildError();
                        }
                        return _buildContent(snapshot.data!);
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Booking created, but details could not be loaded.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Booking ID: ${widget.bookingId}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Retry',
            onPressed: () {
              setState(() => _details = _load());
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.home),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(_ConfirmationDetails details) {
    final booking = details.booking;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF126E63).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 72,
            color: Color(0xFF126E63),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Booking Confirmed!',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Your parking spot has been reserved successfully.',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildRow('Booking ID', booking.id),
              const SizedBox(height: 12),
              _buildRow('Parking Lot', details.lotName),
              const SizedBox(height: 12),
              _buildRow('Slot', details.slotNumber),
              const SizedBox(height: 12),
              _buildRow('Date', AppHelpers.formatDate(booking.startTime)),
              const SizedBox(height: 12),
              _buildRow(
                'Time',
                '${_formatTime(booking.startTime)} - '
                    '${_formatTime(booking.endTime)}',
              ),
              const SizedBox(height: 12),
              _buildRow('Amount', AppHelpers.formatPrice(booking.totalAmount)),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AppButton(
            label: 'View Booking Details',
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.bookingDetails,
              arguments: {'bookingId': booking.id},
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.home),
          child: const Text('Back to Home'),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ConfirmationDetails {
  final Booking booking;
  final String lotName;
  final String slotNumber;

  const _ConfirmationDetails({
    required this.booking,
    required this.lotName,
    required this.slotNumber,
  });
}
