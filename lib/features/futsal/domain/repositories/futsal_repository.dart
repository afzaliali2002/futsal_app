import 'dart:io';
import '../entities/futsal_field.dart';

abstract class FutsalRepository {
  Future<List<FutsalField>> getFutsalFields();
  Future<void> addFutsalField(FutsalField futsal, File? imageFile);
  Future<List<FutsalField>> searchFutsalFields(String query);
  Future<void> deleteGround(String groundId);
  Future<void> updateGround(FutsalField ground);
  Future<void> addToFavorites(String groundId, String userId);
  Future<void> removeFromFavorites(String groundId, String userId);
  Future<List<String>> getFavoriteGrounds(String userId);
}
