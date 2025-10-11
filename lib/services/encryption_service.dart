import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static final Random _random = Random.secure();
  static const String _key = 'trainix_encryption_key_2024';
  
  // Simple XOR encryption for demonstration
  // In production, use proper encryption libraries
  static String _xorEncrypt(String data, String key) {
    try {
      List<int> dataBytes = utf8.encode(data);
      List<int> keyBytes = utf8.encode(key);
      List<int> encrypted = [];
      
      for (int i = 0; i < dataBytes.length; i++) {
        encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return base64.encode(encrypted);
    } catch (e) {
      print('Error in XOR encryption: $e');
      return data;
    }
  }

  static String _xorDecrypt(String encryptedData, String key) {
    try {
      List<int> encryptedBytes = base64.decode(encryptedData);
      List<int> keyBytes = utf8.encode(key);
      List<int> decrypted = [];
      
      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      print('Error in XOR decryption: $e');
      return encryptedData;
    }
  }

  // Instance methods for invite code encryption/decryption
  String encryptInviteCode(String teamId) {
    try {
      final key = 'trainix_team_key_2024';
      return _xorEncrypt(teamId, key);
    } catch (e) {
      print('Error encrypting invite code: $e');
      return teamId;
    }
  }

  String? decryptInviteCode(String encryptedCode) {
    try {
      final key = 'trainix_team_key_2024';
      return _xorDecrypt(encryptedCode, key);
    } catch (e) {
      print('Error decrypting invite code: $e');
      return null;
    }
  }

  // Static utility methods
  static String hashData(String data) {
    try {
      var bytes = utf8.encode(data);
      var digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      print('Error hashing data: $e');
      return data;
    }
  }

  static String generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(_random.nextInt(chars.length))
    ));
  }

  static String generateTeamCode() {
    return generateRandomString(6);
  }

  static bool isValidTeamCode(String code) {
    return code.length == 6 && RegExp(r'^[A-Z0-9]+$').hasMatch(code);
  }

  static String encryptUserData(String data, String userId) {
    try {
      final key = 'trainix_user_${userId.substring(0, 8)}';
      return _xorEncrypt(data, key);
    } catch (e) {
      print('Error encrypting user data: $e');
      return data;
    }
  }

  static String decryptUserData(String encryptedData, String userId) {
    try {
      final key = 'trainix_user_${userId.substring(0, 8)}';
      return _xorDecrypt(encryptedData, key);
    } catch (e) {
      print('Error decrypting user data: $e');
      return encryptedData;
    }
  }

  // Instance methods for user profile encryption/decryption
  Map<String, dynamic>? decryptUserProfile(Map<String, dynamic> encryptedData) {
    try {
      final decryptedData = <String, dynamic>{};
      
      for (final entry in encryptedData.entries) {
        if (entry.value is String) {
          decryptedData[entry.key] = _xorDecrypt(entry.value, _key);
        } else {
          decryptedData[entry.key] = entry.value;
        }
      }
      
      return decryptedData;
    } catch (e) {
      print('Error decrypting user profile: $e');
      return null;
    }
  }

  Map<String, dynamic>? encryptUserProfile(Map<String, dynamic> userData) {
    try {
      final encryptedData = <String, dynamic>{};
      
      for (final entry in userData.entries) {
        if (entry.value is String) {
          encryptedData[entry.key] = _xorEncrypt(entry.value, _key);
        } else {
          encryptedData[entry.key] = entry.value;
        }
      }
      
      return encryptedData;
    } catch (e) {
      print('Error encrypting user profile: $e');
      return null;
    }
  }
}