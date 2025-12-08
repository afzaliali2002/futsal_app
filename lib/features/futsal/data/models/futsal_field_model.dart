import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/futsal_field.dart';

class FutsalFieldModel extends FutsalField {
  FutsalFieldModel({
    required String id,
    required String name,
    required String address,
    required String imageUrl,
    required double pricePerHour,
    required double rating,
    required List<String> features,
    required GeoPoint? location,
    required String ownerId,
    bool isFavorite = false,
    List<String> searchKeywords = const [],
  }) : super(
          id: id,
          name: name,
          address: address,
          imageUrl: imageUrl,
          pricePerHour: pricePerHour,
          rating: rating,
          features: features,
          location: location,
          ownerId: ownerId,
          isFavorite: isFavorite,
          searchKeywords: searchKeywords,
        );

  factory FutsalFieldModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return FutsalFieldModel(
      id: snapshot.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      pricePerHour: (data['pricePerHour'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      features: List<String>.from(data['features'] ?? []),
      location: data['location'] as GeoPoint?,
      ownerId: data['ownerId'] ?? '',
      isFavorite: data['isFavorite'] ?? false,
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
    );
  }

  factory FutsalFieldModel.fromEntity(FutsalField entity) {
    return FutsalFieldModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      imageUrl: entity.imageUrl,
      pricePerHour: entity.pricePerHour,
      rating: entity.rating,
      features: entity.features,
      location: entity.location,
      ownerId: entity.ownerId,
      isFavorite: entity.isFavorite,
      searchKeywords: entity.searchKeywords,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'pricePerHour': pricePerHour,
      'rating': rating,
      'features': features,
      'location': location,
      'ownerId': ownerId,
      'isFavorite': isFavorite,
      'searchKeywords': searchKeywords,
    };
  }

  FutsalField toEntity() {
    return FutsalField(
      id: id,
      name: name,
      address: address,
      imageUrl: imageUrl,
      pricePerHour: pricePerHour,
      rating: rating,
      features: features,
      location: location,
      ownerId: ownerId,
      isFavorite: isFavorite,
      searchKeywords: searchKeywords,
    );
  }
}
