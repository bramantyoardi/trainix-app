import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/team.dart';
import '../models/user_team_role.dart';
import '../services/team_service.dart';
import '../services/firestore_service.dart';

class TeamProvider extends ChangeNotifier {
  final TeamService _teamService = TeamService(FirestoreService());
  
  List<Team> _teams = [];
  List<UserTeamRole> _userTeamRoles = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Team> get teams => _teams;
  List<UserTeamRole> get userTeamRoles => _userTeamRoles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Getter untuk currentTeam yang dipakai UI
  Team? get currentTeam => _teams.isNotEmpty ? _teams.first : null;

  // Load user teams
  Future<void> loadUserTeams() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _teamService.getUserTeams(user.uid).listen((userTeamRoles) {
        // Convert UserTeamRole list to Team list
        _teams = userTeamRoles.map((role) => role.team).toList();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Failed to load teams: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new team
  Future<bool> createTeam(Team team) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final teamId = await _teamService.createTeam(team, user.uid);
      if (teamId != null) {
        // Add to local list with the new ID
        final newTeam = team.copyWith(id: teamId);
        _teams.add(newTeam);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create team: $e';
      notifyListeners();
      return false;
    }
  }

  // Join team by invite code
  Future<bool> joinTeamByInviteCode(String inviteCode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final success = await _teamService.joinTeamByInviteCode(user.uid, inviteCode);
      if (success) {
        // Refresh teams list
        await loadUserTeams();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to join team: $e';
      notifyListeners();
      return false;
    }
  }

  // Leave team
  Future<bool> leaveTeam(String teamId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final success = await _teamService.leaveTeam(teamId, user.uid);
      if (success) {
        _teams.removeWhere((team) => team.id == teamId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to leave team: $e';
      notifyListeners();
      return false;
    }
  }

  // Update team
  Future<bool> updateTeam(String teamId, Map<String, dynamic> data) async {
    try {
      final success = await _teamService.updateTeam(teamId, data);
      if (success) {
        // Update local list
        final index = _teams.indexWhere((team) => team.id == teamId);
        if (index != -1) {
          // Reload the updated team
          final updatedTeam = await _teamService.getTeam(teamId);
          if (updatedTeam != null) {
            _teams[index] = updatedTeam;
            notifyListeners();
          }
        }
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update team: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete team
  Future<bool> deleteTeam(String teamId) async {
    try {
      final success = await _teamService.deleteTeam(teamId);
      if (success) {
        _teams.removeWhere((team) => team.id == teamId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete team: $e';
      notifyListeners();
      return false;
    }
  }

  // Get team by ID
  Team? getTeamById(String teamId) {
    try {
      return _teams.firstWhere((team) => team.id == teamId);
    } catch (e) {
      return null;
    }
  }

  // Get user role in team
  String? getUserRoleInTeam(String teamId) {
    try {
      final userTeamRole = _userTeamRoles.firstWhere((role) => role.team.id == teamId);
      return userTeamRole.role;
    } catch (e) {
      return null;
    }
  }

  // Check if user is coach
  bool isUserCoach(String teamId) {
    return getUserRoleInTeam(teamId) == 'coach';
  }

  // Check if user is athlete
  bool isUserAthlete(String teamId) {
    return getUserRoleInTeam(teamId) == 'athlete';
  }

  // Get team members
  Future<List<Map<String, dynamic>>> getTeamMembers(String teamId) async {
    try {
      return await _teamService.getTeamMembers(teamId);
    } catch (e) {
      _errorMessage = 'Failed to get team members: $e';
      notifyListeners();
      return [];
    }
  }

  // Generate invite code
  Future<String?> generateInviteCode(String teamId) async {
    try {
      return await _teamService.generateInviteCode(teamId);
    } catch (e) {
      _errorMessage = 'Failed to generate invite code: $e';
      notifyListeners();
      return null;
    }
  }

  // Load training logs for team
  Future<void> loadTrainingLogs(String teamId) async {
    try {
      // This method might be used by UI, implement as needed
      // For now, just a placeholder
    } catch (e) {
      _errorMessage = 'Failed to load training logs: $e';
      notifyListeners();
    }
  }
  // Update member status - FIXED WITH NAMED PARAMETERS
  Future<bool> updateMemberStatus({
    required String teamId, 
    required String userId, 
    required String status,
    String? approvedBy
  }) async {
    try {
      return await _teamService.updateMemberStatus(
        teamId: teamId, 
        userId: userId, 
        status: status,
        approvedBy: approvedBy
      );
    } catch (e) {
      _errorMessage = 'Failed to update member status: $e';
      notifyListeners();
      return false;
    }
  }

  // Remove member - FIXED WITH NAMED PARAMETERS
  Future<bool> removeMember({required String teamId, required String userId}) async {
    try {
      return await _teamService.removeMember(teamId: teamId, userId: userId);
    } catch (e) {
      _errorMessage = 'Failed to remove member: $e';
      notifyListeners();
      return false;
    }
  }

  // Change member role - FIXED WITH NAMED PARAMETERS
  Future<bool> changeMemberRole({
    required String teamId, 
    required String userId, 
    required String newRole
  }) async {
    try {
      return await _teamService.changeMemberRole(
        teamId: teamId, 
        userId: userId, 
        newRole: newRole
      );
    } catch (e) {
      _errorMessage = 'Failed to change member role: $e';
      notifyListeners();
      return false;
    }
  }

  // Check if user is coach in team - FIXED WITH NAMED PARAMETERS
  Future<bool> isCoachInTeam({required String teamId, required String userId}) async {
    try {
      return await _teamService.isCoachInTeam(teamId: teamId, userId: userId);
    } catch (e) {
      return false;
    }
  }

  // Get team by code
  Future<Team?> getTeamByCode(String teamCode) async {
    try {
      return await _teamService.getTeamByCode(teamCode);
    } catch (e) {
      _errorMessage = 'Failed to get team by code: $e';
      notifyListeners();
      return null;
    }
  }

  // Join team by code
  Future<bool> joinTeamByCode(String teamCode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final success = await _teamService.joinTeamByCode(user.uid, teamCode);
      if (success) {
        await loadUserTeams();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to join team by code: $e';
      notifyListeners();
      return false;
    }
  }

  // Clear teams
  void clearTeams() {
    _teams.clear();
    _userTeamRoles.clear();
    notifyListeners();
  }

  // Refresh teams
  Future<void> refreshTeams() async {
    await loadUserTeams();
  }

  // Remove team from local list
  void removeTeam(String teamId) {
    _teams.removeWhere((team) => team.id == teamId);
    _userTeamRoles.removeWhere((role) => role.team.id == teamId);
    notifyListeners();
  }
  List<UserTeamRole> _teamMembers = <UserTeamRole>[];
  List<UserTeamRole> get teamMembers => _teamMembers;

  Future<void> loadTeamMembers(String teamId) async {
    _teamMembers = await _teamService.getTeamMembers(teamId: teamId);
    notifyListeners();
  }

  Future<bool> joinTeamByInviteCode(String inviteCode, String userId) async {
    return await _teamService.joinTeamByInviteCode(
      inviteCode: inviteCode, userId: userId,
    );
  }

  Future<bool> joinTeamByCode(String teamCode, String userId) async {
    return await _teamService.joinTeamByCode(
      teamCode: teamCode, userId: userId,
    );
  }
  // Fix getTeamMembers to return Future<List<UserTeamRole>>
  Future<List<UserTeamRole>> getTeamMembers(String teamId) async {
    try {
      return await _teamService.getTeamMembers(teamId: teamId);
    } catch (e) {
      _errorMessage = 'Failed to get team members: $e';
      notifyListeners();
      return [];
    }
  }
}