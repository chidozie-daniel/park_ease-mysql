import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthService>();

    // Hold the splash briefly so it does not flash, but never block navigation
    // on a fixed delay the way an unconditional sleep would.
    const minimumDisplay = Duration(milliseconds: 1500);
    final stopwatch = Stopwatch()..start();

    await auth.init();

    final remaining = minimumDisplay - stopwatch.elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted) return;

    if (auth.isAuthenticated) {
      if (auth.isAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, -0.00),
            end: Alignment(0.50, 1.00),
            colors: [Colors.white, Color(0xFFC5C1CC)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/splash_logo.png',
                width: 331,
                height: 221,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 24),
              const Text(
                'PARK EASE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      offset: Offset(0, -1),
                      blurRadius: 0,
                      color: Colors.black,
                    ),
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 0,
                      color: Colors.black,
                    ),
                    Shadow(
                      offset: Offset(-1, 0),
                      blurRadius: 0,
                      color: Colors.black,
                    ),
                    Shadow(
                      offset: Offset(1, 0),
                      blurRadius: 0,
                      color: Colors.black,
                    ),
                    Shadow(
                      offset: Offset(-1, -1),
                      blurRadius: 0,
                      color: Colors.black,
                    ),
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 0,
                      color: Colors.black,
                    ),
                    Shadow(
                      offset: Offset(-1, 1),
                      blurRadius: 0,
                      color: Colors.black,
                    ),
                    Shadow(
                      offset: Offset(1, -1),
                      blurRadius: 0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'smart parking, effortless living',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.80,
                ),
              ),
              const SizedBox(height: 40),
              const LoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
