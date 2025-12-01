import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/auth/presentation/screens/home_screen.dart';
import '../features/auth/presentation/screens/login-screen.dart';
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase is connecting...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is logged in → Home
        if (snapshot.hasData) {
          return  HomeScreen();
        }

        // User not logged in → Login
        return const LoginScreen();
      },
    );
  }
}
