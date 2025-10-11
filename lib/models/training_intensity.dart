import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingIntensity {
  final String id;
  final String athleteId;
  final String teamId;
  final String programId;
  final double hrrPercentage; // Heart Rate Reserve percentage
  final String intensityZone; // Zone 1-5
  final Timestamp recordedAt;
  final double? avgHeartRate;
  final double? maxHeartRate;
  final int? duration; // in minutes

  TrainingIntensity({
    required this.id,
    required this.athleteId,
    required this.teamId,
    required this.programId,
    required this.hrrPercentage,
    required this.intensityZone,
    required this.recordedAt,
    this.avgHeartRate,
    this.maxHeartRate,
    this.duration,
  });

  factory TrainingIntensity.fromJson(Map<String, dynamic> json) {
    return TrainingIntensity(
      id: json['id'] ?? '',
      athleteId: json['athleteId'] ?? '',
      teamId: json['teamId'] ?? '',
      programId: json['programId'] ?? '',
      hrrPercentage: (json['hrrPercentage'] ?? json['percentage'] ?? 0.0).toDouble(),
      intensityZone: json['intensityZone'] ?? json['zone'] ?? '',
      recordedAt: json['recordedAt'] is Timestamp 
          ? json['recordedAt'] as Timestamp
          : (json['recordedAt'] != null 
              ? Timestamp.fromDate(DateTime.parse(json['recordedAt'])) 
              : Timestamp.now()),
      avgHeartRate: (json['avgHeartRate'] ?? 0.0).toDouble(),
      maxHeartRate: (json['maxHeartRate'] ?? 0.0).toDouble(),
      duration: json['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'athleteId': athleteId,
      'teamId': teamId,
      'programId': programId,
      'hrrPercentage': hrrPercentage,
      'intensityZone': intensityZone,
      'recordedAt': recordedAt,
      'avgHeartRate': avgHeartRate,
      'maxHeartRate': maxHeartRate,
      'duration': duration,
    };
  }

  // Calculate intensity score based on HRR percentage and duration
  double get intensityScore {
    if (duration == null) return hrrPercentage;
    return hrrPercentage * (duration! / 60.0); // Normalize by hour
  }

  // Alias untuk backward compatibility
  double get score => intensityScore;

  // Get zone color for UI
  String get zoneColor {
    switch (intensityZone) {
      case 'Zone 1':
        return '#4CAF50'; // Green
      case 'Zone 2':
        return '#8BC34A'; // Light Green
      case 'Zone 3':
        return '#FFEB3B'; // Yellow
      case 'Zone 4':
        return '#FF9800'; // Orange
      case 'Zone 5':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }
}