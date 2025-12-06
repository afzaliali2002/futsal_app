import '../entities/futsal_field.dart';
import '../repositories/futsal_repository.dart';

class AddFutsalFieldUseCase {
  final FutsalRepository repository;

  AddFutsalFieldUseCase(this.repository);

  Future<void> call(FutsalField futsal) {
    return repository.addFutsalField(futsal);
  }
}
