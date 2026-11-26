import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/routes.dart';
import '../../services/api_service.dart';
import '../../services/booking_service.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';

class ScanToParkScreen extends StatefulWidget {
  const ScanToParkScreen({super.key});

  @override
  State<ScanToParkScreen> createState() => _ScanToParkScreenState();
}

class _ScanToParkScreenState extends State<ScanToParkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bookingIdController = TextEditingController();
  final _qrCodeController = TextEditingController();
  bool _isLoading = false;
  bool _showScanner = false;
  bool _scanHandled = false;
  String? _lastInvalidValue;

  @override
  void dispose() {
    _bookingIdController.dispose();
    _qrCodeController.dispose();
    super.dispose();
  }

  ({String bookingId, String qrCode})? _parseQrPayload(String value) {
    final parts = value.trim().split(':');
    if (parts.length < 4 || parts[0] != 'parkease' || parts[1] != 'booking') {
      return null;
    }
    final bookingId = parts[2].trim();
    final qrCode = parts.sublist(3).join(':').trim();
    if (bookingId.isEmpty || qrCode.isEmpty) return null;
    return (bookingId: bookingId, qrCode: qrCode);
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_scanHandled) return;
    final value = capture.barcodes.firstOrNull?.displayValue;
    if (value == null || value.isEmpty) return;

    final parsed = _parseQrPayload(value);
    if (parsed == null) {
      if (_lastInvalidValue != value && mounted) {
        _lastInvalidValue = value;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This is not a Park Ease booking QR code'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    _scanHandled = true;
    _bookingIdController.text = parsed.bookingId;
    _qrCodeController.text = parsed.qrCode;
    setState(() => _showScanner = false);
    unawaited(_checkIn());
  }

  Future<void> _checkIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final booking = await BookingService().checkIn(
        _bookingIdController.text.trim(),
        _qrCodeController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checked in successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.currentParking,
          arguments: {'bookingId': booking.id},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ApiService.describeError(e)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) return _buildScannerView();
    return Scaffold(
      appBar: AppBar(title: const Text('Scan to Park')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 412),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                children: [
                  Icon(
                    Icons.qr_code_scanner_outlined,
                    size: 72,
                    color: const Color(0xFF126E63),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Enter your booking code',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use the code from your confirmed booking to start parking.',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _bookingIdController,
                    validator: (value) =>
                        AppValidators.required(value, 'Booking ID'),
                    decoration: const InputDecoration(
                      labelText: 'Booking ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _qrCodeController,
                    validator: (value) =>
                        AppValidators.required(value, 'QR code'),
                    decoration: const InputDecoration(
                      labelText: 'QR code',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _scanHandled = false;
                      _lastInvalidValue = null;
                      _showScanner = true;
                    }),
                    icon: const Icon(Icons.qr_code_scanner_outlined),
                    label: const Text('Scan QR Code'),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Check In',
                    isLoading: _isLoading,
                    onPressed: _checkIn,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScannerView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Booking QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => setState(() => _showScanner = false),
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(onDetect: _handleBarcode),
          const Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.greenAccent, width: 3),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.viewPaddingOf(context).bottom + 32,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Align the Park Ease booking QR code inside the frame',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
