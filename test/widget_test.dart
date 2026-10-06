import 'package:flutter_test/flutter_test.dart';

import 'package:park_ease_application/main.dart';

void main() {
  testWidgets('splash screen renders brand and tagline', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ParkEaseApp());

    expect(find.text('PARK EASE'), findsOneWidget);
    expect(find.text('smart parking, effortless living'), findsOneWidget);
  });
}