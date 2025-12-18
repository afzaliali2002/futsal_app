import 'package:flutter/material.dart';

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;
  final double? price; // Custom price for this time slot

  TimeRange({
    required this.start,
    required this.end,
    this.price,
  });

  // From map for Firestore
  factory TimeRange.fromMap(Map<String, dynamic> map) {
    return TimeRange(
      start: TimeOfDay(hour: map['start_hour'], minute: map['start_minute']),
      end: TimeOfDay(hour: map['end_hour'], minute: map['end_minute']),
      price: map['price']?.toDouble(),
    );
  }

  // To map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'start_hour': start.hour,
      'start_minute': start.minute,
      'end_hour': end.hour,
      'end_minute': end.minute,
      'price': price,
    };
  }
}
