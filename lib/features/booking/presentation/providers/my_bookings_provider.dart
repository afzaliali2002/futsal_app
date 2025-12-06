import 'package:flutter/material.dart';
import '../../../profile/data/models/user_model.dart';
import '../../domain/usecases/get_my_bookings_use_case.dart';
import '../../data/models/booking_model.dart';

class MyBookingsProvider extends ChangeNotifier {
  final GetMyBookingsUseCase getMyBookingsUseCase;

  MyBookingsProvider(this.getMyBookingsUseCase);

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchBookings(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await getMyBookingsUseCase(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
