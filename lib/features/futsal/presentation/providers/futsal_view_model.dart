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
  });

  List<FutsalField> _fields = [];
  List<FutsalField> get fields => _fields;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchFutsalFields() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _fields = await getFutsalFieldsUseCase();
      await _loadFavoriteStatus();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFutsalField({
    required String name,
    required String address,
    required double pricePerHour,
    required List<String> features,
    required File? imageFile,
    required String ownerId,
  }) async {
    try {
      final newField = FutsalField(
        id: '', 
        name: name,
        address: address,
        pricePerHour: pricePerHour,
        rating: 0,
        imageUrl: '', 
        features: features,
        ownerId: ownerId,
      );
      await addFutsalFieldUseCase(newField, imageFile);
      await fetchFutsalFields();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleFavorite(FutsalField field) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    field.isFavorite = !field.isFavorite;

    try {
      if (field.isFavorite) {
        await futsalRepository.addToFavorites(field.id, userId);
      } else {
        await futsalRepository.removeFromFavorites(field.id, userId);
      }
    } catch (e) {
      _error = e.toString();
      field.isFavorite = !field.isFavorite; // Revert on error
    }
    notifyListeners();
  }

  Future<void> deleteGround(String groundId) async {
    try {
      await futsalRepository.deleteGround(groundId);
      await fetchFutsalFields();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateGround(FutsalField ground) async {
    try {
      await futsalRepository.updateGround(ground);
      await fetchFutsalFields();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final favoriteIds = await futsalRepository.getFavoriteGrounds(userId);
      for (var field in _fields) {
        if (favoriteIds.contains(field.id)) {
          field.isFavorite = true;
        }
      }
    } catch (e) {
      _error = e.toString();
    }
  }
}
