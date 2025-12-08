import 'package:cloud_firestore/cloud_firestore.dart';

class FutsalField {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final double pricePerHour;
  final double rating;
  final List<String> features;
  final GeoPoint? location;
  final String ownerId;
  final List<String> searchKeywords;
  bool isFavorite;

  FutsalField({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.pricePerHour,
    required this.rating,
    required this.ownerId,
    this.features = const [],
    this.location,
    this.isFavorite = false,
    this.searchKeywords = const [],
  });

  FutsalField copyWith({
    String? id,
    String? name,
    String? address,
    String? imageUrl,
    double? pricePerHour,
    double? rating,
    List<String>? features,
    GeoPoint? location,
    String? ownerId,
    bool? isFavorite,
    List<String>? searchKeywords,
  }) {
    return FutsalField(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      rating: rating ?? this.rating,
      features: features ?? this.features,
      location: location ?? this.location,
      ownerId: ownerId ?? this.ownerId,
      isFavorite: isFavorite ?? this.isFavorite,
      searchKeywords: searchKeywords ?? this.searchKeywords,
    );
  }
}
