import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileProvider>();

    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Center(child: Text("Error: ${vm.error}"));
    }

    if (vm.user == null) {
      return const Center(child: Text("User not found"));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileHeader(user: vm.user!),
        ],
      ),
    );
  }
}
