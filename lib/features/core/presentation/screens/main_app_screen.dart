import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../futsal/presentation/screens/futsal_list_screen.dart';
import '../../../auth/presentation/screens/notifications_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../booking/presentation/screens/favorites_screen.dart';
import '../../../futsal/presentation/screens/search_screen.dart';
import '../widgets/custom_bottom_nav.dart';
import 'package:futsal_app/features/profile/presentation/providers/profile_provider.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FutsalListScreen(),
    const SearchScreen(),
    const FavoritesScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
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
            // When the profile tab is tapped, refresh the user data.
            if (index == 4) {
              context.read<ProfileProvider>().loadUser();
            }
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
