import 'package:firebase_auth/firebase_auth.dart';
import 'package:futsal_app/features/profile/data/models/user_model.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? getCurrentUser();
  Future<User?> login(String email, String password);
  Future<User?> signUp(String email, String password, String name);
  Future<User?> signInWithGoogle();
  Future<User?> signUpWithGoogle();
  Future<void> logout();
  Future<void> signOutFromGoogle();
  Stream<UserModel?> getUserDetails(String uid);
  Future<void> saveFCMToken(String uid, String token);

  // Phone Auth
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
  });
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential);
}
