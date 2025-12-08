import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';

class FutsalModel extends FutsalField {
  FutsalModel({
    required String id,
    required String name,
    required String address,
    required String imageUrl,
    required double pricePerHour,
    required double rating,
    required List<String> features,
    required String ownerId,
    GeoPoint? location,
  }) : super(
          id: id,
          name: name,
          address: address,
          imageUrl: imageUrl,
          pricePerHour: pricePerHour,
          rating: rating,
          features: features,
          ownerId: ownerId,
          location: location,
        );

  factory FutsalModel.fromMap(Map<String, dynamic> map, String id) {
    double safeParseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return FutsalModel(
      id: id,
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      pricePerHour: safeParseDouble(map['pricePerHour']),
      rating: safeParseDouble(map['rating']),
      features: map['features'] is List
          ? List<String>.from(map['features'])
          : [],
      ownerId: map['ownerId'] as String? ?? '',
      location: map['location'] as GeoPoint?,
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
      'ownerId': ownerId,
      'location': location,
    };
  }

  static FutsalModel fromEntity(FutsalField entity) {
    return FutsalModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      imageUrl: entity.imageUrl,
      pricePerHour: entity.pricePerHour,
      rating: entity.rating,
      features: entity.features,
      ownerId: entity.ownerId,
      location: entity.location,
    );
  }
}
