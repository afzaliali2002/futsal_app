import 'package:flutter/material.dart';
import 'package:futsal_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
import 'package:futsal_app/features/futsal/presentation/screens/add_futsal_ground_screen.dart';
import 'package:futsal_app/features/futsal/presentation/screens/field_detail_screen.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
import 'package:futsal_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';
import 'package:futsal_app/features/search/presentation/screens/search_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/futsal_field_card.dart';

class FutsalListScreen extends StatefulWidget {
  const FutsalListScreen({super.key});

  @override
  State<FutsalListScreen> createState() => _FutsalListScreenState();
}

class _FutsalListScreenState extends State<FutsalListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FutsalViewModel>().fetchFutsalFields();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FutsalViewModel>();
    final userViewModel = context.watch<UserViewModel>();
    final isAdmin = userViewModel.user?.role == UserRole.admin;
    final canAddGround = userViewModel.user?.role == UserRole.groundOwner ||
        userViewModel.user?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin
            ? 'Registered Grounds (${vm.fields.length})'
            : 'زمین های موجود'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.dashboard),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AdminDashboardScreen()));
              },
            ),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _buildBody(vm),
      floatingActionButton: canAddGround
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const AddFutsalGroundScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(FutsalViewModel vm) {
    if (vm.isLoading && vm.fields.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('مشکلی پیش آمد: ${vm.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.fetchFutsalFields(),
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    if (vm.fields.isEmpty) {
      return const Center(
        child: Text('هیچ زمینی یافت نشد.'),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.fetchFutsalFields,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: vm.fields.length,
        itemBuilder: (context, index) {
          final field = vm.fields[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FieldDetailScreen(field: field),
                ),
              );
            },
            child: FutsalFieldCard(field: field),
          );
        },
      ),
    );
  }
}
