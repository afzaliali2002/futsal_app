import '../../data/models/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel> getCurrentUser();
}
