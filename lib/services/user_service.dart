import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trainix_app/models/user_profile.dart';
import 'package:trainix_app/services/firestore_service.dart';
import 'package:trainix_app/services/encryption_service.dart';

class UserService {
  final FirestoreService _firestoreService;
  final EncryptionService _encryptionService =
      EncryptionService(); // Add instance
  final _db = FirebaseFirestore.instance;

  UserService(this._firestoreService);

  Future<void> updateFCMToken(String uid, String token) async {
    await _db.collection('users').doc(uid).update({
      'fcmToken': token,
      'fcmUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestoreService.getDocument('users', uid);
      if (doc != null) {
        final decryptedData = _encryptionService.decryptUserProfile(doc);
        if (decryptedData != null) {
          return UserProfile.fromJson({
            'uid': uid,
            ...decryptedData,
          });
        }
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      final encryptedData =
          _encryptionService.encryptUserProfile(profile.toJson());

      if (encryptedData != null) {
        await _firestoreService.updateDocument(
            'users', profile.uid, encryptedData);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      // Simple search implementation
      final docs = await _firestoreService.getCollection('users');
      List<UserProfile> users = [];

      for (var doc in docs) {
        final decryptedData = _encryptionService
            .decryptUserProfile(doc.data() as Map<String, dynamic>);
        if (decryptedData != null) {
          final profile = UserProfile.fromJson({
            'uid': doc.id,
            ...decryptedData,
          });

          if (profile.name.toLowerCase().contains(query.toLowerCase()) ||
              profile.email.toLowerCase().contains(query.toLowerCase())) {
            users.add(profile);
          }
        }
      }

      return users;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  Future<List<UserProfile>> getUsersByIds(List<String> userIds) async {
    try {
      List<UserProfile> users = [];

      for (String uid in userIds) {
        final doc = await _firestoreService.getDocument('users', uid);
        if (doc != null) {
          final decryptedData = _encryptionService.decryptUserProfile(doc);
          if (decryptedData != null) {
            users.add(UserProfile.fromJson({
              'uid': uid,
              ...decryptedData,
            }));
          }
        }
      }

      return users;
    } catch (e) {
      print('Error getting users by IDs: $e');
      return [];
    }
  }
}
