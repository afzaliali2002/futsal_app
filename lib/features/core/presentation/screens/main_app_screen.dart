import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/presentation/screens/futsal_list_screen.dart';
import '../../../auth/presentation/screens/notifications_screen.dart';
import '../../../booking/presentation/screens/favorites_screen.dart';
import '../widgets/custom_bottom_nav.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FutsalListScreen(),
    const FavoritesScreen(),
    const NotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
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
