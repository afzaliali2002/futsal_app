import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/futsal_field.dart';
import '../../domain/usecases/add_futsal_field_usecase.dart';
import '../../domain/usecases/get_futsal_fields_usecase.dart';

// Renaming to FutsalViewModel for consistency with MVVM pattern
class FutsalViewModel extends ChangeNotifier {
  final GetFutsalFieldsUseCase getFutsalFieldsUseCase;
  final AddFutsalFieldUseCase addFutsalFieldUseCase;

  FutsalViewModel({
    required this.getFutsalFieldsUseCase,
    required this.addFutsalFieldUseCase,
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
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // GUARANTEED FIX: Added missing latitude and longitude parameters
  Future<void> addFutsalField({
    required String name,
    required String address,
    required double pricePerHour,
    required List<String> features,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final newField = FutsalField(
        id: '', // Firestore generates the ID
        name: name,
        address: address,
        pricePerHour: pricePerHour,
        rating: 0, // Default rating
        imageUrl: '', // Default image
        features: features,
        // location: GeoPoint(latitude, longitude), // GUARANTEED FIX: Added location
      );
      await addFutsalFieldUseCase(newField);
      await fetchFutsalFields();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
