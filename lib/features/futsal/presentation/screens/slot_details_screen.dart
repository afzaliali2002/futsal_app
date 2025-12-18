import 'package:flutter/material.dart';
import 'package:futsal_app/features/booking/data/models/booking_model.dart';
import 'package:futsal_app/features/booking/data/models/blocked_slot_model.dart';
import 'package:futsal_app/features/booking/domain/entities/booking_status.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/profile/data/models/user_model.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:futsal_app/features/booking/presentation/view_models/booking_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

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

class SlotDetailsScreen extends StatelessWidget {
  final DateTime slot;
  final FutsalField field;
  final BookingModel? booking;
  final BlockedSlotModel? blockedSlot;
  final double? price;

  const SlotDetailsScreen({
    super.key,
    required this.slot,
    required this.field,
    this.booking,
    this.blockedSlot,
    this.price,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBooked = booking != null && booking!.id.isNotEmpty;
    final bool isBlocked = blockedSlot != null && blockedSlot!.id.isNotEmpty;

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (isBooked) {
      statusText = booking!.status == BookingStatus.pending ? 'در انتظار تایید' : 'رزرو شده';
      statusColor = booking!.status == BookingStatus.pending ? Colors.orange : Colors.red;
      statusIcon = booking!.status == BookingStatus.pending ? Icons.hourglass_top_rounded : Icons.event_busy;
    } else if (isBlocked) {
      statusText = 'مسدود شده';
      statusColor = Colors.orange;
      statusIcon = Icons.block;
    } else {
      statusText = 'قابل دسترس';
      statusColor = Colors.green;
      statusIcon = Icons.event_available;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزییات ساعت'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(statusIcon, color: statusColor, size: 40),
                      title: Text(
                        '${_formatDateTimeToPersian12Hour(slot)} - ${_formatDateTimeToPersian12Hour(slot.add(const Duration(minutes: 90)))}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        statusText,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 32),
                    if (isBooked)
                      _buildBookedDetails(context, booking!)
                    else
                       Column(
                         children: [
                           Text(
                            isBlocked ? 'این ساعت توسط شما مسدود شده است.' : 'این ساعت برای رزرو در دسترس است.',
                             style: Theme.of(context).textTheme.titleMedium,
                           ),
                           if (!isBlocked && !isBooked) ...[
                             const SizedBox(height: 12),
                             _buildDetailRow(context, Icons.monetization_on, 'قیمت:', '${_toPersian((price ?? field.pricePerHour).toStringAsFixed(0))} ؋'),
                           ]
                         ],
                       ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            _buildActionButtons(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final currentUser = context.read<UserViewModel>().user;
    final isOwner = currentUser?.uid == field.ownerId;
    final isBooked = booking != null && booking!.id.isNotEmpty;
    final isBlocked = blockedSlot != null && blockedSlot!.id.isNotEmpty;
    final bookingViewModel = context.read<BookingViewModel>();

    if (isBooked) {
      if (isOwner) {
        return _buildOwnerActions(context, booking!, bookingViewModel);
      } else if (currentUser?.uid == booking!.userId) {
        return _buildUserBookingActions(context, booking!, bookingViewModel);
      }
    } else {
      // Slot is not booked
      return _buildUserActions(context, isBlocked, bookingViewModel);
    }

    return const SizedBox.shrink(); // Return empty space if no actions are available
  }
  
  Widget _buildOwnerActions(BuildContext context, BookingModel booking, BookingViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (booking.status == BookingStatus.pending)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    viewModel.rejectBooking(booking.groundId, booking.id, booking.userId, booking.futsalName, booking.startTime);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                  child: const Text('رد کردن'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    viewModel.approveBooking(booking.groundId, booking.id, booking.userId, booking.futsalName, booking.startTime);
                    Navigator.pop(context);
                  },
                  child: const Text('تایید'),
                ),
              ),
            ],
          ),
        if (booking.status == BookingStatus.approved || booking.status == BookingStatus.confirmed)
          Row(
            children: [
              if (booking.bookerPhone.isNotEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(booking.bookerPhone),
                    icon: const Icon(Icons.phone),
                    label: const Text('تماس'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontFamily: 'BYekan'),
                    ),
                  ),
                ),
              if (booking.bookerPhone.isNotEmpty) const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('لغو رزرو'),
                        content: const Text('آیا از لغو این رزرو اطمینان دارید؟ این عمل غیرقابل بازگشت است.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('خیر'),
                          ),
                          TextButton(
                            onPressed: () {
                              viewModel.rejectBooking(booking.groundId, booking.id, booking.userId, booking.futsalName, booking.startTime);
                              Navigator.of(ctx).pop(); 
                              Navigator.of(context).pop();
                            },
                            child: const Text('بله، لغو کن'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('لغو رزرو'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontFamily: 'BYekan'),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildUserBookingActions(BuildContext context, BookingModel booking, BookingViewModel viewModel) {
     if (booking.status == BookingStatus.approved || booking.status == BookingStatus.pending || booking.status == BookingStatus.confirmed) {
      return OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('لغو رزرو'),
              content: const Text('آیا از لغو این رزرو اطمینان دارید؟'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('خیر'),
                ),
                TextButton(
                  onPressed: () {
                    viewModel.rejectBooking(booking.groundId, booking.id, booking.userId, booking.futsalName, booking.startTime);
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('بله، لغو کن'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('لغو رزرو'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontFamily: 'BYekan'),
        ),
      );
    }
    return const SizedBox.shrink();
  }

   Widget _buildUserActions(BuildContext context, bool isBlocked, BookingViewModel viewModel) {
    final currentUser = context.read<UserViewModel>().user;
    final isOwner = currentUser?.uid == field.ownerId;

    if(isOwner) {
       return ElevatedButton.icon(
        onPressed: () {
          if (isBlocked) {
            viewModel.unblockSlot(field.id, slot);
          } else {
            viewModel.blockSlot(BlockedSlotModel(
              id: '',
              groundId: field.id,
              startTime: slot,
              endTime: slot.add(const Duration(minutes: 90)),
            ));
          }
          Navigator.of(context).pop();
        },
        icon: Icon(isBlocked ? Icons.lock_open : Icons.block),
        label: Text(isBlocked ? 'رفع مسدودیت' : 'مسدود کردن ساعت'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isBlocked ? Colors.green : Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontFamily: 'BYekan'),
        ),
      );
    }
    
    if (!isBlocked) {
      return ElevatedButton.icon(
        onPressed: () {
          // The booking dialog should be called from parent screen or implemented here.
          // Since the main booking flow seems to be in field_detail_screen, we might just pop back.
          Navigator.pop(context, 'book');
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('رزرو این ساعت'),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBookedDetails(BuildContext context, BookingModel booking) {
    final userViewModel = context.read<UserViewModel>();
    return FutureBuilder<UserModel?>(
        future: userViewModel.authRepository.getUserDetails(booking.userId).first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(context, Icons.person, 'رزرو شده توسط:', booking.bookerName),
              const SizedBox(height: 16),
              _buildDetailRow(context, Icons.phone, 'شماره تماس:', booking.bookerPhone),
              const SizedBox(height: 16),
              _buildDetailRow(context, Icons.email, 'ایمیل:', user?.email ?? 'نامشخص'),
              const SizedBox(height: 16),
              _buildDetailRow(context, Icons.money, 'قیمت:', '${_toPersian(booking.price.toStringAsFixed(0))} ؋'),
            ],
          );
        });
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
