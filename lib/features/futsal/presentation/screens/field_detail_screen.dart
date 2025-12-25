// FULL VERSION: FieldDetailScreen with Map button (Lat/Lng)

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:futsal_app/features/booking/data/models/blocked_slot_model.dart';
import 'package:futsal_app/features/booking/data/models/booking_model.dart';
import 'package:futsal_app/features/booking/domain/entities/booking_status.dart';
import 'package:futsal_app/features/booking/presentation/view_models/booking_view_model.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/futsal/domain/entities/time_range.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
import 'package:futsal_app/features/futsal/presentation/screens/slot_details_screen.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:url_launcher/url_launcher.dart';

import 'add_futsal_ground_screen.dart';

// ---------------- Persian helpers ----------------
String _toPersian(String input) {
  const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  var res = input;
  for (int i = 0; i < en.length; i++) {
    res = res.replaceAll(en[i], fa[i]);
  }
  return res.replaceAll('AM', 'ق.ظ').replaceAll('PM', 'ب.ظ');
}

String _formatTime12(DateTime dt) {
  return _toPersian(DateFormat('h:mm a', 'en_US').format(dt));
}

String _formatTime24(DateTime dt) {
  return _toPersian(DateFormat('H:mm', 'en_US').format(dt));
}

// ---------------- Screen ----------------
class FieldDetailScreen extends StatefulWidget {
  final FutsalField field;
  const FieldDetailScreen({super.key, required this.field});

  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(DateTime.now());
  }

  // -------- Launchers --------
  Future<void> _openMap(double lat, double lng) async {
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('امکان باز کردن نقشه وجود ندارد')));
      }
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWhatsapp(String phone) async {
    final uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  String _cleanAddress(String address, String city) {
    final parts = address
        .split(',')
        .map((e) => e.trim())
        .where((e) => !(e.contains('+') && e.length < 15))
        .where((e) => e.toLowerCase() != city.toLowerCase())
        .toList();
    if (parts.isEmpty) return city;
    return '${parts.join(', ')}, $city';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final futsalVM = context.watch<FutsalViewModel>();

    final field = futsalVM.fields.firstWhere(
      (f) => f.id == widget.field.id,
      orElse: () => widget.field,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, field),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationRatingAndMap(context, field),
                    const SizedBox(height: 24),
                    _sectionTitle(context, 'توضیحات', Icons.info_outline),
                    const SizedBox(height: 12),
                    Text(field.description, style: theme.textTheme.bodyMedium), // Reduced font
                    const SizedBox(height: 24),
                    _sectionTitle(context, 'اطلاعات تماس', Icons.contact_phone_outlined),
                    const SizedBox(height: 12),
                    _buildContactInfo(context, field),
                    const SizedBox(height: 24),
                    _sectionTitle(context, 'امکانات', Icons.widgets_outlined),
                    const SizedBox(height: 12),
                    _buildFeaturesGrid(field), // Changed to Grid
                    const SizedBox(height: 24),
                    _sectionTitle(
                        context, 'زمان‌بندی', Icons.access_time_rounded),
                    const SizedBox(height: 12),
                    _buildWeeklyCalendar(),
                    const SizedBox(height: 16),
                    _buildTimeSlotsList(context, field), // Changed to List
                  ]),
            ),
          )
        ],
      ),
    );
  }

  // ---------------- AppBar ----------------
  SliverAppBar _buildSliverAppBar(BuildContext context, FutsalField field) {
    final userVM = context.watch<UserViewModel>();
    final futsalVM = context.read<FutsalViewModel>();
    final isOwner = userVM.user?.uid == field.ownerId;
    final isAdmin = userVM.user?.role == UserRole.admin;
    final canEdit = isOwner || isAdmin;

    return SliverAppBar(
      expandedHeight: 240, // Reduced height slightly
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      actions: [
        if (canEdit)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddFutsalGroundScreen(field: field)),
            ),
          ),
        IconButton(
          icon: Icon(field.isFavorite ? Icons.favorite : Icons.favorite_border),
          onPressed: () => futsalVM.toggleFavorite(field),
        )
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(field.name, style: const TextStyle(fontSize: 16)), // Smaller font
        background: Image.network(
          field.coverImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.black26),
        ),
      ),
    );
  }

  // ---------------- Location + Rating + Map ----------------
  Widget _buildLocationRatingAndMap(BuildContext context, FutsalField field) {
    final theme = Theme.of(context);
    final userVM = context.read<UserViewModel>();

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Icon(Icons.location_on_outlined,
          size: 18, color: theme.colorScheme.primary),
      const SizedBox(width: 8),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_cleanAddress(field.address, field.city),
              style: theme.textTheme.titleSmall, // Smaller font
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _openMap(field.latitude, field.longitude),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.map_outlined, size: 16, color: theme.primaryColor),
              const SizedBox(width: 4),
              Text('یافتن در نقشه',
                  style: theme.textTheme.labelSmall?.copyWith( // Smaller font
                      color: theme.primaryColor, fontWeight: FontWeight.bold)),
            ]),
          ),
        ]),
      ),
      const SizedBox(width: 16),
      InkWell(
        onTap: () async {
          if (userVM.user != null) {
            final futsalVM = context.read<FutsalViewModel>();
            final initialRating = await futsalVM.getUserRating(field.id) ?? 3.0;
            if (context.mounted) {
              _showRatingDialog(context, field, initialRating);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('لطفا برای ثبت امتیاز وارد شوید')));
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 5),
            Text(_toPersian(field.rating.toStringAsFixed(1)),
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text('امتیاز دهید',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.primaryColor, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    ]);
  }

  void _showRatingDialog(
      BuildContext context, FutsalField field, double initialRating) {
    double rating = initialRating;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('امتیازدهی'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('لطفا امتیاز خود را به این زمین ثبت کنید'),
          const SizedBox(height: 20),
          RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (r) => rating = r,
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف')),
          TextButton(
            onPressed: () {
              context.read<FutsalViewModel>().rateGround(field.id, rating);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('امتیاز شما با موفقیت ثبت شد')));
            },
            child: const Text('ثبت'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      const SizedBox(width: 8),
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), // Smaller font
    ]);
  }

  // ---------------- Contact Info ----------------
  Widget _buildContactInfo(BuildContext context, FutsalField field) {
    final theme = Theme.of(context);
    final fullName = '${field.firstName ?? ''} ${field.lastName ?? ''}'.trim();
    final hasWhatsapp = field.whatsappNumber != null && field.whatsappNumber!.isNotEmpty;
    final hasEmail = field.email != null && field.email!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fullName.isNotEmpty)
          _contactRow(Icons.person_outline, fullName, theme),
        _contactRow(Icons.phone_outlined, _toPersian(field.phoneNumber), theme,
            onTap: () => _launchPhone(field.phoneNumber)),
        if (hasWhatsapp)
          _contactRow(
              Icons.message_outlined, _toPersian(field.whatsappNumber!), theme,
              onTap: () => _launchWhatsapp(field.whatsappNumber!)),
        if (hasEmail)
          _contactRow(Icons.email_outlined, field.email!, theme,
              onTap: () => _launchEmail(field.email!)),
      ],
    );
  }

  Widget _contactRow(IconData icon, String text, ThemeData theme,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Flexible(child: Text(text, style: theme.textTheme.bodyMedium)), // Smaller font
          ],
        ),
      ),
    );
  }

  // ---------------- Features Grid ----------------
  Widget _buildFeaturesGrid(FutsalField field) {
    final chips = <Widget>[];
    if (field.lightsAvailable) chips.add(_featureItem('چراغ', Icons.lightbulb_outline));
    if (field.parkingAvailable) chips.add(_featureItem('پارکینگ', Icons.local_parking));
    if (field.changingRoomAvailable) chips.add(_featureItem('رختکن', Icons.checkroom));
    if (field.washroomAvailable) chips.add(_featureItem('تشناب', Icons.wash));
    if (field.grassType != null) chips.add(_featureItem('چمن ${field.grassType!}', Icons.grass));
    if (field.size != null) chips.add(_featureItem(field.size!, Icons.aspect_ratio));
    
    if (chips.isEmpty) return const Text('امکانات خاصی ثبت نشده است.');
    
    // Using GridView for features
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: chips,
    );
  }

  Widget _featureItem(String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ---------------- Calendar & Slots ----------------
  Widget _buildWeeklyCalendar() {
    final today = DateUtils.dateOnly(DateTime.now());
    return SizedBox(
      height: 70, // Slightly reduced height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: index));
          final isSelected = date == _selectedDate;
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 55, // Slightly reduced width
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(DateFormat.E('fa').format(date),
                    style: TextStyle(
                        fontSize: 12, // Smaller font
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(DateFormat.d('fa').format(date),
                    style: TextStyle(
                        fontSize: 14, // Smaller font
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface)),
              ]),
            ),
          );
        },
      ),
    );
  }

  // Use List for Time Slots
  Widget _buildTimeSlotsList(BuildContext context, FutsalField field) {
    final bookingVM = context.watch<BookingViewModel>();
    final userVM = context.read<UserViewModel>();
    final currentUserId = userVM.user?.uid;
    final isOwner = currentUserId == field.ownerId;

    return StreamBuilder<List<BookingModel>>(
      stream: bookingVM.getBookings(field.id, _selectedDate),
      builder: (context, bookingSnap) {
        return StreamBuilder<List<BlockedSlotModel>>(
          stream: bookingVM.getBlockedSlots(field.id, _selectedDate),
          builder: (context, blockedSnap) {
            if (bookingSnap.connectionState == ConnectionState.waiting ||
                blockedSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final bookings = bookingSnap.data ?? [];
            final blocked = blockedSnap.data ?? [];
            final slots = _generateSlots(field, _selectedDate);

            if (slots.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('امروز روز کاری نیست')),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slots.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final slotData = slots[i];
                final slot = slotData['time'] as DateTime;
                final price = slotData['price'] as double;
                
                final booking = bookings.firstWhere(
                  (b) =>
                      !slot.isBefore(b.startTime) && slot.isBefore(b.endTime),
                  orElse: () => _emptyBooking(slot),
                );
                
                final blockedSlotObj = blocked.cast<BlockedSlotModel?>().firstWhere(
                  (bs) => bs != null && !slot.isBefore(bs.startTime) && slot.isBefore(bs.endTime),
                  orElse: () => null,
                );

                final isConfirmed = booking.id.isNotEmpty &&
                    booking.status == BookingStatus.confirmed;
                final isPending = booking.id.isNotEmpty &&
                    booking.status == BookingStatus.pending;
                final isBlocked = blockedSlotObj != null;
                final isMyPending =
                    isPending && booking.userId == currentUserId;
                final isAvailable = !isConfirmed && !isBlocked && !isMyPending;

                return _slotListItem(
                    context,
                    field,
                    slot,
                    price,
                    isAvailable,
                    isConfirmed,
                    isMyPending,
                    isBlocked,
                    booking,
                    blockedSlotObj,
                    isOwner);
              },
            );
          },
        );
      },
    );
  }

  Widget _slotListItem(
      BuildContext context,
      FutsalField field,
      DateTime slot,
      double price,
      bool isAvailable,
      bool isConfirmed,
      bool isMyPending,
      bool isBlocked,
      BookingModel booking,
      BlockedSlotModel? blockedSlot,
      bool isOwner) {
    final theme = Theme.of(context);
    String statusLabel;
    Color bgColor;
    Color textColor;

    if (isMyPending) {
      statusLabel = 'در انتظار';
      bgColor = Colors.amber.shade100;
      textColor = Colors.amber.shade900;
    } else if (isConfirmed) {
      statusLabel = 'رزرو';
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade900;
    } else if (isBlocked) {
      statusLabel = 'مسدود';
      bgColor = Colors.grey.shade300;
      textColor = Colors.grey.shade700;
    } else {
      statusLabel = 'آزاد';
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
    }

    final endTime = slot.add(const Duration(minutes: 90));
    final timeStr = '${_formatTime24(slot)} - ${_formatTime24(endTime)}';

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          if (isOwner) {
             await Navigator.push(context, MaterialPageRoute(builder: (context) => SlotDetailsScreen(
               slot: slot,
               field: field,
               price: price,
               booking: (isConfirmed || isMyPending) ? booking : null,
               blockedSlot: blockedSlot,
             )));
          } else {
             if (isAvailable) _confirmBooking(context, field, slot, price);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeStr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  Text(
                    statusLabel,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  if (isConfirmed && isOwner) 
                     Padding(
                       padding: const EdgeInsets.only(right: 8.0),
                       child: Text(
                         '(${booking.bookerName})',
                         style: const TextStyle(fontSize: 10),
                       ),
                     )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmBooking(
      BuildContext context, FutsalField field, DateTime slot, double price) {
    final bookingVM = context.read<BookingViewModel>();
    final userVM = context.read<UserViewModel>();
    showDialog(
      context: context,
      builder: (_) => _BookingConfirmationDialog(
        field: field,
        slot: slot,
        price: price,
        bookingViewModel: bookingVM,
        userViewModel: userVM,
      ),
    );
  }

  List<Map<String, dynamic>> _generateSlots(FutsalField field, DateTime date) {
    final day = DateFormat.EEEE('en_US').format(date).toLowerCase();
    final schedule = field.schedule?[day];
    if (schedule == null || schedule.isEmpty) return [];

    final slots = <Map<String, dynamic>>[];
    for (final TimeRange tr in schedule) {
      var cur = DateTime(
          date.year, date.month, date.day, tr.start.hour, tr.start.minute);
      final end = DateTime(
          date.year, date.month, date.day, tr.end.hour, tr.end.minute);
      final adjustedEnd =
          end.isBefore(cur) ? end.add(const Duration(days: 1)) : end;
      
      final slotPrice = tr.price ?? field.pricePerHour;

      while (cur.isBefore(adjustedEnd)) {
        slots.add({
          'time': cur,
          'price': slotPrice,
        });
        cur = cur.add(const Duration(minutes: 90));
      }
    }
    slots.sort((a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));
    return slots;
  }

  BookingModel _emptyBooking(DateTime slot) => BookingModel(
        id: '',
        groundId: '',
        userId: '',
        futsalName: '',
        startTime: slot,
        endTime: slot,
        price: 0,
        status: BookingStatus.cancelled,
        bookerName: '',
        bookerPhone: '',
        currency: 'AFN',
      );
}

// ---------------- Booking Confirmation ----------------
class _BookingConfirmationDialog extends StatefulWidget {
  final FutsalField field;
  final DateTime slot;
  final double price;
  final BookingViewModel bookingViewModel;
  final UserViewModel userViewModel;
  const _BookingConfirmationDialog(
      {required this.field,
      required this.slot,
      required this.price,
      required this.bookingViewModel,
      required this.userViewModel});

  @override
  State<_BookingConfirmationDialog> createState() =>
      _BookingConfirmationDialogState();
}

class _BookingConfirmationDialogState
    extends State<_BookingConfirmationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.userViewModel.user?.name ?? '');
    _phone = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  String _toShamsi(DateTime d) {
    final j = Jalali.fromDateTime(d);
    final f = j.formatter;
    return _toPersian('${f.wN}، ${f.d} ${f.mN} ${f.yyyy}');
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    var phone = _phone.text;
    if (phone.startsWith('0')) phone = phone.substring(1);
    if (!phone.startsWith('93')) phone = '93$phone';

    final booking = BookingModel(
      id: '',
      groundId: widget.field.id,
      userId: widget.userViewModel.user!.uid,
      futsalName: widget.field.name,
      startTime: widget.slot,
      endTime: widget.slot.add(const Duration(minutes: 90)),
      price: widget.price,
      status: BookingStatus.pending,
      bookerName: _name.text,
      bookerPhone: phone,
      currency: 'AFN',
    );
    widget.bookingViewModel.createBooking(booking, widget.field.ownerId);
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('درخواست رزرو ارسال شد')));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تایید و تکمیل اطلاعات'),
      content: Form(
        key: _formKey,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.field.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('تاریخ: ${_toShamsi(widget.slot)}', style: Theme.of(context).textTheme.bodySmall),
              Text('ساعت: ${_formatTime12(widget.slot)}', style: Theme.of(context).textTheme.bodySmall),
              Text(
                  'قیمت: ${_toPersian(widget.price.toStringAsFixed(0))} ؋', style: Theme.of(context).textTheme.bodySmall),
              const Divider(height: 24),
              TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'نام'),
                  validator: (v) => v!.isEmpty ? 'الزامی' : null),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(
                      labelText: 'شماره تماس', prefixText: '+93 '),
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'الزامی' : null),
            ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف')),
        ElevatedButton(onPressed: _submit, child: const Text('ارسال')),
      ],
    );
  }
}