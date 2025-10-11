import 'package:cloud_firestore/cloud_firestore.dart';
import 'team.dart';

class UserTeamRole {
  final String id;
  final String userId;
  final String teamId;
  final String role; // 'Athlete' or 'Coach'
  final Timestamp joinedAt;
  final bool isActive;
  final String? invitedBy;
  final Timestamp? invitedAt;
  final String? approvedBy;
  final Timestamp? dateJoined;
  final String status; // 'pending', 'approved', 'rejected'
  final bool isOwner;
  final String? userName;
  final String? userEmail;
  final String? userPhotoUrl;
  // ADD MISSING TEAM PROPERTY
  final Team? team;

  UserTeamRole({
    required this.id,
    required this.userId,
    required this.teamId,
    required this.role,
    required this.joinedAt,
    this.isActive = true,
    this.invitedBy,
    this.invitedAt,
    this.approvedBy,
    this.dateJoined,
    this.status = 'pending',
    this.isOwner = false,
    this.userName,
    this.userEmail,
    this.userPhotoUrl,
    this.team, // ADD TEAM PROPERTY
  });

  factory UserTeamRole.fromJson(Map<String, dynamic> json) {
    return UserTeamRole(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      teamId: json['teamId'] ?? '',
      role: json['role'] ?? 'Athlete',
      joinedAt: json['joinedAt'] is Timestamp 
          ? json['joinedAt'] as Timestamp
          : (json['joinedAt'] != null 
              ? Timestamp.fromDate(DateTime.parse(json['joinedAt']))
              : Timestamp.now()),
      isActive: json['isActive'] ?? true,
      invitedBy: json['invitedBy'],
      invitedAt: json['invitedAt'] is Timestamp 
          ? json['invitedAt'] as Timestamp
          : (json['invitedAt'] != null 
              ? Timestamp.fromDate(DateTime.parse(json['invitedAt']))
              : null),
      approvedBy: json['approvedBy'],
      dateJoined: json['dateJoined'] is Timestamp 
          ? json['dateJoined'] as Timestamp
          : (json['dateJoined'] != null 
              ? Timestamp.fromDate(DateTime.parse(json['dateJoined']))
              : null),
      status: json['status'] ?? 'pending',
      isOwner: json['isOwner'] ?? false,
      userName: json['userName'],
      userEmail: json['userEmail'],
      userPhotoUrl: json['userPhotoUrl'],
      // PARSE TEAM FROM JSON
      team: json['team'] != null ? Team.fromJson(json['team']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt,
      'isActive': isActive,
      'invitedBy': invitedBy,
      'invitedAt': invitedAt,
      'approvedBy': approvedBy,
      'dateJoined': dateJoined,
      'status': status,
      'isOwner': isOwner,
      'userName': userName,
      'userEmail': userEmail,
      'userPhotoUrl': userPhotoUrl,
      // INCLUDE TEAM IN JSON
      'team': team?.toJson(),
    };
  }

  UserTeamRole copyWith({
    String? id,
    String? userId,
    String? teamId,
    String? role,
    Timestamp? joinedAt,
    bool? isActive,
    String? invitedBy,
    Timestamp? invitedAt,
    String? approvedBy,
    Timestamp? dateJoined,
    String? status,
    bool? isOwner,
    String? userName,
    String? userEmail,
    String? userPhotoUrl,
    Team? team, // ADD TEAM TO COPYWITH
  }) {
    return UserTeamRole(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      teamId: teamId ?? this.teamId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      invitedBy: invitedBy ?? this.invitedBy,
      invitedAt: invitedAt ?? this.invitedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      dateJoined: dateJoined ?? this.dateJoined,
      status: status ?? this.status,
      isOwner: isOwner ?? this.isOwner,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      team: team ?? this.team, // INCLUDE TEAM IN COPYWITH
    );
  }
}