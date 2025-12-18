import 'dart:async';
import 'dart:io';
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
  }) {
    _listenToFutsalFields();
  }

  List<FutsalField> _fields = [];
  List<FutsalField> get fields => _fields;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  StreamSubscription<List<FutsalField>>? _futsalSubscription;

  void _listenToFutsalFields() {
    _futsalSubscription = getFutsalFieldsUseCase().listen(
      (fieldsData) {
        _fields = fieldsData;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addFutsalField({
    required FutsalField field,
    File? coverImage,
    List<File>? galleryImages,
  }) async {
    try {
      await addFutsalFieldUseCase(field, coverImage, galleryImages ?? []);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _futsalSubscription?.cancel();
    super.dispose();
  }
}
