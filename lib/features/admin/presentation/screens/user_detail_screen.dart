import 'package:flutter/material.dart';
import 'package:futsal_app/features/admin/presentation/screens/edit_user_screen.dart';
import 'package:futsal_app/features/admin/presentation/widgets/confirmation_dialog.dart';
import 'package:futsal_app/features/profile/data/models/user_model.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
import 'package:futsal_app/features/admin/presentation/view_models/admin_view_model.dart';
import 'package:provider/provider.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final adminViewModel = Provider.of<AdminViewModel>(context, listen: false);

    return Consumer<AdminViewModel>(
      builder: (context, vm, child) {
        if (vm.successMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(vm.successMessage!)),
            );
            vm.clearSuccessMessage();
          });
        }

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
                _buildUserInfo(context),
                const SizedBox(height: 24),
                _buildAdminActions(context, adminViewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfo(BuildContext context) {
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
            _buildDetailRow(context, 'تاریخ ایجاد', user.createdAt?.toLocal().toString() ?? 'نامشخص'),
            _buildDetailRow(context, 'ایجاد شده توسط', user.createdBy ?? 'نامشخص'),
            _buildDetailRow(context, 'تاریخ ویرایش', user.modifiedAt?.toLocal().toString() ?? 'نامشخص'),
            _buildDetailRow(context, 'ویرایش شده توسط', user.modifiedBy ?? 'نامشخص'),
            if (user.isBlocked)
              _buildDetailRow(context, 'مسدود تا', user.blockedUntil?.toLocal().toString() ?? 'نامشخص'),
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
              overflow: TextOverflow.fade,
              softWrap: false,
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
          onPressed: () async {
            final confirm = await showConfirmationDialog(
              context,
              'تغییر نقش',
              'آیا از تغییر نقش این کاربر اطمینان دارید؟',
            );
            if (confirm == true) {
              adminViewModel.updateUserRole(
                user.uid,
                user.role == UserRole.admin ? UserRole.viewer : UserRole.admin,
              );
            }
          },
          icon: const Icon(Icons.sync_alt),
          label: const Text('تغییر نقش به ادمین/کاربر'),
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
