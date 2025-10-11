import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/program.dart';
import 'firestore_service.dart';

class ProgramService {
  final FirestoreService _firestoreService;
  final FirebaseFirestore _db;

  // Constructor with optional FirestoreService
  ProgramService([FirestoreService? firestoreService]) 
    : _firestoreService = firestoreService ?? FirestoreService(),
      _db = FirebaseFirestore.instance;

  // CORE IMPLEMENTATIONS

  // Unified getProgram method - handles both single and team-scoped queries
  Future<Program?> getProgram(String programId, [String? teamId]) async {
    try {
      print('Getting program: $programId');
      
      if (teamId != null) {
        // Team-scoped query for compatibility
        final doc = await _db.collection('teams').doc(teamId).collection('programs').doc(programId).get();
        return doc.exists ? Program.fromFirestore(doc) : null;
      } else {
        // Direct program query
        final doc = await _firestoreService.getDocument('programs', programId);
        if (doc != null) {
          return Program.fromJson({'id': programId, ...doc});
        }
        return null;
      }
    } catch (e) {
      print('Error getting program: $e');
      return null;
    }
  }

  Future<List<Program>> fetchPrograms(String teamId) async {
    final qs = await _db.collection('teams').doc(teamId).collection('programs').get();
    return qs.docs.map((d) => Program.fromFirestore(d)).toList();
  }

  Stream<List<Program>> getTeamPrograms(String teamId) {
    return _db
        .collection('programs')
        .where('teamId', isEqualTo: teamId)
        .orderBy('weekAnchor')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Program.fromFirestore(d)).toList());
  }

  Stream<List<Program>> getProgramsByWeek(String teamId, Timestamp weekStart) {
    return _db
        .collection('programs')
        .where('teamId', isEqualTo: teamId)
        .where('weekAnchor', isEqualTo: weekStart)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Program.fromFirestore(d)).toList());
  }

  // Add getPrograms method with named parameters
  Future<List<Program>> getPrograms({
    required String userId,
    required bool isCoach,
  }) async {
    try {
      if (isCoach) {
        // Coach can see all programs for their teams
        return await _db
            .collection('programs')
            .where('coachId', isEqualTo: userId)
            .get()
            .then((snap) => snap.docs.map((d) => Program.fromFirestore(d)).toList());
      } else {
        // Athletes see programs assigned to them
        return await _db
            .collection('programs')
            .where('athleteIds', arrayContains: userId)
            .get()
            .then((snap) => snap.docs.map((d) => Program.fromFirestore(d)).toList());
      }
    } catch (e) {
      print('Error getting programs: $e');
      return [];
    }
  }

  // Fix createProgram to return String?
  Future<String?> createProgram(Program program) async {
    try {
      print('Creating program: ${program.name}');
      final docRef = await _firestoreService.addDocument('programs', program.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating program: $e');
      return null;
    }
  }

  Future<bool> updateProgram(String programId, Map<String, dynamic> data) async {
    try {
      print('Updating program: $programId');
      await _firestoreService.updateDocument('programs', programId, data);
      return true;
    } catch (e) {
      print('Error updating program: $e');
      return false;
    }
  }

  Future<bool> deleteProgram(String programId) async {
    try {
      print('Deleting program: $programId');
      await _firestoreService.deleteDocument('programs', programId);
      return true;
    } catch (e) {
      print('Error deleting program: $e');
      return false;
    }
  }

  bool isSameWeek(DateTime date1, DateTime date2) {
    final startOfWeek1 = date1.subtract(Duration(days: date1.weekday - 1));
    final startOfWeek2 = date2.subtract(Duration(days: date2.weekday - 1));
    return startOfWeek1.year == startOfWeek2.year &&
           startOfWeek1.month == startOfWeek2.month &&
           startOfWeek1.day == startOfWeek2.day;
  }
}