import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService(FirestoreService());

  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _loadUserProfile();
      // Update FCM token when user logs in
      final token = await NotificationService.getToken();
      if (token != null) {
        await _userService.updateFCMToken(user.uid, token);
      }
    } else {
      _userProfile = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserProfile() async {
    if (_user != null) {
      _userProfile = await _userService.getUserProfile(_user!.uid);
      notifyListeners();
    }
  }

  // Add this method to refresh user profile
  Future<void> refreshUserProfile() async {
    if (_user != null) {
      _userProfile = await _userService.getUserProfile(_user!.uid);
      notifyListeners();
    }
  }

  // Enhanced email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Enhanced password validation
  bool _isValidPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    return password.length >= 8 &&
           RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password);
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Enhanced validation
      if (!_isValidEmail(email)) {
        _errorMessage = 'Format email tidak valid';
        return false;
      }

      if (password.isEmpty) {
        _errorMessage = 'Password tidak boleh kosong';
        return false;
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _loadUserProfile();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getEnhancedErrorMessage(e.code);
      print('Sign in error: ${e.message}');
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan yang tidak terduga';
      print('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? username,
    String? gender,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Enhanced validation
      if (!_isValidEmail(email)) {
        _errorMessage = 'Format email tidak valid';
        return false;
      }

      if (!_isValidPassword(password)) {
        _errorMessage = 'Password harus minimal 8 karakter dengan huruf besar, kecil, dan angka';
        return false;
      }

      if (name.trim().isEmpty) {
        _errorMessage = 'Nama tidak boleh kosong';
        return false;
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Send email verification
        await result.user!.sendEmailVerification();

        // Create complete user profile
        UserProfile newProfile = UserProfile(
          uid: result.user!.uid,
          name: name,
          email: email,
          username: username ?? email.split('@')[0], // Generate username from email if not provided
          gender: gender,
          createdAt: Timestamp.now(),
          isEmailVerified: false,
        );

        bool profileSaved = await _userService.updateUserProfile(newProfile);
        if (profileSaved) {
          _userProfile = newProfile;
          return true;
        }
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getEnhancedErrorMessage(e.code);
      print('Sign up error: ${e.message}');
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan yang tidak terduga';
      print('Sign up error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getEnhancedErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Akun dengan email ini tidak ditemukan';
      case 'wrong-password':
        return 'Password yang Anda masukkan salah';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan gunakan email lain';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 8 karakter';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa koneksi Anda';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi';
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      
      if (result.user != null) {
        // Check if user profile exists, create if not
        UserProfile? existingProfile = await _userService.getUserProfile(result.user!.uid);
        
        if (existingProfile == null) {
          UserProfile newProfile = UserProfile(
            uid: result.user!.uid,
            name: result.user!.displayName ?? 'Unknown',
            email: result.user!.email ?? '',
            createdAt: Timestamp.now(),
            isEmailVerified: result.user!.emailVerified,
            profileImageUrl: result.user!.photoURL,
          );
          
          await _userService.updateUserProfile(newProfile);
        } else {
          await _userService.updateUserProfile(
            existingProfile.copyWith(lastLoginAt: Timestamp.now())
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Google sign in failed';
      print('Google sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      // Reset user data
      _user = null;
      _userProfile = null;
      _errorMessage = null;
      _isLoading = false;
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Logout failed';
      print('Sign out error: $e');
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send password reset email';
      print('Password reset error: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Add register method wrapper
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    return await signUpWithEmailPassword(
      email: email,
      password: password,
      name: name,
    );
  }
}
