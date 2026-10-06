import 'package:flutter/foundation.dart';

class ApiConfig {
  // Backend base URL, resolved per platform.
  //
  // - Windows / iOS simulator / web : http://localhost:3000
  // - Android emulator              : http://10.0.2.2:3000
  // - Physical device on LAN        : http://<your-machine-LAN-IP>:3000
  //
  // For a physical device or a non-local deploy, override at build time:
  //   flutter run --dart-define=API_BASE_URL=https://your-tunnel.example.com
  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  // API endpoints
  static const String authLogin = '/api/v1/auth/login';
  static const String authRegister = '/api/v1/auth/register';
  static const String authRefresh = '/api/v1/auth/refresh';
  static const String authLogout = '/api/v1/auth/logout';
  static const String authOtp = '/api/v1/auth/otp';
  static const String authForgotPassword = '/api/v1/auth/forgot-password';
  static const String authResetPassword = '/api/v1/auth/reset-password';

  static const String parkingLots = '/api/v1/parking/lots';
  static const String parkingSlots = '/api/v1/parking/slots';
  static const String parkingSearch = '/api/v1/parking/search';

  static const String bookings = '/api/v1/bookings';
  static const String bookingsHistory = '/api/v1/bookings/history';

  static const String vehicles = '/api/v1/vehicles';
  static const String payments = '/api/v1/payments';
  static const String paymentsHistory = '/api/v1/payments/history';

  static const String notifications = '/api/v1/notifications';

  // Admin endpoints
  static const String adminDashboard = '/api/v1/admin/dashboard';
  static const String adminUsers = '/api/v1/admin/users';
  static const String adminParkingLots = '/api/v1/admin/parking-lots';
  static const String adminBookings = '/api/v1/admin/bookings';
  static const String adminReports = '/api/v1/admin/reports';

  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
}