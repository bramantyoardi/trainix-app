import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: const DecorationImage(
                  image: AssetImage('images/logo/trainix_white_basic.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // App Name
            const Text(
              'Trainix',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Tagline
            const Text(
              'Training Management System',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Loading Indicator
            const CircularProgressIndicator(
              color: Colors.blue,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}