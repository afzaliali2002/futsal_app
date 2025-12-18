import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:futsal_app/core/services/notification_service.dart';
import 'package:futsal_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:futsal_app/features/profile/data/models/user_model.dart';

class UserViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  UserModel? _user;
  String? _error;
  bool _isLoading = true;

  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<UserModel?>? _userSubscription;

  UserModel? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;

  UserViewModel({required this.authRepository}) {
    _authStateSubscription = authRepository.authStateChanges.listen((firebaseUser) {
      _loadOrRefreshUser(firebaseUser);
    });
  }

  Future<void> _loadOrRefreshUser(User? firebaseUser) async {
    _userSubscription?.cancel();

    if (firebaseUser == null) {
      _user = null;
      _isLoading = false;
      _error = null;
      notifyListeners();
      return;
    }

    if (_user == null) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final userStream = authRepository.getUserDetails(firebaseUser.uid);

      final updatedUser = await userStream
          .firstWhere((user) => user != null)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw 'Could not load user profile. Please try again.';
      });

      _user = updatedUser;
      _isLoading = false;
      _error = null;
      notifyListeners();

      // Save FCM token
      final token = await NotificationService().getFCMToken();
      if (token != null && token != _user?.fcmToken) {
        await authRepository.saveFCMToken(firebaseUser.uid, token);
        _user = _user?.copyWith(fcmToken: token);
        notifyListeners();
      }

      _userSubscription = userStream.listen((user) {
        if (user != null) {
          _user = user;
          notifyListeners();
        }
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _user = null;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    final currentUser = authRepository.getCurrentUser();
    await _loadOrRefreshUser(currentUser);
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
