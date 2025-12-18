
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
import 'ground_owner_dashboard_screen.dart';

class FutsalListScreen extends StatelessWidget {
  const FutsalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    final isAdmin = userViewModel.user?.role == UserRole.admin;
    final isGroundOwner = userViewModel.user?.role == UserRole.groundOwner;
    final canAddGround = isGroundOwner || isAdmin;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Consumer<FutsalViewModel>(
          builder: (context, vm, child) {
            return Text(isAdmin ? 'زمین های موجود (${vm.fields.length})' : 'زمین های موجود');
          },
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.dashboard_outlined),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
              },
            ),
          if (isGroundOwner)
             IconButton(
              icon: const Icon(Icons.dashboard_customize_outlined),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GroundOwnerDashboardScreen()));
              },
            ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: canAddGround
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddFutsalGroundScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<FutsalViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading && vm.fields.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('خطایی رخ داد: ${vm.error}'),
            ),
          );
        }

        if (vm.fields.isEmpty) {
          return const Center(
            child: Text('هیچ زمینی برای نمایش وجود ندارد.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80), // Padding for FloatingActionButton
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
        );
      },
    );
  }
}
