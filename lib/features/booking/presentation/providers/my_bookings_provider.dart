import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/get_my_bookings_use_case.dart';
import '../../data/models/booking_model.dart';

class MyBookingsProvider extends ChangeNotifier {
  final GetMyBookingsUseCase getMyBookingsUseCase;
  StreamSubscription? _bookingsSubscription;

  MyBookingsProvider(this.getMyBookingsUseCase);

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void listenToMyBookings(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _bookingsSubscription?.cancel();
    _bookingsSubscription = getMyBookingsUseCase(userId).listen((bookingsData) {
      _bookings = bookingsData;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    super.dispose();
  }
}
