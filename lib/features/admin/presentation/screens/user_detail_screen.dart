import 'package:flutter/material.dart';
import 'package:futsal_app/features/admin/presentation/screens/edit_user_screen.dart';
import 'package:futsal_app/features/admin/presentation/widgets/confirmation_dialog.dart';
import 'package:futsal_app/features/profile/data/models/user_model.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
import 'package:futsal_app/features/admin/presentation/view_models/admin_view_model.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'نامشخص';
    final jalaliDate = Jalali.fromDateTime(dateTime.toLocal());
    final timeFormat = DateFormat('HH:mm'); // Modern 24-hour format
    final formattedTime = timeFormat.format(dateTime.toLocal());
    return '${jalaliDate.year}/${jalaliDate.month}/${jalaliDate.day} - $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    final adminViewModel = Provider.of<AdminViewModel>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('جزئیات کاربر', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.edit_outlined),
          //   tooltip: 'ویرایش اطلاعات',
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => ChangeNotifierProvider.value(
          //           value: adminViewModel,
          //           child: EditUserScreen(user: user),
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'اطلاعات حساب کاربری'),
                  const SizedBox(height: 12),
                  _buildUserInfoCard(context, adminViewModel),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'عملیات مدیریتی'),
                  const SizedBox(height: 12),
                  _buildAdminActions(context, adminViewModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      child: Column(
        children: [
          Hero(
            tag: 'avatar_${user.uid}',
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.primaryColor.withOpacity(0.2), width: 3),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                child: user.avatarUrl.isEmpty
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: theme.primaryColor),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusChip(
                context, 
                user.isOnline ? 'آنلاین' : 'آفلاین', 
                user.isOnline ? Colors.green : Colors.grey,
                user.isOnline ? Icons.wifi : Icons.wifi_off,
              ),
              const SizedBox(width: 8),
              _buildStatusChip(
                context, 
                user.role.toString().split('.').last, 
                user.role == UserRole.admin ? Colors.redAccent : Colors.blueAccent,
                Icons.admin_panel_settings_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold, 
        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8)
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, AdminViewModel adminViewModel) {
    final createdBy = adminViewModel.getUserById(user.createdBy ?? '')?.email ?? 'سیستم';
    final modifiedBy = adminViewModel.getUserById(user.modifiedBy ?? '')?.email ?? '-';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildDetailRow(context, Icons.calendar_today, 'تاریخ ثبت‌نام', _formatDateTime(user.createdAt)),
            const Divider(height: 24),
            _buildDetailRow(context, Icons.person_add_alt, 'ایجاد شده توسط', createdBy),
            const Divider(height: 24),
            _buildDetailRow(context, Icons.edit_calendar, 'آخرین ویرایش', user.modifiedAt != null ? _formatDateTime(user.modifiedAt) : '-'),
            const Divider(height: 24),
            _buildDetailRow(context, Icons.manage_accounts_outlined, 'ویرایش توسط', modifiedBy),
            if (user.isBlocked) ...[
              const Divider(height: 24),
              _buildDetailRow(context, Icons.block, 'مسدود شده تا', _formatDateTime(user.blockedUntil), isError: true),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String title, String value, {bool isError = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isError ? Colors.red : Theme.of(context).primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: isError ? Colors.red : Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w600,
                color: isError ? Colors.red : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminActions(BuildContext context, AdminViewModel adminViewModel) {
    final currentUserViewModel = Provider.of<UserViewModel>(context, listen: false);

    return Column(
      children: [
        _buildActionTile(
          context,
          'تغییر نقش کاربر',
          'ارتقا یا تنزل سطح دسترسی کاربر',
          Icons.shield_outlined,
          Colors.orange,
          () => _showRoleManagementDialog(context, user, adminViewModel),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          user.isBlocked ? 'رفع مسدودیت' : 'مسدود کردن کاربر',
          user.isBlocked ? 'فعال‌سازی مجدد حساب' : 'جلوگیری از دسترسی کاربر به سیستم',
          Icons.block,
          user.isBlocked ? Colors.green : Colors.blueGrey,
          () => _showBlockUserDialog(context, adminViewModel, currentUserViewModel),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          'حذف حساب کاربری',
          'این عملیات غیرقابل بازگشت است',
          Icons.delete_forever,
          Colors.red,
          () async {
            final confirm = await showConfirmationDialog(
              context,
              'حذف کاربر',
              'آیا از حذف این کاربر اطمینان دارید؟ این عمل قابل بازگشت نیست.',
            );
            if (confirm == true) {
              await adminViewModel.deleteUser(user.uid, currentUserViewModel);
              if (context.mounted) Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoleManagementDialog(
      BuildContext context, UserModel user, AdminViewModel adminViewModel) {
    UserRole? selectedRole = user.role;
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تغییر نقش کاربر'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: UserRole.values.map((role) {
                  return RadioListTile<UserRole>(
                    title: Text(role.toString().split('.').last),
                    value: role,
                    groupValue: selectedRole,
                    activeColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('لغو', style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedRole != null) {
                  adminViewModel.updateUserRole(user.uid, selectedRole!, userViewModel);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('ذخیره تغییرات'),
            ),
          ],
        );
      },
    );
  }

  void _showBlockUserDialog(BuildContext context, AdminViewModel adminViewModel, UserViewModel currentUserViewModel) {
    if (user.isBlocked) {
       // Unblock logic immediately if already blocked
       adminViewModel.blockUser(user.uid, null, currentUserViewModel);
       return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('مسدود کردن کاربر'),
          content: const Text('برای چه مدتی این کاربر مسدود شود؟'),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    adminViewModel.blockUser(user.uid, DateTime.now().add(const Duration(days: 7)), currentUserViewModel);
                    Navigator.of(context).pop();
                  },
                  child: const Text('یک هفته'),
                ),
                OutlinedButton(
                  onPressed: () {
                    adminViewModel.blockUser(user.uid, DateTime.now().add(const Duration(days: 30)), currentUserViewModel);
                    Navigator.of(context).pop();
                  },
                  child: const Text('یک ماه'),
                ),
                ElevatedButton(
                  onPressed: () {
                    adminViewModel.blockUser(user.uid, DateTime.now().add(const Duration(days: 365 * 10)), currentUserViewModel); // Effectively permanent
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  child: const Text('دائمی'),
                ),
              ],
            ),
             const SizedBox(height: 12),
             TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('لغو', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }
}
