import '../entities/futsal_field.dart';
import '../repositories/futsal_repository.dart';

class SearchFutsalFieldsUseCase {
  final FutsalRepository repository;

  SearchFutsalFieldsUseCase(this.repository);

  Future<List<FutsalField>> call(String query) {
    return repository.searchFutsalFields(query);
  }
}
