import 'package:flutter/material.dart';
import '../../domain/entities/futsal_field.dart';
import '../../domain/usecases/add_futsal_field_usecase.dart';
import '../../domain/usecases/get_futsal_fields_usecase.dart';

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

  Future<void> addFutsalField({
    required String name,
    required String address,
    required double pricePerHour,
    required List<String> features,
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
      );
      await addFutsalFieldUseCase(newField);
      // Refresh the list to show the new field
      await fetchFutsalFields();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow; // Re-throw to be caught by the UI
    }
  }
}
