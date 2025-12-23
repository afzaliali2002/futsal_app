import 'package:flutter/material.dart';
import 'package:futsal_app/features/booking/domain/entities/booking_status.dart';
import 'package:intl/intl.dart';
import '../../data/models/booking_model.dart';

String _toPersian(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  String result = input;
  for (int i = 0; i < english.length; i++) {
    result = result.replaceAll(english[i], farsi[i]);
  }
  result = result.replaceAll('AM', 'ق.ظ').replaceAll('PM', 'ب.ظ');
  return result;
}

class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'fa_IR');
    final timeFormat = DateFormat('h:mm a', 'en_US');
    final statusText = {
      BookingStatus.upcoming: 'آینده',
      BookingStatus.completed: 'تکمیل شده',
      BookingStatus.cancelled: 'لغو شده',
      BookingStatus.pending: 'در انتظار تایید',
      BookingStatus.confirmed: 'تایید شده',
    };
    final statusColor = {
      BookingStatus.upcoming: Colors.blue,
      BookingStatus.completed: Colors.green,
      BookingStatus.cancelled: Colors.red,
      BookingStatus.pending: Colors.orange,
      BookingStatus.confirmed: Colors.green,
    };

    final String formattedDate = dateFormat.format(booking.startTime);
    final String formattedTime = '${_toPersian(timeFormat.format(booking.startTime))} - ${_toPersian(timeFormat.format(booking.endTime))}';
    final String formattedPrice = booking.price > 0
        ? '${NumberFormat.decimalPattern('fa_IR').format(booking.price)} ${booking.currency}'
        : 'رایگان';

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
                    color: (statusColor[booking.status] ?? Colors.grey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText[booking.status] ?? '',
                    style: TextStyle(
                      color: statusColor[booking.status] ?? Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.calendar_today_outlined, formattedDate),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.access_time_outlined, formattedTime),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.attach_money_outlined, formattedPrice),
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
