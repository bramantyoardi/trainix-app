import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';
import 'firestore_service.dart';

class LeaderboardService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _leaderboardCollection = 'leaderboards';
  final _db = FirebaseFirestore.instance;

  // Get team leaderboard with calculated scores - REFACTORED TO STREAM
  Stream<List<LeaderboardEntry>> getTeamLeaderboard(String teamId) {
    return _db
        .collection(_leaderboardCollection)
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .asyncMap((snapshot) async {
          List<LeaderboardEntry> entries = [];
          
          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            
            // Calculate real-time scores from training logs
            final scores = await _calculateAthleteScores(teamId, data['athleteId']);
            data['scores'] = scores;
            data['totalScore'] = (scores['consistency'] as double) + (scores['intensity'] as double);
            
            entries.add(LeaderboardEntry.fromJson(data));
          }
          
          // Sort by total score descending
          entries.sort((a, b) => b.totalScore.compareTo(a.totalScore));
          return entries;
        });
  }

  // Calculate athlete scores from training logs
  Future<Map<String, double>> _calculateAthleteScores(String teamId, String athleteId) async {
    try {
      final logsSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('trainingLogs')
          .where('athleteId', isEqualTo: athleteId)
          .get();

      if (logsSnapshot.docs.isEmpty) {
        return {'consistency': 0.0, 'intensity': 0.0};
      }

      double totalScore = 0.0;
      int logCount = logsSnapshot.docs.length;
      
      for (var doc in logsSnapshot.docs) {
        final data = doc.data();
        totalScore += (data['score'] as num?)?.toDouble() ?? 0.0;
      }

      double averageScore = totalScore / logCount;
      double consistency = logCount * 2.0; // 2 points per log for consistency
      double intensity = averageScore; // Use average score for intensity

      return {
        'consistency': consistency,
        'intensity': intensity,
      };
    } catch (e) {
      return {'consistency': 0.0, 'intensity': 0.0};
    }
  }

  // Add or update leaderboard entry
  Future<bool> addLeaderboardEntry(
    String teamId,
    String athleteId,
    String athleteName,
    String? athletePhotoUrl,
    int score,
  ) async {
    try {
      // Check if entry already exists
      final existingDocs = await _firestoreService.getFilteredCollection(
        _leaderboardCollection, 
        'athleteId', 
        athleteId
      );

      if (existingDocs.isNotEmpty) {
        // Update existing entry
        final docId = existingDocs.first.id;
        final currentData = existingDocs.first.data() as Map<String, dynamic>;
        
        // Recalculate scores
        final scores = await _calculateAthleteScores(teamId, athleteId);
        
        await _firestoreService.updateDocument(_leaderboardCollection, docId, {
          'scores': scores,
          'totalScore': scores['consistency']! + scores['intensity']!,
          'lastUpdated': Timestamp.now(),
        });
      } else {
        // Create new entry
        final scores = await _calculateAthleteScores(teamId, athleteId);
        
        final entry = LeaderboardEntry(
          id: '',
          teamId: teamId,
          week: _getCurrentWeek(),
          athleteId: athleteId,
          scores: LeaderboardScores(
            consistency: scores['consistency']!,
            intensity: scores['intensity']!,
            total: scores['consistency']! + scores['intensity']!,
          ),
          eligible: true,
          lastUpdated: Timestamp.now(),
          athleteName: athleteName,
          athletePhotoUrl: athletePhotoUrl,
          totalScore: scores['consistency']! + scores['intensity']!,
        );

        await _firestoreService.addDocument(_leaderboardCollection, entry.toJson());
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete leaderboard entry
  Future<bool> deleteLeaderboardEntry(String entryId) async {
    try {
      await _firestoreService.deleteDocument(_leaderboardCollection, entryId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get athlete rank
  Future<int> getAthleteRank(String teamId, String athleteId) async {
    try {
      final leaderboard = await getTeamLeaderboard(teamId).first;
      final index = leaderboard.indexWhere((entry) => entry.athleteId == athleteId);
      return index >= 0 ? index + 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  String _getCurrentWeek() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final daysSinceStart = now.difference(startOfYear).inDays;
    final weekNumber = (daysSinceStart / 7).ceil();
    return '${now.year}-W$weekNumber';
  }
}