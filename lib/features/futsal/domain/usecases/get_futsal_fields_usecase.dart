import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';

import '../../data/models/futsal_model.dart';
import '../repositories/futsal_repository.dart';
class GetFutsalFieldsUseCase {
  final FutsalRepository repository;

  GetFutsalFieldsUseCase(this.repository);

  Future<List<FutsalField>> call() {
    return repository.getFutsalFields();
  }
}
