import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SecurityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Random _random = Random.secure();
  
  // Rate limiting storage
  static final Map<String, List<DateTime>> _rateLimitMap = {};
  
  // Hash data using SHA-256
  static String hashData(String data) {
    try {
      var bytes = utf8.encode(data);
      var digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      print('Error hashing data: $e');
      return '';
    }
  }

  // Generate secure random token
  static String generateSecureToken([int length = 32]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  // Log security events
  static Future<void> logSecurityEvent({
    required String userId,
    required String eventType,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('security_logs').add({
        'userId': userId,
        'eventType': eventType,
        'description': description,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'ipAddress': 'unknown', // Would need additional setup to get real IP
      });
      print('Security event logged: $eventType for user $userId');
    } catch (e) {
      print('Error logging security event: $e');
    }
  }

  // Get user security logs
  static Future<List<Map<String, dynamic>>> getUserSecurityLogs(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('security_logs')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting user security logs: $e');
      return [];
    }
  }

  // Validate team access - UPDATED FOR NEW SCHEMA
  static Future<bool> validateTeamAccess(String userId, String teamId) async {
    try {
      final memberDoc = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(userId)
          .get();

      if (memberDoc.exists) {
        final data = memberDoc.data()!;
        return data['status'] == 'approved';
      }
      
      return false;
    } catch (e) {
      print('Error validating team access: $e');
      return false;
    }
  }

  // Check if user is approved coach
  static Future<bool> isApprovedCoach(String userId, String teamId) async {
    try {
      final memberDoc = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(userId)
          .get();

      if (memberDoc.exists) {
        final data = memberDoc.data()!;
        return data['role'] == 'Coach' && 
               data['status'] == 'approved' && 
               data['isActive'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error checking approved coach status: $e');
      return false;
    }
  }

  // Check if user is team owner
  static Future<bool> isTeamOwner(String userId, String teamId) async {
    try {
      final memberDoc = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(userId)
          .get();

      if (memberDoc.exists) {
        final data = memberDoc.data()!;
        return data['isOwner'] == true && 
               data['status'] == 'approved';
      }
      
      return false;
    } catch (e) {
      print('Error checking team owner status: $e');
      return false;
    }
  }

  // Check if user is approved team member
  static Future<bool> isApprovedTeamMember(String userId, String teamId) async {
    try {
      final memberDoc = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(userId)
          .get();

      if (memberDoc.exists) {
        final data = memberDoc.data()!;
        return data['status'] == 'approved';
      }
      
      return false;
    } catch (e) {
      print('Error checking team member status: $e');
      return false;
    }
  }

  // Check if user can write to programs/training logs
  static Future<bool> canWriteToTeamData(String userId, String teamId) async {
    try {
      return await isApprovedCoach(userId, teamId) || await isTeamOwner(userId, teamId);
    } catch (e) {
      print('Error checking write permissions: $e');
      return false;
    }
  }

  // Check if user can manage team members
  static Future<bool> canManageTeamMembers(String userId, String teamId) async {
    try {
      return await isApprovedCoach(userId, teamId) || await isTeamOwner(userId, teamId);
    } catch (e) {
      print('Error checking member management permissions: $e');
      return false;
    }
  }

  // Check if user can read leaderboards
  static Future<bool> canReadLeaderboards(String userId, String teamId) async {
    try {
      return await isApprovedTeamMember(userId, teamId);
    } catch (e) {
      print('Error checking leaderboard read permissions: $e');
      return false;
    }
  }

  // Check if user can write to leaderboards
  static Future<bool> canWriteLeaderboards(String userId, String teamId) async {
    try {
      return await isApprovedCoach(userId, teamId);
    } catch (e) {
      print('Error checking leaderboard write permissions: $e');
      return false;
    }
  }

  // DEPRECATED - Keep for backward compatibility
  @deprecated
  static Future<bool> isCoach(String userId, String teamId) async {
    return await isApprovedCoach(userId, teamId);
  }

  // Validate data integrity - overload untuk kompatibilitas
  static bool validateDataIntegrity(Map<String, dynamic> data, List<String> requiredFields) {
    try {
      // Validasi field yang diperlukan
      for (String field in requiredFields) {
        if (!data.containsKey(field) || data[field] == null) {
          return false;
        }
      }
      return true;
    } catch (e) {
      print('Error validating data integrity: $e');
      return false;
    }
  }

  // Method lama tetap ada untuk backward compatibility
  static bool validateDataIntegrityWithHash(Map<String, dynamic> data, String expectedHash) {
    try {
      final dataString = json.encode(data);
      final actualHash = hashData(dataString);
      return actualHash == expectedHash;
    } catch (e) {
      print('Error validating data integrity: $e');
      return false;
    }
  }

  // Sanitize input untuk Map
  static Map<String, dynamic> sanitizeInput(Map<String, dynamic> input) {
    Map<String, dynamic> sanitized = {};
    input.forEach((key, value) {
      if (value is String) {
        sanitized[key] = value
            .replaceAll('<', '')
            .replaceAll('>', '')
            .replaceAll('"', '')
            .replaceAll("'", '')
            .replaceAll(';', '')
            .replaceAll('\\', '')
            .replaceAll('[', '')
            .replaceAll(']', '');
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  // Sanitize input untuk String
  static String sanitizeStringInput(String input) {
    return input
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll(';', '')
        .replaceAll('\\', '')
        .replaceAll('[', '')
        .replaceAll(']', '');
  }

  // Rate limiting check
  static bool checkRateLimit(String identifier, {int maxRequests = 10, Duration window = const Duration(minutes: 1)}) {
    try {
      final now = DateTime.now();
      final windowStart = now.subtract(window);
      
      // Clean old entries
      _rateLimitMap[identifier]?.removeWhere((timestamp) => timestamp.isBefore(windowStart));
      
      // Initialize if not exists
      _rateLimitMap[identifier] ??= [];
      
      // Check if limit exceeded
      if (_rateLimitMap[identifier]!.length >= maxRequests) {
        return false;
      }
      
      // Add current request
      _rateLimitMap[identifier]!.add(now);
      return true;
    } catch (e) {
      print('Error checking rate limit: $e');
      return true; // Allow on error to prevent blocking legitimate users
    }
  }

  // Generate data hash for integrity checking
  static String generateDataHash(Map<String, dynamic> data) {
    try {
      final dataString = json.encode(data);
      return hashData(dataString);
    } catch (e) {
      print('Error generating data hash: $e');
      return '';
    }
  }

  // Enhanced permission validation with detailed logging
  static Future<bool> validatePermission(String userId, String action, String resourceId) async {
    try {
      // Log the permission check
      await logSecurityEvent(
        userId: userId,
        eventType: 'permission_check',
        description: 'Permission check for action: $action on resource: $resourceId',
      );

      bool hasPermission = false;

      switch (action) {
        case 'create_program':
        case 'update_program':
        case 'delete_program':
        case 'create_training_log':
        case 'update_training_log':
        case 'delete_training_log':
          hasPermission = await canWriteToTeamData(userId, resourceId);
          break;
        case 'manage_team_members':
        case 'approve_member':
        case 'reject_member':
          hasPermission = await canManageTeamMembers(userId, resourceId);
          break;
        case 'read_leaderboard':
          hasPermission = await canReadLeaderboards(userId, resourceId);
          break;
        case 'write_leaderboard':
          hasPermission = await canWriteLeaderboards(userId, resourceId);
          break;
        case 'view_team_data':
          hasPermission = await validateTeamAccess(userId, resourceId);
          break;
        default:
          hasPermission = false;
      }

      // Log the result
      await logSecurityEvent(
        userId: userId,
        eventType: hasPermission ? 'permission_granted' : 'permission_denied',
        description: 'Permission ${hasPermission ? 'granted' : 'denied'} for action: $action on resource: $resourceId',
        metadata: {'action': action, 'resourceId': resourceId},
      );

      return hasPermission;
    } catch (e) {
      print('Error validating permission: $e');
      // Log the error
      await logSecurityEvent(
        userId: userId,
        eventType: 'permission_error',
        description: 'Error validating permission for action: $action on resource: $resourceId - $e',
        metadata: {'action': action, 'resourceId': resourceId, 'error': e.toString()},
      );
      return false;
    }
  }

  // Validate write access to specific collections
  static Future<bool> validateWriteAccess({
    required String userId,
    required String teamId,
    required String collection,
  }) async {
    try {
      switch (collection) {
        case 'programs':
        case 'trainingLogs':
          return await canWriteToTeamData(userId, teamId);
        case 'members':
          return await canManageTeamMembers(userId, teamId);
        case 'leaderboards':
          return await canWriteLeaderboards(userId, teamId);
        default:
          return false;
      }
    } catch (e) {
      print('Error validating write access: $e');
      return false;
    }
  }
}