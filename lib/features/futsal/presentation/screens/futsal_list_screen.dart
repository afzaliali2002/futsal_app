
import 'package:flutter/material.dart';
import 'package:futsal_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
import 'package:futsal_app/features/futsal/presentation/screens/add_futsal_ground_screen.dart';
import 'package:futsal_app/features/futsal/presentation/screens/field_detail_screen.dart';
import 'package:futsal_app/features/notification/presentation/providers/notification_view_model.dart';
import 'package:futsal_app/features/notification/presentation/screens/notification_screen.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
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
    final notificationViewModel = context.watch<NotificationViewModel>();
    final user = userViewModel.user;
    final isAdmin = user?.role == UserRole.admin;
    final isGroundOwner = user?.role == UserRole.groundOwner;
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
          icon: StreamBuilder<int>(
            stream: user != null ? notificationViewModel.getUnreadNotificationsCount(user.uid) : Stream.value(0),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined),
                  if (count > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
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

        final topRatedFields = vm.fields.where((f) => f.rating >= 3.5).toList();
        final allFields = vm.fields;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Rated Section (Horizontal Scroll)
              if (topRatedFields.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'برترین زمین‌ها',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to All Top Rated Screen
                        }, 
                        child: const Text('مشاهده همه'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 300, // Reduced height for the section (was 340)
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: topRatedFields.length,
                    itemBuilder: (context, index) {
                      final field = topRatedFields[index];
                      return SizedBox(
                        width: 260, // Reduced width for horizontal cards (was 300)
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FieldDetailScreen(field: field),
                              ),
                            );
                          },
                          child: FutsalFieldCard(field: field, isCompact: true), // Pass compact flag if needed
                        ),
                      );
                    },
                  ),
                ),
              ],

              // All Grounds / Nearby Section (Vertical)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: const Text(
                  'همه زمین‌ها',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: allFields.length,
                itemBuilder: (context, index) {
                  final field = allFields[index];
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
            ],
          ),
        );
      },
    );
  }
}
