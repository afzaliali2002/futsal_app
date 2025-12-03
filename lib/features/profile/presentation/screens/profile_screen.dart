import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule the loadUser call for after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("پروفایل"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'خروج',
            onPressed: () {
              // Perform logout
              context.read<AuthRepository>().logout();

              // The user will be automatically navigated to the login screen
              // by the StreamProvider in main.dart
            },
          ),
        ],
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
              ? Center(child: Text("An error occurred: ${vm.error}"))
              : vm.user == null
                  ? const Center(child: Text("User data could not be loaded."))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          ProfileHeader(user: vm.user!),
                        ],
                      ),
                    ),
    );
  }
}
