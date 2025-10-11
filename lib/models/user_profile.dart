import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? username;
  final String? gender;
  final String? profileImageUrl;
  final Timestamp createdAt;
  final Timestamp? lastLoginAt;
  final bool isEmailVerified;
  final Map<String, dynamic>? preferences;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.username,
    this.gender,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.preferences,
  });

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? username,
    String? gender,
    String? profileImageUrl,
    Timestamp? createdAt,
    Timestamp? lastLoginAt,
    bool? isEmailVerified,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      preferences: preferences ?? this.preferences,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      name: json['name'] ?? json['displayName'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      gender: json['gender'],
      profileImageUrl: json['profileImageUrl'] ?? json['photoURL'],
      createdAt: json['createdAt'] is Timestamp 
          ? json['createdAt'] as Timestamp
          : (json['createdAt'] != null 
              ? Timestamp.fromDate(DateTime.parse(json['createdAt'])) 
              : Timestamp.now()),
      lastLoginAt: json['lastLoginAt'] is Timestamp 
          ? json['lastLoginAt'] as Timestamp
          : (json['lastLoginAt'] != null 
              ? Timestamp.fromDate(DateTime.parse(json['lastLoginAt'])) 
              : null),
      isEmailVerified: json['isEmailVerified'] ?? json['isActive'] ?? false,
      preferences: json['preferences'] ?? json['stats'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'username': username,
      'gender': gender,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'isEmailVerified': isEmailVerified,
      'preferences': preferences,
    };
  }
}