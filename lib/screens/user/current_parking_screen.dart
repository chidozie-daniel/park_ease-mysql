import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../app/routes.dart';
import '../../models/booking.dart';
import '../../models/parking_lot.dart';
import '../../services/api_service.dart';
import '../../services/booking_service.dart';
import '../../services/parking_service.dart';
import '../../utils/utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/loading_indicator.dart';

class CurrentParkingScreen extends StatefulWidget {
  final String bookingId;

  const CurrentParkingScreen({super.key, required this.bookingId});

  @override
  State<CurrentParkingScreen> createState() => _CurrentParkingScreenState();
}

class _CurrentParkingScreenState extends State<CurrentParkingScreen> {
  final _bookingService = BookingService();
  final _parkingService = ParkingService();

  late Future<_SessionDetails> _details = _load();
  Timer? _timer;
  DateTime _now = DateTime.now();
  String? _actionError;
  bool _isEnding = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<_SessionDetails> _load() async {
    final booking = await _bookingService.getBooking(widget.bookingId);
    if (booking.status != BookingStatus.checkedIn) {
      throw StateError('This booking is not an active parking session.');
    }

    ParkingLot? lot;
    var slotNumber = 'Not selected';
    try {
      lot = await _parkingService.getParkingLot(booking.parkingLotId);
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

    return _SessionDetails(
      booking: booking,
      lot: lot,
      slotNumber: slotNumber,
    );
  }

  Future<void> _endParking(_SessionDetails details) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End parking?'),
        content: const Text('This will check out of your reserved space.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep parking'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End Parking'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _isEnding = true;
      _actionError = null;
    });
    try {
      await _bookingService.checkOut(details.booking.id);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.bookingDetails,
        arguments: {'bookingId': details.booking.id},
      );
    } catch (error) {
      if (mounted) {
        setState(() => _actionError = ApiService.describeError(error));
      }
    } finally {
      if (mounted) setState(() => _isEnding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFDEDCEC),
            child: const Center(
              child: Icon(Icons.map_rounded, size: 80, color: Color(0xFF9894BD)),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: FutureBuilder<_SessionDetails>(
                future: _details,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 320,
                      child: Center(child: LoadingIndicator()),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return _buildError(snapshot.error);
                  }
                  return _buildSession(snapshot.data!);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object? error) {
    final message = error is StateError
        ? error.message
        : 'Could not load this parking session.';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 56, color: Colors.red),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        AppButton(
          label: 'Retry',
          onPressed: () => setState(() => _details = _load()),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(
            context,
            AppRoutes.bookingDetails,
            arguments: {'bookingId': widget.bookingId},
          ),
          child: const Text('View Booking Details'),
        ),
      ],
    );
  }

  Widget _buildSession(_SessionDetails details) {
    final booking = details.booking;
    final elapsed = _elapsedSince(booking.startTime);
    final cost = _runningCost(details);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Currently Parked',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          details.lot?.name ?? 'Parking lot',
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Slot ${details.slotNumber}',
          style: const TextStyle(
            color: Color(0xFF126E63),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Divider(height: 32),
        _buildInfoRow(
          Icons.access_time_outlined,
          'Started at',
          _formatTime(booking.startTime),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          Icons.timer_outlined,
          'Elapsed time',
          AppHelpers.formatDuration(elapsed),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          Icons.attach_money_outlined,
          'Current cost',
          cost == null ? 'Unavailable' : 'Rs ${cost.toStringAsFixed(2)}',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.qr_code_rounded, color: Color(0xFF126E63)),
              const SizedBox(width: 8),
              Expanded(
                child: SelectableText(
                  'Exit code: ${booking.qrCode ?? 'Not available'}',
                  maxLines: 2,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        if (_actionError != null) ...[
          const SizedBox(height: 12),
          Text(
            _actionError!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        AppButton(
          label: 'End Parking',
          isLoading: _isEnding,
          onPressed: () => _endParking(details),
        ),
      ],
    );
  }

  Duration _elapsedSince(DateTime start) {
    final end = _now.isBefore(start) ? start : _now;
    return end.difference(start);
  }

  double? _runningCost(_SessionDetails details) {
    final lot = details.lot;
    if (lot == null) return null;
    final hours = _elapsedSince(details.booking.startTime).inMinutes / 60.0;
    if (hours >= 24) {
      final dailyRate = lot.dailyRate ?? lot.hourlyRate * 24;
      return (hours / 24).ceil() * dailyRate;
    }
    return hours * lot.hourlyRate;
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
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

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _SessionDetails {
  final Booking booking;
  final ParkingLot? lot;
  final String slotNumber;

  const _SessionDetails({
    required this.booking,
    required this.lot,
    required this.slotNumber,
  });
}
