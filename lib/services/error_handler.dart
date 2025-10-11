import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Hapus import yang tidak perlu
// import 'package:cloud_firestore/cloud_firestore.dart';

class ErrorHandler {
  static String getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Pengguna tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun pengguna telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan.';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }

  static String getFirestoreErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Akses ditolak. Periksa izin Anda.';
      case 'unavailable':
        return 'Layanan tidak tersedia. Coba lagi nanti.';
      case 'deadline-exceeded':
        return 'Koneksi timeout. Periksa koneksi internet Anda.';
      case 'not-found':
        return 'Data tidak ditemukan.';
      case 'already-exists':
        return 'Data sudah ada.';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
