import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../booking/presentation/providers/my_bookings_provider.dart';
import '../../../booking/presentation/widgets/booking_card.dart';
import '../../../booking/domain/usecases/get_my_bookings_use_case.dart';
import '../../../booking/data/repositories/booking_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('رزرو های من'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('برای دیدن رزروهای خود، لطفاً ابتدا وارد شوید.'),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => MyBookingsProvider(
        GetMyBookingsUseCase(
          BookingRepositoryImpl(FirebaseFirestore.instance),
        ),
      )..listenToMyBookings(user.uid),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('رزرو های من'),
          centerTitle: true,
        ),
        body: Consumer<MyBookingsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text('خطا: ${provider.error}'));
            }

            if (provider.bookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'شما هنوز هیچ رزروی انجام نداده‌اید.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: provider.bookings.length,
              itemBuilder: (context, index) {
                return BookingCard(booking: provider.bookings[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
