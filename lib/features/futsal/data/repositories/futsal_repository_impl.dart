import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/futsal_field.dart';
import '../../domain/repositories/futsal_repository.dart';
import '../models/futsal_field_model.dart';

class FutsalRepositoryImpl implements FutsalRepository {
  final FirebaseFirestore firestore;

  FutsalRepositoryImpl({required this.firestore});

  @override
  Future<List<FutsalField>> getFutsalFields() async {
    try {
      final snapshot = await firestore.collection('fields').get();
      return snapshot.docs
          .map((doc) => FutsalFieldModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      // In a real app, you would handle this error more gracefully
      print("Error fetching futsal fields: $e");
      rethrow;
    }
  }

  @override
  Future<void> addFutsalField(FutsalField field) async {
    try {
      await firestore.collection('fields').add({
        'name': field.name,
        'address': field.address,
        'pricePerHour': field.pricePerHour,
        'rating': field.rating,
        'imageUrl': field.imageUrl,
        'features': field.features,
      });
    } catch (e) {
      print("Error adding futsal field: $e");
      rethrow;
    }
  }
}
