import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingLog {
  final String id;
  final String athleteId;
  final String teamId;
  final String programId;
  final String category;
  final String preset;
  final Map<String, dynamic> data;
  final Timestamp date;
  final double score;
  final String notes;
  final bool isCompleted;
  final String? coachFeedback;
  final Map<String, dynamic>? metadata;
  final String inputBy;
  final String userRole;
  final String? hrrBand; // Add missing hrrBand field

  TrainingLog({
    required this.id,
    required this.athleteId,
    required this.teamId,
    required this.programId,
    required this.category,
    required this.preset,
    required this.data,
    required this.date,
    required this.score,
    required this.notes,
    required this.isCompleted,
    this.coachFeedback,
    this.metadata,
    required this.inputBy,
    required this.userRole,
    this.hrrBand, // Add hrrBand parameter
  });

  factory TrainingLog.fromJson(Map<String, dynamic> json) {
    return TrainingLog(
      id: json['id'] ?? '',
      athleteId: json['athleteId'] ?? '',
      teamId: json['team_id'] ?? json['teamId'] ?? '',
      programId: json['programId'] ?? '',
      category: json['category'] ?? '',
      preset: json['preset'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      date: json['date'] is Timestamp 
          ? json['date'] as Timestamp
          : (json['date'] != null 
              ? Timestamp.fromDate(DateTime.parse(json['date']))
              : Timestamp.now()),
      inputBy: json['input_by'] ?? json['inputBy'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      userRole: json['userRole'] ?? 'athlete',
      notes: json['notes'],
      isCompleted: json['isCompleted'] ?? false,
      coachFeedback: json['coachFeedback'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'athleteId': athleteId,
      'team_id': teamId,
      'programId': programId,
      'category': category,
      'preset': preset,
      'data': data,
      'date': date,
      'input_by': inputBy,
      'score': score,
      'userRole': userRole,
      'notes': notes,
      'isCompleted': isCompleted,
      'coachFeedback': coachFeedback,
      'metadata': metadata,
      // Backward compatibility
      'teamId': teamId,
      'inputBy': inputBy,
    };
  }

  TrainingLog copyWith({
    String? id,
    String? athleteId,
    String? teamId,
    String? programId,
    String? category,
    String? preset,
    Map<String, dynamic>? data,
    Timestamp? date,
    String? inputBy,
    double? score,
    String? userRole,
    String? notes,
    bool? isCompleted,
    String? coachFeedback,
    Map<String, dynamic>? metadata,
  }) {
    return TrainingLog(
      id: id ?? this.id,
      athleteId: athleteId ?? this.athleteId,
      teamId: teamId ?? this.teamId,
      programId: programId ?? this.programId,
      category: category ?? this.category,
      preset: preset ?? this.preset,
      data: data ?? this.data,
      date: date ?? this.date,
      inputBy: inputBy ?? this.inputBy,
      score: score ?? this.score,
      userRole: userRole ?? this.userRole,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      coachFeedback: coachFeedback ?? this.coachFeedback,
      metadata: metadata ?? this.metadata,
    );
  }
}