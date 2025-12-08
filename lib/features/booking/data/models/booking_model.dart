import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { upcoming, completed, canceled }

class BookingModel {
  final String id;
  final String userId;
  final String futsalId;
  final String futsalName;
  final DateTime? date; // Made nullable
  final String timeSlot;
  final double price;
  final BookingStatus status;
  final DateTime? createdAt; // Made nullable

  BookingModel({
    required this.id,
    required this.userId,
    required this.futsalId,
    required this.futsalName,
    this.date, // Made nullable
    required this.timeSlot,
    required this.price,
    this.status = BookingStatus.upcoming,
    this.createdAt, // Made nullable
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      userId: map['userId'] ?? '',
      futsalId: map['futsalId'] ?? '',
      futsalName: map['futsalName'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate(), // Safely parse nullable Timestamp
      timeSlot: map['timeSlot'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0, // Made safer
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${map['status']}',
        orElse: () => BookingStatus.upcoming,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(), // Safely parse nullable Timestamp
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'futsalId': futsalId,
      'futsalName': futsalName,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'timeSlot': timeSlot,
      'price': price,
      'status': status.toString().split('.').last,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
