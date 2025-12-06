import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  double _selectedDuration = 1.5;
  bool _isBooking = false;

  FutsalField? field;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (field == null) {
      final arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments is FutsalField) {
        setState(() {
          field = arguments;
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('خطا: اطلاعات زمین برای رزرو یافت نشد.'), backgroundColor: Colors.red),
            );
          }
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _confirmBooking() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (_selectedTime == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('لطفاً ابتدا ساعت شروع را انتخاب کنید.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('برای رزرو زمین باید وارد حساب کاربری خود شوید.');
      }

      final timeParts = _selectedTime!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final bookingStartDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, hour, minute);

      final pricePerStandardSlot = field!.pricePerHour;
      final finalPrice = (pricePerStandardSlot / 1.5) * _selectedDuration;

      final bookingData = {
        'userId': user.uid,
        'fieldId': field!.id,
        'fieldName': field!.name,
        'fieldAddress': field!.address,
        'fieldImageUrl': field!.imageUrl,
        'bookingTime': Timestamp.fromDate(bookingStartDateTime),
        'durationHours': _selectedDuration,
        'totalPrice': finalPrice,
        'createdAt': Timestamp.now(), // Use local timestamp
      };

      await FirebaseFirestore.instance.collection('bookings').add(bookingData);

      if (!mounted) return;
      Navigator.of(context).pop();
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('زمین با موفقیت برای شما رزرو شد!'), backgroundColor: Colors.green),
      );

    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('خطا در ثبت رزرو: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (field == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final FutsalField currentField = field!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('رزرو زمین'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 150),
        children: [
          _buildFieldSummary(context, currentField),
          const SizedBox(height: 30),
          _buildSectionTitle(context, '۱. تاریخ را انتخاب کنید', Icons.calendar_today_outlined),
          const SizedBox(height: 12),
          _buildDatePicker(context),
          const SizedBox(height: 30),
          _buildSectionTitle(context, '۲. ساعت شروع را انتخاب کنید', Icons.access_time_rounded),
          const SizedBox(height: 12),
          _buildTimeSlots(context),
          const SizedBox(height: 30),
          _buildSectionTitle(context, '۳. مدت زمان را انتخاب کنید', Icons.hourglass_bottom_rounded),
          const SizedBox(height: 12),
          _buildDurationChips(context),
        ],
      ),
      bottomNavigationBar: _buildBookingBottomBar(context, currentField),
    );
  }

  Widget _buildFieldSummary(BuildContext context, FutsalField field) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: field.imageUrl.isNotEmpty
                ? Image.network(field.imageUrl, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 70, height: 70, color: theme.dividerColor, child: const Icon(Icons.sports_soccer)))
                : Container(width: 70, height: 70, color: theme.dividerColor, child: const Icon(Icons.sports_soccer)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(field.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(field.address, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'fa_IR').format(_selectedDate);
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formattedDate, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Icon(Icons.edit_calendar_outlined, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots(BuildContext context) {
    final List<String> times = ['09:00', '11:00', '14:00', '16:00', '18:00', '20:00'];
    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: times.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final time = times[index];
          return ChoiceChip(
            label: Text(time),
            selected: _selectedTime == time,
            onSelected: (selected) {
              setState(() {
                _selectedTime = selected ? time : null;
              });
            },
            labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: _selectedTime == time ? Colors.white : null, fontWeight: FontWeight.bold),
            selectedColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          );
        },
      ),
    );
  }

  Widget _buildDurationChips(BuildContext context) {
    final Map<String, double> durations = {'۱ ساعت': 1.0, '۱.۵ ساعت': 1.5, '۲ ساعت': 2.0};
    return Wrap(
      spacing: 12,
      children: durations.keys.map((label) {
        final duration = durations[label]!;
        return ChoiceChip(
          label: Text(label),
          selected: _selectedDuration == duration,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedDuration = duration;
              });
            }
          },
          labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: _selectedDuration == duration ? Colors.white : null, fontWeight: FontWeight.bold),
          selectedColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      }).toList(),
    );
  }

  Widget _buildBookingBottomBar(BuildContext context, FutsalField field) {
    final theme = Theme.of(context);
    final pricePerStandardSlot = field.pricePerHour;
    final finalPrice = (pricePerStandardSlot / 1.5) * _selectedDuration;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15).copyWith(bottom: MediaQuery.of(context).padding.bottom + 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        border: Border(top: BorderSide(color: theme.dividerColor, width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('مبلغ نهایی', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 2),
                Text('${finalPrice.toStringAsFixed(0)} افغانی', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 3,
            child: ElevatedButton(
              onPressed: _isBooking ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isBooking
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                  : const Text('تایید و رزرو', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}