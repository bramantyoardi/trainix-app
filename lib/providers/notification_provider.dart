import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _notifications = [];
  bool _pushNotificationsEnabled = true;
  bool _reminderNotificationsEnabled = true;
  bool _teamNotificationsEnabled = true;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get reminderNotificationsEnabled => _reminderNotificationsEnabled;
  bool get teamNotificationsEnabled => _teamNotificationsEnabled;

  // Get unread notifications count
  int get unreadCount => _notifications.where((n) => !n['isRead']).length;

  // Add notification to local list
  void addNotification({
    required String title,
    required String body,
    String? payload,
    DateTime? timestamp,
  }) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'payload': payload,
      'timestamp': timestamp ?? DateTime.now(),
      'isRead': false,
    });
    notifyListeners();
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    notifyListeners();
  }

  // Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // Toggle push notifications
  void togglePushNotifications(bool enabled) {
    _pushNotificationsEnabled = enabled;
    notifyListeners();
  }

  // Toggle reminder notifications
  void toggleReminderNotifications(bool enabled) {
    _reminderNotificationsEnabled = enabled;
    notifyListeners();
  }

  // Toggle team notifications
  void toggleTeamNotifications(bool enabled) {
    _teamNotificationsEnabled = enabled;
    notifyListeners();
  }

  // Subscribe to team notifications
  Future<void> subscribeToTeam(String teamId) async {
    if (_teamNotificationsEnabled) {
      await NotificationService.subscribeToTopic('team_$teamId');
    }
  }

  // Unsubscribe from team notifications
  Future<void> unsubscribeFromTeam(String teamId) async {
    await NotificationService.unsubscribeFromTopic('team_$teamId');
  }

  // Schedule reminder notification
  Future<void> scheduleReminder({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (_reminderNotificationsEnabled) {
      final id = DateTime.now().millisecondsSinceEpoch;
      await NotificationService.scheduleReminderNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );
    }
  }

  // Cancel scheduled notification
  Future<void> cancelScheduledNotification(int notificationId) async {
    await NotificationService.cancelNotification(notificationId);
  }

  // Update FCM token
  Future<void> updateFCMToken(String userId) async {
    try {
      await NotificationService.updateFCMToken(userId);
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }
}