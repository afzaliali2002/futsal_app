// lib/features/booking/presentation/screens/booking_form_screen.dart

import 'package:flutter/material.dart';

class BookingFormScreen extends StatelessWidget {
  const BookingFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final field = {
      'name': 'فوتسال المپیک',
      'pricePerHour': 250000, // in IRR (for calculation)
    };

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('رزرو زمین'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Field Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sports_soccer, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${field['name']}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '۲۵۰,۰۰۰ تومان / ساعت',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Date Picker
          _buildSectionTitle(context, 'تاریخ رزرو'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Text(
                  'سه‌شنبه، ۱۵ دی ۱۴۰۳',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_calendar),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Time Slots
          _buildSectionTitle(context, 'ساعت شروع'),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTimeSlot(context, '18:00'),
                _buildTimeSlot(context, '19:00', selected: true),
                _buildTimeSlot(context, '20:00'),
                _buildTimeSlot(context, '21:00'),
                _buildTimeSlot(context, '22:00'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Duration
          _buildSectionTitle(context, 'مدت زمان'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              _buildDurationChip(context, '۱ ساعت', selected: true),
              _buildDurationChip(context, '۱.۵ ساعت'),
              _buildDurationChip(context, '۲ ساعت'),
            ],
          ),
          const SizedBox(height: 24),

          // Team Name
          _buildSectionTitle(context, 'نام تیم (اختیاری)'),
          const SizedBox(height: 8),
          TextField(
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'تیم پرشین',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 100), // Space for sticky button
        ],
      ),

      // Sticky Confirm Button
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Navigate to confirmation or payment
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'تایید رزرو – ۵۰۰,۰۰۰ تومان',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTimeSlot(BuildContext context, String time, {bool selected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: selected
            ? null
            : Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          time,
          style: TextStyle(
            color: selected ? Colors.black : Theme.of(context).colorScheme.onSurface,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip(BuildContext context, String label, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}