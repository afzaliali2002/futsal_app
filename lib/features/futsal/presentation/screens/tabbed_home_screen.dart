import 'package:flutter/material.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import 'futsal_list_screen.dart';

class TabbedHomeScreen extends StatefulWidget {
  const TabbedHomeScreen({super.key});

  @override
  State<TabbedHomeScreen> createState() => _TabbedHomeScreenState();
}

class _TabbedHomeScreenState extends State<TabbedHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FutsalListScreen(), // Tab 1: Home
    const Center(child: Text('صفحه جستجو')),        // Tab 2: Search
    const Center(child: Text('علاقه‌مندی‌ها')),     // Tab 3: Favorites
    const Center(child: Text('اعلان‌ها')),          // Tab 4: Notifications
    const ProfileScreen(),           // Tab 5: Profile
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
