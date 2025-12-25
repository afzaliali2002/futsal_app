import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/futsal/domain/repositories/futsal_repository.dart';
import 'package:futsal_app/features/futsal/domain/usecases/add_futsal_field_usecase.dart';
import 'package:futsal_app/features/futsal/domain/usecases/get_futsal_fields_usecase.dart';

class FutsalViewModel extends ChangeNotifier {
  final GetFutsalFieldsUseCase getFutsalFieldsUseCase;
  final AddFutsalFieldUseCase addFutsalFieldUseCase;
  final FutsalRepository futsalRepository;

  FutsalViewModel({
    required this.getFutsalFieldsUseCase,
    required this.addFutsalFieldUseCase,
    required this.futsalRepository,
  }) {
    listenToFutsalFields();
  }

  List<FutsalField> _fields = [];
  List<FutsalField> get fields => _fields;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  StreamSubscription? _subscription;

  void listenToFutsalFields() {
    _subscription = getFutsalFieldsUseCase().listen((fields) async {
      // Sort fields by rating in descending order (highest to lowest)
      fields.sort((a, b) => b.rating.compareTo(a.rating));
      
      _fields = fields;
      await _loadFavoriteStatus();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addFutsalField({
    required FutsalField field,
    File? coverImage,
    List<File>? galleryImages,
  }) async {
    await addFutsalFieldUseCase(field, coverImage, galleryImages ?? []);
  }

  Future<void> toggleFavorite(FutsalField field) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    field.isFavorite = !field.isFavorite;
    notifyListeners();

    if (field.isFavorite) {
      await futsalRepository.addToFavorites(field.id, uid);
    } else {
      await futsalRepository.removeFromFavorites(field.id, uid);
    }
  }

  // ⭐ NEW
  Future<void> rateGround(String groundId, double rating) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await futsalRepository.rateGround(
      groundId: groundId,
      userId: uid,
      rating: rating,
    );
  }

  Future<double?> getUserRating(String groundId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    return await futsalRepository.getUserRating(groundId, uid);
  }

  Future<void> deleteGround(String groundId) async {
    await futsalRepository.deleteGround(groundId);
  }

  Future<void> updateGround(FutsalField ground, {File? coverImage}) async {
    await futsalRepository.updateGround(ground, coverImage: coverImage);
  }

  Future<void> _loadFavoriteStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      for (final f in _fields) {
        f.isFavorite = false;
      }
      return;
    }

    final favs = await futsalRepository.getFavoriteGrounds(uid);
    for (final f in _fields) {
      f.isFavorite = favs.contains(f.id);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
