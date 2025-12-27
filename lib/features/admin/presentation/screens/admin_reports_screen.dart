import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/admin_view_model.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final bookings = vm.bookings;
    final users = vm.users;
    final grounds = vm.grounds;

    // Calculate stats
    final totalBookings = bookings.length;
    final totalRevenue = bookings.fold(0.0, (sum, b) => sum + b.price);
    final confirmedBookings = bookings.where((b) => b.status.toString().contains('confirmed')).length;
    final rejectedBookings = bookings.where((b) => b.status.toString().contains('rejected')).length;
    final pendingBookings = bookings.where((b) => b.status.toString().contains('pending')).length;
    
    final totalUsers = users.length;
    final totalGrounds = grounds.length;

    // User Roles Data for Pie Chart
    final adminCount = users.where((u) => u.role == UserRole.admin).length;
    final ownerCount = users.where((u) => u.role == UserRole.groundOwner).length;
    final userCount = users.where((u) => u.role == UserRole.user).length;

    return Scaffold(
      appBar: AppBar(title: const Text('گزارشات و آمار')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Cards Row 1
            Row(
              children: [
                Expanded(child: _buildStatCard(context, 'کل کاربران', '$totalUsers', Icons.people, Colors.purple)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, 'کل زمین‌ها', '$totalGrounds', Icons.sports_soccer, Colors.teal)),
              ],
            ),
            const SizedBox(height: 12),
            // Summary Cards Row 2
            Row(
              children: [
                Expanded(child: _buildStatCard(context, 'کل درآمد', '${totalRevenue.toStringAsFixed(0)}', Icons.attach_money, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, 'کل رزروها', '$totalBookings', Icons.book_online, Colors.blue)),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Booking Status Pie Chart
            if (totalBookings > 0) ...[
               Text('وضعیت رزروها', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
               const SizedBox(height: 16),
               SizedBox(
                 height: 250,
                 child: Row(
                   children: [
                     Expanded(
                       child: PieChart(
                         PieChartData(
                           pieTouchData: PieTouchData(
                             touchCallback: (FlTouchEvent event, pieTouchResponse) {
                               setState(() {
                                 if (!event.isInterestedForInteractions ||
                                     pieTouchResponse == null ||
                                     pieTouchResponse.touchedSection == null) {
                                   _touchedIndex = -1;
                                   return;
                                 }
                                 _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                               });
                             },
                           ),
                           borderData: FlBorderData(show: false),
                           sectionsSpace: 0,
                           centerSpaceRadius: 40,
                           sections: [
                             _buildPieChartSection(0, confirmedBookings.toDouble(), Colors.green, 'تایید شده'),
                             _buildPieChartSection(1, pendingBookings.toDouble(), Colors.orange, 'در انتظار'),
                             _buildPieChartSection(2, rejectedBookings.toDouble(), Colors.red, 'رد شده'),
                           ],
                         ),
                       ),
                     ),
                     const SizedBox(width: 16),
                     Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          _buildLegendItem(Colors.green, 'تایید شده: $confirmedBookings'),
                          const SizedBox(height: 4),
                          _buildLegendItem(Colors.orange, 'در انتظار: $pendingBookings'),
                          const SizedBox(height: 4),
                          _buildLegendItem(Colors.red, 'رد شده: $rejectedBookings'),
                       ],
                     ),
                   ],
                 ),
               ),
            ],

            const SizedBox(height: 24),
            
            // User Roles Bar Chart
             Text('توزیع کاربران', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
             const SizedBox(height: 16),
             SizedBox(
               height: 300,
               child: BarChart(
                 BarChartData(
                   alignment: BarChartAlignment.spaceAround,
                   maxY: (totalUsers + 5).toDouble(),
                   barTouchData: BarTouchData(
                     enabled: true,
                   ),
                   titlesData: FlTitlesData(
                     show: true,
                     bottomTitles: AxisTitles(
                       sideTitles: SideTitles(
                         showTitles: true,
                         getTitlesWidget: (value, meta) {
                           switch (value.toInt()) {
                             case 0: return const Text('ادمین', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                             case 1: return const Text('صاحب زمین', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                             case 2: return const Text('کاربر', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                             default: return const Text('');
                           }
                         },
                       ),
                     ),
                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                   ),
                   gridData: const FlGridData(show: false),
                   borderData: FlBorderData(show: false),
                   barGroups: [
                     _buildBarGroup(0, adminCount.toDouble(), Colors.purple),
                     _buildBarGroup(1, ownerCount.toDouble(), Colors.teal),
                     _buildBarGroup(2, userCount.toDouble(), Colors.blue),
                   ],
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildPieChartSection(int index, double value, Color color, String title) {
    final isTouched = index == _touchedIndex;
    final fontSize = isTouched ? 16.0 : 12.0;
    final radius = isTouched ? 60.0 : 50.0;
    
    return PieChartSectionData(
      color: color,
      value: value > 0 ? value : 0.001, // Prevent zero division visual issues
      title: value > 0 ? '${value.toInt()}' : '',
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
  
  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
