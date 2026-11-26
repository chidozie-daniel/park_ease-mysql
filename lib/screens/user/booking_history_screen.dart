import 'package:material_ui/material_ui.dart';

import 'my_bookings_screen.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyBookingsScreen(
      initialTab: 2,
      title: 'Booking History',
    );
  }
}
