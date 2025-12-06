import '../../data/models/booking_model.dart';
abstract class BookingRepository {
  Future<List<BookingModel>> getMyBookings(String userId);
}
