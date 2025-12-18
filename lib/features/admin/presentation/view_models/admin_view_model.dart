import 'package:flutter/material.dart';
import 'package:futsal_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:futsal_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/profile/data/models/user_model.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminRepository _adminRepository;
  final AuthRepository _authRepository;

  AdminViewModel(this._adminRepository, this._authRepository);

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  List<UserModel> get users => _filteredUsers;

  List<FutsalField> _allGrounds = [];
  List<FutsalField> _filteredGrounds = [];
  List<FutsalField> get grounds => _filteredGrounds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _successMessage;
  String? get successMessage => _successMessage;

  void clearSuccessMessage() {
    _successMessage = null;
  }

  Future<void> fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allUsers = await _adminRepository.getUsers();
      _allGrounds = await _adminRepository.getGrounds();
      _filteredUsers = _allUsers;
      _filteredGrounds = _allGrounds;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  UserModel? getUserById(String id) {
    try {
      return _allUsers.firstWhere((user) => user.uid == id);
    } catch (e) {
      return null;
    }
  }

  void searchUsers(String query) {
    final lowerCaseQuery = query.toLowerCase();
    if (lowerCaseQuery.isEmpty) {
      _filteredUsers = _allUsers;
    } else {
      _filteredUsers = _allUsers
          .where((user) =>
              user.name.toLowerCase().contains(lowerCaseQuery) ||
              user.email.toLowerCase().contains(lowerCaseQuery))
          .toList();
    }
    notifyListeners();
  }

  void searchGrounds(String query) {
    final lowerCaseQuery = query.toLowerCase();
    if (lowerCaseQuery.isEmpty) {
      _filteredGrounds = _allGrounds;
    } else {
      _filteredGrounds = _allGrounds
          .where((ground) =>
              ground.name.toLowerCase().contains(lowerCaseQuery) ||
              ground.address.toLowerCase().contains(lowerCaseQuery))
          .toList();
    }
    notifyListeners();
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _adminRepository.deleteUser(userId);
      _successMessage = 'کاربر با موفقیت حذف شد';
      await fetchData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUserRole(
      String userId, UserRole newRole, UserViewModel userViewModel) async {
    try {
      await _adminRepository.updateUserRole(userId, newRole);
      _successMessage = 'نقش کاربر با موفقیت تغییر کرد';
      await fetchData();
      await userViewModel.refreshUser();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> blockUser(String userId, DateTime? blockedUntil) async {
    try {
      await _adminRepository.blockUser(userId, blockedUntil);
      _successMessage = 'کاربر با موفقیت مسدود شد';
      await fetchData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _adminRepository.updateUser(user);
      _successMessage = 'اطلاعات کاربر با موفقیت ویرایش شد';
      await fetchData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
