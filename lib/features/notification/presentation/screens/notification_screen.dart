import 'package:flutter/material.dart';
import 'package:futsal_app/features/booking/data/models/booking_model.dart';
import 'package:futsal_app/features/booking/domain/entities/booking_status.dart';
import 'package:futsal_app/features/booking/presentation/view_models/booking_view_model.dart';
import 'package:futsal_app/features/notification/data/models/notification_model.dart';
import 'package:futsal_app/features/notification/presentation/providers/notification_view_model.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';


// Helper function to convert English numerals and AM/PM to Persian
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

String _formatDateTimeToPersian12Hour(DateTime dt) {
  final format = DateFormat('h:mm a', 'en_US');
  final formattedString = format.format(dt);
  return _toPersian(formattedString);
}


class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  String _toShamsi(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    final f = jalali.formatter;
    return _toPersian('${f.wN}، ${f.d} ${f.mN} ${f.yyyy}');
  }


  @override
  Widget build(BuildContext context) {
    final notificationViewModel = context.watch<NotificationViewModel>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('اعلانات'),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to see notifications.'))
          : StreamBuilder<List<NotificationModel>>(
              stream: user.uid.isEmpty ? null : notificationViewModel.getNotifications(user.uid),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return const Center(
                      child: Text('هیچ اعلانی برای نمایش وجود ندارد.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(context, notification, user.uid);
                  },
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, NotificationModel notification, String currentUserId) {
    final bookingId = notification.metadata['bookingId'] as String?;
    final groundId = notification.metadata['groundId'] as String?;
    final bookingViewModel = context.read<BookingViewModel>();
    final notificationViewModel = context.read<NotificationViewModel>();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            notificationViewModel.markAsRead(currentUserId, notification.id);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!notification.isRead)
                    Icon(Icons.circle, color: Theme.of(context).primaryColor, size: 12),
                  if (!notification.isRead) const SizedBox(width: 8),
                  Expanded(
                    child: Text(notification.title, style: Theme.of(context).textTheme.titleLarge),
                  ),
                   Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                ],
              ),
              const SizedBox(height: 8),
              Text(notification.body),
              const SizedBox(height: 4),
              Text(
                _toShamsi(notification.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
              if (notification.type == NotificationType.bookingRequest &&
                  bookingId != null && bookingId.isNotEmpty &&
                  groundId != null && groundId.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: StreamBuilder<BookingModel>(
                    stream: bookingViewModel.getBookingById(groundId, bookingId),
                    builder: (context, snapshot) {
                       if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                      }
                      if (!snapshot.hasData || snapshot.data!.id.isEmpty) {
                         return const Text('این رزرو دیگر موجود نیست.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
                      }

                      final booking = snapshot.data!;
                      final isHandled = booking.status == BookingStatus.confirmed ||
                                        booking.status == BookingStatus.cancelled;

                      if (isHandled) {
                        return Text(
                          booking.status == BookingStatus.confirmed
                              ? 'این درخواست قبلا تایید شده است.'
                              : 'این درخواست قبلا رد شده است.',
                          style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _showConfirmationDialog(
                                context,
                                title: 'رد کردن رزرو',
                                content: 'آیا از رد کردن این درخواست مطمئن هستید؟',
                                onConfirm: () => bookingViewModel.rejectBooking(groundId, bookingId, booking.userId, booking.futsalName, booking.startTime),
                              ),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red)),
                              child: const Text('رد کردن'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _showConfirmationDialog(
                                context,
                                title: 'تایید رزرو',
                                content: 'آیا از تایید این درخواست مطمئن هستید؟',
                                onConfirm: () => bookingViewModel.approveBooking(groundId, bookingId, booking.userId, booking.futsalName, booking.startTime),
                              ),
                              child: const Text('تایید'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
      {
        required String title,
        required String content,
        required VoidCallback onConfirm,
      }
    ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            },
            child: const Text('تایید'),
          ),
        ],
      ),
    );
  }
}
