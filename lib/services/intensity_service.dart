import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trainix_app/models/training_intensity.dart';
import 'package:trainix_app/services/firestore_service.dart';

class IntensityService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'training_intensities';
  final _db = FirebaseFirestore.instance;

  // Mendapatkan intensitas latihan berdasarkan ID
  Future<TrainingIntensity?> getIntensity(String intensityId) async {
    try {
      final data = await _firestoreService.getDocument(_collection, intensityId);
      if (data != null) {
        data['id'] = intensityId;
        return TrainingIntensity.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting intensity: $e');
      return null;
    }
  }

  // Membuat intensitas latihan baru
  Future<String?> createIntensity(TrainingIntensity intensity) async {
    try {
      DocumentReference docRef = await _firestoreService.addDocument(
        _collection,
        intensity.toJson(),
      );
      return docRef.id;
    } catch (e) {
      print('Error creating intensity: $e');
      return null;
    }
  }

  // Memperbarui intensitas latihan
  Future<bool> updateIntensity(String intensityId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(_collection, intensityId, data);
      return true;
    } catch (e) {
      print('Error updating intensity: $e');
      return false;
    }
  }

  // Menghapus intensitas latihan
  Future<bool> deleteIntensity(String intensityId) async {
    try {
      await _firestoreService.deleteDocument(_collection, intensityId);
      return true;
    } catch (e) {
      print('Error deleting intensity: $e');
      return false;
    }
  }

  // Mendapatkan semua intensitas latihan untuk program tertentu - REFACTORED TO STREAM
  Stream<List<TrainingIntensity>> getProgramIntensities(String programId) {
    return _db
        .collection(_collection)
        .where('programId', isEqualTo: programId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return TrainingIntensity.fromJson(data);
        }).toList());
  }

  // Mendapatkan intensitas latihan untuk atlet tertentu - REFACTORED TO STREAM
  Stream<List<TrainingIntensity>> getAthleteIntensities(String athleteId) {
    return _db
        .collection(_collection)
        .where('athleteId', isEqualTo: athleteId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return TrainingIntensity.fromJson(data);
        }).toList());
  }

  // Mendapatkan intensitas latihan untuk tim tertentu - REFACTORED TO STREAM
  Stream<List<TrainingIntensity>> getTeamIntensities(String teamId) {
    return _db
        .collection(_collection)
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return TrainingIntensity.fromJson(data);
        }).toList());
  }

  // Mendapatkan rata-rata intensitas latihan untuk atlet tertentu
  Future<double> getAverageIntensity(String athleteId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('athleteId', isEqualTo: athleteId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      int totalScore = 0;
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalScore += data['score'] as int;
      }

      return totalScore / snapshot.docs.length;
    } catch (e) {
      print('Error getting average intensity: $e');
      return 0.0;
    }
  }
}