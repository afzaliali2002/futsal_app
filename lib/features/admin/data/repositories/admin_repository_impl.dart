import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:futsal_app/core/services/cloudinary_service.dart'; // Import your cloudinary instance
import 'package:futsal_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:futsal_app/features/booking/data/models/booking_model.dart';
import 'package:futsal_app/features/futsal/data/models/futsal_field_model.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/profile/data/models/user_model.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';

class AdminRepositoryImpl implements AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepositoryImpl(this._firestore);

  @override
  Future<List<UserModel>> getUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<FutsalField>> getGrounds() async {
    final snapshot = await _firestore.collection('fields').get();
    return snapshot.docs
        .map((doc) => FutsalFieldModel.fromSnapshot(doc).toEntity())
        .toList();
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  @override
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    await _firestore.collection('users').doc(userId).update({'role': newRole.toString().split('.').last});
  }

  @override
  Future<void> blockUser(String userId, DateTime? blockedUntil) async {
    await _firestore.collection('users').doc(userId).update({
      'isBlocked': blockedUntil != null,
      'blockedUntil': blockedUntil,
    });
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  @override
  Future<void> deleteGround(String groundId) async {
    await _firestore.collection('fields').doc(groundId).delete();
  }

  @override
  Future<void> updateGround(FutsalField ground) async {
    final model = FutsalFieldModel.fromEntity(ground);
    await _firestore.collection('fields').doc(ground.id).update(model.toMap());
  }
  
  @override
  Future<List<BookingModel>> getAllBookings() async {
    final snapshot = await _firestore.collectionGroup('bookings').get();
    return snapshot.docs.map((doc) => BookingModel.fromSnapshot(doc)).toList();
  }
  
  @override
  Future<void> approveGround(String groundId) async {
     await _firestore.collection('fields').doc(groundId).update({'status': 'approved'});
  }
  
  @override
  Future<void> rejectGround(String groundId) async {
     await _firestore.collection('fields').doc(groundId).update({'status': 'rejected'});
  }
  
  @override
  Future<void> logAction(String action, String adminId) async {
    await _firestore.collection('audit_logs').add({
      'action': action,
      'adminId': adminId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  @override
  Future<List<Map<String, dynamic>>> getAuditLogs() async {
     final snapshot = await _firestore.collection('audit_logs').orderBy('timestamp', descending: true).limit(100).get();
     return snapshot.docs.map((d) => d.data()).toList();
  }

  @override
  Future<String> uploadBroadcastImage(File image) async {
    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image),
    );
    return response.secureUrl;
  }

  @override
  Future<void> queueBroadcastNotification({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    await _firestore.collection('notifications_queue').add({
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
