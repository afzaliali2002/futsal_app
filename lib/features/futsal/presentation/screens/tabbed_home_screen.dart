// lib/features/futsal/presentation/screens/tabbed_home_screen.dart

import 'package:flutter/material.dart';
import '../../../auth/presentation/screens/home_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class TabbedHomeScreen extends StatefulWidget {
  const TabbedHomeScreen({super.key});

  @override
  State<TabbedHomeScreen> createState() => _TabbedHomeScreenState();
}

class _TabbedHomeScreenState extends State<TabbedHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),                                  // Tab 1: Home
    const Center(child: Text('صفحه جستجو')),        // Tab 2: Search
    const Center(child: Text('علاقه‌مندی‌ها')),     // Tab 3: Favorites
    const Center(child: Text('اعلان‌ها')),          // Tab 4: Notifications
    const Center(child: Text('پروفایل')),           // Tab 5: Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
