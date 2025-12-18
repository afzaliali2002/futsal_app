import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  bookingRequest,
  bookingConfirmation,
  bookingCancellation,
  paymentUpdate,
  systemAlert,
}

class NotificationModel {
  final String id;
  final String userId; // The ID of the user who should receive the notification
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> metadata; // e.g., {'bookingId': 'xyz', 'groundId': 'abc'}
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.metadata = const {},
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${data['type']}',
        orElse: () => NotificationType.systemAlert,
      ),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'metadata': metadata,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}
