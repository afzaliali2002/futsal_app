// features/auth/presentation/view_models/login_view_model.dart

import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  String _email = '';
  String _password = '';

  String get email => _email;
  String get password => _password;

  void setEmail(String value) {
    _email = value.trim();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  bool get isValid {
    return _email.isNotEmpty && _email.contains('@') && _password.length >= 6;
  }

  Future<void> login() async {
    // TODO: Add real login logic later
    print('Login attempt with: $_email');
  }
}