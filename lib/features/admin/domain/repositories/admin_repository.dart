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
}
