import '../../data/models/user_model.dart';
import '../repositories/profile_repository.dart';

class GetCurrentUserUseCase {
  final ProfileRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserModel> call() {
    return repository.getCurrentUser();
  }
}
