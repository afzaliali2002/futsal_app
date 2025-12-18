
import 'package:cloud_firestore/cloud_firestore.dart';

class BlockedSlotModel {
  final String id;
  final String groundId;
  final DateTime startTime;
  final DateTime endTime;

  BlockedSlotModel({
    required this.id,
    required this.groundId,
    required this.startTime,
    required this.endTime,
  });

  factory BlockedSlotModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlockedSlotModel(
      id: doc.id,
      groundId: data['groundId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groundId': groundId,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
