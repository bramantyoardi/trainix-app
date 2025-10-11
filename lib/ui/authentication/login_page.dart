import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';
import '../../services/error_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isFormValid = false; // Tambahkan state untuk validitas form
  
  // Add validation state tracking with timers
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _showEmailError = false;
  bool _showPasswordError = false;
  
  Timer? _emailErrorTimer;
  Timer? _passwordErrorTimer;

  @override
  void initState() {
    super.initState();
    // Tambahkan listener untuk memantau perubahan input
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _emailController.dispose();
    _passwordController.dispose();
    _emailErrorTimer?.cancel();
    _passwordErrorTimer?.cancel();
    super.dispose();
  }

  // Fungsi untuk memvalidasi form
  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    bool isValid = email.isNotEmpty && 
                   password.isNotEmpty && 
                   password.length >= 6 &&
                   !password.contains(' ');
    
    // Validasi email jika mengandung @
    if (email.contains('@')) {
      isValid = isValid && RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    }
    
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002122), // Ubah dari 0xFF1A1A1A ke 0xFF002122
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                
                // Logo Section
                Column(
                  children: [
                    Image.asset(
                      'images/logo/trainix_transparent.png',
                      height: 62,
                      width: 240,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40), // Tambahkan margin horizontal
                      padding: const EdgeInsets.all(7), // Padding untuk rounded background
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 45, // Ukuran button yang lebih proporsional
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.45), // Active color for Sign In (black with 45% transparency)
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextButton(
                                onPressed: () {}, // Already on login page
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8), // Tambahkan spacing horizontal
                          Expanded(
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: Color(0xFFD9D9D9).withOpacity(0.15), // Active color for Sign In (D9D9D9 with 15% transparency)
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                
                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email/Username Field
                      _buildTextField(
                        controller: _emailController,
                        label: 'Enter email or username',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan email atau username';
                          }
                          if (value.contains('@') && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Password Field
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Enter password',
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan kata sandi';
                          }
                          if (value.contains(' ')) {
                            return 'Kata sandi tidak boleh mengandung spasi';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (_isLoading || !_isFormValid) ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF65EAE8), // 65EAE8 dengan 100% opasitas
                            disabledBackgroundColor: const Color(0xFF1E5555), // 65EAE8 dengan 30% opasitas yang benar
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'LOG IN',
                                  style: TextStyle(
                                    color: Color(0xFF000000), // Ubah dari Colors.white ke 000000
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    // Determine which field this is
    bool isEmailField = controller == _emailController;
    bool isPasswordField = controller == _passwordController;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword ? !_isPasswordVisible : false,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            onChanged: (value) {
              // Mark field as touched and start timer for error display
              setState(() {
                if (isEmailField && !_emailTouched) {
                  _emailTouched = true;
                  _emailErrorTimer?.cancel();
                  _emailErrorTimer = Timer(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _showEmailError = true;
                      });
                    }
                  });
                } else if (isPasswordField && _emailTouched && !_passwordTouched) {
                  _passwordTouched = true;
                  _passwordErrorTimer?.cancel();
                  _passwordErrorTimer = Timer(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _showPasswordError = true;
                      });
                    }
                  });
                }
              });
            },
            decoration: InputDecoration(
              hintText: label, // Ganti labelText dengan hintText
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.6),
                fontFamily: 'Poppins',
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey.withOpacity(0.8),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12, // Kurangi padding vertical untuk ukuran yang lebih kecil
              ),
              errorStyle: const TextStyle(height: 0, fontSize: 0), // Hide default error
            ),
            validator: validator,
          ),
        ),
        // Custom error message display with progressive validation and delay
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            String? error;
            bool shouldShowError = false;
            
            // Progressive validation logic with delay
            if (isEmailField && _emailTouched && _showEmailError) {
              error = validator?.call(value.text);
              shouldShowError = true;
            } else if (isPasswordField && _passwordTouched && _showPasswordError && _emailTouched) {
              // Only show password error if email field has been touched first
              final emailError = _emailController.text.isEmpty || 
                  (_emailController.text.contains('@') && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text));
              if (!emailError) {
                error = validator?.call(value.text);
                shouldShowError = true;
              }
            }
            
            if (error != null && error.isNotEmpty && shouldShowError) {
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      bool success = await authProvider.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return; // Check if widget is still mounted

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        if (authProvider.errorMessage != null) {
          ErrorHandler.showErrorSnackBar(context, authProvider.errorMessage!);
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
