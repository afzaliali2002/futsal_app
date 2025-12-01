// features/auth/presentation/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login-screen.dart'; // For hiding status bar

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Hide status bar for full-screen splash
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Navigate to Login after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    // Restore status bar when leaving splash
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Soccer Ball Logo (replace with your asset)
            Image.asset(
              'assets/images/soccer_ball.png',
              height: 150,
            ),
            const SizedBox(height: 32),
            Text(
              'Futsal Booking',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}