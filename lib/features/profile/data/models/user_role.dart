enum UserRole {
  admin,
  groundOwner,
  user,
}

extension UserRoleExtension on UserRole {
  String translate() {
    switch (this) {
      case UserRole.admin:
        return 'مدیر';
      case UserRole.groundOwner:
        return 'صاحب زمین';
      case UserRole.user:
        return 'کاربر عادی';
      default:
        return '';
    }
  }
}
