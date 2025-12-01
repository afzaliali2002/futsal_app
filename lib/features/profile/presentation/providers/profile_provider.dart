import 'package:flutter/material.dart';

import '../../domain/usecases/get_current_user_usecase.dart';
import '../../data/models/user_model.dart';

class ProfileProvider extends ChangeNotifier {
  final GetCurrentUserUseCase getCurrentUser;

  ProfileProvider(this.getCurrentUser);

  UserModel? user;
  bool loading = false;
  String? error;

  Future<void> loadUser() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      user = await getCurrentUser();

    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }
}
