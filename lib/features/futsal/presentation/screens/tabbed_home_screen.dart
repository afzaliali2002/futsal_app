import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/presentation/screens/favorite_futsal_screen.dart';
import 'package:futsal_app/features/futsal/presentation/screens/futsal_list_screen.dart';
import 'package:futsal_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:provider/provider.dart';

class TabbedHomeScreen extends StatefulWidget {
  const TabbedHomeScreen({super.key});

  @override
  State<TabbedHomeScreen> createState() => _TabbedHomeScreenState();
}

class _TabbedHomeScreenState extends State<TabbedHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FutsalListScreen(),
    const FavoriteFutsalScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withAlpha(153),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'خانه',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'علاقه‌مندی‌ها',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'پروفایل',
          ),
        ],
      ),
    );
  }
}
