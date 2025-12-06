import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futsal_app/features/futsal/data/models/futsal_model.dart';
import '../../domain/entities/futsal_field.dart';
import '../../domain/repositories/futsal_repository.dart';

class FutsalRepositoryImpl implements FutsalRepository {
  final FirebaseFirestore firestore;

  FutsalRepositoryImpl({required this.firestore});

  @override
  Future<List<FutsalField>> getFutsalFields() async {
    try {
      final snapshot = await firestore.collection('futsals').get();
      return snapshot.docs
          .map((doc) => FutsalModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching futsal fields: $e");
      rethrow;
    }
  }

  @override
  Future<void> addFutsalField(FutsalField field) async {
    try {
      final model = FutsalModel.fromEntity(field);
      await firestore.collection('futsals').add(model.toMap());
    } catch (e) {
      print("Error adding futsal field: $e");
      rethrow;
    }
  }
}
