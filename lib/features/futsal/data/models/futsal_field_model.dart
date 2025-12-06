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
    // required GeoPoint location, // This was missing
  }) : super(
          id: id,
          name: name,
          address: address,
          imageUrl: imageUrl,
          pricePerHour: pricePerHour,
          rating: rating,
          features: features,
          // location: location, // This was missing
        );

  // This factory now correctly handles a missing or null location from Firestore.
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
      // location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
    );
  }
}
