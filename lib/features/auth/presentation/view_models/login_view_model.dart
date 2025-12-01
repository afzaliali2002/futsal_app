import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository);

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  // GETTERS
  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // SET EMAIL
  void setEmail(String value) {
    _email = value.trim();
    _errorMessage = null; // clear previous error
    notifyListeners();
  }

  // SET PASSWORD
  void setPassword(String value) {
    _password = value.trim();
    _errorMessage = null; // clear previous error
    notifyListeners();
  }

  // VALIDATION
  bool get isValid {
    return _email.isNotEmpty &&
        _email.contains('@') &&
        _password.length >= 6;
  }

  // LOGIN METHOD WITH NAVIGATION
  Future<void> login(BuildContext context) async {
    if (!isValid) {
      _errorMessage = "ایمیل یا رمز عبور معتبر نیست.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.login(_email, _password);

      _isLoading = false;
      notifyListeners();

      if (user != null) {
        // SUCCESS → GO TO HOME
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _errorMessage = "ورود ناموفق بود. لطفاً دوباره امتحان کنید.";
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString(); // FirebaseAuthException message
      notifyListeners();
    }
  }
}
