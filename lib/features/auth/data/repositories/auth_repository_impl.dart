import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:futsal_app/features/profile/data/models/user_model.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  static const String _adminEmail = 'alidanishafzali21@gmail.com';

  AuthRepositoryImpl(this._firebaseAuth, this._firestore, this._googleSignIn);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> _updateUserOnlineStatus(String uid, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(uid).update({'isOnline': isOnline});
    } catch (e) {
      // Ignore errors if document doesn't exist yet or network fails
    }
  }

  @override
  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _updateUserOnlineStatus(userCredential.user!.uid, true);
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
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
          role: email == _adminEmail ? UserRole.admin : UserRole.user,
          avatarUrl: '',
          isOnline: true, // Set to true on signup
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }
      return user;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final userDoc = await _firestore.collection('users').where('email', isEqualTo: googleUser.email).get();
      if (userDoc.docs.isEmpty) {
        await _googleSignIn.signOut();
        throw FirebaseAuthException(code: 'user-not-found');
      }

      final googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _updateUserOnlineStatus(userCredential.user!.uid, true);
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      await _googleSignIn.signOut();
      rethrow;
    }
  }

  @override
  Future<User?> signUpWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          final newUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            role: user.email == _adminEmail ? UserRole.admin : UserRole.user,
            avatarUrl: user.photoURL ?? '',
            isOnline: true, // Set to true
            createdAt: DateTime.now(),
          );
          await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        } else {
           await _updateUserOnlineStatus(user.uid, true);
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      await _googleSignIn.signOut();
      rethrow;
    }
  }

  @override
  Future<void> signOutFromGoogle() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _updateUserOnlineStatus(user.uid, false);
    }
    await _googleSignIn.signOut();
  }

  @override
  Future<void> logout() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _updateUserOnlineStatus(user.uid, false);
    }
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Stream<UserModel?> getUserDetails(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final user = UserModel.fromMap(snapshot.data()!, uid);
        if (user.email == _adminEmail && user.role != UserRole.admin) {
          _firestore.collection('users').doc(uid).update({'role': 'admin'});
          return user.copyWith(role: UserRole.admin);
        }
        return user;
      } else {
        return null;
      }
    });
  }

  @override
  Future<void> saveFCMToken(String uid, String token) async {
    await _firestore.collection('users').doc(uid).update({'fcmToken': token});
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification
        final userCredential = await signInWithCredential(credential);
        verificationCompleted(userCredential.credential as PhoneAuthCredential);
      },
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  @override
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        final newUser = UserModel(
          uid: user.uid,
          name: 'کاربر جدید', // Default name
          email: user.phoneNumber ?? '', // Use phone number if email is null
          role: UserRole.user,
          avatarUrl: '',
          isOnline: true, // Set to true
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      } else {
         await _updateUserOnlineStatus(user.uid, true);
      }
    }
    return userCredential;
  }
}
