import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trainix_app/models/reminder.dart';
import 'package:trainix_app/services/firestore_service.dart';

class ReminderService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'reminders';
  final _db = FirebaseFirestore.instance;

  // Mendapatkan reminder berdasarkan ID
  Future<Reminder?> getReminder(String reminderId) async {
    try {
      final data = await _firestoreService.getDocument(_collection, reminderId);
      if (data != null) {
        data['id'] = reminderId;
        return Reminder.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting reminder: $e');
      return null;
    }
  }

  // Membuat reminder baru dengan named parameters
  // Ensure createReminder uses named parameters
  Future<void> createReminder({
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestoreService.addDocument(_collection, data);
    } catch (e) {
      print('Error creating reminder: $e');
      rethrow;
    }
  }

  // Memperbarui reminder
  // Updated signature to use named parameters
  Future<bool> updateReminder({
    required String reminderId, 
    required Map<String, dynamic> data
  }) async {
    try {
      await _firestoreService.updateDocument(_collection, reminderId, data);
      return true;
    } catch (e) {
      print('Error updating reminder: $e');
      return false;
    }
  }

  // Memperbarui status reminder - FIXED TO ACCEPT STRING
  Future<bool> updateReminderStatus(String reminderId, String status) async {
    try {
      await _firestoreService.updateDocument(_collection, reminderId, {
        'status': status,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Error updating reminder status: $e');
      return false;
    }
  }

  // Menghapus reminder
  Future<bool> deleteReminder(String reminderId) async {
    try {
      await _firestoreService.deleteDocument(_collection, reminderId);
      return true;
    } catch (e) {
      print('Error deleting reminder: $e');
      return false;
    }
  }

  // Mendapatkan semua reminder untuk atlet tertentu - REFACTORED TO STREAM
  Stream<List<Reminder>> getAthleteReminders(String athleteId) {
    return _db
        .collection(_collection)
        .where('athleteId', isEqualTo: athleteId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return Reminder.fromJson(data);
        }).toList());
  }

  // Mendapatkan semua reminder untuk tim tertentu - REFACTORED TO STREAM
  Stream<List<Reminder>> getTeamReminders(String teamId) {
    return _db
        .collection(_collection)
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return Reminder.fromJson(data);
        }).toList());
  }

  // Mendapatkan reminder berdasarkan status - REFACTORED TO STREAM
  Stream<List<Reminder>> getRemindersByStatus(String athleteId, String status) {
    return _db
        .collection(_collection)
        .where('athleteId', isEqualTo: athleteId)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return Reminder.fromJson(data);
        }).toList());
  }
}