import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futsal_app/features/admin/domain/repositories/admin_repository.dart';
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



}
