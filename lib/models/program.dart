

import 'package:cloud_firestore/cloud_firestore.dart';

class Program {
  final String id;
  final String name;
  final String teamId;
  final Timestamp weekAnchor;
  final Map<String, dynamic> template;
  final List<String> categories;
  final int targetDays;
  final String createdBy;

  Program({
    required this.id,
    required this.name,
    required this.teamId,
    required this.weekAnchor,
    required this.template,
    required this.categories,
    required this.targetDays,
    required this.createdBy,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Program Minggu ${DateTime.now().weekday}',
      teamId: json['team_id'] ?? json['teamId'] ?? '',
      weekAnchor: json['week_anchor'] is Timestamp 
          ? json['week_anchor'] as Timestamp
          : (json['week_anchor'] != null 
              ? Timestamp.fromDate(DateTime.parse(json['week_anchor']))
              : Timestamp.now()),
      template: Map<String, dynamic>.from(json['template'] ?? {}),
      categories: List<String>.from(json['categories'] ?? []),
      targetDays: json['target_days'] ?? json['targetDays'] ?? 7,
      createdBy: json['created_by'] ?? json['createdBy'] ?? '',
    );
  }

  // Add fromFirestore factory for Firestore compatibility
  factory Program.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    DateTime? _toDate(dynamic v) =>
      v is Timestamp ? v.toDate() : (v is DateTime ? v : null);

    return Program(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      teamId: (data['team_id'] ?? data['teamId'] ?? '') as String,
      weekAnchor: data['week_anchor'] is Timestamp 
          ? data['week_anchor'] as Timestamp
          : Timestamp.now(),
      template: Map<String, dynamic>.from(data['template'] ?? {}),
      categories: List<String>.from(data['categories'] ?? []),
      targetDays: (data['target_days'] ?? data['targetDays'] ?? 7) as int,
      createdBy: (data['created_by'] ?? data['createdBy'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'team_id': teamId,
      'week_anchor': weekAnchor,
      'template': template,
      'categories': categories,
      'target_days': targetDays,
      'created_by': createdBy,
      // Backward compatibility
      'teamId': teamId,
      'targetDays': targetDays,
      'createdBy': createdBy,
    };
  }

  // Add toMap method for Firestore compatibility
  Map<String, dynamic> toMap() => {
    'name': name,
    'team_id': teamId,
    'week_anchor': weekAnchor,
    'template': template,
    'categories': categories,
    'target_days': targetDays,
    'created_by': createdBy,
  };

  Program copyWith({
    String? id,
    String? name,
    String? teamId,
    Timestamp? weekAnchor,
    Map<String, dynamic>? template,
    List<String>? categories,
    int? targetDays,
    String? createdBy,
  }) {
    return Program(
      id: id ?? this.id,
      name: name ?? this.name,
      teamId: teamId ?? this.teamId,
      weekAnchor: weekAnchor ?? this.weekAnchor,
      template: template ?? this.template,
      categories: categories ?? this.categories,
      targetDays: targetDays ?? this.targetDays,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}