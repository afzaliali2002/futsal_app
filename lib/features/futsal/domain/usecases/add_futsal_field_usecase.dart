import '../entities/futsal_field.dart';
import '../repositories/futsal_repository.dart';

class AddFutsalFieldUseCase {
  final FutsalRepository repository;

  AddFutsalFieldUseCase(this.repository);

  Future<void> call(FutsalField field) async {
    return await repository.addFutsalField(field);
  }
}
