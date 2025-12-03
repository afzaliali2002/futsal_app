import 'package:flutter/material.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../data/models/user_model.dart';

class ProfileProvider extends ChangeNotifier {
  final GetCurrentUserUseCase getCurrentUserUseCase;

  ProfileProvider(this.getCurrentUserUseCase);

  UserModel? user;
  bool loading = false;
  String? error;

  Future<void> loadUser() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      user = await getCurrentUserUseCase();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
