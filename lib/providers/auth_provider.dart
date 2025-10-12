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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> refreshUserProfile() async {
    if (_user != null) {
      _userProfile = await _userService.getUserProfile(_user!.uid);
      notifyListeners();
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
           RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password);
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }
    if (password.contains(' ')) {
      return 'Password tidak boleh mengandung spasi';
    }
    return null;
  }

  String _getEnhancedErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan';
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

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
        await result.user!.sendEmailVerification();

        UserProfile newProfile = UserProfile(
          uid: result.user!.uid,
          name: name,
          email: email,
          username: username ?? email.split('@')[0],
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

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If user cancels the sign-in process
      if (googleUser == null) {
        _errorMessage = 'Login dibatalkan';
        return false;
      }

      try {
        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          // Check if this is a new user
          final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

          if (isNewUser) {
            // Create a new user profile for new Google users
            final userProfile = UserProfile(
              uid: user.uid,
              email: user.email ?? '',
              name: user.displayName ?? '',
              username: user.email?.split('@')[0] ?? '',
              profileImageUrl: user.photoURL ?? '',
              createdAt: Timestamp.now(),
              lastLoginAt: Timestamp.now(),
              isEmailVerified: user.emailVerified,
            );

            // Save the new user profile to Firestore
            await _firestore.collection('users').doc(user.uid).set(userProfile.toJson());
          } else {
            // Update last login time for existing users
            await _firestore.collection('users').doc(user.uid).update({
              'lastLoginAt': Timestamp.now(),
            });
          }

          // Load the user profile
          await _loadUserProfile();
          return true;
        }
        _errorMessage = 'Gagal mendapatkan data pengguna';
        return false;
      } catch (e) {
        print('Error getting auth details: $e');
        _errorMessage = 'Gagal mendapatkan data autentikasi Google';
        return false;
      }
    } catch (e) {
      print('Error during Google sign in: $e');
      _errorMessage = 'Terjadi kesalahan saat login dengan Google';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _user = null;
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (!_isValidEmail(email)) {
        _errorMessage = 'Format email tidak valid';
        return false;
      }

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getEnhancedErrorMessage(e.code);
      print('Password reset error: ${e.message}');
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan yang tidak terduga';
      print('Password reset error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      print('Check email verification error: $e');
      return false;
    }
  }
}
