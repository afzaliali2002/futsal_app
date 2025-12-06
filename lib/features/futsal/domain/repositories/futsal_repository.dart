import '../entities/futsal_field.dart';

abstract class FutsalRepository {
  Future<List<FutsalField>> getFutsalFields();
  Future<void> addFutsalField(FutsalField futsal);
}
