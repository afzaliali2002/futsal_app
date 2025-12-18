import 'package:futsal_app/features/notification/data/models/notification_model.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> getNotifications(String userId);
  Stream<int> getUnreadNotificationsCount(String userId);
  Future<void> createNotification(NotificationModel notification);
  Future<void> markAsRead(String userId, String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String userId, String notificationId);
}
