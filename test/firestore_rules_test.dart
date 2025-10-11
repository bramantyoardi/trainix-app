import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

// Note: These tests require Firebase emulator to be running
// Run: firebase emulators:start --only firestore,auth

void main() {
  group('Firestore Security Rules Tests', () {
    late FirebaseFirestore firestore;
    late FirebaseAuth auth;

    setUpAll(() async {
      // Initialize Firebase for testing
      await Firebase.initializeApp();
      
      // Connect to emulators
      firestore = FirebaseFirestore.instance;
      auth = FirebaseAuth.instance;
      
      // Use emulator
      firestore.useFirestoreEmulator('localhost', 8080);
      await auth.useAuthEmulator('localhost', 9099);
    });

    setUp(() async {
      // Clear all data before each test
      await _clearFirestore();
    });

    group('Team Programs Access Control', () {
      test('should allow approved coach to write programs', () async {
        // Arrange
        const teamId = 'test-team-1';
        const coachId = 'coach-user-1';
        
        // Create coach user and sign in
        final coachCredential = await auth.createUserWithEmailAndPassword(
          email: 'coach@test.com',
          password: 'password123',
        );
        
        // Set up team membership
        await firestore
            .collection('teams')
            .doc(teamId)
            .collection('members')
            .doc(coachId)
            .set({
          'role': 'Coach',
          'status': 'approved',
          'isActive': true,
          'isOwner': false,
        });

        // Act & Assert
        expect(() async {
          await firestore
              .collection('teams')
              .doc(teamId)
              .collection('programs')
              .add({
            'name': 'Test Program',
            'description': 'Test Description',
            'createdBy': coachId,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }, returnsNormally);
      });

      test('should deny athlete write access to programs', () async {
        // Arrange
        const teamId = 'test-team-1';
        const athleteId = 'athlete-user-1';
        
        // Create athlete user and sign in
        await auth.createUserWithEmailAndPassword(
          email: 'athlete@test.com',
          password: 'password123',
        );
        
        // Set up team membership
        await firestore
            .collection('teams')
            .doc(teamId)
            .collection('members')
            .doc(athleteId)
            .set({
          'role': 'Athlete',
          'status': 'approved',
          'isActive': true,
          'isOwner': false,
        });

        // Act & Assert
        expect(() async {
          await firestore
              .collection('teams')
              .doc(teamId)
              .collection('programs')
              .add({
            'name': 'Test Program',
            'description': 'Test Description',
            'createdBy': athleteId,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }, throwsA(isA<FirebaseException>()));
      });
    });

    group('Training Logs Access Control', () {
      test('should allow approved coach to write training logs', () async {
        // Arrange
        const teamId = 'test-team-1';
        const coachId = 'coach-user-1';
        
        // Create coach user and sign in
        await auth.createUserWithEmailAndPassword(
          email: 'coach@test.com',
          password: 'password123',
        );
        
        // Set up team membership
        await firestore
            .collection('teams')
            .doc(teamId)
            .collection('members')
            .doc(coachId)
            .set({
          'role': 'Coach',
          'status': 'approved',
          'isActive': true,
          'isOwner': false,
        });

        // Act & Assert
        expect(() async {
          await firestore
              .collection('teams')
              .doc(teamId)
              .collection('trainingLogs')
              .add({
            'programId': 'program-1',
            'athleteId': 'athlete-1',
            'score': 85.5,
            'date': FieldValue.serverTimestamp(),
            'inputBy': coachId,
          });
        }, returnsNormally);
      });

      test('should deny athlete write access to training logs', () async {
        // Arrange
        const teamId = 'test-team-1';
        const athleteId = 'athlete-user-1';
        
        // Create athlete user and sign in
        await auth.createUserWithEmailAndPassword(
          email: 'athlete@test.com',
          password: 'password123',
        );
        
        // Set up team membership
        await firestore
            .collection('teams')
            .doc(teamId)
            .collection('members')
            .doc(athleteId)
            .set({
          'role': 'Athlete',
          'status': 'approved',
          'isActive': true,
          'isOwner': false,
        });

        // Act & Assert
        expect(() async {
          await firestore
              .collection('teams')
              .doc(teamId)
              .collection('trainingLogs')
              .add({
            'programId': 'program-1',
            'athleteId': athleteId,
            'score': 85.5,
            'date': FieldValue.serverTimestamp(),
            'inputBy': athleteId,
          });
        }, throwsA(isA<FirebaseException>()));
      });
    });

    group('Team Members Access Control', () {
      test('should allow approved coach to manage members', () async {
        // Arrange
        const teamId = 'test-team-1';
        const coachId = 'coach-user-1';
        const newMemberId = 'new-member-1';
        
        // Create coach user and sign in
        await auth.createUserWithEmailAndPassword(
          email: 'coach@test.com',
          password: 'password123',
        );
        
        // Set up team membership
        await firestore
            .collection('teams')
            .doc(teamId)
            .collection('members')
            .doc(coachId)
            .set({
          'role': 'Coach',
          'status': 'approved',
          'isActive': true,
          'isOwner': false,
        });

        // Act & Assert
        expect(() async {
          await firestore
              .collection('teams')
              .doc(teamId)
              .collection('members')
              .doc(newMemberId)
              .set({
            'role': 'Athlete',
            'status': 'approved',
            'isActive': true,
            'isOwner': false,
            'approvedBy': coachId,
          });
        }, returnsNormally);
      });

      test('should deny athlete access to manage members', () async {
        // Arrange
        const teamId = 'test-team-1';
        const athleteId = 'athlete-user-1';
        const newMemberId = 'new-member-1';
        
        // Create athlete user and sign in
        await auth.createUserWithEmailAndPassword(
          email: 'athlete@test.com',
          password: 'password123',
        );
        
        // Set up team membership
        await firestore
            .collection('teams')
            .doc(teamId)
            .collection('members')
            .doc(athleteId)
            .set({
          'role': 'Athlete',
          'status': 'approved',
          'isActive': true,
          'isOwner': false,
        });

        // Act & Assert
        expect(() async {
          await firestore
              .collection('teams')
              .doc(teamId)
              .collection('members')
              .doc(newMemberId)
              .set({
            'role': 'Athlete',
            'status': 'approved',
            'isActive': true,
            'isOwner': false,
            'approvedBy': athleteId,
          });
        }, throwsA(isA<FirebaseException>()));
      });
    });

    group('Leaderboards Access Control', () {
      test('should allow team members to read leaderboards', () async {
        // Arrange
        const teamId = 'test-team-1';
        const athleteId = 'athlete-user-1';
        
        // Create athlete user and sign in
        await auth.createUserWithEmailAndPassword(
          email: 'athlete@test.com',
          password: 'password123',
        );
        
        // Set up team membership
        await firestore
            .collection('teams')
            .doc(teamId)
            .collection('members')
            .doc(athleteId)
            .set({
          'role': 'Athlete',
          'status': 'approved',
          'isActive': true,
          'isOwner': false,
        });

        // Create leaderboard entry
        await firestore
            .collection('leaderboards')
            .doc('leaderboard-1')
            .set({
          'team_id': teamId,
          'athleteId': athleteId,
          'totalScore': 100.0,
          'rank': 1,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Act & Assert
        expect(() async {
          await firestore
              .collection('leaderboards')
              .doc('leaderboard-1')
              .get();
        }, returnsNormally);
      });

      test('should deny non-team members access to leaderboards', () async {
        // Arrange
        const teamId = 'test-team-1';
        const outsiderId = 'outsider-user-1';
        
        // Create outsider user and sign in
        await auth.createUserWithEmailAndPassword(
          email: 'outsider@test.com',
          password: 'password123',
        );

        // Create leaderboard entry
        await firestore
            .collection('leaderboards')
            .doc('leaderboard-1')
            .set({
          'team_id': teamId,
          'athleteId': 'some-athlete',
          'totalScore': 100.0,
          'rank': 1,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Act & Assert
        expect(() async {
          await firestore
              .collection('leaderboards')
              .doc('leaderboard-1')
              .get();
        }, throwsA(isA<FirebaseException>()));
      });
    });
  });
}

// Helper function to clear Firestore data
Future<void> _clearFirestore() async {
  // This would need to be implemented based on your testing setup
  // You might use Firebase Admin SDK or emulator REST API to clear data
}