import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futsal_app/features/notification/data/models/notification_model.dart';
import 'package:futsal_app/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl(this._firestore);

  @override
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => NotificationModel.fromSnapshot(doc)).toList());
  }
  
  @override
  Stream<int> getUnreadNotificationsCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.where((doc) {
             final data = doc.data();
             final type = data['type'] as String?;
             // Filter to count only bookingRequest and bookingConfirmation
             return type == 'bookingRequest' || type == 'bookingConfirmation';
          }).length;
        });
  }

  @override
  Future<void> createNotification(NotificationModel notification) async {
    await _firestore
        .collection('users')
        .doc(notification.userId)
        .collection('notifications')
        .add(notification.toMap());
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
  
  @override
  Future<void> deleteNotification(String userId, String notificationId) async {
     await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}
