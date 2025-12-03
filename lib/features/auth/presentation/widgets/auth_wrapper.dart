import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futsal_app/features/auth/presentation/screens/login-screen.dart';
import 'package:futsal_app/features/futsal/presentation/screens/tabbed_home_screen.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // If user is logged in, show home screen.
    if (user != null) {
      return const TabbedHomeScreen();
    }

    // If user is not logged in, show login screen.
    return const LoginScreen();
  }
}
