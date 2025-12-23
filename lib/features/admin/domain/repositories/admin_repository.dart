import 'dart:io';
import 'package:futsal_app/features/booking/data/models/booking_model.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/profile/data/models/user_model.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';

abstract class AdminRepository {
  Future<List<UserModel>> getUsers();
  Future<List<FutsalField>> getGrounds();
  Future<void> deleteUser(String userId);
  Future<void> updateUserRole(String userId, UserRole newRole);
  Future<void> blockUser(String userId, DateTime? blockedUntil);
  Future<void> updateUser(UserModel user);
  Future<void> deleteGround(String groundId);
  Future<void> updateGround(FutsalField ground);
  
  // Analytics & Reports
  Future<List<BookingModel>> getAllBookings();
  
  // Ground Approval
  Future<void> approveGround(String groundId);
  Future<void> rejectGround(String groundId);
  
  // Audit Logs
  Future<void> logAction(String action, String adminId);
  Future<List<Map<String, dynamic>>> getAuditLogs();

  // Notifications
  Future<String> uploadBroadcastImage(File image);
  Future<void> queueBroadcastNotification({
    required String title,
    required String body,
    String? imageUrl,
  });
}
