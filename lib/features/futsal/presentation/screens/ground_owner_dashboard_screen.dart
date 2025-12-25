import 'package:flutter/material.dart';
import 'package:futsal_app/features/booking/data/models/blocked_slot_model.dart';
import 'package:futsal_app/features/booking/data/models/booking_model.dart';
import 'package:futsal_app/features/booking/domain/entities/booking_status.dart';
import 'package:futsal_app/features/booking/presentation/view_models/booking_view_model.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/futsal/domain/entities/time_range.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
import 'package:futsal_app/features/futsal/presentation/screens/add_futsal_ground_screen.dart';
import 'package:futsal_app/features/futsal/presentation/screens/slot_details_screen.dart';
import 'package:futsal_app/features/profile/presentation/view_models/user_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  String? _selectedFieldId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userViewModel = context.watch<UserViewModel>();
    final ownerId = userViewModel.user?.uid;

    return Consumer<FutsalViewModel>(
      builder: (context, vm, child) {
        final myFields = vm.fields.where((f) => f.ownerId == ownerId).toList();

        FutsalField? selectedField;
        if (myFields.isNotEmpty) {
          if (_selectedFieldId != null) {
            try {
              selectedField = myFields.firstWhere((f) => f.id == _selectedFieldId);
            } catch (_) {
              selectedField = myFields.first;
              _selectedFieldId = selectedField.id;
            }
          } else {
            selectedField = myFields.first;
            _selectedFieldId = selectedField.id;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('پنل مدیریت'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: theme.colorScheme.onSurface,
          ),
          body: myFields.isEmpty
              ? _buildEmptyState(context, vm)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildGroundSelector(myFields, selectedField, theme),
                      const SizedBox(height: 16),
                      if (selectedField != null)
                         _buildGroundImage(selectedField),
                      const SizedBox(height: 16),
                      if (selectedField != null)
                        GroundManagementScreen(field: selectedField),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddFutsalGroundScreen()),
              );
            },
            label: const Text('افزودن زمین جدید'),
            icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildGroundSelector(List<FutsalField> myFields, FutsalField? selectedField, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedField?.id,
          isExpanded: true,
          hint: const Text('انتخاب زمین'),
          items: myFields.map((field) {
            return DropdownMenuItem<String>(
              value: field.id,
              child: Text(field.name, style: theme.textTheme.titleMedium),
            );
          }).toList(),
          onChanged: (fieldId) {
            if (fieldId != null) {
              setState(() {
                _selectedFieldId = fieldId;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildGroundImage(FutsalField field) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200,
      ),
      clipBehavior: Clip.antiAlias,
      child: field.coverImageUrl.isNotEmpty 
          ? Image.network(
              field.coverImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
            )
          : const Center(child: Icon(Icons.sports_soccer, size: 80, color: Colors.grey)),
    );
  }

  Widget _buildEmptyState(BuildContext context, FutsalViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('شما هنوز زمینی ثبت نکرده‌اید'),
        ],
      ),
    );
  }
}

class GroundManagementScreen extends StatefulWidget {
  final FutsalField field;

  const GroundManagementScreen({super.key, required this.field});

  @override
  State<GroundManagementScreen> createState() => _GroundManagementScreenState();
}

class _GroundManagementScreenState extends State<GroundManagementScreen> {
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

  // New helper method to find slot price
  double _getSlotPrice(FutsalField field, DateTime slot) {
    final day = DateFormat.EEEE('en_US').format(slot).toLowerCase();
    final schedule = field.schedule?[day];
    if (schedule == null) return field.pricePerHour;

    final slotStartMinutes = slot.hour * 60 + slot.minute;

    for (final tr in schedule) {
      final startMinutes = tr.start.hour * 60 + tr.start.minute;
      final endMinutes = tr.end.hour * 60 + tr.end.minute;
      
      // Handle simple day ranges (no midnight crossing logic here for simplicity, assuming typical operating hours)
      // Check if the slot starts within this range [start, end)
      // Note: _generateTimeSlots generates slots based on these ranges, so exact matches or inclusion is expected.
      if (slotStartMinutes >= startMinutes && slotStartMinutes < endMinutes) {
        return tr.price ?? field.pricePerHour;
      }
    }
    return field.pricePerHour;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSummaryCard(context, theme, widget.field),
        const SizedBox(height: 24),
        _buildTimeSlotManager(context, widget.field),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, ThemeData theme, FutsalField field) {
    final bookingViewModel = context.watch<BookingViewModel>();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<List<BookingModel>>(
            stream: bookingViewModel.getBookings(field.id, DateTime.now()),
            builder: (context, snapshot) {
              final confirmedBookings = snapshot.data?.where((b) => 
                b.status == BookingStatus.confirmed || 
                b.status == BookingStatus.completed
              ).toList() ?? [];
              
              final todayIncome = confirmedBookings.fold<double>(0, (sum, booking) => sum + booking.price);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(context, 'رزروهای امروز', _toPersian(confirmedBookings.length.toString()), Icons.today),
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
                final booking = bookings.firstWhere((b) => !slot.isBefore(b.startTime) && slot.isBefore(b.endTime), orElse: () => BookingModel(id: '', groundId: '', userId: '', futsalName: '', startTime: slot, endTime: slot.add(const Duration(minutes: 90)), price: 0, status: BookingStatus.cancelled, bookerName: '', bookerPhone: '', currency: 'AFN'));
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
                
                // Fetch the specific price for this slot
                final slotPrice = _getSlotPrice(field, slot);

                return ListTile(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SlotDetailsScreen(
                      slot: slot,
                      field: field,
                      booking: booking.id.isNotEmpty ? booking : null,
                      blockedSlot: isBlocked ? blockedSlot : null,
                      price: slotPrice, // Pass the specific price to SlotDetailsScreen
                    ),
                  )),
                  leading: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                  title: Text('${_formatDateTimeToPersian12Hour(slot)} - ${_formatDateTimeToPersian12Hour(slot.add(const Duration(minutes: 90)))}'),
                  // Display the price in subtitle
                  subtitle: Text('$statusText - ${_toPersian(slotPrice.toStringAsFixed(0))} ؋', style: TextStyle(color: statusColor)),
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
