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


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Set to store the IDs of notifications selected for deletion
  final Set<String> _selectedNotifications = {};
  bool _isSelectionMode = false;

  String _toShamsi(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    final f = jalali.formatter;
    return _toPersian('${f.wN}، ${f.d} ${f.mN} ${f.yyyy}');
  }

  void _toggleSelection(String notificationId) {
    setState(() {
      if (_selectedNotifications.contains(notificationId)) {
        _selectedNotifications.remove(notificationId);
        if (_selectedNotifications.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedNotifications.add(notificationId);
        _isSelectionMode = true;
      }
    });
  }

  void _deleteSelectedNotifications(String userId) {
    if (_selectedNotifications.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف اعلانات'),
        content: Text('آیا از حذف ${_selectedNotifications.length} اعلان انتخاب شده مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
               final viewModel = context.read<NotificationViewModel>();
               // Create a copy of the list to avoid concurrent modification issues during iteration if that were happening,
               // but here we just iterate the set.
               for (final id in _selectedNotifications) {
                 viewModel.deleteNotification(userId, id);
               }
               
               setState(() {
                 _selectedNotifications.clear();
                 _isSelectionMode = false;
               });
               
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationViewModel = context.watch<NotificationViewModel>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode 
          ? '${_selectedNotifications.length} انتخاب شده'
          : 'اعلانات'
        ),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => user != null ? _deleteSelectedNotifications(user.uid) : null,
            ),
        ],
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
                    final isSelected = _selectedNotifications.contains(notification.id);
                    return _buildNotificationCard(context, notification, user.uid, isSelected);
                  },
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, NotificationModel notification, String currentUserId, bool isSelected) {
    final bookingId = notification.metadata['bookingId'] as String?;
    final groundId = notification.metadata['groundId'] as String?;
    final imageUrl = notification.metadata['imageUrl'] as String?; // Retrieve image URL if available
    final bookingViewModel = context.read<BookingViewModel>();
    final notificationViewModel = context.read<NotificationViewModel>();

    return Card(
      elevation: 1,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200),
      ),
      child: InkWell(
        onLongPress: () {
          _toggleSelection(notification.id);
        },
        onTap: _isSelectionMode 
            ? () => _toggleSelection(notification.id) 
            : () {
              // Only mark as read, do NOT show loading or navigate
              if (!notification.isRead) {
                notificationViewModel.markAsRead(currentUserId, notification.id);
              }
            },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   if (_isSelectionMode)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8.0),
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                        size: 20,
                      ),
                    ),

                  if (!notification.isRead && !_isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Icon(Icons.circle, color: Theme.of(context).primaryColor, size: 8),
                    ),
                  if (!notification.isRead && !_isSelectionMode) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              
              // Image Display (If available in notification)
              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(), // Hide if image fails to load
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              Text(
                notification.body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _toShamsi(notification.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ),
              if (!_isSelectionMode && notification.type == NotificationType.bookingRequest &&
                  bookingId != null && bookingId.isNotEmpty &&
                  groundId != null && groundId.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: StreamBuilder<BookingModel>(
                    stream: bookingViewModel.getBookingById(groundId, bookingId),
                    builder: (context, snapshot) {
                       if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                      }
                      if (!snapshot.hasData || snapshot.data!.id.isEmpty) {
                         return Text('این رزرو دیگر موجود نیست.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontStyle: FontStyle.italic));
                      }

                      final booking = snapshot.data!;
                      final isHandled = booking.status == BookingStatus.confirmed ||
                                        booking.status == BookingStatus.cancelled;

                      if (isHandled) {
                        return Text(
                          booking.status == BookingStatus.confirmed
                              ? 'این درخواست قبلا تایید شده است.'
                              : 'این درخواست قبلا رد شده است.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontStyle: FontStyle.italic),
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: OutlinedButton(
                                onPressed: () => _showConfirmationDialog(
                                  context,
                                  title: 'رد کردن رزرو',
                                  content: 'آیا از رد کردن این درخواست مطمئن هستید؟',
                                  onConfirm: () => bookingViewModel.rejectBooking(groundId, bookingId, booking.userId, booking.futsalName, booking.startTime),
                                ),
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: EdgeInsets.zero
                                ),
                                child: const Text('رد کردن', style: TextStyle(fontSize: 13)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                onPressed: () => _showConfirmationDialog(
                                  context,
                                  title: 'تایید رزرو',
                                  content: 'آیا از تایید این درخواست مطمئن هستید؟',
                                  onConfirm: () => bookingViewModel.approveBooking(groundId, bookingId, booking.userId, booking.futsalName, booking.startTime),
                                ),
                                style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                                child: const Text('تایید', style: TextStyle(fontSize: 13)),
                              ),
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
