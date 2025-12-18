import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';
import 'package:futsal_app/features/futsal/domain/entities/time_range.dart';

class FutsalModel extends FutsalField {
  FutsalModel({
    required String id,
    required String name,
    String? groundType,
    required String description,
    required String address,
    required String city,
    GeoPoint? location,
    required double pricePerHour,
    double? discount,
    required String currency,
    Map<String, List<TimeRange>>? schedule,
    String? size,
    String? grassType,
    bool lightsAvailable = false,
    bool parkingAvailable = false,
    bool changingRoomAvailable = false,
    bool washroomAvailable = false,
    required String coverImageUrl,
    List<String> galleryImageUrls = const [],
    required String phoneNumber,
    String? whatsappNumber,
    String? email,
    required String ownerId,
    double rating = 0.0,
  }) : super(
          id: id,
          name: name,
          groundType: groundType,
          description: description,
          address: address,
          city: city,
          location: location,
          pricePerHour: pricePerHour,
          discount: discount,
          currency: currency,
          schedule: schedule,
          size: size,
          grassType: grassType,
          lightsAvailable: lightsAvailable,
          parkingAvailable: parkingAvailable,
          changingRoomAvailable: changingRoomAvailable,
          washroomAvailable: washroomAvailable,
          coverImageUrl: coverImageUrl,
          galleryImageUrls: galleryImageUrls,
          phoneNumber: phoneNumber,
          whatsappNumber: whatsappNumber,
          email: email,
          ownerId: ownerId,
          rating: rating,
        );

  factory FutsalModel.fromMap(Map<String, dynamic> map, String id) {
    return FutsalModel(
      id: id,
      name: map['name'] as String? ?? '',
      groundType: map['groundType'] as String?,
      description: map['description'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      location: map['location'] as GeoPoint?,
      pricePerHour: (map['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble(),
      currency: map['currency'] as String? ?? '',
       schedule: (map['schedule'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          (value as List)
              .map((e) => TimeRange.fromMap(e as Map<String, dynamic>))
              .toList(),
        ),
      ),
      size: map['size'] as String?,
      grassType: map['grassType'] as String?,
      lightsAvailable: map['lightsAvailable'] as bool? ?? false,
      parkingAvailable: map['parkingAvailable'] as bool? ?? false,
      changingRoomAvailable: map['changingRoomAvailable'] as bool? ?? false,
      washroomAvailable: map['washroomAvailable'] as bool? ?? false,
      coverImageUrl: map['coverImageUrl'] as String? ?? '',
      galleryImageUrls: map['galleryImageUrls'] is List
          ? List<String>.from(map['galleryImageUrls'])
          : [],
      phoneNumber: map['phoneNumber'] as String? ?? '',
      whatsappNumber: map['whatsappNumber'] as String?,
      email: map['email'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'groundType': groundType,
      'description': description,
      'address': address,
      'city': city,
      'location': location,
      'pricePerHour': pricePerHour,
      'discount': discount,
      'currency': currency,
      'schedule': schedule?.map((key, value) =>
          MapEntry(key, value.map((e) => e.toMap()).toList())),
      'size': size,
      'grassType': grassType,
      'lightsAvailable': lightsAvailable,
      'parkingAvailable': parkingAvailable,
      'changingRoomAvailable': changingRoomAvailable,
      'washroomAvailable': washroomAvailable,
      'coverImageUrl': coverImageUrl,
      'galleryImageUrls': galleryImageUrls,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'ownerId': ownerId,
      'rating': rating,
    };
  }

  static FutsalModel fromEntity(FutsalField entity) {
    return FutsalModel(
      id: entity.id,
      name: entity.name,
      groundType: entity.groundType,
      description: entity.description,
      address: entity.address,
      city: entity.city,
      location: entity.location,
      pricePerHour: entity.pricePerHour,
      discount: entity.discount,
      currency: entity.currency,
      schedule: entity.schedule,
      size: entity.size,
      grassType: entity.grassType,
      lightsAvailable: entity.lightsAvailable,
      parkingAvailable: entity.parkingAvailable,
      changingRoomAvailable: entity.changingRoomAvailable,
      washroomAvailable: entity.washroomAvailable,
      coverImageUrl: entity.coverImageUrl,
      galleryImageUrls: entity.galleryImageUrls,
      phoneNumber: entity.phoneNumber,
      whatsappNumber: entity.whatsappNumber,
      email: entity.email,
      ownerId: entity.ownerId,
      rating: entity.rating,
    );
  }
}
