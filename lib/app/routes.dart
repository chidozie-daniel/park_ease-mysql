import 'package:flutter/material.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/password_reset_success_screen.dart';
import '../screens/user/home_screen.dart';
import '../screens/user/search_parking_screen.dart';
import '../screens/user/parking_results_screen.dart';
import '../screens/user/parking_details_screen.dart';
import '../screens/user/select_slot_screen.dart';
import '../screens/user/navigate_parking_screen.dart';
import '../screens/user/booking_confirmation_screen.dart';
import '../screens/user/booking_details_screen.dart';
import '../screens/user/my_bookings_screen.dart';
import '../screens/user/current_parking_screen.dart';
import '../screens/user/booking_history_screen.dart';
import '../screens/user/profile_screen.dart';
import '../screens/user/edit_profile_screen.dart';
import '../screens/user/my_vehicles_screen.dart';
import '../screens/user/add_vehicle_screen.dart';
import '../screens/user/payment_screen.dart';
import '../screens/user/notifications_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/manage_users_screen.dart';
import '../screens/admin/manage_parking_lots_screen.dart';
import '../screens/admin/manage_bookings_screen.dart';
import '../screens/admin/reports_analytics_screen.dart';
import '../screens/admin/admin_notifications_screen.dart';
import '../screens/admin/add_edit_parking_lot_screen.dart';
import '../screens/admin/admin_booking_details_screen.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/';
  static const login = '/login';
  static const register = '/register';
  static const otpVerification = '/otp-verification';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const passwordResetSuccess = '/password-reset-success';

  static const home = '/home';
  static const searchParking = '/search-parking';
  static const parkingResults = '/parking-results';
  static const parkingDetails = '/parking-details';
  static const selectSlot = '/select-slot';
  static const navigateParking = '/navigate-parking';
  static const bookingConfirmation = '/booking-confirmation';
  static const bookingDetails = '/booking-details';
  static const myBookings = '/my-bookings';
  static const currentParking = '/current-parking';
  static const bookingHistory = '/booking-history';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const myVehicles = '/my-vehicles';
  static const addVehicle = '/add-vehicle';
  static const payment = '/payment';
  static const notifications = '/notifications';

  static const adminDashboard = '/admin-dashboard';
  static const adminLogin = '/admin-login';
  static const manageUsers = '/manage-users';
  static const manageParkingLots = '/manage-parking-lots';
  static const manageBookings = '/manage-bookings';
  static const reportsAnalytics = '/reports-analytics';
  static const adminNotifications = '/admin-notifications';
  static const addEditParkingLot = '/add-edit-parking-lot';
  static const adminBookingDetails = '/admin-booking-details';

  static Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _route(const SplashScreen());
      case welcome:
        return _route(const WelcomeScreen());
      case login:
        return _route(const LoginScreen());
      case register:
        return _route(const RegisterScreen());
      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return _route(OtpVerificationScreen(
          email: args?['email'] ?? '',
        ));
      case forgotPassword:
        return _route(const ForgotPasswordScreen());
      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        return _route(ResetPasswordScreen(
          email: args?['email'] ?? '',
          otp: args?['otp'] ?? '',
        ));
      case passwordResetSuccess:
        return _route(const PasswordResetSuccessScreen());
      case home:
        return _route(const HomeScreen());
      case searchParking:
        return _route(const SearchParkingScreen());
      case parkingResults:
        final args = settings.arguments as Map<String, dynamic>?;
        return _route(ParkingResultsScreen(
          query: args?['query'] ?? '',
        ));
      case parkingDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return _route(ParkingDetailsScreen(
          parkingLotId: args?['parkingLotId'] ?? '',
        ));
      case selectSlot:
        final args = settings.arguments as Map<String, dynamic>?;
        return _route(SelectSlotScreen(
          parkingLotId: args?['parkingLotId'] ?? '',
        ));
      case navigateParking:
        final args = settings.arguments as Map<String, dynamic>?;
        return _route(NavigateParkingScreen(
          parkingLotId: args?['parkingLotId'] ?? '',
        ));
      case bookingConfirmation:
        final args = settings.arguments as Map<String, dynamic>?;
        return _route(BookingConfirmationScreen(
          bookingId: args?['bookingId'] ?? '',
        ));
      case bookingDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return _route(BookingDetailsScreen(
          bookingId: args?['bookingId'] ?? '',
        ));
      case myBookings:
        return _route(const MyBookingsScreen());
      case currentParking:
        final args = settings.arguments as Map<String, dynamic>?;
        return _route(CurrentParkingScreen(
          bookingId: args?['bookingId'] ?? '',
        ));
      case bookingHistory:
        return _route(const BookingHistoryScreen());
      case profile:
        return _route(const ProfileScreen());
      case editProfile:
        return _route(const EditProfileScreen());
      case myVehicles:
        return _route(const MyVehiclesScreen());
      case addVehicle:
        return _route(const AddVehicleScreen());
      case payment:
        final args = settings.arguments as Map<String, dynamic>?;
        return _route(PaymentScreen(
          bookingId: args?['bookingId'] ?? '',
          amount: args?['amount'] ?? 0.0,
        ));
      case notifications:
        return _route(const NotificationsScreen());
      case adminDashboard:
        return _route(const AdminDashboardScreen());
      case adminLogin:
        return _route(const AdminLoginScreen());
      case manageUsers:
        return _route(const ManageUsersScreen());
      case manageParkingLots:
        return _route(const ManageParkingLotsScreen());
      case manageBookings:
        return _route(const ManageBookingsScreen());
      case reportsAnalytics:
        return _route(const ReportsAnalyticsScreen());
      case adminNotifications:
        return _route(const AdminNotificationsScreen());
      case addEditParkingLot:
        final args = settings.arguments as Map<String, dynamic>?;
        return _route(AddEditParkingLotScreen(
          parkingLotId: args?['parkingLotId'],
        ));
      case adminBookingDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return _route(AdminBookingDetailsScreen(
          bookingId: args?['bookingId'] ?? '',
        ));
    }
    return null;
  }

  static PageRoute _route(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}