import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/image_upload_service.dart';
import '../../services/user_service.dart';
import '../../services/firestore_service.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'account_settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImageUploadService _imageUploadService = ImageUploadService();
  final UserService _userService = UserService(FirestoreService());
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    // Refresh user profile when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userProfile == null && authProvider.user != null) {
        authProvider.refreshUserProfile();
      }
    });
  }

  Future<void> _updateProfileImage() async {
    try {
      final imageSource = await _imageUploadService.showImageSourceDialog(context);
      if (imageSource == null) return;

      final imageFile = await _imageUploadService.pickImage(source: imageSource);
      if (imageFile == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        throw Exception('User not found');
      }

      // Upload image to Firebase Storage
      final imageUrl = await _imageUploadService.uploadProfileImage(
        imageFile,
        authProvider.user!.uid,
      );

      if (imageUrl != null) {
        // Update user profile with new image URL
        final currentProfile = authProvider.userProfile;
        if (currentProfile != null) {
          // Delete old image if exists
          if (currentProfile.profileImageUrl != null && 
              currentProfile.profileImageUrl!.startsWith('https://')) {
            await _imageUploadService.deleteProfileImage(currentProfile.profileImageUrl!);
          }

          final updatedProfile = currentProfile.copyWith(
            profileImageUrl: imageUrl,
          );

          final success = await _userService.updateUserProfile(updatedProfile);
          if (success) {
            await authProvider.refreshUserProfile();
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Foto profil berhasil diperbarui'),
                  backgroundColor: Color(0xFF00BF63),
                ),
              );
            }
          } else {
            throw Exception('Failed to update profile');
          }
        }
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002122),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002122),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading || authProvider.userProfile == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF00BF63),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memuat profil...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }

          final userProfile = authProvider.userProfile!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(userProfile),
                const SizedBox(height: 24),
                
                // Profile Info Cards
                _buildInfoCard('Email', userProfile.email, Icons.email),
                const SizedBox(height: 12),
                // Role dihapus karena sekarang bersifat per tim
                _buildInfoCard(
                  'Bergabung', 
                  _formatDate(userProfile.createdAt), 
                  Icons.calendar_today
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  'Status Email', 
                  userProfile.isEmailVerified ? 'Terverifikasi' : 'Belum Terverifikasi', 
                  userProfile.isEmailVerified ? Icons.verified : Icons.warning,
                  valueColor: userProfile.isEmailVerified ? Colors.green : Colors.orange,
                ),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile userProfile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4A4B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00BF63).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Profile Image
          Stack(
            children: [
              GestureDetector(
                onTap: _updateProfileImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF00BF63),
                  backgroundImage: userProfile.profileImageUrl != null && 
                      userProfile.profileImageUrl!.startsWith('https://')
                      ? NetworkImage(userProfile.profileImageUrl!) 
                      : null,
                  child: _isUploadingImage
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : (userProfile.profileImageUrl == null || 
                         !userProfile.profileImageUrl!.startsWith('https://'))
                          ? Text(
                              userProfile.name.isNotEmpty ? userProfile.name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                ),
              ),
              if (!_isUploadingImage)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF00BF63),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      onPressed: _updateProfileImage,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Name
          Text(
            userProfile.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          // Last Login
          if (userProfile.lastLoginAt != null)
            Text(
              'Terakhir login: ${_formatDate(userProfile.lastLoginAt!)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4A4B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00BF63).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF00BF63),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
            icon: const Icon(Icons.lock, color: Colors.white),
            label: const Text(
              'Ubah Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A4747),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountSettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.white70),
            label: const Text(
              'Pengaturan Akun',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    DateTime dateTime;
    if (date is Timestamp) {
      dateTime = date.toDate();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return 'Invalid date';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
