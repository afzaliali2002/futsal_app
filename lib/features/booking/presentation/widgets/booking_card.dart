import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'fa_IR');
    final statusText = {
      BookingStatus.upcoming: 'آینده',
      BookingStatus.completed: 'تکمیل شده',
      BookingStatus.canceled: 'لغو شده',
    };
    final statusColor = {
      BookingStatus.upcoming: Colors.blue,
      BookingStatus.completed: Colors.green,
      BookingStatus.canceled: Colors.red,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.futsalName,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor[booking.status]?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText[booking.status] ?? '',
                    style: TextStyle(
                      color: statusColor[booking.status],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.calendar_today_outlined, dateFormat.format(booking.date)),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.access_time_outlined, booking.timeSlot),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.attach_money_outlined, '${NumberFormat.decimalPattern('fa_IR').format(booking.price)} تومان'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
      ],
    );
  }
}
