import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:futsal_app/features/profile/data/models/user_model.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  static const String _adminEmail = 'alidanishafzali21@gmail.com';

  AuthRepositoryImpl(this._firebaseAuth, this._firestore);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        await getUserDetails(user.uid); // Ensure user document exists
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> signUp(String email, String password, String name) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        final newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          role: email == _adminEmail ? UserRole.admin : UserRole.viewer,
          avatarUrl: '',
          isOnline: false,
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getUserDetails(String uid) async {
    final userDocRef = _firestore.collection('users').doc(uid);
    final doc = await userDocRef.get();

    if (doc.exists) {
      // User document exists, load it
      final user = UserModel.fromMap(doc.data()!, uid);
      // Always override role if email matches admin email, as a security measure
      if (user.email == _adminEmail && user.role != UserRole.admin) {
        await userDocRef.update({'role': UserRole.admin.toString().split('.').last});
        return user.copyWith(role: UserRole.admin);
      }
      return user;
    } else {
      // User document does not exist, but user is authenticated. Create it.
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null && firebaseUser.uid == uid) {
        final role = firebaseUser.email == _adminEmail ? UserRole.admin : UserRole.viewer;
        final newUser = UserModel(
          uid: uid,
          name: firebaseUser.displayName ?? 'New User',
          email: firebaseUser.email!,
          avatarUrl: firebaseUser.photoURL ?? '',
          isOnline: true,
          role: role,
        );
        // Save the new user document to Firestore
        await userDocRef.set(newUser.toMap());
        return newUser;
      }
    }
    return null;
  }
}
