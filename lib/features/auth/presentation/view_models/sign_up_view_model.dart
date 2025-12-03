import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';

class SignUpViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  SignUpViewModel(this._authRepository);

  // This ViewModel will now be simpler.
  // The UI will handle controllers and loading state.

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    // The use case for this will be created in the next refactoring step.
    try {
      await _authRepository.signUp(email, password, name);
    } catch (e) {
      // Re-throw the exception to be handled by the UI.
      rethrow;
    }
  }
}
