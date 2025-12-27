import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  bookingRequest,
  bookingConfirmation,
  bookingCancellation,
  paymentUpdate,
  systemAlert,
  broadcast, // Add broadcast type
}

class NotificationModel {
  final String id;
  final String userId; // The ID of the user who should receive the notification
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> metadata; // e.g., {'bookingId': 'xyz', 'groundId': 'abc', 'imageUrl': '...'}
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
    
    // Handle String types from Firestore which might be just "broadcast" instead of "NotificationType.broadcast"
    NotificationType parseType(dynamic typeData) {
      if (typeData == null) return NotificationType.systemAlert;
      final typeString = typeData.toString();
      // Check if it already has the prefix
      if (typeString.startsWith('NotificationType.')) {
         return NotificationType.values.firstWhere(
            (e) => e.toString() == typeString,
            orElse: () => NotificationType.systemAlert,
         );
      }
      // Otherwise assume it is the short name (e.g. "broadcast")
      return NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == typeString,
        orElse: () => NotificationType.systemAlert,
      );
    }

    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '', // Might be null for broadcast/manual creation if not strictly enforced
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: parseType(data['type']),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['createdAt'] is Timestamp) 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(), // Fallback if timestamp is missing or processing
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
