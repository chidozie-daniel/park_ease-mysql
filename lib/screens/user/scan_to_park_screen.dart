import 'package:material_ui/material_ui.dart';

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

  @override
  void dispose() {
    _bookingIdController.dispose();
    _qrCodeController.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Scan to Park')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 412),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                    validator: (value) => AppValidators.required(value, 'Booking ID'),
                    decoration: const InputDecoration(
                      labelText: 'Booking ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _qrCodeController,
                    validator: (value) => AppValidators.required(value, 'QR code'),
                    decoration: const InputDecoration(
                      labelText: 'QR code',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),
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
}
