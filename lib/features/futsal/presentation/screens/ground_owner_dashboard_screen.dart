import 'package:flutter/material.dart';
import 'package:futsal_app/features/booking/data/models/blocked_slot_model.dart';
import 'package:futsal_app/features/booking/data/models/booking_model.dart';
import 'package:futsal_app/features/booking/domain/entities/booking_status.dart';
import 'package:futsal_app/features/booking/presentation/view_models/booking_view_model.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/futsal/domain/entities/time_range.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
import 'package:futsal_app/features/futsal/presentation/screens/add_futsal_ground_screen.dart';
import 'package:futsal_app/features/futsal/presentation/screens/field_detail_screen.dart';
import 'package:futsal_app/features/futsal/presentation/screens/slot_details_screen.dart';
import 'package:futsal_app/features/notification/presentation/screens/notification_screen.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../widgets/futsal_field_card.dart';

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

class GroundOwnerDashboardScreen extends StatefulWidget {
  const GroundOwnerDashboardScreen({super.key});

  @override
  State<GroundOwnerDashboardScreen> createState() => _GroundOwnerDashboardScreenState();
}

class _GroundOwnerDashboardScreenState extends State<GroundOwnerDashboardScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(DateTime.now());
  }

  String _formatDateTimeToPersian12Hour(DateTime dt) {
    final format = DateFormat('h:mm a', 'en_US');
    final formattedString = format.format(dt);
    return _toPersian(formattedString);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userViewModel = context.watch<UserViewModel>();
    final ownerId = userViewModel.user?.uid;

    return Consumer<FutsalViewModel>(
      builder: (context, vm, child) {
        final myFields = vm.fields.where((f) => f.ownerId == ownerId).toList();
        final hasGround = myFields.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text('پنل مدیریت'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: theme.colorScheme.onSurface,
            actions: [
              // IconButton(
              //   icon: const badges.Badge(
              //     badgeContent: Text('3'), // Replace with actual notification count
              //     child: Icon(Icons.notifications_outlined),
              //   ),
              //   onPressed: () {
              //     Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
              //   },
              // ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCard(context, theme, hasGround ? myFields.first : null),
                const SizedBox(height: 24),
                Text(
                  'زمین من',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildMyGroundsList(context, vm, myFields, ownerId),
                if (hasGround) _buildTimeSlotManager(context, myFields.first),
              ],
            ),
          ),
          floatingActionButton: !hasGround
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddFutsalGroundScreen()),
                    );
                  },
                  label: const Text('افزودن زمین جدید'),
                  icon: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, ThemeData theme, FutsalField? field) {
    final bookingViewModel = context.watch<BookingViewModel>();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<List<BookingModel>>(
            stream: field != null ? bookingViewModel.getBookings(field.id, DateTime.now()) : Stream.value([]),
            builder: (context, snapshot) {
              final approvedBookings = snapshot.data?.where((b) => b.status == BookingStatus.approved).toList() ?? [];
              final todayIncome = approvedBookings.fold<double>(0, (sum, booking) => sum + booking.price);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(context, 'رزروهای امروز', _toPersian(approvedBookings.length.toString()), Icons.today),
                  _buildStatItem(context, 'درآمد امروز', '${_toPersian(todayIncome.toStringAsFixed(0))} ؋', Icons.attach_money),
                ],
              );
            }),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 30, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
      ],
    );
  }

  Widget _buildMyGroundsList(
      BuildContext context, FutsalViewModel vm, List<FutsalField> myFields, String? ownerId) {
    if (ownerId == null) return const Center(child: Text('کاربر یافت نشد'));

    if (vm.isLoading && myFields.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (myFields.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('شما هنوز زمینی ثبت نکرده‌اید'),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FieldDetailScreen(field: myFields.first),
          ),
        );
      },
      child: FutsalFieldCard(field: myFields.first),
    );
  }

  Widget _buildTimeSlotManager(BuildContext context, FutsalField field) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'مدیریت ساعات کاری',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_calendar_outlined),
                  onPressed: () => _showEditScheduleDialog(context, field),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWeeklyCalendar(),
            const SizedBox(height: 16),
            const Divider(),
            _buildTimeSlots(context, field),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    final today = DateUtils.dateOnly(DateTime.now());
    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: index));
          final isSelected = date == _selectedDate;
          return InkWell(
            onTap: () => setState(() => _selectedDate = date),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat.E('fa').format(date),
                      style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Theme.of(context).primaryColor : null)),
                  const SizedBox(height: 4),
                  Text(DateFormat.d('fa').format(date),
                      style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                          color: isSelected ? Theme.of(context).primaryColor : null)),
                  Text(DateFormat.MMM('fa').format(date), style: TextStyle(fontSize: 12, color: isSelected ? Theme.of(context).primaryColor : Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots(BuildContext context, FutsalField field) {
    final bookingViewModel = context.read<BookingViewModel>();

    return StreamBuilder<List<BookingModel>>(
      stream: bookingViewModel.getBookings(field.id, _selectedDate),
      builder: (context, bookingSnapshot) {
        return StreamBuilder<List<BlockedSlotModel>>(
          stream: bookingViewModel.getBlockedSlots(field.id, _selectedDate),
          builder: (context, blockedSlotSnapshot) {
            if (bookingSnapshot.connectionState == ConnectionState.waiting ||
                blockedSlotSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
            }

            // Filter out cancelled bookings to prevent them from showing as "Reserved" in details
            final bookings = (bookingSnapshot.data ?? [])
                .where((b) => b.status != BookingStatus.cancelled)
                .toList();

            final blockedSlots = blockedSlotSnapshot.data ?? [];
            final timeSlots = _generateTimeSlots(field.schedule, _selectedDate);

            if (timeSlots.isEmpty) {
              return const Center(
                  child: Padding(padding: EdgeInsets.all(32.0), child: Text('امروز روز کاری شما نیست')));
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timeSlots.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final slot = timeSlots[index];
                final booking = bookings.firstWhere((b) => !slot.isBefore(b.startTime) && slot.isBefore(b.endTime), orElse: () => BookingModel(id: '', groundId: '', userId: '', futsalName: '', startTime: slot, endTime: slot.add(const Duration(minutes: 90)), price: 0, status: BookingStatus.cancelled, bookerName: '', bookerPhone: ''));
                final blockedSlot = blockedSlots.firstWhere((bs) => !slot.isBefore(bs.startTime) && slot.isBefore(bs.endTime), orElse: () => BlockedSlotModel(id: '', groundId: '', startTime: slot, endTime: slot.add(const Duration(minutes: 90))));

                final isConfirmed = booking.id.isNotEmpty && (
                  booking.status == BookingStatus.confirmed || 
                  booking.status == BookingStatus.approved ||
                  booking.status == BookingStatus.completed
                );
                final isPending = booking.id.isNotEmpty && booking.status == BookingStatus.pending;
                final isBlocked = blockedSlot.id.isNotEmpty;

                String statusText;
                Color statusColor;

                if (isConfirmed) {
                  statusText = 'رزرو شده';
                  statusColor = Colors.red;
                } else if (isPending) {
                  statusText = 'در انتظار تایید';
                  statusColor = Colors.orange;
                } else if (isBlocked) {
                  statusText = 'مسدود';
                  statusColor = Colors.orange.shade700;
                } else {
                  statusText = 'قابل دسترس';
                  statusColor = Colors.green;
                }

                return ListTile(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SlotDetailsScreen(
                      slot: slot,
                      field: field,
                      booking: booking.id.isNotEmpty ? booking : null,
                      blockedSlot: isBlocked ? blockedSlot : null,
                    ),
                  )),
                  leading: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                  title: Text('${_formatDateTimeToPersian12Hour(slot)} - ${_formatDateTimeToPersian12Hour(slot.add(const Duration(minutes: 90)))}'),
                  subtitle: Text(statusText, style: TextStyle(color: statusColor)),
                  trailing: const Icon(Icons.chevron_right),
                );
              },
            );
          },
        );
      },
    );
  }

  List<DateTime> _generateTimeSlots(
      Map<String, List<TimeRange>>? schedule, DateTime date) {
    if (schedule == null) return [];

    final dayOfWeek = DateFormat.EEEE('en_US').format(date).toLowerCase();
    final daySchedule = schedule[dayOfWeek];

    if (daySchedule == null) return [];

    final slots = <DateTime>[];
    for (final timeRange in daySchedule) {
      var current = DateTime(date.year, date.month, date.day, timeRange.start.hour, timeRange.start.minute);
      final end = DateTime(date.year, date.month, date.day, timeRange.end.hour, timeRange.end.minute);

      final adjustedEnd = end.isBefore(current) ? end.add(const Duration(days: 1)) : end;

      while (current.isBefore(adjustedEnd)) {
        slots.add(current);
        current = current.add(const Duration(minutes: 90));
      }
    }

    return slots;
  }

  void _showEditScheduleDialog(BuildContext context, FutsalField field) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => _EditScheduleScreen(field: field)));
  }
}

class _EditScheduleScreen extends StatefulWidget {
  final FutsalField field;

  const _EditScheduleScreen({required this.field});

  @override
  State<_EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<_EditScheduleScreen> {
  late Map<String, List<TimeRange>> _schedule;

  @override
  void initState() {
    super.initState();
    // Deep copy the schedule to avoid modifying the original object
    _schedule = Map.from(widget.field.schedule?.map(
      (key, value) => MapEntry(key, value.map((e) => TimeRange(start: e.start, end: e.end)).toList()),
    ) ?? {});
  }

  void _saveSchedule() {
    final futsalViewModel = context.read<FutsalViewModel>();
    final updatedField = widget.field.copyWith(
      schedule: _schedule,
    );
    futsalViewModel.updateGround(updatedField);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('زمانبندی با موفقیت ویرایش شد')));
  }

  String _formatPersianTime(BuildContext context, TimeOfDay time) {
    final localizations = MaterialLocalizations.of(context);
    final formattedString = localizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
    return _toPersian(formattedString);
  }

  @override
  Widget build(BuildContext context) {
    const weekDays = {
      'شنبه': 'saturday',
      'یکشنبه': 'sunday',
      'دوشنبه': 'monday',
      'سه‌شنبه': 'tuesday',
      'چهارشنبه': 'wednesday',
      'پنجشنبه': 'thursday',
      'جمعه': 'friday',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('ویرایش زمانبندی کاری'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveSchedule)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: weekDays.entries.map((entry) {
          final dayName = entry.key;
          final englishDayName = entry.value;
          final isSelected = _schedule.containsKey(englishDayName);

          return Card(
            elevation: isSelected ? 2 : 0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    value: isSelected,
                    onChanged: (bool value) {
                      setState(() {
                        if (value) {
                          _schedule[englishDayName] = [TimeRange(start: const TimeOfDay(hour: 9, minute: 0), end: const TimeOfDay(hour: 17, minute: 30))];
                        } else {
                          _schedule.remove(englishDayName);
                        }
                      });
                    },
                  ),
                  if (isSelected)
                    ..._schedule[englishDayName]!.asMap().entries.map((rangeEntry) {
                      final index = rangeEntry.key;
                      final timeRange = rangeEntry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: timeRange.start,
                                    builder: (context, child) => MediaQuery(
                                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                      child: child!,
                                    ),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _schedule[englishDayName]![index] = TimeRange(start: picked, end: timeRange.end);
                                    });
                                  }
                                },
                                child: Text(_formatPersianTime(context, timeRange.start), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('–'),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: timeRange.end,
                                    builder: (context, child) => MediaQuery(
                                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                      child: child!,
                                    ),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _schedule[englishDayName]![index] = TimeRange(start: timeRange.start, end: picked);
                                    });
                                  }
                                },
                                child: Text(_formatPersianTime(context, timeRange.end), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _schedule[englishDayName]!.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  if (isSelected)
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('افزودن بازه جدید'),
                      onPressed: () {
                        setState(() {
                          _schedule[englishDayName]!.add(TimeRange(start: const TimeOfDay(hour: 18, minute: 0), end: const TimeOfDay(hour: 22, minute: 0)));
                        });
                      },
                    )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
