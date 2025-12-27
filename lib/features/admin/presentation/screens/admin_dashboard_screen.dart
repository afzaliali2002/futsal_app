import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:futsal_app/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:futsal_app/features/admin/presentation/screens/admin_audit_logs_screen.dart';
import 'package:futsal_app/features/admin/presentation/screens/admin_bookings_screen.dart';
import 'package:futsal_app/features/admin/presentation/screens/admin_reports_screen.dart';
import 'package:futsal_app/features/admin/presentation/screens/broadcast_notification_screen.dart';
import 'package:futsal_app/features/admin/presentation/screens/ground_detail_screen.dart';
import 'package:futsal_app/features/admin/presentation/screens/user_detail_screen.dart';
import 'package:futsal_app/features/admin/presentation/view_models/admin_view_model.dart';
import 'package:futsal_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/futsal/presentation/widgets/futsal_field_card.dart';
import 'package:futsal_app/features/profile/data/models/user_model.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _userSearchController = TextEditingController();
  final _groundSearchController = TextEditingController();
  
  // Filter state for users
  String? _selectedRoleFilter; // null means 'All', otherwise 'admin', 'groundOwner', 'user'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userSearchController.dispose();
    _groundSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (context) => AdminViewModel(
        AdminRepositoryImpl(FirebaseFirestore.instance),
        context.read<AuthRepository>(),
      )..fetchData(),
      child: Consumer<AdminViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('داشبورد ادمین', style: TextStyle(fontWeight: FontWeight.bold)),
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              foregroundColor: theme.colorScheme.onSurface,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: theme.primaryColor,
                labelColor: theme.primaryColor,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'کاربران'),
                  Tab(text: 'زمین‌ها'),
                ],
              ),
            ),
            drawer: _buildDrawer(context, vm),
            body: vm.isLoading && vm.users.isEmpty && vm.grounds.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : vm.error != null
                    ? Center(child: Text('خطا: ${vm.error}', style: TextStyle(color: theme.colorScheme.error)))
                    : Column(
                        children: [
                          _buildSummary(vm.totalUsersCount, vm.onlineUsersCount, vm.totalGroundsCount, context),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildUsersTab(vm, context),
                                _buildGroundsTab(vm, context),
                              ],
                            ),
                          ),
                        ],
                      ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AdminViewModel vm) {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.primaryColor),
            accountName: const Text('ادمین سیستم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: const Text('مدیریت کل', style: TextStyle(fontSize: 14)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.cardColor,
              child: Icon(Icons.admin_panel_settings, size: 40, color: theme.primaryColor),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, Icons.dashboard_outlined, 'داشبورد', onTap: () => Navigator.pop(context), selected: true),
                _buildDrawerItem(context, Icons.analytics_outlined, 'گزارشات و آمار', onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(value: vm, child: const AdminReportsScreen())));
                  }),
                _buildDrawerItem(context, Icons.book_online_outlined, 'مدیریت رزروها', onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(value: vm, child: const AdminBookingsScreen())));
                  }),
                _buildDrawerItem(context, Icons.security_outlined, 'لاگ‌های امنیتی', onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(value: vm, child: const AdminAuditLogsScreen())));
                  }),
                _buildDrawerItem(context, Icons.notifications_active_outlined, 'ارسال اعلان', onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: vm,
                          child: const BroadcastNotificationScreen(),
                        ),
                      ),
                    );
                  }),
                const Divider(),
                _buildDrawerItem(context, Icons.logout, 'خروج', onTap: () => vm.logout(), color: theme.colorScheme.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, {required VoidCallback onTap, bool selected = false, Color? color}) {
     final theme = Theme.of(context);
     return ListTile(
       leading: Icon(icon, color: color ?? (selected ? theme.primaryColor : theme.iconTheme.color)),
       title: Text(title, style: TextStyle(color: color ?? (selected ? theme.primaryColor : theme.textTheme.bodyLarge?.color), fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
       selected: selected,
       onTap: onTap,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
       contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
     );
  }

  Widget _buildSummary(int userCount, int onlineUserCount, int groundCount, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildSummaryCard(context, 'کاربران', userCount.toString(), Icons.people_outline, Colors.blue)),
          const SizedBox(width: 8),
          Expanded(child: _buildSummaryCard(context, 'آنلاین', onlineUserCount.toString(), Icons.wifi, Colors.orange)),
          const SizedBox(width: 8),
          Expanded(child: _buildSummaryCard(context, 'زمین‌ها', groundCount.toString(), Icons.sports_soccer_outlined, Colors.green)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab(AdminViewModel vm, BuildContext context) {
    // Filter users based on selected role
    List<UserModel> displayedUsers = vm.users;
    
    // Apply role/status filter
    if (_selectedRoleFilter != null) {
      if (_selectedRoleFilter == 'groundOwner') {
        displayedUsers = displayedUsers.where((u) => u.role == UserRole.groundOwner).toList();
      } else if (_selectedRoleFilter == 'admin') {
        displayedUsers = displayedUsers.where((u) => u.role == UserRole.admin).toList();
      } else if (_selectedRoleFilter == 'user') {
        displayedUsers = displayedUsers.where((u) => u.role == UserRole.user).toList();
      } else if (_selectedRoleFilter == 'online') {
         displayedUsers = displayedUsers.where((u) => u.isOnline).toList();
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _userSearchController,
                  decoration: InputDecoration(
                    hintText: 'جستجوی کاربران...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (query) => vm.searchUsers(query),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedRoleFilter,
                    hint: const Text('همه'),
                    icon: const Icon(Icons.filter_list),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRoleFilter = newValue;
                      });
                    },
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('همه'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'online', // New Online Filter
                        child: Row(
                          children: [
                            Icon(Icons.wifi, size: 16, color: Colors.green),
                            SizedBox(width: 8),
                            Text('کاربران آنلاین'),
                          ],
                        ),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'groundOwner',
                        child: Text('صاحبان زمین'),
                      ),
                       DropdownMenuItem<String?>(
                        value: 'user',
                        child: Text('کاربران عادی'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'admin',
                        child: Text('مدیران'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildUsersGrid(displayedUsers, context, vm)),
      ],
    );
  }

  Widget _buildGroundsTab(AdminViewModel vm, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: TextField(
            controller: _groundSearchController,
            decoration: InputDecoration(
              hintText: 'جستجوی زمین‌ها...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (query) => vm.searchGrounds(query),
          ),
        ),
        Expanded(child: _buildGroundsGrid(vm.grounds, context, vm)),
      ],
    );
  }

  Widget _buildUsersGrid(
      List<UserModel> users, BuildContext context, AdminViewModel adminViewModel) {
    if (users.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('کاربری یافت نشد', style: TextStyle(color: Colors.grey[600])),
        ],
      ));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: adminViewModel,
                    child: UserDetailScreen(user: user),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                        child: user.avatarUrl.isEmpty
                            ? Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                              )
                            : null,
                      ),
                      if (user.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      user.role.toString().split('.').last,
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    backgroundColor: user.role.toString().contains('admin') ? Colors.redAccent : Colors.blueGrey,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroundsGrid(List<FutsalField> grounds, BuildContext context, AdminViewModel vm) {
    if (grounds.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stadium_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('زمینی یافت نشد', style: TextStyle(color: Colors.grey[600])),
        ],
      ));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: grounds.length,
      itemBuilder: (context, index) {
        final ground = grounds[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                  value: vm,
                  child: GroundDetailScreen(ground: ground),
                ),
            ));
          },
          child: Stack(
            children: [
               FutsalFieldCard(field: ground, isCompact: true),
               // Overlay status if needed
               if (ground.status != 'approved')
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ground.status == 'pending' ? Colors.orange : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ground.status,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
