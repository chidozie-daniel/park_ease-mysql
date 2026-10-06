import 'package:flutter/material.dart';

import '../../app/routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 412),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: constraints.maxHeight * 0.368,
                      child: Container(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight * 0.363,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/login image.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: constraints.maxHeight * 0.165,
                      child: Text(
                        'PARK EASE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3.40,
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
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: constraints.maxHeight * 0.241,
                      child: Text(
                        'smart parking, \neffortless living',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.10,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 72,
                      top: constraints.maxHeight * 0.082,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.home,
                          );
                        },
                        child: Text(
                          'Skip',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.70,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 26,
                      right: 26,
                      bottom: 56,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9894BD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Sign in',
                                style: TextStyle(color: Color(0xFF783C3E)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
