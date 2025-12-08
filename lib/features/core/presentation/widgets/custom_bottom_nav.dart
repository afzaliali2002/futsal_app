// lib/features/core/presentation/widgets/custom_bottom_nav.dart

import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: const TextStyle(
          fontFamily: 'BYekan',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'BYekan',
          fontSize: 12,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 22),
            activeIcon: Icon(Icons.home, size: 22),
            label: 'خانه',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border, size: 22),
            activeIcon: Icon(Icons.favorite, size: 22),
            label: 'علاقه‌مندی‌ها',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined, size: 22),
            activeIcon: Icon(Icons.notifications, size: 22),
            label: 'اعلان‌ها',
          ),
        ],
      ),
    );
  }
}
