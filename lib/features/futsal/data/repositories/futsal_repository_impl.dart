import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:futsal_app/features/futsal/data/models/futsal_field_model.dart';
import '../../domain/entities/futsal_field.dart';
import '../../domain/repositories/futsal_repository.dart';

class FutsalRepositoryImpl implements FutsalRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  FutsalRepositoryImpl({required this.firestore, required this.storage});

  @override
  Future<List<FutsalField>> getFutsalFields() async {
    final snapshot = await firestore.collection('fields').get();
    return snapshot.docs
        .map((doc) => FutsalFieldModel.fromSnapshot(doc).toEntity())
        .toList();
  }

  @override
  Future<void> addFutsalField(FutsalField field, File? image) async {
    String imageUrl = '';
    if (image != null) {
      final ref = storage
          .ref()
          .child('futsal_images')
          .child('${DateTime.now().toIso8601String()}');
      await ref.putFile(image);
      imageUrl = await ref.getDownloadURL();
    }

    List<String> searchKeywords = [];
    for (int i = 0; i < field.name.length; i++) {
      searchKeywords.add(field.name.substring(0, i + 1).toLowerCase());
    }

    final fieldWithImage = field.copyWith(
      imageUrl: imageUrl,
    );

    final model = FutsalFieldModel.fromEntity(fieldWithImage);
    final map = model.toMap();
    map['searchKeywords'] = searchKeywords;

    await firestore.collection('fields').add(map);
  }

  @override
  Future<List<FutsalField>> searchFutsalFields(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final snapshot = await firestore
        .collection('fields')
        .where('searchKeywords', arrayContains: query.toLowerCase())
        .get();
        
    return snapshot.docs
        .map((doc) => FutsalFieldModel.fromSnapshot(doc).toEntity())
        .toList();
  }

  @override
  Future<void> deleteGround(String groundId) async {
    await firestore.collection('fields').doc(groundId).delete();
  }

  @override
  Future<void> updateGround(FutsalField ground) async {
    final model = FutsalFieldModel.fromEntity(ground);
    await firestore.collection('fields').doc(ground.id).update(model.toMap());
  }

  @override
  Future<void> addToFavorites(String groundId, String userId) async {
    await firestore.collection('users').doc(userId).collection('favorites').doc(groundId).set({});
  }

  @override
  Future<void> removeFromFavorites(String groundId, String userId) async {
    await firestore.collection('users').doc(userId).collection('favorites').doc(groundId).delete();
  }

  @override
  Future<List<String>> getFavoriteGrounds(String userId) async {
    final snapshot = await firestore.collection('users').doc(userId).collection('favorites').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }
}
