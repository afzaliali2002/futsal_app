import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';

class SignUpViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  SignUpViewModel(this._authRepository);

  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;

  // Update Email
  void setEmail(String value) {
    _email = value.trim();
    notifyListeners();
  }

  // Update Password
  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  // Update Confirm Password
  void setConfirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }

  // Password Match
  bool get isPasswordConfirmed {
    return _password == _confirmPassword;
  }

  // Form Valid
  bool get isValid {
    return _email.isNotEmpty &&
        _email.contains('@') &&
        _password.length >= 6 &&
        isPasswordConfirmed;
  }

  // SIGN UP
  Future<void> signUp(BuildContext context) async {
    if (!isValid || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.signUp(_email, _password);

      // Success → Go to Home Screen
      Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      print("Signup error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطا در ثبت‌نام: $e")),
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}
