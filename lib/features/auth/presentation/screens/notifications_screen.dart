import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual notifications from a ViewModel
    final List<dynamic> notifications = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('اعلان‌ها'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : _buildNotificationsList(notifications),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'در حال حاضر هیچ اعلانی وجود ندارد',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<dynamic> notifications) {
    // TODO: Use a custom notification card and real data
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        // Replace with a custom notification card
        return const ListTile(
          leading: Icon(Icons.check_circle, color: Colors.green),
          title: Text('رزرو موفقیت‌آمیز بود'),
          subtitle: Text('زمین فوتسال شما برای ساعت 18:00 رزرو شد.'),
        );
      },
    );
  }
}
