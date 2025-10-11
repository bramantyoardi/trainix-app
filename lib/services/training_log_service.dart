
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trainix_app/models/training_log.dart';
import 'package:trainix_app/services/firestore_service.dart';

class TrainingLogService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'training_logs';
  final _db = FirebaseFirestore.instance;

  // Create training log
  Future<String> createTrainingLog(TrainingLog trainingLog) async {
    try {
      final docRef = await _firestoreService.addDocument(
        _collection,
        trainingLog.toJson(),
      );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create training log: $e');
    }
  }

  // Get training log by ID
  Future<TrainingLog?> getTrainingLog(String id) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, id);
      if (doc != null) {
        return TrainingLog.fromJson({...doc, 'id': id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get training log: $e');
    }
  }

  // Update training log
  Future<void> updateTrainingLog(String id, TrainingLog trainingLog) async {
    try {
      await _firestoreService.updateDocument(
        _collection,
        id,
        trainingLog.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to update training log: $e');
    }
  }

  // Delete training log
  Future<void> deleteTrainingLog(String id) async {
    try {
      await _firestoreService.deleteDocument(_collection, id);
    } catch (e) {
      throw Exception('Failed to delete training log: $e');
    }
  }

  // Get training logs by program - REFACTORED TO STREAM
  Stream<List<TrainingLog>> getProgramTrainingLogs(String programId) {
    return _db
        .collection(_collection)
        .where('programId', isEqualTo: programId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return TrainingLog.fromJson(data);
        }).toList());
  }

  // Get training logs by athlete - REFACTORED TO STREAM
  Stream<List<TrainingLog>> getAthleteTrainingLogs(String athleteId) {
    return _db
        .collection(_collection)
        .where('athleteId', isEqualTo: athleteId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return TrainingLog.fromJson(data);
        }).toList());
  }

  // Get training logs by team - REFACTORED TO STREAM
  Stream<List<TrainingLog>> getTeamTrainingLogs(String teamId) {
    return _db
        .collection(_collection)
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return TrainingLog.fromJson(data);
        }).toList());
  }

  // Get training logs by week (date range) - REFACTORED TO STREAM
  Stream<List<TrainingLog>> getWeekTrainingLogs(DateTime startDate, DateTime endDate) {
    return _db
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              Map<String, dynamic> data = doc.data();
              data['id'] = doc.id;
              return TrainingLog.fromJson(data);
            })
            .where((log) => 
              log.date.toDate().isAfter(startDate.subtract(const Duration(days: 1))) &&
              log.date.toDate().isBefore(endDate.add(const Duration(days: 1)))
            )
            .toList());
  }

  // Get training logs by date range for specific athlete - REFACTORED TO STREAM
  Stream<List<TrainingLog>> getAthleteTrainingLogsByDateRange(
    String athleteId, 
    DateTime startDate, 
    DateTime endDate
  ) {
    return _db
        .collection(_collection)
        .where('athleteId', isEqualTo: athleteId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              Map<String, dynamic> data = doc.data();
              data['id'] = doc.id;
              return TrainingLog.fromJson(data);
            })
            .where((log) => 
              log.date.toDate().isAfter(startDate.subtract(const Duration(days: 1))) &&
              log.date.toDate().isBefore(endDate.add(const Duration(days: 1)))
            )
            .toList());
  }

  // Stream training logs for real-time updates
  Stream<List<TrainingLog>> streamProgramTrainingLogs(String programId) {
    return _db
        .collection(_collection)
        .where('programId', isEqualTo: programId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return TrainingLog.fromJson(data);
        }).toList());
  }

  // Stream athlete training logs for real-time updates
  Stream<List<TrainingLog>> streamAthleteTrainingLogs(String athleteId) {
    return _db
        .collection(_collection)
        .where('athleteId', isEqualTo: athleteId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return TrainingLog.fromJson(data);
        }).toList());
  }
}