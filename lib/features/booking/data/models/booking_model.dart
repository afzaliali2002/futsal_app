import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { upcoming, completed, canceled }

class BookingModel {
  final String id;
  final String userId;
  final String futsalId;
  final String futsalName;
  final DateTime date;
  final String timeSlot;
  final double price;
  final BookingStatus status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.futsalId,
    required this.futsalName,
    required this.date,
    required this.timeSlot,
    required this.price,
    this.status = BookingStatus.upcoming,
    required this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      userId: map['userId'] ?? '',
      futsalId: map['futsalId'] ?? '',
      futsalName: map['futsalName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      timeSlot: map['timeSlot'] ?? '',
      price: (map['price'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${map['status']}',
        orElse: () => BookingStatus.upcoming,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'futsalId': futsalId,
      'futsalName': futsalName,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'price': price,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
