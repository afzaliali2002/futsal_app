import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String avatarUrl;
  final bool isOnline;

  // Audit fields
  final DateTime? createdAt;
  final String? createdBy;
  final DateTime? modifiedAt;
  final String? modifiedBy;

  // Soft delete fields
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? deletedBy;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.isOnline,
    this.createdAt,
    this.createdBy,
    this.modifiedAt,
    this.modifiedBy,
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
  });

  // Helper to check if user is active
  bool get isActive => !isDeleted;

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      isOnline: map['isOnline'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy'] as String?,
      modifiedAt: (map['modifiedAt'] as Timestamp?)?.toDate(),
      modifiedBy: map['modifiedBy'] as String?,
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: (map['deletedAt'] as Timestamp?)?.toDate(),
      deletedBy: map['deletedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'createdBy': createdBy,
      'modifiedAt': modifiedAt != null ? Timestamp.fromDate(modifiedAt!) : null,
      'modifiedBy': modifiedBy,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'deletedBy': deletedBy,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isOnline,
    DateTime? createdAt,
    String? createdBy,
    DateTime? modifiedAt,
    String? modifiedBy,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }
}
