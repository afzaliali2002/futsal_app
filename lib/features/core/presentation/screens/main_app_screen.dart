// lib/features/core/presentation/screens/main_app_screen.dart

import 'package:flutter/material.dart';
import '../../../auth/presentation/screens/home_screen.dart';
import '../../../auth/presentation/screens/notifications_screen.dart';
import '../../../auth/presentation/screens/profile_screen.dart';
import '../../../booking/presentation/screens/favorites_screen.dart';
import '../../../futsal/presentation/screens/search_screen.dart';
import '../widgets/custom_bottom_nav.dart';

// Import all screens
import 'package:futsal_app/features/auth/presentation/screens/home_screen.dart';
class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
     HomeScreen(),           // خانه
    const SearchScreen(),         // جستجو
    const FavoritesScreen(),      // علاقه‌مندی‌ها
    const NotificationsScreen(),  // اعلان‌ها
    const ProfileScreen(),        // پروفایل
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: CustomBottomNav(
          currentIndex: _currentIndex,
          onTabTapped: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}