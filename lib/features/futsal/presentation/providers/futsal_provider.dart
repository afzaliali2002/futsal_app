import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // GUARANTEED FIX: Made lat/long/image nullable to match your request
  Future<void> addFutsalField({
    required String name,
    required String address,
    required double pricePerHour,
    required List<String> features,
    required String ownerId,
    double? latitude,
    double? longitude,
    File? image,
  }) async {
    GeoPoint? location;
    if (latitude != null && longitude != null) {
      location = GeoPoint(latitude, longitude);
    }

    final newField = FutsalField(
      id: '',
      name: name,
      address: address,
      pricePerHour: pricePerHour,
      rating: 0,
      imageUrl: '',
      features: features,
      location: location,
      ownerId: ownerId,
    );

    await addFutsalFieldUseCase(newField, image);
    await fetchFutsalFields();
  }
}
