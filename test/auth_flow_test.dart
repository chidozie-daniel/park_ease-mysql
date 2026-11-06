import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:park_ease_application/app/routes.dart';
import 'package:park_ease_application/screens/auth/login_screen.dart';
import 'package:park_ease_application/screens/auth/register_screen.dart';
import 'package:park_ease_application/services/auth_service.dart';

void main() {
  testWidgets('login validates required fields before sending a request', (
    tester,
  ) async {
    await _pumpAuthApp(tester);

    final loginButton = find.widgetWithText(ElevatedButton, 'Log In');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('login navigation opens registration with validated fields', (
    tester,
  ) async {
    await _pumpAuthApp(tester);

    final registerLink = find.widgetWithText(TextButton, 'Register');
    await tester.ensureVisible(registerLink);
    await tester.tap(registerLink);
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsNWidgets(2));
    expect(find.text('Name is required'), findsNothing);

    final createAccountButton = find.widgetWithText(
      ElevatedButton,
      'Create Account',
    );
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Phone number is required'), findsOneWidget);
  });

  testWidgets('registration requires agreement to the terms', (tester) async {
    await _pumpAuthApp(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Register'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test Person');
    await tester.enterText(fields.at(1), 'test@example.com');
    await tester.enterText(fields.at(2), '1234567890');
    await tester.enterText(fields.at(3), 'ParkEase123');
    await tester.enterText(fields.at(4), 'ParkEase123');

    final createAccountButton = find.widgetWithText(
      ElevatedButton,
      'Create Account',
    );
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Please agree to the Terms of Service and Privacy Policy.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpAuthApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    Provider<AuthService>.value(
      value: AuthService(),
      child: MaterialApp(
        home: const LoginScreen(),
        routes: {AppRoutes.register: (_) => const RegisterScreen()},
      ),
    ),
  );
  await tester.pumpAndSettle();
}
