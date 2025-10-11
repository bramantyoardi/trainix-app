import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/error_handler.dart';
import 'email_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isFormValid = false; // Tambahkan state untuk validitas form
  String? _errorMessage; // Add missing error message field
  
  // Add validation state tracking with timers
  bool _nameTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmPasswordTouched = false;
  
  bool _showNameError = false;
  bool _showEmailError = false;
  bool _showPasswordError = false;
  bool _showConfirmPasswordError = false;
  
  Timer? _nameErrorTimer;
  Timer? _emailErrorTimer;
  Timer? _passwordErrorTimer;
  Timer? _confirmPasswordErrorTimer;

  @override
  void initState() {
    super.initState();
    // Tambahkan listener untuk memantau perubahan input
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _confirmPasswordController.removeListener(_validateForm);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameErrorTimer?.cancel();
    _emailErrorTimer?.cancel();
    _passwordErrorTimer?.cancel();
    _confirmPasswordErrorTimer?.cancel();
    super.dispose();
  }

  // Fungsi untuk memvalidasi form
  void _validateForm() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    bool isValid = name.isNotEmpty && 
                   email.isNotEmpty && 
                   password.isNotEmpty && 
                   confirmPassword.isNotEmpty &&
                   password.length >= 6 &&
                   !password.contains(' ') &&
                   !confirmPassword.contains(' ') &&
                   password == confirmPassword;
    
    // Validasi email
    if (email.isNotEmpty) {
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
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12), // Ubah dari 26 ke 12 untuk samakan dengan login_page
                                  ),
                                ),
                                child: Text(
                                  'Sign In',
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
                          const SizedBox(width: 8), // Tambahkan spacing horizontal
                          Expanded(
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.45), // Active color for Sign Up
                                borderRadius: BorderRadius.circular(12), // Ubah dari 26 ke 12 untuk samakan dengan login_page
                              ),
                              child: TextButton(
                                onPressed: () {}, // Already on register page
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12), // Ubah dari 26 ke 12 untuk samakan dengan login_page
                                  ),
                                ),
                                child: const Text(
                                  'Sign Up',
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
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Register Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      _buildTextField(
                        controller: _nameController,
                        label: 'Enter your name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan nama lengkap';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Email Field
                      _buildTextField(
                        controller: _emailController,
                        label: 'Enter email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Password Field
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Create password',
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan kata sandi';
                          }
                          if (value.length < 6) {
                            return 'Kata sandi minimal 6 karakter';
                          }
                          if (value.contains(' ')) {
                            return 'Kata sandi tidak boleh mengandung spasi';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Confirm Password Field
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm password',
                        isPassword: true,
                        isConfirmPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi kata sandi';
                          }
                          if (value.contains(' ')) {
                            return 'Kata sandi tidak boleh mengandung spasi';
                          }
                          if (value != _passwordController.text) {
                            return 'Kata sandi tidak cocok';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (_isLoading || !_isFormValid) ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF65EAE8), // Samakan dengan login_page - 65EAE8 dengan 100% opasitas
                            disabledBackgroundColor: const Color(0xFF1E5555), // 65EAE8 dengan 30% opasitas yang benar
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14), // Ubah dari 28 ke 14 untuk samakan dengan login_page
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
                                  'SIGN UP',
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
                      
                      const SizedBox(height: 40),
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
    bool isConfirmPassword = false,
    String? Function(String?)? validator,
  }) {
    // Determine which field this is
    bool isNameField = controller == _nameController;
    bool isEmailField = controller == _emailController;
    bool isPasswordField = controller == _passwordController && !isConfirmPassword;
    bool isConfirmPasswordField = controller == _confirmPasswordController;
    
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
            obscureText: isPassword 
                ? (isConfirmPassword ? !_isConfirmPasswordVisible : !_isPasswordVisible) 
                : false,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            onChanged: (value) {
              // Mark fields as touched progressively with timer
              setState(() {
                if (isNameField && !_nameTouched) {
                  _nameTouched = true;
                  _nameErrorTimer?.cancel();
                  _nameErrorTimer = Timer(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _showNameError = true;
                      });
                    }
                  });
                } else if (isEmailField && _nameTouched && !_emailTouched) {
                  _emailTouched = true;
                  _emailErrorTimer?.cancel();
                  _emailErrorTimer = Timer(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _showEmailError = true;
                      });
                    }
                  });
                } else if (isPasswordField && _emailTouched && _nameTouched && !_passwordTouched) {
                  _passwordTouched = true;
                  _passwordErrorTimer?.cancel();
                  _passwordErrorTimer = Timer(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _showPasswordError = true;
                      });
                    }
                  });
                } else if (isConfirmPasswordField && _passwordTouched && _emailTouched && _nameTouched && !_confirmPasswordTouched) {
                  _confirmPasswordTouched = true;
                  _confirmPasswordErrorTimer?.cancel();
                  _confirmPasswordErrorTimer = Timer(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _showConfirmPasswordError = true;
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
                        (isConfirmPassword ? _isConfirmPasswordVisible : _isPasswordVisible) 
                            ? Icons.visibility 
                            : Icons.visibility_off,
                        color: Colors.grey.withOpacity(0.8),
                      ),
                      onPressed: () {
                        setState(() {
                          if (isConfirmPassword) {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          } else {
                            _isPasswordVisible = !_isPasswordVisible;
                          }
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
            if (isNameField && _nameTouched && _showNameError) {
              error = validator?.call(value.text);
              shouldShowError = true;
            } else if (isEmailField && _emailTouched && _showEmailError && _nameTouched) {
              // Only show email error if name is valid
              final nameError = _nameController.text.isEmpty;
              if (!nameError) {
                error = validator?.call(value.text);
                shouldShowError = true;
              }
            } else if (isPasswordField && _passwordTouched && _showPasswordError && _emailTouched && _nameTouched) {
              // Only show password error if previous fields are valid
              final nameError = _nameController.text.isEmpty;
              final emailError = _emailController.text.isEmpty || 
                  !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text);
              if (!nameError && !emailError) {
                error = validator?.call(value.text);
                shouldShowError = true;
              }
            } else if (isConfirmPasswordField && _confirmPasswordTouched && _showConfirmPasswordError && _passwordTouched && _emailTouched && _nameTouched) {
              // Only show confirm password error if all previous fields are valid
              final nameError = _nameController.text.isEmpty;
              final emailError = _emailController.text.isEmpty || 
                  !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text);
              final passwordError = _passwordController.text.isEmpty || 
                  _passwordController.text.length < 6 || 
                  _passwordController.text.contains(' ');
              if (!nameError && !emailError && !passwordError) {
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Use named arguments for register method
      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const EmailVerificationPage(),
          ),
        );
      } else {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? 'Registrasi gagal';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
