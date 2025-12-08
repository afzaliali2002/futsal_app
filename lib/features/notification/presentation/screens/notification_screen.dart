import 'package:flutter/material.dart';
import 'package:futsal_app/features/notification/presentation/providers/notification_view_model.dart';
import 'package:futsal_app/features/notification/presentation/widgets/notification_card.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('اعلان‌ها'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: vm.notifications.isEmpty
          ? const Center(
              child: Text('هیچ اعلانی یافت نشد.'),
            )
          : ListView.builder(
              itemCount: vm.notifications.length,
              itemBuilder: (context, index) {
                final notification = vm.notifications[index];
                return NotificationCard(notification: notification);
              },
            ),
    );
  }
}
