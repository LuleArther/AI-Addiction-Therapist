import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String addictionType;
  final DateTime recoveryStartDate;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCheckIn;
  final List<String> achievements;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    required this.addictionType,
    required this.recoveryStartDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCheckIn,
    this.achievements = const [],
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      addictionType: json['addictionType'] as String,
      recoveryStartDate: (json['recoveryStartDate'] as Timestamp).toDate(),
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastCheckIn: json['lastCheckIn'] != null
          ? (json['lastCheckIn'] as Timestamp).toDate()
          : null,
      achievements: List<String>.from(json['achievements'] ?? []),
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'addictionType': addictionType,
      'recoveryStartDate': Timestamp.fromDate(recoveryStartDate),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCheckIn': lastCheckIn != null ? Timestamp.fromDate(lastCheckIn!) : null,
      'achievements': achievements,
      'preferences': preferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? addictionType,
    DateTime? recoveryStartDate,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCheckIn,
    List<String>? achievements,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      addictionType: addictionType ?? this.addictionType,
      recoveryStartDate: recoveryStartDate ?? this.recoveryStartDate,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      achievements: achievements ?? this.achievements,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
