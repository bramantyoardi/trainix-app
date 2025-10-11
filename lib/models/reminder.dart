import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id;
  final String title;
  final String description;
  final Timestamp dateTime;
  final String teamId;
  final String createdBy;
  final bool isCompleted;
  final String? athleteId;
  final Timestamp? targetDate;
  final String status;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.teamId,
    required this.createdBy,
    this.isCompleted = false,
    this.athleteId,
    this.targetDate,
    this.status = 'pending',
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dateTime: json['dateTime'] is Timestamp 
          ? json['dateTime'] as Timestamp
          : (json['dateTime'] != null 
              ? Timestamp.fromDate(DateTime.parse(json['dateTime'])) 
              : Timestamp.now()),
      teamId: json['teamId'] ?? '',
      createdBy: json['createdBy'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      targetDate: json['targetDate'] is Timestamp 
          ? json['targetDate'] as Timestamp
          : (json['targetDate'] != null 
              ? Timestamp.fromDate(DateTime.parse(json['targetDate'])) 
              : null),
      athleteId: json['athleteId'],
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime,
      'teamId': teamId,
      'createdBy': createdBy,
      'isCompleted': isCompleted,
      'athleteId': athleteId,
      'targetDate': targetDate,
      'status': status,
    };
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    Timestamp? dateTime,
    String? teamId,
    String? createdBy,
    bool? isCompleted,
    String? athleteId,
    Timestamp? targetDate,
    String? status,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      teamId: teamId ?? this.teamId,
      createdBy: createdBy ?? this.createdBy,
      isCompleted: isCompleted ?? this.isCompleted,
      athleteId: athleteId ?? this.athleteId,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
    );
  }
}