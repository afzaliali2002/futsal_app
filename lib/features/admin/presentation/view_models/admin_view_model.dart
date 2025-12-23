import 'dart:io';
import 'package:flutter/material.dart';
import 'package:futsal_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:futsal_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:futsal_app/features/booking/data/models/booking_model.dart';
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
  
  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;
  
  List<Map<String, dynamic>> _auditLogs = [];
  List<Map<String, dynamic>> get auditLogs => _auditLogs;

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
      // Fetch core data first
      _allUsers = await _adminRepository.getUsers();
      _allGrounds = await _adminRepository.getGrounds();
      _filteredUsers = _allUsers;
      _filteredGrounds = _allGrounds;
    } catch (e) {
      _error = 'Failed to load users/grounds: $e';
    }

    // Fetch extra data separately so it doesn't block the main UI if it fails (e.g., missing index)
    try {
      _bookings = await _adminRepository.getAllBookings();
    } catch (e) {
      debugPrint('Failed to load bookings: $e');
      // Don't set _error here to allow users/grounds to show
    }

    _isLoading = false;
    notifyListeners();
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

  Future<void> deleteUser(String userId, UserViewModel currentUser) async {
    try {
      await _adminRepository.deleteUser(userId);
      // Pass the actual admin name or email instead of just 'admin'
      final adminName = currentUser.user?.name ?? currentUser.user?.email ?? 'Admin';
      await _adminRepository.logAction('Deleted User: $userId', adminName);
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
      final adminName = userViewModel.user?.name ?? userViewModel.user?.email ?? 'Admin';
      await _adminRepository.logAction('Updated Role User: $userId to $newRole', adminName);
      _successMessage = 'نقش کاربر با موفقیت تغییر کرد';
      await fetchData();
      await userViewModel.refreshUser();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> blockUser(String userId, DateTime? blockedUntil, UserViewModel currentUser) async {
    try {
      await _adminRepository.blockUser(userId, blockedUntil);
      final adminName = currentUser.user?.name ?? currentUser.user?.email ?? 'Admin';
      await _adminRepository.logAction('Blocked User: $userId', adminName);
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
  
  Future<void> approveGround(String groundId, UserViewModel currentUser) async {
    try {
      await _adminRepository.approveGround(groundId);
      final adminName = currentUser.user?.name ?? currentUser.user?.email ?? 'Admin';
      await _adminRepository.logAction('Approved Ground: $groundId', adminName);
      _successMessage = 'زمین با موفقیت تایید شد';
      await fetchData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> rejectGround(String groundId, UserViewModel currentUser) async {
    try {
      await _adminRepository.rejectGround(groundId);
      final adminName = currentUser.user?.name ?? currentUser.user?.email ?? 'Admin';
      await _adminRepository.logAction('Rejected Ground: $groundId', adminName);
      _successMessage = 'زمین رد شد';
      await fetchData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> deleteGround(String groundId, UserViewModel currentUser) async {
    try {
      await _adminRepository.deleteGround(groundId);
      final adminName = currentUser.user?.name ?? currentUser.user?.email ?? 'Admin';
      await _adminRepository.logAction('Deleted Ground: $groundId', adminName);
      _successMessage = 'زمین حذف شد';
      await fetchData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> fetchAuditLogs() async {
     try {
       _auditLogs = await _adminRepository.getAuditLogs();
       notifyListeners();
     } catch (e) {
       _error = e.toString();
     }
  }

  Future<void> sendBroadcastNotification({
    required String title,
    required String body,
    File? image,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? imageUrl;
      if (image != null) {
        imageUrl = await _adminRepository.uploadBroadcastImage(image);
      }

      await _adminRepository.queueBroadcastNotification(
        title: title,
        body: body,
        imageUrl: imageUrl,
      );
      
      _successMessage = 'اعلان با موفقیت در صف ارسال قرار گرفت';
    } catch (e) {
      _error = 'خطا در ارسال اعلان: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
