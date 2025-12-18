import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futsal_app/features/booking/data/models/blocked_slot_model.dart';
import 'package:futsal_app/features/booking/data/models/booking_model.dart';
import 'package:futsal_app/features/booking/domain/entities/booking_status.dart';
import 'package:futsal_app/features/booking/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepositoryImpl(this._firestore);

  @override
  Stream<List<BookingModel>> getBookingsForDate(String groundId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _firestore
        .collection('grounds')
        .doc(groundId)
        .collection('bookings')
        .where('startTime', isGreaterThanOrEqualTo: start)
        .where('startTime', isLessThan: end)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BookingModel.fromSnapshot(doc)).toList());
  }

  @override
  Stream<List<BookingModel>> getMyBookings(String userId) {
    final controller = StreamController<List<BookingModel>>();
    final Map<String, List<BookingModel>> allBookingsByGround = {};
    final List<StreamSubscription> subscriptions = [];

    // 1. Listen to the list of grounds.
    final groundsSubscription = _firestore.collection('fields').snapshots().listen((fieldsSnapshot) {
      // 2. When grounds change, cancel old listeners.
      for (var sub in subscriptions) {
        sub.cancel();
      }
      subscriptions.clear();
      allBookingsByGround.clear();

      final groundIds = fieldsSnapshot.docs.map((doc) => doc.id).toList();
      if (groundIds.isEmpty) {
        controller.add([]);
        return;
      }

      // 3. For each ground, create a new listener for the user's bookings.
      for (final groundId in groundIds) {
        final sub = _firestore
            .collection('grounds')
            .doc(groundId)
            .collection('bookings')
            .where('userId', isEqualTo: userId)
            .snapshots()
            .listen((bookingSnapshot) {
          allBookingsByGround[groundId] = bookingSnapshot.docs.map((doc) => BookingModel.fromSnapshot(doc)).toList();

          // 4. Combine all results and emit.
          final combinedList = allBookingsByGround.values.expand((list) => list).toList();
          combinedList.sort((a, b) => b.startTime.compareTo(a.startTime));
          controller.add(combinedList);
        });
        subscriptions.add(sub);
      }
    });

    controller.onCancel = () {
      groundsSubscription.cancel();
      for (var sub in subscriptions) {
        sub.cancel();
      }
    };

    return controller.stream;
  }

  @override
  Stream<BookingModel> getBookingById(String groundId, String bookingId) {
    return _firestore
        .collection('grounds')
        .doc(groundId)
        .collection('bookings')
        .doc(bookingId)
        .snapshots()
        .map((doc) => BookingModel.fromSnapshot(doc));
  }

  @override
  Future<String> createBooking(BookingModel booking) async {
    final docRef = await _firestore
        .collection('grounds')
        .doc(booking.groundId)
        .collection('bookings')
        .add(booking.toMap());
    return docRef.id;
  }

  @override
  Future<void> cancelBooking(String groundId, String bookingId) async {
    await _firestore
        .collection('grounds')
        .doc(groundId)
        .collection('bookings')
        .doc(bookingId)
        .delete();
  }

  @override
  Future<void> updateBookingStatus(String groundId, String bookingId, BookingStatus status) async {
    await _firestore
        .collection('grounds')
        .doc(groundId)
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status.toString().split('.').last});
  }

  @override
  Stream<List<BlockedSlotModel>> getBlockedSlotsForDate(String groundId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _firestore
        .collection('grounds')
        .doc(groundId)
        .collection('blockedSlots')
        .where('startTime', isGreaterThanOrEqualTo: start)
        .where('startTime', isLessThan: end)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BlockedSlotModel.fromSnapshot(doc)).toList());
  }

  @override
  Future<void> blockSlot(BlockedSlotModel slot) async {
    await _firestore
        .collection('grounds')
        .doc(slot.groundId)
        .collection('blockedSlots')
        .add(slot.toMap());
  }

  @override
  Future<String?> findBlockedSlotId(String groundId, DateTime startTime) async {
    final querySnapshot = await _firestore
        .collection('grounds')
        .doc(groundId)
        .collection('blockedSlots')
        .where('startTime', isEqualTo: startTime)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }
    return null;
  }

  @override
  Future<void> unblockSlot(String groundId, String slotId) async {
    await _firestore
        .collection('grounds')
        .doc(groundId)
        .collection('blockedSlots')
        .doc(slotId)
        .delete();
  }
}
