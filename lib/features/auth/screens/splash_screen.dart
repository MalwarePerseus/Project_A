// lib/features/auth/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_a/features/auth/providers/auth_provider.dart';
import 'package:project_a/features/auth/screens/onboarding_screen.dart';
import 'package:project_a/features/auth/screens/login_screen.dart';
import 'package:project_a/features/home/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation; // Fixed: Added type parameter <double>

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      // Fixed: Added type parameter <double>
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();

    // Navigate after animation completes
    Future.delayed(Duration(seconds: 3), () {
      _checkFirstTimeAndNavigate();
    });
  }

  Future<void> _checkFirstTimeAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      // First time user, show onboarding
      await prefs.setBool('isFirstTime', false);
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => OnboardingScreen()));
    } else {
      // Check if user is logged in
      final authState = ref.read(authStateProvider);

      authState.when(
        data: (user) {
          if (user != null) {
            // User is logged in, go to home
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
          } else {
            // User is not logged in, go to login
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
          }
        },
        loading: () {
          // Keep showing splash screen
        },
        error: (_, __) {
          // Error occurred, go to login
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
        },
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/app_logo.png',
                width: 150,
                height: 150,
              ),
              SizedBox(height: 24),
              Text(
                'Super Alarmy',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Wake up on time, every time',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
