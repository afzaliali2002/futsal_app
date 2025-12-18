import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/presentation/screens/favorite_futsal_screen.dart';
import 'package:futsal_app/features/futsal/presentation/screens/futsal_list_screen.dart';
import 'package:futsal_app/features/notification/presentation/providers/notification_view_model.dart';
import 'package:futsal_app/features/notification/presentation/screens/notification_screen.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';
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
    const NotificationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserViewModel>().user;
    final notificationViewModel = context.watch<NotificationViewModel>();

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
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'خانه',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'علاقه‌مندی‌ها',
          ),
          BottomNavigationBarItem(
            icon: StreamBuilder<int>(
              stream: user != null ? notificationViewModel.getUnreadNotificationsCount(user.uid) : Stream.value(0),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined),
                    if (count > 0)
                      Positioned(
                        top: -4,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: 'اعلان‌ها',
          ),
        ],
      ),
    );
  }
}
