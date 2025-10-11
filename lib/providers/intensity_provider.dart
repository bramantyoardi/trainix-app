import 'package:flutter/material.dart';
import '../models/training_intensity.dart';
import '../services/intensity_service.dart';
import '../services/leaderboard_service.dart';

class IntensityProvider extends ChangeNotifier {
  final IntensityService _intensityService = IntensityService();
  final LeaderboardService _leaderboardService = LeaderboardService();

  List<TrainingIntensity> _intensities = [];
  bool _isLoading = false;

  List<TrainingIntensity> get intensities => _intensities;
  bool get isLoading => _isLoading;

  // Mendapatkan semua intensitas latihan untuk program tertentu
  void loadProgramIntensities(String programId) {
    _isLoading = true;
    notifyListeners();

    try {
      _intensityService.getProgramIntensities(programId).listen((intensities) {
        _intensities = intensities;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      print('Error loading program intensities: $e');
      notifyListeners();
    }
  }

  // Mendapatkan intensitas latihan untuk atlet tertentu
  void loadAthleteIntensities(String athleteId) {
    _isLoading = true;
    notifyListeners();

    try {
      _intensityService.getAthleteIntensities(athleteId).listen((intensities) {
        _intensities = intensities;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      print('Error loading athlete intensities: $e');
      notifyListeners();
    }
  }

  // Membuat intensitas latihan baru
  Future<bool> createIntensity(TrainingIntensity intensity, String athleteName,
      String? athletePhotoUrl) async {
    _isLoading = true;
    notifyListeners();

    try {
      final intensityId = await _intensityService.createIntensity(intensity);

      if (intensityId != null) {
        // Update leaderboard
        await _leaderboardService.addLeaderboardEntry(
          intensity.teamId,
          intensity.athleteId,
          athleteName,
          athletePhotoUrl,
          intensity.intensityScore.round(), // Convert double to int
        );

        // Refresh daftar intensitas
        loadProgramIntensities(intensity.programId);
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      print('Error creating intensity: $e');
      notifyListeners();
      return false;
    }
  }

  // Mendapatkan rata-rata intensitas latihan untuk atlet tertentu
  Future<double> getAverageIntensity(String athleteId) async {
    try {
      return await _intensityService.getAverageIntensity(athleteId);
    } catch (e) {
      print('Error getting average intensity: $e');
      return 0.0;
    }
  }
}
