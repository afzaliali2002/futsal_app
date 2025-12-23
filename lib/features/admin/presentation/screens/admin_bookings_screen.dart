import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../view_models/admin_view_model.dart';
import 'package:futsal_app/features/booking/domain/entities/booking_status.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final bookings = vm.bookings;

    // Optional: Sort manually if backend sorting is disabled to avoid index errors
    bookings.sort((a, b) => b.startTime.compareTo(a.startTime));

    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت رزروها')),
      body: bookings.isEmpty 
          ? const Center(child: Text('هیچ رزروی یافت نشد'))
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final isConfirmed = booking.status == BookingStatus.confirmed;
                final isPending = booking.status == BookingStatus.pending;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: Text('${booking.futsalName}'),
                    subtitle: Text('${_formatDate(booking.startTime)} - ${booking.bookerName}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isConfirmed ? Colors.green : (isPending ? Colors.orange : Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        booking.status.toString().split('.').last,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('نام رزرو کننده: ${booking.bookerName}'),
                            Text('شماره تماس: ${booking.bookerPhone}'),
                            Text('مبلغ: ${booking.price} ${booking.currency}'),
                            const SizedBox(height: 16),
                            // Here you could add Admin actions like "Force Cancel"
                            if (isPending || isConfirmed)
                              ElevatedButton(
                                onPressed: () {
                                  // Implement cancel logic in ViewModel if needed
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('قابلیت لغو توسط ادمین به زودی اضافه می‌شود')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('لغو رزرو (مدیریت)', style: TextStyle(color: Colors.white)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime dt) {
    final j = Jalali.fromDateTime(dt);
    return '${j.year}/${j.month}/${j.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
