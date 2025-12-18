import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:futsal_app/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:futsal_app/features/admin/presentation/screens/user_detail_screen.dart';
import 'package:futsal_app/features/admin/presentation/view_models/admin_view_model.dart';
import 'package:futsal_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/futsal/presentation/screens/field_detail_screen.dart';
import 'package:futsal_app/features/profile/data/models/user_model.dart';
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
    return ChangeNotifierProvider(
      create: (context) => AdminViewModel(
        AdminRepositoryImpl(FirebaseFirestore.instance),
        context.read<AuthRepository>(),
      )..fetchData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('داشبورد ادمین'),
          actions: [
            Consumer<AdminViewModel>(
              builder: (context, adminViewModel, _) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    adminViewModel.logout();
                  },
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'کاربران'),
              Tab(text: 'زمین‌ها'),
            ],
          ),
        ),
        body: Consumer<AdminViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading && vm.users.isEmpty && vm.grounds.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.error != null) {
              return Center(child: Text('خطا: ${vm.error}'));
            }

            return Column(
              children: [
                _buildSummary(vm.users.length, vm.grounds.length),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummary(int userCount, int groundCount) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(userCount.toString(),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('کاربران'),
              ],
            ),
            Column(
              children: [
                Text(groundCount.toString(),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('زمین‌ها'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab(AdminViewModel vm, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _userSearchController,
            decoration: InputDecoration(
              hintText: 'جستجوی کاربران...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (query) => vm.searchUsers(query),
          ),
        ),
        Expanded(child: _buildUsersList(vm.users, context, vm)),
      ],
    );
  }

  Widget _buildGroundsTab(AdminViewModel vm, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _groundSearchController,
            decoration: InputDecoration(
              hintText: 'جستجوی زمین‌ها...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (query) => vm.searchGrounds(query),
          ),
        ),
        Expanded(child: _buildGroundsList(vm.grounds, context)),
      ],
    );
  }

  Widget _buildUsersList(
      List<UserModel> users, BuildContext context, AdminViewModel adminViewModel) {
    if (users.isEmpty) {
      return const Center(child: Text('کاربری یافت نشد.'));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(user.name),
            subtitle: Text(user.email),
            trailing: Text(user.role.toString().split('.').last),
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
          ),
        );
      },
    );
  }

  Widget _buildGroundsList(List<FutsalField> grounds, BuildContext context) {
    if (grounds.isEmpty) {
      return const Center(child: Text('زمینی یافت نشد.'));
    }

    return ListView.builder(
      itemCount: grounds.length,
      itemBuilder: (context, index) {
        final ground = grounds[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(ground.name),
            subtitle: Text(ground.address),
            trailing: Text('قیمت: ${ground.pricePerHour}'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FieldDetailScreen(field: ground),
              ));
            },
          ),
        );
      },
    );
  }
}
