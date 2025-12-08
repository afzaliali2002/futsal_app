import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';
import 'package:provider/provider.dart';

class FieldDetailScreen extends StatelessWidget {
  final FutsalField field;

  const FieldDetailScreen({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<FutsalViewModel>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, field, vm),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationAndRating(context, field),
                  const SizedBox(height: 24),
                  if (field.features.isNotEmpty) ...[
                    _buildSectionTitle(context, 'امکانات', Icons.widgets_outlined),
                    const SizedBox(height: 16),
                    _buildFeaturesGrid(context, field.features),
                    const SizedBox(height: 24),
                  ],
                  _buildSectionTitle(context, 'توضیحات', Icons.info_outline),
                  const SizedBox(height: 16),
                  Text(
                    'این یک توضیح نمونه برای زمین فوتسال است که جزئیات بیشتری در مورد امکانات و شرایط آن ارائه می‌دهد. این زمین دارای بهترین کیفیت چمن مصنوعی و نورپردازی حرفه‌ای است.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                      context, 'زمان‌های آزاد', Icons.access_time_rounded),
                  const SizedBox(height: 16),
                  _buildTimeSlots(context),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBookingBottomBar(context, field),
    );
  }

  SliverAppBar _buildSliverAppBar(
      BuildContext context, FutsalField field, FutsalViewModel vm) {
    final userViewModel = context.watch<UserViewModel>();
    final isOwner = userViewModel.user?.uid == field.ownerId;
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
              // TODO: Navigate to edit screen
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
                await vm.deleteGround(field.id);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
        IconButton(
          icon: Icon(
            field.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
          ),
          onPressed: () {
            vm.toggleFavorite(field);
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: Text(
          field.name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            field.imageUrl.isNotEmpty
                ? Image.network(
                    field.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const Center(
                        child: Icon(Icons.broken_image,
                            size: 60, color: Colors.white70)),
                  )
                : Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.5)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationAndRating(BuildContext context, FutsalField field) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.location_on_outlined,
            size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            field.address,
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
              field.rating.toStringAsFixed(1),
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
              theme.colorScheme.secondaryContainer.withOpacity(0.4),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlots(BuildContext context) {
    final theme = Theme.of(context);
    final List<String> times = [
      '09:00',
      '11:00',
      '14:00',
      '16:00',
      '18:00',
      '20:00'
    ];

    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: times.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          bool isSelected = index == 1;

          return ActionChip(
            label: Text(times[index]),
            onPressed: () {},
            labelStyle: theme.textTheme.titleMedium?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.primaryContainer.withOpacity(0.3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          );
        },
      ),
    );
  }

  Widget _buildBookingBottomBar(BuildContext context, FutsalField field) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15)
          .copyWith(bottom: MediaQuery.of(context).padding.bottom + 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 1.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'قیمت برای ۱.۵ ساعت',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${field.pricePerHour.toStringAsFixed(0)} افغانی',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/booking', arguments: field);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('رزرو الان',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
