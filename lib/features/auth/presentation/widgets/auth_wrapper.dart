import 'package:flutter/material.dart';
import 'package:futsal_app/features/auth/presentation/screens/login-screen.dart';
import 'package:futsal_app/features/futsal/presentation/screens/tabbed_home_screen.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();

    if (userViewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userViewModel.user != null) {
      return const TabbedHomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
