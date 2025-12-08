import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futsal_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:futsal_app/features/profile/data/models/user_model.dart';

class UserViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  late final StreamSubscription<User?> _authStateSubscription;

  UserViewModel({required this.authRepository}) {
    _authStateSubscription = authRepository.authStateChanges.listen(_loadCurrentUser);
  }

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> _loadCurrentUser(User? firebaseUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (firebaseUser != null) {
        _user = await authRepository.getUserDetails(firebaseUser.uid);
      } else {
        _user = null; // User logged out
      }
    } catch (e) {
      _user = null; // Clear user on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
