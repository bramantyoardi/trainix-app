import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardService _leaderboardService = LeaderboardService();

  List<LeaderboardEntry> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LeaderboardEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Perbaiki loadTeamLeaderboard dengan error handling
  void loadTeamLeaderboard(String teamId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _leaderboardService.getTeamLeaderboard(teamId).listen((entries) {
        _entries = entries;
        _isLoading = false;
        notifyListeners();
        print('Loaded ${entries.length} leaderboard entries for team $teamId');
      }, onError: (error) {
        _errorMessage = 'Gagal memuat leaderboard: $error';
        _isLoading = false;
        print('Error loading team leaderboard: $error');
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Gagal memuat leaderboard: $e';
      _isLoading = false;
      print('Error setting up leaderboard stream: $e');
      notifyListeners();
    }
  }

  // Tambah fungsi refresh manual
  Future<void> refreshLeaderboard(String teamId) async {
    try {
      final entries =
          await _leaderboardService.getTeamLeaderboard(teamId).first;
      _entries = entries;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal refresh leaderboard: $e';
      print('Error refreshing leaderboard: $e');
      notifyListeners();
    }
  }

  // Tambah fungsi untuk update skor secara manual
  Future<void> updateAthleteScore(String teamId, String athleteId,
      String athleteName, String? photoUrl, int score) async {
    try {
      await _leaderboardService.addLeaderboardEntry(
          teamId, athleteId, athleteName, photoUrl, score);
      // Refresh leaderboard setelah update
      refreshLeaderboard(teamId);
    } catch (e) {
      print('Error updating athlete score: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
