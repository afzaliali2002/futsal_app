import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futsal_app/features/notification/domain/entities/notification.dart';

class NotificationModel extends Notification {
  NotificationModel({
    required String id,
    required String title,
    required String body,
    required Timestamp timestamp,
    bool isRead = false,
  }) : super(
          id: id,
          title: title,
          body: body,
          timestamp: timestamp,
          isRead: isRead,
        );

  factory NotificationModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return NotificationModel(
      id: snapshot.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}
