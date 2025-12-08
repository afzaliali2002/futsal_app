import 'package:firebase_auth/firebase_auth.dart';
import 'package:futsal_app/features/profile/data/models/user_model.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? getCurrentUser();
  Future<User?> login(String email, String password);
  Future<User?> signUp(String email, String password, String name);
  Future<void> logout();
  Future<UserModel?> getUserDetails(String uid);
}
