import 'package:futsal_app/features/booking/data/models/blocked_slot_model.dart';
import 'package:futsal_app/features/booking/data/models/booking_model.dart';
import 'package:futsal_app/features/booking/domain/entities/booking_status.dart';

abstract class BookingRepository {
  Stream<List<BookingModel>> getBookingsForDate(String groundId, DateTime date);
  Stream<List<BookingModel>> getMyBookings(String userId);
  Stream<BookingModel> getBookingById(String groundId, String bookingId);
  Future<String> createBooking(BookingModel booking);
  Future<void> cancelBooking(String groundId, String bookingId);
  Future<void> updateBookingStatus(String groundId, String bookingId, BookingStatus status);
  Stream<List<BlockedSlotModel>> getBlockedSlotsForDate(String groundId, DateTime date);
  Future<void> blockSlot(BlockedSlotModel slot);
  Future<void> unblockSlot(String groundId, String slotId);
  Future<String?> findBlockedSlotId(String groundId, DateTime startTime);
}
