import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futsal_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:futsal_app/features/auth/presentation/screens/login-screen.dart';
import 'package:futsal_app/features/core/presentation/screens/main_app_screen.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<User?>(context);

    if (firebaseUser == null) {
      // User is not logged in, show login screen.
      return const LoginScreen();
    } else {
      // User is logged in, but we need to verify if they exist in Firestore.
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If document doesn't exist, user was deleted from Firestore.
          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Log the user out from Firebase Auth
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<AuthRepository>().logout();
            });

            // While logging out, show a loader. The stream will update and show the login screen.
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // User is authenticated and their data exists in Firestore.
          return const MainAppScreen();
        },
      );
    }
  }
}
