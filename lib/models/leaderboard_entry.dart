
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScores {
  final double consistency;
  final double intensity;
  final double total;

  LeaderboardScores({
    required this.consistency,
    required this.intensity,
    required this.total,
  });

  factory LeaderboardScores.fromJson(Map<String, dynamic> json) {
    return LeaderboardScores(
      consistency: (json['consistency'] ?? 0).toDouble(),
      intensity: (json['intensity'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consistency': consistency,
      'intensity': intensity,
      'total': total,
    };
  }
}

class LeaderboardEntry {
  final String id;
  final String teamId;
  final String week;
  final String athleteId;
  final LeaderboardScores scores;
  final bool eligible;
  final Map<String, dynamic>? breakdown;
  final Timestamp lastUpdated;
  final String? athleteName;
  final String? athletePhotoUrl;
  final double totalScore;

  LeaderboardEntry({
    required this.id,
    required this.teamId,
    required this.week,
    required this.athleteId,
    required this.scores,
    this.eligible = true,
    this.breakdown,
    Timestamp? lastUpdated,
    this.athleteName,
    this.athletePhotoUrl,
    double? totalScore,
  }) : lastUpdated = lastUpdated ?? Timestamp.now(),
       totalScore = totalScore ?? scores.total;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] ?? '',
      teamId: json['teamId'] ?? json['team_id'] ?? '',
      week: json['week'] ?? '',
      athleteId: json['athleteId'] ?? json['athlete_id'] ?? '',
      scores: json['scores'] != null 
          ? LeaderboardScores.fromJson(json['scores'])
          : LeaderboardScores(
              consistency: (json['consistency'] ?? 0).toDouble(),
              intensity: (json['intensity'] ?? 0).toDouble(),
              total: (json['total'] ?? json['score'] ?? 0).toDouble(),
            ),
      eligible: json['eligible'] ?? true,
      breakdown: json['breakdown'],
      lastUpdated: json['lastUpdated'] is Timestamp 
          ? json['lastUpdated'] as Timestamp
          : (json['last_updated'] is Timestamp 
              ? json['last_updated'] as Timestamp
              : (json['lastUpdated'] != null 
                  ? Timestamp.fromDate(DateTime.parse(json['lastUpdated']))
                  : (json['last_updated'] != null 
                      ? Timestamp.fromDate(DateTime.parse(json['last_updated'])) 
                      : Timestamp.now()))),
      athleteName: json['athleteName'] ?? json['athlete_name'],
      athletePhotoUrl: json['athletePhotoUrl'] ?? json['athlete_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'week': week,
      'athleteId': athleteId,
      'scores': scores.toJson(),
      'eligible': eligible,
      'breakdown': breakdown,
      'lastUpdated': lastUpdated,
      'athleteName': athleteName,
      'athletePhotoUrl': athletePhotoUrl,
      'totalScore': totalScore,
    };
  }

  LeaderboardEntry copyWith({
    String? id,
    String? teamId,
    String? week,
    String? athleteId,
    LeaderboardScores? scores,
    bool? eligible,
    Map<String, dynamic>? breakdown,
    Timestamp? lastUpdated,
    String? athleteName,
    String? athletePhotoUrl,
    double? totalScore,
  }) {
    return LeaderboardEntry(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      week: week ?? this.week,
      athleteId: athleteId ?? this.athleteId,
      scores: scores ?? this.scores,
      eligible: eligible ?? this.eligible,
      breakdown: breakdown ?? this.breakdown,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      athleteName: athleteName ?? this.athleteName,
      athletePhotoUrl: athletePhotoUrl ?? this.athletePhotoUrl,
      totalScore: totalScore ?? this.totalScore,
    );
  }
}