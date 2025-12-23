import 'package:flutter/material.dart';
import 'package:futsal_app/features/booking/data/models/booking_model.dart';
import 'package:futsal_app/features/booking/data/models/blocked_slot_model.dart';
import 'package:futsal_app/features/booking/domain/entities/booking_status.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/futsal/domain/entities/time_range.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
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

class SlotDetailsScreen extends StatefulWidget {
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

  @override
  State<SlotDetailsScreen> createState() => _SlotDetailsScreenState();
}

class _SlotDetailsScreenState extends State<SlotDetailsScreen> {
  late final TextEditingController _priceController;
  bool _isSavingPrice = false;

  @override
  void initState() {
    super.initState();
    final initialPrice = widget.price ?? widget.field.pricePerHour;
    _priceController =
        TextEditingController(text: initialPrice.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _savePrice() async {
    final newPrice = double.tryParse(_priceController.text);
    if (newPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لطفا قیمت معتبر وارد کنید')));
      return;
    }

    setState(() {
      _isSavingPrice = true;
    });

    try {
      final futsalVM = context.read<FutsalViewModel>();
      final dayOfWeek =
          DateFormat.EEEE('en_US').format(widget.slot).toLowerCase();

      // Deep copy the schedule
      final newSchedule = widget.field.schedule?.map(
            (key, value) =>
                MapEntry(key, value.map((tr) => tr.copyWith()).toList()),
          ) ??
          {};

      final daySchedule = newSchedule[dayOfWeek];
      if (daySchedule == null) {
        throw Exception('Schedule for $dayOfWeek not found!');
      }

      final containingTimeRangeIndex = daySchedule.indexWhere((tr) {
        final startDt = DateTime(widget.slot.year, widget.slot.month,
            widget.slot.day, tr.start.hour, tr.start.minute);
        var endDt = DateTime(widget.slot.year, widget.slot.month,
            widget.slot.day, tr.end.hour, tr.end.minute);
        
        if (endDt.isBefore(startDt)) {
           endDt = endDt.add(const Duration(days: 1));
        }
            
        final adjustedEnd = endDt;

        return (widget.slot.isAtSameMomentAs(startDt) ||
                widget.slot.isAfter(startDt)) &&
            widget.slot.isBefore(adjustedEnd);
      });

      if (containingTimeRangeIndex != -1) {
        final oldTimeRange = daySchedule[containingTimeRangeIndex];
        
        // --- SPLITTING LOGIC START ---
        daySchedule.removeAt(containingTimeRangeIndex);

        TimeOfDay toTime(DateTime dt) => TimeOfDay(hour: dt.hour, minute: dt.minute);

        final trStartDt = DateTime(widget.slot.year, widget.slot.month, widget.slot.day, oldTimeRange.start.hour, oldTimeRange.start.minute);
        var trEndDt = DateTime(widget.slot.year, widget.slot.month, widget.slot.day, oldTimeRange.end.hour, oldTimeRange.end.minute);
        
        if (trEndDt.isBefore(trStartDt)) {
            trEndDt = trEndDt.add(const Duration(days: 1));
        }

        final slotStartDt = widget.slot;
        final slotEndDt = slotStartDt.add(const Duration(minutes: 90));

        // 1. Pre-segment
        if (trStartDt.isBefore(slotStartDt)) {
          daySchedule.add(TimeRange(
            start: toTime(trStartDt),
            end: toTime(slotStartDt),
            price: oldTimeRange.price,
          ));
        }

        // 2. Target slot
        daySchedule.add(TimeRange(
          start: toTime(slotStartDt),
          end: toTime(slotEndDt),
          price: newPrice,
        ));

        // 3. Post-segment
        if (slotEndDt.isBefore(trEndDt)) {
          daySchedule.add(TimeRange(
            start: toTime(slotEndDt),
            end: toTime(trEndDt),
            price: oldTimeRange.price,
          ));
        }
        
        // Sort the schedule to keep time ranges in order
        daySchedule.sort((a, b) {
           final aMin = a.start.hour * 60 + a.start.minute;
           final bMin = b.start.hour * 60 + b.start.minute;
           return aMin.compareTo(bMin);
        });
        // --- SPLITTING LOGIC END ---

      } else {
        throw Exception('Could not find containing time range for this slot.');
      }

      final updatedField = widget.field.copyWith(schedule: newSchedule);
      await futsalVM.updateGround(updatedField);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('قیمت با موفقیت ذخیره شد')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطا در ذخیره قیمت: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingPrice = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.read<UserViewModel>();
    final isOwner = userVM.user?.uid == widget.field.ownerId;
    final bool isBooked = widget.booking != null && widget.booking!.id.isNotEmpty;
    final bool isBlocked =
        widget.blockedSlot != null && widget.blockedSlot!.id.isNotEmpty;
    final bool isAvailable = !isBooked && !isBlocked;

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (isBooked) {
      statusText = widget.booking!.status == BookingStatus.pending
          ? 'در انتظار تایید'
          : 'رزرو شده';
      statusColor =
          widget.booking!.status == BookingStatus.pending ? Colors.orange : Colors.red;
      statusIcon = widget.booking!.status == BookingStatus.pending
          ? Icons.hourglass_top_rounded
          : Icons.event_busy;
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(statusIcon, color: statusColor, size: 40),
                      title: Text(
                        '${_formatDateTimeToPersian12Hour(widget.slot)} - ${_formatDateTimeToPersian12Hour(widget.slot.add(const Duration(minutes: 90)))}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                      _buildBookedDetails(context, widget.booking!)
                    else if (isOwner && isAvailable)
                      _buildOwnerPriceEditor(context)
                    else
                      _buildAvailableSlotDetails(context, isBlocked),
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

  Widget _buildOwnerPriceEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('قیمت سانس را تعیین کنید:',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'قیمت',
                  prefixText: '؋ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            _isSavingPrice
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _savePrice,
                    child: const Text('ذخیره'),
                  ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailableSlotDetails(BuildContext context, bool isBlocked) {
    return Column(
      children: [
        Text(
          isBlocked
              ? 'این ساعت توسط شما مسدود شده است.'
              : 'این ساعت برای رزرو در دسترس است.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (!isBlocked) ...[
          const SizedBox(height: 12),
          _buildDetailRow(
              context,
              Icons.monetization_on,
              'قیمت:',
              '${_toPersian((widget.price ?? widget.field.pricePerHour).toStringAsFixed(0))} ؋'),
        ]
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final currentUser = context.read<UserViewModel>().user;
    final isOwner = currentUser?.uid == widget.field.ownerId;
    final isBooked = widget.booking != null && widget.booking!.id.isNotEmpty;
    final isBlocked =
        widget.blockedSlot != null && widget.blockedSlot!.id.isNotEmpty;
    final bookingViewModel = context.read<BookingViewModel>();

    if (isBooked) {
      if (isOwner) {
        return _buildOwnerActions(context, widget.booking!, bookingViewModel);
      } else if (currentUser?.uid == widget.booking!.userId) {
        return _buildUserBookingActions(
            context, widget.booking!, bookingViewModel);
      }
    } else {
      // Slot is not booked
      return _buildUserActions(context, isBlocked, bookingViewModel);
    }

    return const SizedBox.shrink(); // Return empty space if no actions are available
  }

  Widget _buildOwnerActions(
      BuildContext context, BookingModel booking, BookingViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (booking.status == BookingStatus.pending)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    viewModel.rejectBooking(booking.groundId, booking.id,
                        booking.userId, booking.futsalName, booking.startTime);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red)),
                  child: const Text('رد کردن'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    viewModel.approveBooking(booking.groundId, booking.id,
                        booking.userId, booking.futsalName, booking.startTime);
                    Navigator.pop(context);
                  },
                  child: const Text('تایید'),
                ),
              ),
            ],
          ),
        if (booking.status == BookingStatus.approved ||
            booking.status == BookingStatus.confirmed)
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
                      textStyle:
                          const TextStyle(fontSize: 16, fontFamily: 'BYekan'),
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
                        content: const Text(
                            'آیا از لغو این رزرو اطمینان دارید؟ این عمل غیرقابل بازگشت است.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('خیر'),
                          ),
                          TextButton(
                            onPressed: () {
                              viewModel.rejectBooking(
                                  booking.groundId,
                                  booking.id,
                                  booking.userId,
                                  booking.futsalName,
                                  booking.startTime);
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
                    textStyle:
                        const TextStyle(fontSize: 16, fontFamily: 'BYekan'),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildUserBookingActions(
      BuildContext context, BookingModel booking, BookingViewModel viewModel) {
    if (booking.status == BookingStatus.approved ||
        booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.confirmed) {
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
                    viewModel.rejectBooking(booking.groundId, booking.id,
                        booking.userId, booking.futsalName, booking.startTime);
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

  Widget _buildUserActions(
      BuildContext context, bool isBlocked, BookingViewModel viewModel) {
    final currentUser = context.read<UserViewModel>().user;
    final isOwner = currentUser?.uid == widget.field.ownerId;

    if (isOwner) {
      return ElevatedButton.icon(
        onPressed: () {
          if (isBlocked) {
            viewModel.unblockSlot(widget.field.id, widget.slot);
          } else {
            viewModel.blockSlot(BlockedSlotModel(
              id: '',
              groundId: widget.field.id,
              startTime: widget.slot,
              endTime: widget.slot.add(const Duration(minutes: 90)),
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
        future:
            userViewModel.authRepository.getUserDetails(booking.userId).first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  context, Icons.person, 'رزرو شده توسط:', booking.bookerName),
              const SizedBox(height: 16),
              _buildDetailRow(
                  context, Icons.phone, 'شماره تماس:', booking.bookerPhone),
              const SizedBox(height: 16),
              _buildDetailRow(
                  context, Icons.email, 'ایمیل:', user?.email ?? 'نامشخص'),
              const SizedBox(height: 16),
              _buildDetailRow(context, Icons.money, 'قیمت:',
                  '${_toPersian(booking.price.toStringAsFixed(0))} ؋'),
            ],
          );
        });
  }

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
