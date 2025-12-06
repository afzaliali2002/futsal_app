import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/screens/login-screen.dart';
import '../providers/profile_provider.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حساب کاربری',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSettingsCard([
              _buildSettingsItem(
                context,
                icon: Icons.lock_outline,
                title: 'تغییر رمز عبور',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
              ),
            ]),
            const SizedBox(height: 30),
            Text(
              'عمومی',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSettingsCard([
              _buildSettingsItem(
                context,
                icon: Icons.notifications_outlined,
                title: 'اعلانات',
                onTap: () { /* TODO: Navigate to Notifications screen */ },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.help_outline,
                title: 'راهنما و پشتیبانی',
                onTap: () { /* TODO: Navigate to Help screen */ },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.info_outline,
                title: 'درباره ما',
                onTap: () { /* TODO: Navigate to About screen */ },
              ),
            ]),
            const SizedBox(height: 30),
            _buildDangerZone(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? theme.iconTheme.color),
      title: Text(title, style: theme.textTheme.titleMedium?.copyWith(color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'منطقه خطر',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.error),
        ),
        const SizedBox(height: 10),
        _buildSettingsCard([
            _buildSettingsItem(
            context,
            icon: Icons.logout,
            title: 'خروج از حساب کاربری',
            color: theme.colorScheme.error,
            onTap: () => _showLogoutConfirmation(context),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildSettingsItem(
            context,
            icon: Icons.delete_forever_outlined,
            title: 'حذف حساب کاربری',
            color: theme.colorScheme.error,
            onTap: () => _showDeleteConfirmation(context),
          ),
        ]),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('خروج از حساب'),
        content: const Text('آیا مطمئن هستید که می‌خواهید از حساب خود خارج شوید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _logout(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('بله، خارج شو'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      context.read<ProfileProvider>().clearUser();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen(), settings: const RouteSettings(name: '/')),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در خروج از حساب: ${e.toString()}')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('حذف حساب کاربری'),
        content: const Text('آیا مطمئن هستید؟ این عمل قابل بازگشت نیست و تمام اطلاعات شما به صورت دائمی حذف خواهد شد.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _deleteAccount(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('بله، حذف کن'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': user.uid,
      });
      await FirebaseAuth.instance.signOut();
      context.read<ProfileProvider>().clearUser();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen(), settings: const RouteSettings(name: '/')),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در حذف حساب: ${e.toString()}')),
      );
    }
  }
}
