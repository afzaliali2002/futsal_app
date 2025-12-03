import '../entities/futsal_field.dart';
import '../repositories/futsal_repository.dart';

class GetFutsalFieldsUseCase {
  final FutsalRepository repository;

  GetFutsalFieldsUseCase(this.repository);

  Future<List<FutsalField>> call() async {
    return await repository.getFutsalFields();
  }
}
