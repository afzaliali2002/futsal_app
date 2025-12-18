import 'dart:io';
import 'package:futsal_app/features/booking/data/models/blocked_slot_model.dart';
import 'package:futsal_app/features/booking/data/models/booking_model.dart';
import '../entities/futsal_field.dart';

abstract class FutsalRepository {
  Stream<List<FutsalField>> getFutsalFields();

  Future<void> addFutsalField(
      FutsalField futsal,
      File? coverImage,
      List<File> galleryImages,
      );
  Future<List<FutsalField>> searchFutsalFields(String query);
  Future<void> deleteGround(String groundId);
  Future<void> updateGround(FutsalField ground, {File? coverImage});
  Future<void> addToFavorites(String groundId, String userId);
  Future<void> removeFromFavorites(String groundId, String userId);
  Future<List<String>> getFavoriteGrounds(String userId);
  Future<void> rateGround({
    required String groundId,
    required String userId,
    required double rating,
  });
  Future<double?> getUserRating(String groundId, String userId);

  // Booking
  Stream<List<BookingModel>> getBookings(String groundId, DateTime date);
  Future<void> createBooking(BookingModel booking);
  Future<void> cancelBooking(String bookingId);

  // Blocked Slots
  Stream<List<BlockedSlotModel>> getBlockedSlots(String groundId, DateTime date);
  Future<void> blockSlot(BlockedSlotModel slot);
  Future<void> unblockSlot(String groundId, DateTime startTime);
}
