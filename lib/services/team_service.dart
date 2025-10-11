import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team.dart';
import '../models/user_team_role.dart';
import 'firestore_service.dart';
import 'encryption_service.dart';

class TeamService {
  final FirestoreService _firestoreService;
  final EncryptionService _encryptionService = EncryptionService();

  TeamService(this._firestoreService);
  final String _teamCollection = 'teams';

  // Mendapatkan tim berdasarkan ID
  Future<Team?> getTeam(String teamId) async {
    try {
      final data = await _firestoreService.getDocument(_teamCollection, teamId);
      if (data != null) {
        data['id'] = teamId;
        return Team.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting team: $e');
      return null;
    }
  }

  // Membuat tim baru
  Future<String?> createTeam(Team team, String creatorUserId) async {
    try {
      print('Debug TeamService: Converting team to JSON...');
      final teamData = team.toJsonForFirestore();
      print('Debug TeamService: Team data: $teamData');

      print('Debug TeamService: Adding document to Firestore...');
      DocumentReference docRef = await _firestoreService.addDocument(
        _teamCollection,
        teamData,
      );

      print('Debug TeamService: Document created with ID: ${docRef.id}');

      // Create owner membership in subcollection
      await _createOwnerMembership(docRef.id, creatorUserId);

      return docRef.id;
    } catch (e) {
      print('Debug TeamService: Error creating team: $e');
      return null;
    }
  }

  // Create owner membership in subcollection
  Future<void> _createOwnerMembership(String teamId, String userId) async {
    try {
      final memberData = {
        'userId': userId,
        'role': 'Coach',
        'status': 'approved',
        'isOwner': true,
        'approvedBy': userId,
        'dateJoined': FieldValue.serverTimestamp(),
        'joinedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      await FirebaseFirestore.instance
          .collection(_teamCollection)
          .doc(teamId)
          .collection('members')
          .doc(userId)
          .set(memberData);

      print('Owner membership created for team $teamId, user $userId');
    } catch (e) {
      print('Error creating owner membership: $e');
      throw e;
    }
  }

  // Memperbarui tim
  Future<bool> updateTeam(String teamId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(_teamCollection, teamId, data);
      return true;
    } catch (e) {
      print('Error updating team: $e');
      return false;
    }
  }

  // Menghapus tim
  Future<bool> deleteTeam(String teamId) async {
    try {
      await _firestoreService.deleteDocument(_teamCollection, teamId);
      return true;
    } catch (e) {
      print('Error deleting team: $e');
      return false;
    }
  }

  // Mendapatkan semua tim
  Future<List<Team>> getAllTeams() async {
    try {
      final docs = await _firestoreService.getCollection(_teamCollection);
      return docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Team.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting all teams: $e');
      return [];
    }
  }

  // Mendapatkan tim berdasarkan pembuat
  Stream<List<Team>> getTeamsByCreator(String creatorId) {
    return _firestoreService
        .getFilteredCollection(_teamCollection, 'createdBy', creatorId)
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Team.fromJson(data);
      }).toList();
    });
  }

  // STANDARDIZED API METHODS WITH NAMED PARAMETERS

  // Join team by code - FIXED WITH NAMED PARAMETERS
  Future<String?> joinTeamByCode(
      {required String teamCode, required String userId}) async {
    try {
      final team = await getTeamByCode(teamCode);
      if (team == null) return null;

      final existingMember = await FirebaseFirestore.instance
          .collection(_teamCollection)
          .doc(team.id)
          .collection('members')
          .doc(userId)
          .get();

      if (existingMember.exists) {
        return 'already_member';
      }

      final memberData = {
        'userId': userId,
        'role': 'Athlete',
        'status': 'pending',
        'isOwner': false,
        'joinedAt': FieldValue.serverTimestamp(),
        'isActive': false,
      };

      await FirebaseFirestore.instance
          .collection(_teamCollection)
          .doc(team.id)
          .collection('members')
          .doc(userId)
          .set(memberData);

      return userId;
    } catch (e) {
      print('Error joining team: $e');
      return null;
    }
  }

  // Check if user is coach in team - FIXED WITH NAMED PARAMETERS
  Future<bool> isCoachInTeam(
      {required String teamId, required String userId}) async {
    try {
      final memberDoc = await FirebaseFirestore.instance
          .collection(_teamCollection)
          .doc(teamId)
          .collection('members')
          .doc(userId)
          .get();

      if (memberDoc.exists) {
        final data = memberDoc.data()!;
        return data['role'] == 'Coach' && data['status'] == 'approved';
      }
      return false;
    } catch (e) {
      print('Error checking coach status: $e');
      return false;
    }
  }

  // Update member status - SINGLE IMPLEMENTATION WITH NAMED PARAMETERS
  Future<bool> updateMemberStatus(
      {required String teamId,
      required String userId,
      required String status,
      String? approvedBy}) async {
    try {
      final updateData = <String, dynamic>{
        'isActive': status == 'approved',
        'status': status,
      };

      if (status == 'approved' && approvedBy != null) {
        updateData['approvedBy'] = approvedBy;
        updateData['dateJoined'] = FieldValue.serverTimestamp();
        print(
            'Member approved: userId=$userId, teamId=$teamId, approvedBy=$approvedBy');
      } else if (status == 'rejected' && approvedBy != null) {
        updateData['approvedBy'] = approvedBy;
        updateData['dateJoined'] = null;
        print(
            'Member rejected: userId=$userId, teamId=$teamId, rejectedBy=$approvedBy');
      }

      await FirebaseFirestore.instance
          .collection(_teamCollection)
          .doc(teamId)
          .collection('members')
          .doc(userId)
          .update(updateData);

      return true;
    } catch (e) {
      print('Error updating member status: $e');
      return false;
    }
  }

  // Remove member - SINGLE IMPLEMENTATION WITH NAMED PARAMETERS
  Future<bool> removeMember(
      {required String teamId, required String userId}) async {
    try {
      await FirebaseFirestore.instance
          .collection(_teamCollection)
          .doc(teamId)
          .collection('members')
          .doc(userId)
          .delete();
      return true;
    } catch (e) {
      print('Error removing member: $e');
      return false;
    }
  }

  // Change member role - WITH NAMED PARAMETERS
  Future<bool> changeMemberRole(
      {required String teamId,
      required String userId,
      required String newRole}) async {
    try {
      await FirebaseFirestore.instance
          .collection(_teamCollection)
          .doc(teamId)
          .collection('members')
          .doc(userId)
          .update({'role': newRole});
      return true;
    } catch (e) {
      print('Error changing member role: $e');
      return false;
    }
  }

  // Fix getTeamMembers to return Future<List<UserTeamRole>>
  Future<List<UserTeamRole>> getTeamMembers({required String teamId}) async {
    final snap = await _firestoreService.getCollection('teams/$teamId/members');
    
    return snap.docs.map((d) {
      final data = d.data();
      return UserTeamRole.fromJson({...data, 'id': d.id});
    }).toList();
  }

  Future<bool> joinTeamByCode({required String teamCode, required String userId}) async {
    final q = await _firestoreService.queryCollection(
      'teams',
      field: 'code',
      isEqualTo: teamCode,
      limit: 1
    );
    
    if (q.docs.isEmpty) return false;
    final teamId = q.docs.first.id;
    // ... tulis membership
    return true;
  }

  Future<bool> joinTeamByInviteCode({required String inviteCode, required String userId}) async {
    final q = await _firestoreService.queryCollection(
      'teams',
      field: 'inviteCode',
      isEqualTo: inviteCode,
      limit: 1
    );
    
    if (q.docs.isEmpty) return false;
    final teamId = q.docs.first.id;
    // ... tulis membership
    return true;
  }

  // Get user teams
  Stream<List<UserTeamRole>> getUserTeams(String userId) {
    return FirebaseFirestore.instance
        .collectionGroup('members')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<UserTeamRole> userTeams = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;

        // Extract teamId from document reference path
        final pathSegments = doc.reference.path.split('/');
        final teamId = pathSegments[pathSegments.length - 3];
        data['teamId'] = teamId;

        // Get team details
        final team = await getTeam(teamId);
        data['team'] = team?.toJson();

        userTeams.add(UserTeamRole.fromJson(data));
      }

      return userTeams;
    });
  }

  // Get team by code
  Future<Team?> getTeamByCode(String teamCode) async {
    try {
      QuerySnapshot querySnapshot = await _firestoreService
          .getFilteredCollection(_teamCollection, 'teamCode', teamCode)
          .first;

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Team.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting team by code: $e');
      return null;
    }
  }

  // Utility methods

  Future<Map<String, dynamic>?> joinTeamByInviteCode(
      String userId, String inviteCode) async {
    try {
      final teamId = _encryptionService.decryptInviteCode(inviteCode);
      if (teamId == null) {
        throw Exception('Invalid invite code');
      }

      final teamDoc = await _firestoreService.getDocument('teams', teamId);
      if (teamDoc == null) {
        throw Exception('Team not found');
      }

      await _createMembership(userId, teamId, 'athlete');

      return {'success': true, 'teamId': teamId};
    } catch (e) {
      print('Error joining team: $e');
      return null;
    }
  }

  Future<bool> leaveTeam(String userId, String teamId) async {
    try {
      await FirebaseFirestore.instance
          .collection(_teamCollection)
          .doc(teamId)
          .collection('members')
          .doc(userId)
          .delete();
      return true;
    } catch (e) {
      print('Error leaving team: $e');
      return false;
    }
  }

  Future<String?> getUserRoleInTeam(String userId, String teamId) async {
    try {
      final memberDoc = await FirebaseFirestore.instance
          .collection(_teamCollection)
          .doc(teamId)
          .collection('members')
          .doc(userId)
          .get();

      if (memberDoc.exists) {
        return memberDoc.data()!['role'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  Future<String?> generateInviteCode(String teamId) async {
    try {
      return _encryptionService.encryptInviteCode(teamId);
    } catch (e) {
      print('Error generating invite code: $e');
      return null;
    }
  }

  Future<Team?> getTeamByInviteCode(String inviteCode) async {
    try {
      final teamId = _encryptionService.decryptInviteCode(inviteCode);
      if (teamId != null) {
        return await getTeam(teamId);
      }
      return null;
    } catch (e) {
      print('Error getting team by invite code: $e');
      return null;
    }
  }

  Future<void> _createMembership(
      String userId, String teamId, String role) async {
    try {
      await FirebaseFirestore.instance
          .collection(_teamCollection)
          .doc(teamId)
          .collection('members')
          .doc(userId)
          .set({
        'userId': userId,
        'role': role,
        'joinedAt': Timestamp.now(),
        'isActive': true,
        'status': 'approved',
        'isOwner': false,
      });
    } catch (e) {
      print('Error creating membership: $e');
      rethrow;
    }
  }
}
