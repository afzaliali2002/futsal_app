import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/presentation/screens/favorite_futsal_screen.dart';
import 'package:futsal_app/features/notification/presentation/screens/notification_screen.dart';
import 'futsal_list_screen.dart';

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
    const NotificationScreen(),
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
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
            icon: Icon(Icons.notifications_outlined),
            label: 'اعلان‌ها',
          ),
        ],
      ),
    );
  }
}
