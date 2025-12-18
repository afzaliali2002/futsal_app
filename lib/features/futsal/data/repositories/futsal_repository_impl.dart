import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futsal_app/features/booking/data/models/blocked_slot_model.dart';
import 'package:futsal_app/features/booking/data/models/booking_model.dart';
import 'package:futsal_app/features/futsal/data/models/futsal_field_model.dart';
import '../../domain/entities/futsal_field.dart';
import '../../domain/repositories/futsal_repository.dart';

class FutsalRepositoryImpl implements FutsalRepository {
  final FirebaseFirestore firestore;
  final CloudinaryPublic cloudinary;

  FutsalRepositoryImpl({
    required this.firestore,
    required this.cloudinary,
  });

  @override
  Stream<List<FutsalField>> getFutsalFields() {
    return firestore.collection('fields').snapshots().map(
          (snapshot) =>
          snapshot.docs.map((d) => FutsalFieldModel.fromSnapshot(d).toEntity()).toList(),
    );
  }

  @override
  Future<void> addFutsalField(
      FutsalField field,
      File? coverImage,
      List<File> galleryImages,
      ) async {
    final docRef = firestore.collection('fields').doc();

    String coverImageUrl = '';
    List<String> galleryImageUrls = [];

    if (coverImage != null) {
      final res = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          coverImage.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'futsal_images/${docRef.id}',
        ),
      );
      coverImageUrl = res.secureUrl;
    }

    for (final image in galleryImages) {
      final res = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'futsal_images/${docRef.id}',
        ),
      );
      galleryImageUrls.add(res.secureUrl);
    }

    final searchKeywords = <String>[];
    for (int i = 1; i <= field.name.length; i++) {
      searchKeywords.add(field.name.substring(0, i).toLowerCase());
    }

    final fieldWithImages = field.copyWith(
      id: docRef.id,
      coverImageUrl: coverImageUrl,
      galleryImageUrls: galleryImageUrls,
      rating: 0.0,
    );

    final model = FutsalFieldModel.fromEntity(fieldWithImages);
    final map = model.toMap()..addAll({
      'searchKeywords': searchKeywords,
      'ratingCount': 0,
    });

    await docRef.set(map);
  }

  @override
  Future<void> updateGround(FutsalField ground, {File? coverImage}) async {
    var updated = ground;

    if (coverImage != null) {
      final res = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          coverImage.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'futsal_images/${ground.id}',
        ),
      );
      updated = ground.copyWith(coverImageUrl: res.secureUrl);
    }

    final model = FutsalFieldModel.fromEntity(updated);
    await firestore
        .collection('fields')
        .doc(ground.id)
        .set(model.toMap(), SetOptions(merge: true));
  }

  @override
  Future<List<FutsalField>> searchFutsalFields(String query) async {
    final snapshot = await firestore
        .collection('fields')
        .where('searchKeywords', arrayContains: query.toLowerCase())
        .get();

    return snapshot.docs
        .map((d) => FutsalFieldModel.fromSnapshot(d).toEntity())
        .toList();
  }

  @override
  Future<void> deleteGround(String groundId) async {
    await firestore.collection('fields').doc(groundId).delete();
  }

  @override
  Future<void> addToFavorites(String groundId, String userId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(groundId)
        .set({});
  }

  @override
  Future<void> removeFromFavorites(String groundId, String userId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(groundId)
        .delete();
  }

  @override
  Future<List<String>> getFavoriteGrounds(String userId) async {
    final snap = await firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    return snap.docs.map((d) => d.id).toList();
  }

  @override
  Future<void> rateGround({
    required String groundId,
    required String userId,
    required double rating,
  }) async {
    final fieldRef = firestore.collection('fields').doc(groundId);
    final ratingRef = fieldRef.collection('ratings').doc(userId);

    await firestore.runTransaction((tx) async {
      final fieldSnap = await tx.get(fieldRef);
      final ratingSnap = await tx.get(ratingRef);

      final data = fieldSnap.data();
      if (data == null) throw Exception("Field data not found!");

      final currentRating = (data['rating'] is int) 
          ? (data['rating'] as int).toDouble() 
          : (data['rating'] ?? 0.0) as double;
          
      final ratingCount = (data['ratingCount'] ?? 0) as int;

      double newRating;
      int newCount = ratingCount;

      if (ratingSnap.exists) {
        final ratingData = ratingSnap.data();
        if (ratingData == null) throw Exception("Rating data not found!");
        
        final old = (ratingData['value'] is int) 
            ? (ratingData['value'] as int).toDouble() 
            : (ratingData['value'] as double);

        if (ratingCount > 0) {
           newRating = ((currentRating * ratingCount) - old + rating) / ratingCount;
        } else {
           newRating = rating;
           newCount = 1; 
        }
      } else {
        newCount++;
        newRating = ((currentRating * ratingCount) + rating) / newCount;
      }

      tx.set(ratingRef, {'value': rating});
      tx.update(fieldRef, {
        'rating': newRating,
        'ratingCount': newCount,
      });
    });
  }

  @override
  Future<double?> getUserRating(String groundId, String userId) async {
    final doc = await firestore
        .collection('fields')
        .doc(groundId)
        .collection('ratings')
        .doc(userId)
        .get();
    
    if (doc.exists) {
      final data = doc.data();
      if (data == null) return null;
      
      final val = data['value'];
      if (val is int) return val.toDouble();
      return val as double?;
    }
    return null;
  }

  @override
  Stream<List<BookingModel>> getBookings(String groundId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return firestore
        .collection('bookings')
        .where('groundId', isEqualTo: groundId)
        .where('startTime', isGreaterThanOrEqualTo: start)
        .where('startTime', isLessThan: end)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => BookingModel.fromSnapshot(d)).toList());
  }

  @override
  Future<void> createBooking(BookingModel booking) async {
    await firestore.collection('bookings').add(booking.toMap());
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await firestore.collection('bookings').doc(bookingId).delete();
  }

  @override
  Stream<List<BlockedSlotModel>> getBlockedSlots(String groundId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return firestore
        .collection('fields')
        .doc(groundId)
        .collection('blockedSlots')
        .where('startTime', isGreaterThanOrEqualTo: start)
        .where('startTime', isLessThan: end)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => BlockedSlotModel.fromSnapshot(d)).toList());
  }

  @override
  Future<void> blockSlot(BlockedSlotModel slot) async {
    await firestore.collection('fields').doc(slot.groundId).collection('blockedSlots').add(slot.toMap());
  }

  @override
  Future<void> unblockSlot(String groundId, DateTime startTime) async {
    final snapshot = await firestore
        .collection('fields')
        .doc(groundId)
        .collection('blockedSlots')
        .where('startTime', isEqualTo: startTime)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
