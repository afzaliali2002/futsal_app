import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/admin_view_model.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final bookings = vm.bookings;
    
    // Calculate stats
    final totalBookings = bookings.length;
    final totalRevenue = bookings.fold(0.0, (sum, b) => sum + b.price);
    final confirmedBookings = bookings.where((b) => b.status.toString().contains('confirmed')).length;

    return Scaffold(
      appBar: AppBar(title: const Text('گزارشات و آمار')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
           _buildStatCard(context, 'کل درآمد', '${totalRevenue.toStringAsFixed(0)} افغانی', Icons.attach_money, Colors.green),
           _buildStatCard(context, 'تعداد کل رزروها', '$totalBookings', Icons.book_online, Colors.blue),
           _buildStatCard(context, 'رزروهای قطعی', '$confirmedBookings', Icons.check_circle, Colors.orange),
           // Add more charts or lists here if needed
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
