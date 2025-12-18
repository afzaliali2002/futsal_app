import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:intl/intl.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() => _selectedDate = pickedDate);
    });
  }

  void _presentTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((pickedTime) {
      if (pickedTime == null) return;
      setState(() => _selectedTime = pickedTime);
    });
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لطفا تاریخ و زمان را انتخاب کنید')),
        );
        return;
      }
      // TODO: Implement booking logic with a view model
      // e.g., context.read<BookingViewModel>().createBooking(...);
      print('Booking Submitted');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final FutsalField? field = ModalRoute.of(context)?.settings.arguments as FutsalField?;
    final theme = Theme.of(context);

    if (field == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('خطا: مشخصات زمین یافت نشد.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('رزرو ${field.name}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildGroundInfoCard(theme, field),
            const SizedBox(height: 24),
            Text('اطلاعات شما', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'نام شما'),
              validator: (v) => v!.isEmpty ? 'لطفا نام خود را وارد کنید' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'شماره تماس'),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'لطفا شماره تماس خود را وارد کنید' : null,
            ),
            const SizedBox(height: 24),
            Text('انتخاب زمان', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildDateTimePicker(
              label: 'تاریخ',
              value: _selectedDate != null ? DateFormat('y/MM/d').format(_selectedDate!) : 'انتخاب نشده',
              onPressed: _presentDatePicker,
            ),
            const SizedBox(height: 12),
            _buildDateTimePicker(
              label: 'زمان',
              value: _selectedTime != null ? _selectedTime!.format(context) : 'انتخاب نشده',
              onPressed: _presentTimePicker,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitBooking,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('تایید و ثبت رزرو'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroundInfoCard(ThemeData theme, FutsalField field) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildInfoRow(theme, Icons.location_on_outlined, '${field.address}, ${field.city}'),
            const SizedBox(height: 4),
            _buildInfoRow(theme, Icons.payment_outlined, '${field.pricePerHour.toStringAsFixed(0)} ${field.currency} فی ساعت'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }
  
  Widget _buildDateTimePicker({required String label, required String value, required VoidCallback onPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        TextButton(
          onPressed: onPressed,
          child: Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
        ),
      ],
    );
  }
}