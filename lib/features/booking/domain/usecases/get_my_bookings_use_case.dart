import '../../data/models/booking_model.dart';
import '../repositories/booking_repository.dart';
class GetMyBookingsUseCase {
  final BookingRepository repository;

  GetMyBookingsUseCase(this.repository);

  Stream<List<BookingModel>> call(String userId) {
    return repository.getMyBookings(userId);
  }
}
