import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderService _reminderService = ReminderService();
  
  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load reminders by team
  Future<void> loadRemindersByTeam(String teamId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reminderService.getTeamReminders(teamId).listen((reminders) {
        _reminders = reminders;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Failed to load reminders: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new reminder with Map data
  Future<bool> createReminder(Map<String, dynamic> data) async {
    try {
      await _reminderService.createReminder(data: data);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create reminder: $e';
      notifyListeners();
      return false;
    }
  }

  // Update reminder
  Future<bool> updateReminder(String reminderId, Map<String, dynamic> data) async {
    try {
      final success = await _reminderService.updateReminder(
        reminderId: reminderId, 
        data: data
      );
      if (success) {
        // Update local list
        final index = _reminders.indexWhere((r) => r.id == reminderId);
        if (index != -1) {
          // Reload the updated reminder
          final updatedReminder = await _reminderService.getReminder(reminderId);
          if (updatedReminder != null) {
            _reminders[index] = updatedReminder;
            notifyListeners();
          }
        }
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update reminder: $e';
      notifyListeners();
      return false;
    }
  }

  // Mark reminder as read
  Future<bool> markAsRead(String reminderId) async {
    try {
      final result = await _reminderService.updateReminder(
        reminderId: reminderId, 
        data: {'isCompleted': true}
      );
      if (result) {
        // Update local list
        final index = _reminders.indexWhere((r) => r.id == reminderId);
        if (index != -1) {
          _reminders[index] = _reminders[index].copyWith(isCompleted: true);
          notifyListeners();
        }
      }
      return result;
    } catch (e) {
      _errorMessage = 'Failed to mark reminder as read: $e';
      notifyListeners();
      return false;
    }
  }

  // Update reminder
  Future<bool> updateReminder(String reminderId, Map<String, dynamic> data) async {
    try {
      final success = await _reminderService.updateReminder(
        reminderId: reminderId, 
        data: data
      );
      if (success) {
        // Update local list
        final index = _reminders.indexWhere((r) => r.id == reminderId);
        if (index != -1) {
          // Reload the updated reminder
          final updatedReminder = await _reminderService.getReminder(reminderId);
          if (updatedReminder != null) {
            _reminders[index] = updatedReminder;
            notifyListeners();
          }
        }
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update reminder: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete reminder
  Future<bool> deleteReminder(String reminderId) async {
    try {
      final success = await _reminderService.deleteReminder(reminderId);
      if (success) {
        _reminders.removeWhere((r) => r.id == reminderId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete reminder: $e';
      notifyListeners();
      return false;
    }
  }

  // Get unread reminders count
  int get unreadCount {
    return _reminders.where((r) => !r.isCompleted).length;
  }

  // Get today's reminders
  List<Reminder> get todayReminders {
    final today = DateTime.now();
    return _reminders.where((r) {
      final reminderDate = r.dateTime.toDate();
      return reminderDate.year == today.year &&
             reminderDate.month == today.month &&
             reminderDate.day == today.day;
    }).toList();
  }

  // Get upcoming reminders (next 7 days)
  List<Reminder> get upcomingReminders {
    final now = DateTime.now();
    final nextWeek = now.add(Duration(days: 7));
    
    return _reminders.where((r) {
      final reminderDate = r.dateTime.toDate();
      return reminderDate.isAfter(now) && reminderDate.isBefore(nextWeek);
    }).toList();
  }

  // Get overdue reminders
  List<Reminder> get overdueReminders {
    final now = DateTime.now();
    return _reminders.where((r) {
      final reminderDate = r.dateTime.toDate();
      return reminderDate.isBefore(now) && !r.isCompleted;
    }).toList();
  }

  // Get reminders by athlete
  List<Reminder> getRemindersByAthlete(String athleteId) {
    return _reminders.where((r) => r.athleteId == athleteId).toList();
  }

  // Get reminders by status
  List<Reminder> getRemindersByStatus(String status) {
    return _reminders.where((r) => r.status == status).toList();
  }

  // Search reminders
  List<Reminder> searchReminders(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _reminders.where((r) {
      return r.title.toLowerCase().contains(lowercaseQuery) ||
             r.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Clear all reminders
  void clearReminders() {
    _reminders.clear();
    notifyListeners();
  }

  // Refresh reminders
  Future<void> refreshReminders(String teamId) async {
    await loadRemindersByTeam(teamId);
  }

  // Add missing updateReminderStatus method
  // Fix updateReminderStatus to pass String instead of bool
  Future<bool> updateReminderStatus(String reminderId, String status) async {
    try {
      final success = await _reminderService.updateReminderStatus(reminderId, status);
      if (success) {
        // Update local state
        final index = _reminders.indexWhere((r) => r.id == reminderId);
        if (index != -1) {
          _reminders[index] = _reminders[index].copyWith(
            status: status,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update reminder status: $e';
      notifyListeners();
      return false;
    }
  }

  // Remove duplicate updateReminder method - keep only this one
  Future<void> updateReminder(String reminderId, Map<String, dynamic> data) async {
    await _reminderService.updateReminder(reminderId: reminderId, data: data);
  }

  // Add createReminder method that accepts Map<String, dynamic>
  Future<void> createReminder(Map<String, dynamic> data) async {
    await _reminderService.createReminder(data: data);
  }

  // Add missing methods for team and athlete reminders
  Future<void> loadTeamReminders(String teamId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reminderService.getTeamReminders(teamId).listen((reminders) {
        _reminders = reminders;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Failed to load team reminders: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAthleteReminders(String athleteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reminderService.getAthleteReminders(athleteId).listen((reminders) {
        _reminders = reminders;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Failed to load athlete reminders: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add overloaded updateReminder method for Reminder objects
  Future<bool> updateReminder(Reminder reminder) async {
    try {
      final success = await _reminderService.updateReminder(
        reminderId: reminder.id, 
        data: reminder.toJson()
      );
      if (success) {
        // Update local list
        final index = _reminders.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          _reminders[index] = reminder;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update reminder: $e';
      notifyListeners();
      return false;
    }
  }
}