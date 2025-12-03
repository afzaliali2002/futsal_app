import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/repositories/profile_repository.dart';
import 'models/user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel> getCurrentUser() async {
    final firebaseUser = auth.currentUser;

    if (firebaseUser == null) {
      throw Exception("User not logged in");
    }

    final doc =
    await firestore.collection("users").doc(firebaseUser.uid).get();

    if (!doc.exists) {
      throw Exception("User document does not exist");
    }

    final data = doc.data()!;
    return UserModel.fromMap(data, firebaseUser.uid); // ✅ FIXED
  }
}
