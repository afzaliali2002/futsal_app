import 'dart:io';
import '../entities/futsal_field.dart';
import '../repositories/futsal_repository.dart';

class AddFutsalFieldUseCase {
  final FutsalRepository repository;

  AddFutsalFieldUseCase(this.repository);

  // GUARANTEED FIX: Added the image file as an optional parameter
  Future<void> call(FutsalField field, [File? image]) async {
    return await repository.addFutsalField(field, image);
  }
}
