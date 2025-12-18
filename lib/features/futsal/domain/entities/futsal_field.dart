import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/domain/entities/time_range.dart';

class FutsalField {
  final String id;
  final String name;
  final String? groundType;
  final String description;

  final String address;
  final String city;
  final GeoPoint? location; // For latitude and longitude

  final double pricePerHour;
  final double? discount;
  final String currency;

  final Map<String, List<TimeRange>>? schedule; // New schedule field

  final String? size;
  final String? grassType;
  final bool lightsAvailable;
  final bool parkingAvailable;
  final bool changingRoomAvailable;
  final bool washroomAvailable;

  final String coverImageUrl;
  final List<String> galleryImageUrls;

  final String phoneNumber;
  final String? whatsappNumber;
  final String? email;

  final String ownerId;
  final double rating;
  bool isFavorite;

  // New fields for permissions and status
  final bool autoAcceptBookings;
  final String? bankDetails;
  final String status; // 'pending', 'approved', 'suspended', 'rejected'
  final Map<String, dynamic>? pendingUpdates; // Stores changes waiting for approval

  FutsalField({
    required this.id,
    required this.name,
    this.groundType,
    required this.description,
    required this.address,
    required this.city,
    this.location,
    required this.pricePerHour,
    this.discount,
    required this.currency,
    this.schedule,
    this.size,
    this.grassType,
    this.lightsAvailable = false,
    this.parkingAvailable = false,
    this.changingRoomAvailable = false,
    this.washroomAvailable = false,
    required this.coverImageUrl,
    this.galleryImageUrls = const [],
    required this.phoneNumber,
    this.whatsappNumber,
    this.email,
    required this.ownerId,
    this.rating = 0.0,
    this.isFavorite = false,
    this.autoAcceptBookings = true,
    this.bankDetails,
    this.status = 'pending',
    this.pendingUpdates,
  });

  double get latitude => location?.latitude ?? 0.0;
  double get longitude => location?.longitude ?? 0.0;

  List<String> get features {
    final list = <String>[];
    if (lightsAvailable) list.add('Lights');
    if (parkingAvailable) list.add('Parking');
    if (changingRoomAvailable) list.add('Changing Room');
    if (washroomAvailable) list.add('Washroom');
    if (size != null) list.add('Size: $size');
    if (grassType != null) list.add('Grass: $grassType');
    return list;
  }

  FutsalField copyWith({
    String? id,
    String? name,
    String? groundType,
    String? description,
    String? address,
    String? city,
    GeoPoint? location,
    double? pricePerHour,
    double? discount,
    String? currency,
    Map<String, List<TimeRange>>? schedule,
    String? size,
    String? grassType,
    bool? lightsAvailable,
    bool? parkingAvailable,
    bool? changingRoomAvailable,
    bool? washroomAvailable,
    String? coverImageUrl,
    List<String>? galleryImageUrls,
    String? phoneNumber,
    String? whatsappNumber,
    String? email,
    String? ownerId,
    double? rating,
    bool? isFavorite,
    bool? autoAcceptBookings,
    String? bankDetails,
    String? status,
    Map<String, dynamic>? pendingUpdates,
    bool? clearPendingUpdates,
  }) {
    return FutsalField(
      id: id ?? this.id,
      name: name ?? this.name,
      groundType: groundType ?? this.groundType,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      location: location ?? this.location,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      discount: discount ?? this.discount,
      currency: currency ?? this.currency,
      schedule: schedule ?? this.schedule,
      size: size ?? this.size,
      grassType: grassType ?? this.grassType,
      lightsAvailable: lightsAvailable ?? this.lightsAvailable,
      parkingAvailable: parkingAvailable ?? this.parkingAvailable,
      changingRoomAvailable: changingRoomAvailable ?? this.changingRoomAvailable,
      washroomAvailable: washroomAvailable ?? this.washroomAvailable,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      galleryImageUrls: galleryImageUrls ?? this.galleryImageUrls,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      email: email ?? this.email,
      ownerId: ownerId ?? this.ownerId,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      autoAcceptBookings: autoAcceptBookings ?? this.autoAcceptBookings,
      bankDetails: bankDetails ?? this.bankDetails,
      status: status ?? this.status,
      pendingUpdates: clearPendingUpdates == true ? null : pendingUpdates ?? this.pendingUpdates,
    );
  }
}
