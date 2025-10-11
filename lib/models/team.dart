import 'package:cloud_firestore/cloud_firestore.dart';

class TeamConfig {
  final int targetDays;
  final Map<String, double> weights;
  final bool allowRecovery;

  TeamConfig({
    required this.targetDays,
    required this.weights,
    this.allowRecovery = true,
  });

  factory TeamConfig.fromJson(Map<String, dynamic> json) {
    return TeamConfig(
      targetDays: json['targetDays'] ?? 6,
      weights: Map<String, double>.from(json['weights'] ?? {}),
      allowRecovery: json['allowRecovery'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetDays': targetDays,
      'weights': weights,
      'allowRecovery': allowRecovery,
    };
  }
}

class Team {
  final String id;
  final String name;
  final String description;
  final String coachId;
  final String coachName;
  final String? coachPhotoUrl;
  final String? teamPhotoUrl;
  final String? inviteCode;
  final Timestamp createdAt;
  final Timestamp? tglMulai;
  final Timestamp? tglSelesai;
  final TeamConfig config;
  final bool isActive;
  final int maxMembers;
  final List<String> categories;
  final String? location;
  final Map<String, dynamic>? metadata;
  
  // Legacy fields for backward compatibility
  final List<String>? memberIds;
  final String? logoUrl;
  final String? cabor;
  final String? kontingen;
  final String? event;
  final String? teamCode;
  final int? totalMembers;
  final String? sport;
  final List<String>? tags;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.coachId,
    required this.coachName,
    this.coachPhotoUrl,
    this.teamPhotoUrl,
    this.inviteCode,
    required this.createdAt,
    this.tglMulai,
    this.tglSelesai,
    required this.config,
    this.isActive = true,
    this.maxMembers = 50,
    this.categories = const [],
    this.location,
    this.metadata,
    // Legacy fields
    this.memberIds,
    this.logoUrl,
    this.cabor,
    this.kontingen,
    this.event,
    this.teamCode,
    this.totalMembers,
    this.sport,
    this.tags,
  });

  // Add memberCount getter
  int get memberCount => totalMembers ?? memberIds?.length ?? 0;

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      coachId: json['coachId'] ?? json['createdBy'] ?? '',
      coachName: json['coachName'] ?? '',
      coachPhotoUrl: json['coachPhotoUrl'],
      teamPhotoUrl: json['teamPhotoUrl'],
      inviteCode: json['inviteCode'],
      createdAt: json['createdAt'] is Timestamp 
          ? json['createdAt'] as Timestamp
          : (json['createdAt'] != null 
              ? Timestamp.fromDate(DateTime.parse(json['createdAt']))
              : Timestamp.now()),
      tglMulai: json['tglMulai'] is Timestamp 
          ? json['tglMulai'] as Timestamp
          : (json['tglMulai'] != null 
              ? Timestamp.fromDate(DateTime.parse(json['tglMulai']))
              : null),
      tglSelesai: json['tglSelesai'] is Timestamp 
          ? json['tglSelesai'] as Timestamp
          : (json['tglSelesai'] != null 
              ? Timestamp.fromDate(DateTime.parse(json['tglSelesai']))
              : null),
      config: json['config'] != null 
          ? TeamConfig.fromJson(json['config'])
          : TeamConfig(targetDays: 6, weights: {}),
      isActive: json['isActive'] ?? true,
      maxMembers: json['maxMembers'] ?? 50,
      categories: List<String>.from(json['categories'] ?? []),
      location: json['location'],
      metadata: json['metadata'],
      // Legacy fields
      memberIds: json['memberIds'] != null ? List<String>.from(json['memberIds']) : null,
      logoUrl: json['logoUrl'],
      cabor: json['cabor'],
      kontingen: json['kontingen'],
      event: json['event'],
      teamCode: json['teamCode'],
      totalMembers: json['totalMembers'],
      sport: json['sport'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coachId': coachId,
      'coachName': coachName,
      'coachPhotoUrl': coachPhotoUrl,
      'teamPhotoUrl': teamPhotoUrl,
      'inviteCode': inviteCode,
      'createdAt': createdAt,
      'tglMulai': tglMulai,
      'tglSelesai': tglSelesai,
      'config': config.toJson(),
      'isActive': isActive,
      'maxMembers': maxMembers,
      'categories': categories,
      'location': location,
      'metadata': metadata,
      // Legacy fields for backward compatibility
      'createdBy': coachId,
      'memberIds': memberIds,
      'logoUrl': logoUrl,
      'cabor': cabor,
      'kontingen': kontingen,
      'event': event,
      'teamCode': teamCode,
      'totalMembers': totalMembers,
      'sport': sport,
      'tags': tags,
    };
  }

  // Add toJsonForFirestore method for compatibility
  Map<String, dynamic> toJsonForFirestore() {
    return toJson();
  }

  Team copyWith({
    String? id,
    String? name,
    String? description,
    String? coachId,
    String? coachName,
    String? coachPhotoUrl,
    String? teamPhotoUrl,
    String? inviteCode,
    Timestamp? createdAt,
    Timestamp? tglMulai,
    Timestamp? tglSelesai,
    TeamConfig? config,
    bool? isActive,
    int? maxMembers,
    List<String>? categories,
    String? location,
    Map<String, dynamic>? metadata,
    // Legacy fields
    List<String>? memberIds,
    String? logoUrl,
    String? cabor,
    String? kontingen,
    String? event,
    String? teamCode,
    int? totalMembers,
    String? sport,
    List<String>? tags,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coachId: coachId ?? this.coachId,
      coachName: coachName ?? this.coachName,
      coachPhotoUrl: coachPhotoUrl ?? this.coachPhotoUrl,
      teamPhotoUrl: teamPhotoUrl ?? this.teamPhotoUrl,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      tglMulai: tglMulai ?? this.tglMulai,
      tglSelesai: tglSelesai ?? this.tglSelesai,
      config: config ?? this.config,
      isActive: isActive ?? this.isActive,
      maxMembers: maxMembers ?? this.maxMembers,
      categories: categories ?? this.categories,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
      // Legacy fields
      memberIds: memberIds ?? this.memberIds,
      logoUrl: logoUrl ?? this.logoUrl,
      cabor: cabor ?? this.cabor,
      kontingen: kontingen ?? this.kontingen,
      event: event ?? this.event,
      teamCode: teamCode ?? this.teamCode,
      totalMembers: totalMembers ?? this.totalMembers,
      sport: sport ?? this.sport,
      tags: tags ?? this.tags,
    );
  }
}