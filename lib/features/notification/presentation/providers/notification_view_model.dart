import 'package:flutter/material.dart';
import 'package:futsal_app/features/notification/domain/entities/notification.dart' as app_notification;
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationViewModel extends ChangeNotifier {
  List<app_notification.Notification> _notifications = [];
  List<app_notification.Notification> get notifications => _notifications;

  NotificationViewModel() {
    _fetchNotifications();
  }

  void _fetchNotifications() {
    FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        return app_notification.Notification(
          id: doc.id,
          title: data['title'] ?? '',
          body: data['body'] ?? '',
          timestamp: data['timestamp'] ?? Timestamp.now(),
          isRead: data['isRead'] ?? false,
        );
      }).toList();
      notifyListeners();
    });
  }

  void markAsRead(app_notification.Notification notification) {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(notification.id)
        .update({'isRead': true});
  }
}
