import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository);

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _authRepository.login(email, password);
    } catch (e) {
      // Re-throw the original Firebase exception to be handled by the UI
      rethrow;
    }
  }
}
