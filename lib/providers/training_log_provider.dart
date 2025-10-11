import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/training_log.dart';
import '../services/training_log_service.dart';

class TrainingLogProvider with ChangeNotifier {
  final TrainingLogService _svc = TrainingLogService();

  List<TrainingLog> _logs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TrainingLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Updated to use Stream from service
  void loadLogsByTeam(String teamId) {
    _isLoading = true; 
    _errorMessage = null; 
    notifyListeners();
    
    _svc.getTeamTrainingLogs(teamId).listen(
      (logs) {
        _logs = logs;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Failed to load training logs: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Updated to use Stream from service
  void loadLogsByProgram(String programId) {
    _isLoading = true; 
    _errorMessage = null; 
    notifyListeners();
    
    _svc.getProgramTrainingLogs(programId).listen(
      (logs) {
        _logs = logs;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Failed to load training logs: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Updated to use Stream from service
  // Fix: Change async Stream method to return Future
  Future<List<TrainingLog>> getTrainingLogsByDateRange(
      String teamId, DateTime start, DateTime end) async {
    final teamLogs = await _svc.getTeamTrainingLogs(teamId).first;
    return teamLogs.where((log) {
      final d = log.date.toDate();
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();
  }

  // Fix: Change async Stream method to return Future
  Future<List<TrainingLog>> getTrainingLogsByAthlete(
      String teamId, String athleteId) async {
    final teamLogs = await _svc.getTeamTrainingLogs(teamId).first;
    return teamLogs.where((l) => l.athleteId == athleteId).toList();
  }

  // Updated to use Stream from service
  void filterTrainingLogsByDateRange(
      String programId, DateTime start, DateTime end) {
    _svc.getProgramTrainingLogs(programId).listen(
      (programLogs) {
        _logs = programLogs.where((log) {
          final d = log.date.toDate();
          return !d.isBefore(start) && !d.isAfter(end);
        }).toList();
        notifyListeners();
      },
    );
  }

  // Fix: Remove async from void method
  void getTrainingLogsByHRRBand(String programId, int band) {
    _loadLogsByHRRBand(programId, band);
  }

  // Fix: Correct the async method call
  Future<void> _loadLogsByHRRBand(String programId, int band) async {
    final programLogs = await _svc.getProgramTrainingLogs(programId).first;
    _logs = programLogs.where((log) {
      final data = log.data;
      final v = data['hrrBand'] ?? data['hrr_band'] ?? data['hrr'] ?? data['band'];
      if (v is int) return v == band;
      if (v is String) return v == 'hrr$band' || v == '$band';
      return false;
    }).toList();
    notifyListeners();
  }

  Future<bool> createTrainingLogWithHRR({
    required String teamId,
    required String programId,
    required String athleteId,
    required String inputBy,
    required int age,
    required int hrRest,
    required int hrAvg,
    required int hrPeak,
    required int totalMinutes,
    required String category,
    required String type,
  }) async {
    try {
      final data = <String, dynamic>{
        'age': age,
        'restingHR': hrRest,
        'avgHR': hrAvg,
        'peakHR': hrPeak,
        'minutes': totalMinutes,
        'category': category,
        'type': type,
      };

      final log = TrainingLog(
        id: '',
        athleteId: athleteId,
        teamId: teamId,
        programId: programId,
        category: category,
        preset: type,
        data: data,
        date: Timestamp.now(),
        inputBy: inputBy,
        score: hrAvg.toDouble(),
        userRole: 'coach',
        notes: '',
        isCompleted: true,
      );

      final id = await _svc.createTrainingLog(log);
      await loadLogsByProgram(programId);
      return id.isNotEmpty;
    } catch (e) {
      _errorMessage = 'Failed to create training log: $e';
      notifyListeners();
      return false;
    }
  }

  List<TrainingLog> getLogsByAthlete(String athleteId) =>
      _logs.where((l) => l.athleteId == athleteId).toList();

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  // Fix: Change loadLogsByProgram to async for consistency
  // Add getter for trainingLogs
  List<TrainingLog> get trainingLogs => _logs;
  
  // Remove duplicate loadLogsByProgram - keep only one
  Future<void> loadLogsByProgram(String programId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  
    try {
      final logs = await _svc.getProgramTrainingLogs(programId).first;
      _logs = logs;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load training logs: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}