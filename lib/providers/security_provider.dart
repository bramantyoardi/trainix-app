import 'package:flutter/material.dart';
import '../services/security_service.dart';

class SecurityProvider with ChangeNotifier {
  List<Map<String, dynamic>> _securityLogs = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get securityLogs => _securityLogs;
  bool get isLoading => _isLoading;

  // Log security event
  Future<void> logSecurityEvent(String eventType, String description, {Map<String, dynamic>? metadata}) async {
    await SecurityService.logSecurityEvent(
      userId: 'current_user_id', // Ganti dengan user ID yang sebenarnya
      eventType: eventType,
      description: description,
      metadata: metadata,
    );
  }

  Future<void> loadUserSecurityLogs(String userId) async {
    try {
      _securityLogs = await SecurityService.getUserSecurityLogs(userId);
      notifyListeners();
    } catch (e) {
      print('Error loading security logs: $e');
    }
  }

  Future<bool> validateTeamAccess(String userId, String teamId) async {
    return await SecurityService.validateTeamAccess(userId, teamId);
  }

  Future<bool> isCoach(String userId, String teamId) async {
    return await SecurityService.isCoach(userId, teamId);
  }

  // Check rate limit
  bool checkRateLimit(String identifier, {int maxRequests = 10, Duration window = const Duration(minutes: 1)}) {
    return SecurityService.checkRateLimit(identifier, maxRequests: maxRequests, window: window);
  }

  // Perbaiki method signature
  bool validateDataIntegrity(Map<String, dynamic> data, List<String> requiredFields) {
    return SecurityService.validateDataIntegrity(data, requiredFields);
  }

  // Perbaiki return type
  Map<String, dynamic> sanitizeInput(Map<String, dynamic> input) {
    return SecurityService.sanitizeInput(input);
  }
}