import 'package:flutter/material.dart';

import '../../models/vehicle.dart';
import '../../services/api_service.dart';
import '../../services/booking_service.dart';
import '../../services/vehicle_service.dart';
import '../../utils/utils.dart';
import '../../widgets/app_button.dart';

/// Lets the user pick a vehicle + time window, then creates a booking.
/// Navigates to /booking-confirmation on success.
class BookingFormScreen extends StatefulWidget {
  final String parkingLotId;
  final String? parkingSlotId;

  const BookingFormScreen({
    super.key,
    required this.parkingLotId,
    this.parkingSlotId,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _bookingService = BookingService();
  final _vehicleService = VehicleService();

  List<Vehicle> _vehicles = [];
  bool _loadingVehicles = true;
  String? _vehiclesError;

  Vehicle? _selectedVehicle;
  DateTime _startTime = DateTime.now().add(const Duration(minutes: 5));
  DateTime _endTime = DateTime.now().add(const Duration(hours: 2, minutes: 5));

  bool _isBooking = false;
  String? _bookingError;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _loadingVehicles = true;
      _vehiclesError = null;
    });
    try {
      final vehicles = await _vehicleService.getMyVehicles();
      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          // Pre-select the default vehicle if one exists
          _selectedVehicle = vehicles.firstWhere(
            (v) => v.isDefault,
            orElse: () => vehicles.isNotEmpty ? vehicles.first : vehicles.first,
          );
        });
      }
    } catch (e) {
      if (mounted) setState(() => _vehiclesError = ApiService.describeError(e));
    } finally {
      if (mounted) setState(() => _loadingVehicles = false);
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = picked;
        if (_endTime.isBefore(_startTime.add(const Duration(minutes: 15)))) {
          _endTime = _startTime.add(const Duration(hours: 1));
        }
      } else {
        _endTime = picked;
      }
    });
  }

  bool get _isValid {
    return _selectedVehicle != null &&
        _endTime.isAfter(_startTime.add(const Duration(minutes: 14)));
  }

  Future<void> _book() async {
    if (!_isValid) return;
    setState(() {
      _isBooking = true;
      _bookingError = null;
    });
    try {
      final booking = await _bookingService.createBooking(
        parkingLotId: widget.parkingLotId,
        parkingSlotId: widget.parkingSlotId,
        vehicleId: _selectedVehicle!.id,
        startTime: _startTime,
        endTime: _endTime,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/booking-confirmation',
          arguments: {'bookingId': booking.id},
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _bookingError = ApiService.describeError(e));
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  String _formatDateTime(DateTime dt) {
    final hour = TimeOfDay.fromDateTime(dt);
    final h = hour.hourOfPeriod == 0 ? 12 : hour.hourOfPeriod;
    final m = hour.minute.toString().padLeft(2, '0');
    final period = hour.period == DayPeriod.am ? 'AM' : 'PM';
    return '${dt.day}/${dt.month}/${dt.year}  $h:$m $period';
  }

  Duration get _duration => _endTime.difference(_startTime);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Slot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Vehicle ──────────────────────────────────────────────
          _sectionTitle('Select Vehicle'),
          const SizedBox(height: 12),
          if (_loadingVehicles)
            const Center(child: CircularProgressIndicator())
          else if (_vehiclesError != null)
            _errorWidget(_vehiclesError!, _loadVehicles)
          else if (_vehicles.isEmpty)
            _emptyVehicles()
          else
            ..._vehicles.map((v) => _vehicleTile(v)),

          const SizedBox(height: 24),

          // ── Start Time ───────────────────────────────────────────
          _sectionTitle('Start Time'),
          const SizedBox(height: 8),
          _timeTile(
            label: _formatDateTime(_startTime),
            onTap: () => _pickDate(isStart: true),
          ),

          const SizedBox(height: 16),

          // ── End Time ─────────────────────────────────────────────
          _sectionTitle('End Time'),
          const SizedBox(height: 8),
          _timeTile(
            label: _formatDateTime(_endTime),
            onTap: () => _pickDate(isStart: false),
          ),

          const SizedBox(height: 16),

          // ── Duration summary ────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF126E63).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    color: Color(0xFF126E63), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${AppHelpers.formatDuration(_duration)}',
                  style: const TextStyle(
                    color: Color(0xFF126E63),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (_bookingError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _bookingError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],

          const SizedBox(height: 32),

          AppButton(
            label: 'Book Now',
            onPressed: _isValid ? _book : null,
            isLoading: _isBooking,
            backgroundColor: const Color(0xFF126E63),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _vehicleTile(Vehicle v) {
    final isSelected = _selectedVehicle?.id == v.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicle = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF126E63).withValues(alpha: 0.07)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF126E63)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _vehicleIcon(v.type),
                color: const Color(0xFF9894BD),
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${v.brand} ${v.model}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    v.licensePlate,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (v.isDefault)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF126E63).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: Color(0xFF126E63),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF126E63), size: 22),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timeTile({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 18, color: Color(0xFF9894BD)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _emptyVehicles() {
    return Column(
      children: [
        const Text(
          'No vehicles added yet. Add a vehicle to book.',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pushNamed(context, '/add-vehicle'),
          child: const Text('Add Vehicle'),
        ),
      ],
    );
  }

  Widget _errorWidget(String msg, VoidCallback retry) {
    return Column(
      children: [
        Text(msg, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 8),
        TextButton(onPressed: retry, child: const Text('Retry')),
      ],
    );
  }

  IconData _vehicleIcon(VehicleType type) {
    return switch (type) {
      VehicleType.car => Icons.directions_car_rounded,
      VehicleType.bike => Icons.directions_bike_rounded,
      VehicleType.scooter => Icons.electric_scooter_rounded,
      VehicleType.truck => Icons.local_shipping_rounded,
    };
  }
}
