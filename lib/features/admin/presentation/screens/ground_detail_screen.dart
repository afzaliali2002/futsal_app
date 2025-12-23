import 'package:flutter/material.dart';
import 'package:futsal_app/features/admin/presentation/view_models/admin_view_model.dart';
import 'package:futsal_app/features/futsal/presentation/screens/add_futsal_ground_screen.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';
import 'package:provider/provider.dart';

class GroundDetailScreen extends StatelessWidget {
  final FutsalField ground;

  const GroundDetailScreen({super.key, required this.ground});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<AdminViewModel>();
    
    // Fix: Get the latest ground data from the ViewModel to ensure UI updates after actions
    final currentGround = vm.grounds.firstWhere(
      (g) => g.id == ground.id, 
      orElse: () => ground
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, currentGround, vm),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationAndRating(context, currentGround),
                  const SizedBox(height: 24),
                  // New Status & Approval Section
                  _buildAdminStatusCard(context, currentGround, vm),
                  const SizedBox(height: 24),
                  if (currentGround.features.isNotEmpty) ...[
                    _buildSectionTitle(context, 'امکانات', Icons.widgets_outlined),
                    const SizedBox(height: 16),
                    _buildFeaturesGrid(context, currentGround.features),
                    const SizedBox(height: 24),
                  ],
                  _buildSectionTitle(context, 'توضیحات', Icons.info_outline),
                  const SizedBox(height: 16),
                  Text(
                    currentGround.description.isNotEmpty 
                        ? currentGround.description 
                        : 'توضیحاتی برای این زمین ثبت نشده است.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                      color: theme.colorScheme.onSurface.withAlpha(179),
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                      context, 'زمان‌های کاری', Icons.access_time_rounded),
                  const SizedBox(height: 16),
                  _buildScheduleInfo(context, currentGround),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildAdminActionsBar(context, currentGround, vm),
    );
  }
  
  Widget _buildAdminStatusCard(BuildContext context, FutsalField ground, AdminViewModel vm) {
    Color color = Colors.grey;
    IconData icon = Icons.help_outline;
    String text = 'نامشخص';
    
    switch (ground.status) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'تایید شده';
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        text = 'در انتظار تایید';
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        text = 'رد شده';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          if (ground.status == 'pending')
             const Text('لطفا بررسی کنید', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
      BuildContext context, FutsalField ground, AdminViewModel vm) {
    final userViewModel = context.watch<UserViewModel>();
    final isOwner = userViewModel.user?.uid == ground.ownerId;
    final isAdmin = userViewModel.user?.role == UserRole.admin;
    final canEdit = isOwner || isAdmin;

    return SliverAppBar(
      expandedHeight: 260.0,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      actions: [
        if (canEdit) ...[
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFutsalGroundScreen(field: ground),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('حذف زمین'),
                  content: const Text('آیا از حذف این زمین مطمئن هستید؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('انصراف'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('حذف'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await vm.deleteGround(ground.id, context.read<UserViewModel>());
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: Text(
          ground.name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            ground.coverImageUrl.isNotEmpty
                ? Image.network(
                    ground.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const Center(
                        child: Icon(Icons.broken_image,
                            size: 60, color: Colors.white70)),
                  )
                : Container(
                    color: Theme.of(context).primaryColor.withAlpha(128)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(140),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationAndRating(BuildContext context, FutsalField ground) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.location_on_outlined,
            size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            ground.address,
            style: theme.textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 5),
            Text(
              ground.rating.toStringAsFixed(1),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 22),
        const SizedBox(width: 8),
        Text(title,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, List<String> features) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: features.map((feature) {
        return Chip(
          label: Text(
            feature,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          backgroundColor:
              theme.colorScheme.secondaryContainer.withAlpha(102),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        );
      }).toList(),
    );
  }

  Widget _buildScheduleInfo(BuildContext context, FutsalField ground) {
    // Show real schedule if available
    if (ground.schedule != null && ground.schedule!.isNotEmpty) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ground.schedule!.keys.map((day) => Chip(label: Text(day))).toList(),
      );
    }
    return const Text('برنامه کاری مشخص نشده است');
  }

  Widget _buildAdminActionsBar(BuildContext context, FutsalField ground, AdminViewModel vm) {
    final theme = Theme.of(context);
    
    // Only show approval buttons if pending
    if (ground.status != 'pending') return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15)
          .copyWith(bottom: MediaQuery.of(context).padding.bottom + 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 1.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => vm.rejectGround(ground.id, context.read<UserViewModel>()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('رد کردن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => vm.approveGround(ground.id, context.read<UserViewModel>()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('تایید کردن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
