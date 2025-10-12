import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String name;
  final int? usia;
  final String? gender;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    this.usia,
    this.gender,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'usia': usia,
      'gender': gender,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      usia: map['usia'],
      gender: map['gender'],
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? name,
    int? usia,
    String? gender,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      usia: usia ?? this.usia,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username, name: $name, usia: $usia, gender: $gender, createdAt: $createdAt)';
  }
}