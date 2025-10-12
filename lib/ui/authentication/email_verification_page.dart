import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../homepage.dart';
import '../../services/error_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final String name;

  const EmailVerificationPage({
    Key? key,
    required this.email,
    required this.name,
  }) : super(key: key);

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isLoading = false;
  bool _isVerified = false;
  int _resendCooldown = 0;
  Timer? _timer;
  Timer? _checkTimer;
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _checkTimer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await auth.currentUser?.reload();
      final user = auth.currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isVerified = true;
          });
          _navigateToDashboard();
        }
      }
    });
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCooldown--;
        });

        if (_resendCooldown <= 0) {
          timer.cancel();
        }
      }
    });
  }

  Future<void> _checkVerification() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await auth.currentUser?.reload();
      final user = auth.currentUser;

      if (user?.emailVerified ?? false) {
        if (mounted) {
          setState(() {
            _isVerified = true;
          });
          _navigateToDashboard();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Email belum terverifikasi. Silakan cek email Anda dan klik link verifikasi.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (e is FirebaseAuthException) {
          ErrorHandler.showErrorSnackBar(
              context, ErrorHandler.getFirebaseAuthErrorMessage(e));
        } else {
          ErrorHandler.showErrorSnackBar(
              context, 'Terjadi kesalahan: ${e.toString()}');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (!mounted) return;

    try {
      final user = auth.currentUser;
      await user?.sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Email verifikasi telah dikirim ulang. Silakan cek email Anda.'),
            backgroundColor: Colors.green,
          ),
        );
        _startResendCooldown();
      }
    } catch (e) {
      if (mounted) {
        if (e is FirebaseAuthException) {
          ErrorHandler.showErrorSnackBar(
              context, ErrorHandler.getFirebaseAuthErrorMessage(e));
        } else {
          ErrorHandler.showErrorSnackBar(
              context, 'Terjadi kesalahan: ${e.toString()}');
        }
      }
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Icon
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: _isVerified
                          ? Colors.green.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      _isVerified ? Icons.verified : Icons.mark_email_unread,
                      color: _isVerified ? Colors.green : Colors.blue,
                      size: 60,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Title
                  Text(
                    _isVerified ? 'Email Verified!' : 'Verify Your Email',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Subtitle
                  Text(
                    _isVerified
                        ? 'Great! Your email has been verified successfully. You can now access all features of Trainix.'
                        : 'We have sent a verification link to your email address. Please check your inbox and click the link to verify your account.',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // Email Info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF3A3A3A),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Name: ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              widget.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Email: ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.email,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  if (!_isVerified) ...[
                    // Check Verification Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _checkVerification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'I\'ve Verified My Email',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Resend Email Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _resendCooldown > 0
                            ? null
                            : _resendVerificationEmail,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                _resendCooldown > 0 ? Colors.grey : Colors.blue,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          _resendCooldown > 0
                              ? 'Resend in ${_resendCooldown}s'
                              : 'Resend Verification Email',
                          style: TextStyle(
                            color:
                                _resendCooldown > 0 ? Colors.grey : Colors.blue,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
