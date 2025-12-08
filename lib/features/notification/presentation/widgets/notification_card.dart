import 'package:flutter/material.dart';
import 'package:futsal_app/features/notification/domain/entities/notification.dart' as app_notification;

class NotificationCard extends StatelessWidget {
  final app_notification.Notification notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: notification.isRead ? Colors.grey.shade200 : Colors.white,
      child: ListTile(
        title: Text(notification.title, style: theme.textTheme.titleMedium),
        subtitle: Text(notification.body, style: theme.textTheme.bodyMedium),
        trailing: Text(
          '${notification.timestamp.toDate().hour}:${notification.timestamp.toDate().minute}',
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}
