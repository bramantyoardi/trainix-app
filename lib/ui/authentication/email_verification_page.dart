import 'package:flutter/material.dart';
import 'dart:async';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final String name;
  // final String role; // HAPUS - tidak diperlukan lagi

  const EmailVerificationPage({
    Key? key,
    required this.email,
    required this.name,
    // required this.role, // HAPUS - tidak diperlukan lagi
  }) : super(key: key);

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isLoading = false;
  bool _isVerified = false;
  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCooldown--;
      });

      if (_resendCooldown <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      const SizedBox(height: 10),
                      const SizedBox(height: 10),
                      // Role section dihapus sesuai spesifikasi v1.3
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
                      onPressed:
                          _resendCooldown > 0 ? null : _resendVerificationEmail,
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
                ] else ...[
                  // Continue Button (when verified)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/main',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue to Trainix',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Help Text
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.help_outline,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Didn\'t receive the email?',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        '• Check your spam/junk folder\n• Make sure the email address is correct\n• Wait a few minutes for the email to arrive',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Back to Login
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkVerification() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate checking verification status
    await Future.delayed(const Duration(seconds: 2));

    // Mock verification check - replace with actual Firebase verification check
    // For demo purposes, let's say it's verified after first check
    setState(() {
      _isLoading = false;
      _isVerified = true;
    });
  }

  void _resendVerificationEmail() async {
    // Mock resend verification email - replace with actual Firebase resend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification email sent!'),
        backgroundColor: Colors.green,
      ),
    );

    _startResendCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
