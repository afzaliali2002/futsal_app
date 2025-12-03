import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<User?> login(String email, String password);
  Future<User?> signUp(String email, String password, String name);
  Future<void> logout();
}
