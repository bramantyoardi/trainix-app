import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  
  // Login controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  
  // Register controllers
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _registerConfirmPasswordController = TextEditingController();
  
  // State variables
  bool _isLoginPasswordVisible = false;
  bool _isRegisterPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoginLoading = false;
  bool _isRegisterLoading = false;
  bool _isLoginFormValid = false;
  bool _isRegisterFormValid = false;
  
  // Error messages
  String? _loginEmailError;
  String? _loginPasswordError;
  String? _registerNameError;
  String? _registerEmailError;
  String? _registerPasswordError;
  String? _registerConfirmPasswordError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
    
    // Add listener to TabController to update UI when tab changes
    _tabController.addListener(() {
      setState(() {});
    });
    
    // Add listeners for login form validation
    _loginEmailController.addListener(_validateLoginForm);
    _loginPasswordController.addListener(_validateLoginForm);
    
    // Add listeners for register form validation
    _registerNameController.addListener(_validateRegisterForm);
    _registerEmailController.addListener(_validateRegisterForm);
    _registerPasswordController.addListener(_validateRegisterForm);
    _registerConfirmPasswordController.addListener(_validateRegisterForm);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  void _validateLoginForm() {
    setState(() {
      _loginEmailError = null;
      _loginPasswordError = null;
      
      bool isEmailValid = _loginEmailController.text.isNotEmpty && 
                         _loginEmailController.text.contains('@');
      bool isPasswordValid = _loginPasswordController.text.length >= 6;
      
      if (_loginEmailController.text.isNotEmpty && !_loginEmailController.text.contains('@')) {
        _loginEmailError = 'Format email tidak valid';
      }
      
      if (_loginPasswordController.text.isNotEmpty && _loginPasswordController.text.length < 6) {
        _loginPasswordError = 'Password minimal 6 karakter';
      }
      
      _isLoginFormValid = isEmailValid && isPasswordValid;
    });
  }

  void _validateRegisterForm() {
    setState(() {
      _registerNameError = null;
      _registerEmailError = null;
      _registerPasswordError = null;
      _registerConfirmPasswordError = null;
      
      bool isNameValid = _registerNameController.text.trim().isNotEmpty;
      bool isEmailValid = _registerEmailController.text.isNotEmpty && 
                         _registerEmailController.text.contains('@');
      bool isPasswordValid = _registerPasswordController.text.length >= 6;
      bool isConfirmPasswordValid = _registerConfirmPasswordController.text == _registerPasswordController.text;
      
      if (_registerNameController.text.isNotEmpty && _registerNameController.text.trim().isEmpty) {
        _registerNameError = 'Nama tidak boleh kosong';
      }
      
      if (_registerEmailController.text.isNotEmpty && !_registerEmailController.text.contains('@')) {
        _registerEmailError = 'Format email tidak valid';
      }
      
      if (_registerPasswordController.text.isNotEmpty && _registerPasswordController.text.length < 6) {
        _registerPasswordError = 'Password minimal 6 karakter';
      }
      
      if (_registerConfirmPasswordController.text.isNotEmpty && 
          _registerConfirmPasswordController.text != _registerPasswordController.text) {
        _registerConfirmPasswordError = 'Password tidak sama';
      }
      
      _isRegisterFormValid = isNameValid && isEmailValid && isPasswordValid && isConfirmPasswordValid;
    });
  }

  Future<void> _handleLogin() async {
    if (!_isLoginFormValid || _isLoginLoading) return;
    
    setState(() {
      _isLoginLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.signInWithEmailPassword(
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
      );
      
      if (!success && authProvider.errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoginLoading = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_isRegisterFormValid || _isRegisterLoading) return;
    
    setState(() {
      _isRegisterLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.signUpWithEmailPassword(
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
        name: _registerNameController.text.trim(),
      );
      
      if (success) {
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/email-verification',
            arguments: {
              'email': _registerEmailController.text.trim(),
              'name': _registerNameController.text.trim(),
            },
          );
        }
      } else {
        if (authProvider.errorMessage != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegisterLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.signInWithGoogle();
    
    if (success) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } else {
      if (authProvider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _switchToRegister() {
    _tabController.animateTo(1);
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _switchToLogin() {
    _tabController.animateTo(0);
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002122),
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo
            Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0, bottom: 0.0),
              child: Column(
                children: [
                  Image.asset(
                      'images/logo/trainix_transparent.png',
                      height: 62,
                      width: 240,
                    ),
                ],
              ),
            ),
            
            // Tab buttons
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Sliding background indicator
                  AnimatedAlign(
                    alignment: _tabController.index == 0 
                        ? Alignment.centerLeft 
                        : Alignment.centerRight,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5 - 47, // Half width minus margins and padding
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          child: TextButton(
                            onPressed: _switchToLogin,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: _tabController.index == 0 
                                    ? Colors.white 
                                    : Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 45,
                          child: TextButton(
                            onPressed: _switchToRegister,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: _tabController.index == 1 
                                    ? Colors.white 
                                    : Colors.white.withOpacity(0.7),
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
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Form content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  _tabController.animateTo(index);
                },
                children: [
                  _buildLoginForm(),
                  _buildRegisterForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sign in to continue your fitness journey',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 40),
          
          // Email field
          TextField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: 'Email',
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.6),
                fontFamily: 'Poppins',
                fontSize: 10,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          
          if (_loginEmailError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _loginEmailError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Password field
          TextField(
            controller: _loginPasswordController,
            obscureText: !_isLoginPasswordVisible,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.6),
                fontFamily: 'Poppins',
                fontSize: 10,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isLoginPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isLoginPasswordVisible = !_isLoginPasswordVisible;
                  });
                },
              ),
            ),
          ),
          
          if (_loginPasswordError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _loginPasswordError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 40),
          
          // Login button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isLoginLoading || !_isLoginFormValid) ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoginFormValid && !_isLoginLoading 
                    ? const Color(0xFF65EAE8) 
                    : const Color(0xFF1E5555),
                disabledBackgroundColor: const Color(0xFF1E5555),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoginLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'LOG IN',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Forgot password
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Color(0xFF65EAE8),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Divider with "OR"
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Google Sign In Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _handleGoogleSignIn,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: Colors.white, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              icon: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              label: const Text(
                'Continue with Google',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join us and start your fitness journey today',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 40),
          
          // Name field
          TextField(
            controller: _registerNameController,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: 'Full Name',
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.6),
                fontFamily: 'Poppins',
                fontSize: 10,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          
          if (_registerNameError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _registerNameError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Email field
          TextField(
            controller: _registerEmailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: 'Email',
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.6),
                fontFamily: 'Poppins',
                fontSize: 10,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          
          if (_registerEmailError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _registerEmailError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Password field
          TextField(
            controller: _registerPasswordController,
            obscureText: !_isRegisterPasswordVisible,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.6),
                fontFamily: 'Poppins',
                fontSize: 10,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isRegisterPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isRegisterPasswordVisible = !_isRegisterPasswordVisible;
                  });
                },
              ),
            ),
          ),
          
          if (_registerPasswordError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _registerPasswordError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Confirm Password field
          TextField(
            controller: _registerConfirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: 'Confirm Password',
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.6),
                fontFamily: 'Poppins',
                fontSize: 10,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
          ),
          
          if (_registerConfirmPasswordError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _registerConfirmPasswordError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 40),
          
          // Sign Up Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (_isRegisterLoading || !_isRegisterFormValid) ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF65EAE8),
                disabledBackgroundColor: const Color(0xFF1E5555),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isRegisterLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'SIGN UP',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Divider with "OR"
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Google Sign In Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _handleGoogleSignIn,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Image.asset(
                'images/icons/google_icon.png', // You'll need to add this icon
                height: 24,
                width: 24,
              ),
              label: const Text(
                'Continue with Google',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Terms and Privacy Policy
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  'By signing up, you agree to our ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/terms');
                  },
                  child: const Text(
                    'Terms of Service',
                    style: TextStyle(
                      color: Color(0xFF65EAE8),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const Text(
                  ' and ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/privacy');
                  },
                  child: const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF65EAE8),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}