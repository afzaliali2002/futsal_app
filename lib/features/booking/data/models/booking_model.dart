import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futsal_app/features/booking/domain/entities/booking_status.dart';

class BookingModel {
  final String id;
  final String groundId;
  final String userId;
  final String futsalName;
  final DateTime startTime;
  final DateTime endTime;
  final double price;
  final BookingStatus status;
  final String bookerName;
  final String bookerPhone;

  BookingModel({
    required this.id,
    required this.groundId,
    required this.userId,
    required this.futsalName,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
    required this.bookerName,
    required this.bookerPhone,
  });

  factory BookingModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      groundId: data['groundId'] ?? '',
      userId: data['userId'] ?? '',
      futsalName: data['futsalName'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      price: (data['price'] as num).toDouble(),
      status: BookingStatus.values.firstWhere((e) => e.toString() == 'BookingStatus.${data['status']}', orElse: () => BookingStatus.upcoming),
      bookerName: data['bookerName'] ?? '',
      bookerPhone: data['bookerPhone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groundId': groundId,
      'userId': userId,
      'futsalName': futsalName,
      'startTime': startTime,
      'endTime': endTime,
      'price': price,
      'status': status.toString().split('.').last,
      'bookerName': bookerName,
      'bookerPhone': bookerPhone,
    };
  }
}
