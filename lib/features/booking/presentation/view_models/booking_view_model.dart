import 'package:flutter/material.dart';
import 'package:futsal_app/features/booking/data/models/blocked_slot_model.dart';
import 'package:futsal_app/features/booking/data/models/booking_model.dart';
import 'package:futsal_app/features/booking/domain/entities/booking_status.dart';
import 'package:futsal_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:futsal_app/features/notification/data/models/notification_model.dart';
import 'package:futsal_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:intl/intl.dart';

// Helper function to convert English numerals and AM/PM to Persian
String _toPersian(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  String result = input;
  for (int i = 0; i < english.length; i++) {
    result = result.replaceAll(english[i], farsi[i]);
  }
  result = result.replaceAll('AM', 'ق.ظ').replaceAll('PM', 'ب.ظ');
  return result;
}

String _formatDateTimeToPersian12Hour(DateTime dt) {
  final format = DateFormat('h:mm a', 'en_US');
  final formattedString = format.format(dt);
  return _toPersian(formattedString);
}

class BookingViewModel extends ChangeNotifier {
  final BookingRepository _bookingRepository;
  final NotificationRepository _notificationRepository;

  BookingViewModel(this._bookingRepository, this._notificationRepository);

  Stream<List<BookingModel>> getBookings(String groundId, DateTime date) {
    return _bookingRepository.getBookingsForDate(groundId, date);
  }
  
  Stream<BookingModel> getBookingById(String groundId, String bookingId) {
    return _bookingRepository.getBookingById(groundId, bookingId);
  }

  Future<void> createBooking(BookingModel booking, String groundOwnerId) async {
    try {
      final bookingId = await _bookingRepository.createBooking(booking);

      final formattedTime = _formatDateTimeToPersian12Hour(booking.startTime);
      final notification = NotificationModel(
        id: '', 
        userId: groundOwnerId, 
        title: 'درخواست رزرو جدید',
        body:
            '${booking.bookerName} برای ساعت $formattedTime درخواست رزرو ثبت کرده است.',
        type: NotificationType.bookingRequest,
        metadata: {'bookingId': bookingId, 'groundId': booking.groundId},
        createdAt: DateTime.now(),
      );
      await _notificationRepository.createNotification(notification);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> approveBooking(String groundId, String bookingId, String userId, String futsalName, DateTime startTime) async {
    try {
      await _bookingRepository.updateBookingStatus(
          groundId, bookingId, BookingStatus.confirmed);

      final notification = NotificationModel(
        id: '', 
        userId: userId,
        title: 'رزرو شما تایید شد',
        body: 'رزرو شما برای زمین $futsalName در ساعت ${_formatDateTimeToPersian12Hour(startTime)} تایید شد.',
        type: NotificationType.bookingConfirmation,
        metadata: {'bookingId': bookingId, 'groundId': groundId},
        createdAt: DateTime.now(),
      );
      await _notificationRepository.createNotification(notification);

      notifyListeners();
    } catch (e) {
      // Optionally handle error
    }
  }

  Future<void> rejectBooking(String groundId, String bookingId, String userId, String futsalName, DateTime startTime) async {
    try {
      await _bookingRepository.updateBookingStatus(
          groundId, bookingId, BookingStatus.cancelled);

      final notification = NotificationModel(
        id: '', 
        userId: userId,
        title: 'رزرو شما رد شد',
        body: 'متاسفانه رزرو شما برای زمین $futsalName در ساعت ${_formatDateTimeToPersian12Hour(startTime)} رد شد.',
        type: NotificationType.bookingCancellation,
        metadata: {'bookingId': bookingId, 'groundId': groundId},
        createdAt: DateTime.now(),
      );
      await _notificationRepository.createNotification(notification);
      
      notifyListeners();
    } catch (e) {
      // Optionally handle error
    }
  }

  Future<void> cancelBooking(String groundId, String bookingId) async {
    try {
      await _bookingRepository.cancelBooking(groundId, bookingId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<BlockedSlotModel>> getBlockedSlots(
      String groundId, DateTime date) {
    return _bookingRepository.getBlockedSlotsForDate(groundId, date);
  }

  Future<void> blockSlot(BlockedSlotModel slot) async {
    try {
      await _bookingRepository.blockSlot(slot);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unblockSlot(String groundId, DateTime startTime) async {
    try {
      final slotId =
          await _bookingRepository.findBlockedSlotId(groundId, startTime);
      if (slotId != null) {
        await _bookingRepository.unblockSlot(groundId, slotId);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
