
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../futsal/presentation/screens/tabbed_home_screen.dart';
import 'login-screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user != null) {
      return const TabbedHomeScreen();
    }
    return const LoginScreen();
  }
}
