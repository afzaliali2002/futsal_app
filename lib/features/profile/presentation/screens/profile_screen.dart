import 'package:flutter/material.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/screens/notifications_screen.dart'; // This import is likely incorrect if the file is not there.
import '../../../notification/presentation/screens/notification_screen.dart'; // Correct import based on file search
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'my_bookings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUser();
    });
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("پروفایل"),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
              ? Center(child: Text("An error occurred: \${vm.error}"))
              : vm.user == null
                  ? const Center(child: Text("User data could not be loaded."))
                  : RefreshIndicator(
                      onRefresh: () => context.read<ProfileProvider>().loadUser(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            ProfileHeader(user: vm.user!),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "حساب کاربری",
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  _ProfileMenuCard(
                                    items: [
                                      _ProfileMenuItem(
                                        title: 'ویرایش پروفایل',
                                        icon: Icons.person_outline,
                                        onTap: () => _navigateTo(EditProfileScreen(user: vm.user!)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 25),
                                  Text(
                                    "عمومی",
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  _ProfileMenuCard(
                                    items: [
                                      _ProfileMenuItem(
                                        title: 'رزرو های من',
                                        icon: Icons.history_outlined,
                                        onTap: () => _navigateTo(const MyBookingsScreen()),
                                      ),
                                      _ProfileMenuItem(
                                        title: 'اعلانات',
                                        icon: Icons.notifications_outlined,
                                        onTap: () => _navigateTo(const NotificationScreen()),
                                      ),
                                      _ProfileMenuItem(
                                        title: 'راهنما و پشتیبانی',
                                        icon: Icons.help_outline,
                                        onTap: () {
                                          // TODO: Navigate to Help screen
                                        },
                                      ),
                                      _ProfileMenuItem(
                                        title: 'درباره ما',
                                        icon: Icons.info_outline,
                                        onTap: () {
                                          // TODO: Navigate to About screen
                                        },
                                      ),
                                      _ProfileMenuItem(
                                        title: 'تنظیمات',
                                        icon: Icons.settings_outlined,
                                        onTap: () => _navigateTo(const SettingsScreen()),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  final List<_ProfileMenuItem> items;

  const _ProfileMenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Column(
        children: items,
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? textColor;

  const _ProfileMenuItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Theme.of(context).colorScheme.onSurface),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
