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
    final timeFormat = DateFormat('h:mm a');
    final formattedTime = timeFormat.format(dateTime.toLocal());
    return '${jalaliDate.year}/${jalaliDate.month}/${jalaliDate.day} - $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    final adminViewModel = Provider.of<AdminViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: adminViewModel,
                    child: EditUserScreen(user: user),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(context, adminViewModel),
            const SizedBox(height: 24),
            _buildAdminActions(context, adminViewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, AdminViewModel adminViewModel) {
    final createdBy = adminViewModel.getUserById(user.createdBy ?? '')?.email ?? 'نامشخص';
    final modifiedBy = adminViewModel.getUserById(user.modifiedBy ?? '')?.email ?? 'نامشخص';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(context, 'ایمیل', user.email),
            _buildDetailRow(context, 'نقش', user.role.toString().split('.').last),
            _buildDetailRow(context, 'وضعیت', user.isOnline ? 'آنلاین' : 'آفلاین'),
            _buildDetailRow(context, 'تاریخ ایجاد', _formatDateTime(user.createdAt)),
            _buildDetailRow(context, 'ایجاد شده توسط', createdBy),
            _buildDetailRow(context, 'تاریخ ویرایش', _formatDateTime(user.modifiedAt)),
            _buildDetailRow(context, 'ویرایش شده توسط', modifiedBy),
            if (user.isBlocked)
              _buildDetailRow(context, 'مسدود تا', _formatDateTime(user.blockedUntil)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context, AdminViewModel adminViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showRoleManagementDialog(context, user, adminViewModel),
          icon: const Icon(Icons.sync_alt),
          label: const Text('تغییر نقش'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _showBlockUserDialog(context, adminViewModel),
          icon: const Icon(Icons.block),
          label: const Text('مسدود کردن کاربر'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            final confirm = await showConfirmationDialog(
              context,
              'حذف کاربر',
              'آیا از حذف این کاربر اطمینان دارید؟ این عمل قابل بازگشت نیست.',
            );
            if (confirm == true) {
              adminViewModel.deleteUser(user.uid);
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.delete),
          label: const Text('حذف کاربر'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')),
            ElevatedButton(
              onPressed: () {
                if (selectedRole != null) {
                  adminViewModel.updateUserRole(user.uid, selectedRole!, userViewModel);
                }
                Navigator.pop(context);
              },
              child: const Text('ذخیره'),
            ),
          ],
        );
      },
    );
  }

  void _showBlockUserDialog(BuildContext context, AdminViewModel adminViewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('مسدود کردن کاربر'),
          content: const Text('برای چه مدتی این کاربر مسدود شود؟'),
          actions: [
            TextButton(
              onPressed: () {
                adminViewModel.blockUser(user.uid, DateTime.now().add(const Duration(days: 7)));
                Navigator.of(context).pop();
              },
              child: const Text('یک هفته'),
            ),
            TextButton(
              onPressed: () {
                adminViewModel.blockUser(user.uid, DateTime.now().add(const Duration(days: 30)));
                Navigator.of(context).pop();
              },
              child: const Text('یک ماه'),
            ),
            TextButton(
              onPressed: () {
                adminViewModel.blockUser(user.uid, null); // Indefinite
                Navigator.of(context).pop();
              },
              child: const Text('نامحدود'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('لغو'),
            ),
          ],
        );
      },
    );
  }
}
