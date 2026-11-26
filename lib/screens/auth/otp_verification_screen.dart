import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String purpose;
  final String? devOtp;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.purpose = 'register',
    this.devOtp,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _resendTimer = 60;
  Timer? _resendCountdown;
  String? _devOtp;

  @override
  void initState() {
    super.initState();
    _devOtp = widget.devOtp;
    _resendCountdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_resendTimer > 0) _resendTimer--;
      });
    });
  }

  @override
  void dispose() {
    _resendCountdown?.cancel();
    for (final c in _otpController) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _otpController.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.purpose == 'password_reset') {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.resetPassword,
          arguments: {'email': widget.email, 'otp': _otp},
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final auth = context.read<AuthService>();
    try {
      await auth.verifyOtp(widget.email, _otp);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Map<String, dynamic>?> _sendCode({required bool showError}) async {
    try {
      final response = await context.read<AuthService>().sendOtp(
        widget.email,
        purpose: widget.purpose,
      );
      final devOtp = response['devOtp'];
      if (devOtp is String && mounted) {
        setState(() => _devOtp = devOtp);
      }
      return response;
    } catch (e) {
      if (showError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ApiService.describeError(e)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _resend() async {
    if (_resendTimer > 0) return;
    setState(() => _resendTimer = 60);
    await _sendCode(showError: true);
  }

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 412),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              children: [
                Text(
                  'Verify Your Email',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a 6-digit code to ${widget.email}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                if (_devOtp != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F5F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Development code: $_devOtp',
                      style: const TextStyle(
                        color: Color(0xFF126E63),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Row(
                    spacing: 8,
                    children: List.generate(6, (index) {
                      return Expanded(
                        child: TextField(
                          controller: _otpController[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          obscuringCharacter: '•',
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFC8C7D4),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFC8C7D4),
                                width: 1,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onTap: () {
                            _otpController[index].selection =
                                TextSelection.collapsed(offset: 0);
                          },
                          onChanged: (value) => _onChanged(index, value),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Verify',
                  isLoading: _isLoading,
                  onPressed: _verify,
                ),
                const SizedBox(height: 24),
                Row(
                  spacing: 6,
                  children: [
                    const Expanded(
                      child: Text(
                        "Didn't receive the code?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _resendTimer > 0 ? null : _resend,
                      child: Text(
                        _resendTimer > 0
                            ? 'Resend in ${_resendTimer}s'
                            : 'Resend',
                        style: TextStyle(
                          color: _resendTimer > 0
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF6B1111),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
