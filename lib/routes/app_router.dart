// lib/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:futsal_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:futsal_app/features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/login-screen.dart';
import 'app_routes.dart';
// import HomeScreen later

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
    // case AppRoutes.home:
    //   return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text('Page not found: ${AppRoutes.login}')),
      ),
    );
  }
}