import 'dart:io';
import '../entities/futsal_field.dart';
import '../repositories/futsal_repository.dart';

class AddFutsalFieldUseCase {
  final FutsalRepository repository;

  AddFutsalFieldUseCase(this.repository);

  Future<void> call(FutsalField field, File? coverImage, List<File> galleryImages) async {
    return repository.addFutsalField(field, coverImage, galleryImages);
  }
}