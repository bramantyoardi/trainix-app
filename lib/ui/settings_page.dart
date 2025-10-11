import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/top_navbar.dart';
import 'components/bottom_navbar.dart';
import 'user_management/profile_page.dart';
import 'user_management/account_settings_page.dart';
import '../providers/auth_provider.dart';
import 'authentication/login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002122),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopNavBar(),
              const SizedBox(height: 20),
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildSettingItem(
                      context,
                      Icons.person_outline, 
                      'Profile Settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
                    ),
                    _buildSettingItem(
                      context,
                      Icons.notifications_none, 
                      'Notifications',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountSettingsPage(),
                          ),
                        );
                      },
                    ),
                    _buildSettingItem(
                      context,
                      Icons.lock_outline, 
                      'Privacy & Security',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountSettingsPage(),
                          ),
                        );
                      },
                    ),
                    _buildSettingItem(context, Icons.help_outline, 'Help & Support'),
                    _buildSettingItem(context, Icons.info_outline, 'About'),
                    _buildSettingItem(
                      context, 
                      Icons.logout, 
                      'Logout', 
                      isLogout: true,
                      onTap: () => _handleLogout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A4747),
          title: const Text(
            'Konfirmasi Logout',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00BF63),
                    ),
                  ),
                );
                
                // Perform logout
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();
                
                // Navigate to login page
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, {bool isLogout = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A4747),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: isLogout ? Colors.red : Colors.white),
          title: Text(
            title,
            style: TextStyle(
              color: isLogout ? Colors.red : Colors.white,
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }
}