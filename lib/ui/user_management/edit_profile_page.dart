import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../services/image_upload_service.dart';
import '../../services/user_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_profile.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  UserProfile? _userProfile;
  File? _selectedImage;
  String? _newImageUrl;
  
  final ImageUploadService _imageUploadService = ImageUploadService();
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userProfile = authProvider.userProfile;
    if (_userProfile != null) {
      _nameController.text = _userProfile!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imageSource = await _imageUploadService.showImageSourceDialog(context);
    if (imageSource != null) {
      final image = await _imageUploadService.pickImage(source: imageSource);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null || _userProfile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final imageUrl = await _imageUploadService.uploadProfileImage(
        _selectedImage!,
        _userProfile!.uid,
      );

      if (imageUrl != null) {
        setState(() {
          _newImageUrl = imageUrl;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto berhasil diupload'),
            backgroundColor: Color(0xFF00BF63),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengupload foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate() && _userProfile != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Upload image first if selected
        String? finalImageUrl = _newImageUrl ?? _userProfile!.profileImageUrl;
        
        if (_selectedImage != null && _newImageUrl == null) {
          finalImageUrl = await _imageUploadService.uploadProfileImage(
            _selectedImage!,
            _userProfile!.uid,
          );
        }
        
        final userService = UserService(FirestoreService());
        final updatedProfile = _userProfile!.copyWith(
          name: _nameController.text.trim(),
          profileImageUrl: finalImageUrl,
        );
        
        bool success = await userService.updateUserProfile(updatedProfile);
        
        if (success) {
          // Update the profile in AuthProvider
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.refreshUserProfile();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile berhasil diperbarui'),
                backgroundColor: Color(0xFF00BF63),
              ),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gagal memperbarui profile'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002122),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002122),
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.userProfile == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00BF63),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFF00BF63),
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (_newImageUrl != null
                                  ? NetworkImage(_newImageUrl!)
                                  : (authProvider.userProfile!.profileImageUrl != null 
                                      ? NetworkImage(authProvider.userProfile!.profileImageUrl!) 
                                      : null)) as ImageProvider?,
                          child: (_selectedImage == null && 
                                  _newImageUrl == null && 
                                  authProvider.userProfile!.profileImageUrl == null)
                              ? Text(
                                  authProvider.userProfile!.name.isNotEmpty 
                                      ? authProvider.userProfile!.name[0].toUpperCase() 
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        if (_isUploadingImage)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00BF63),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF00BF63),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: _isUploadingImage ? null : _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _isUploadingImage ? null : _uploadImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BF63),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isUploadingImage
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Upload Foto',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Name Field
                  const Text(
                    'Nama Lengkap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Masukkan nama lengkap'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      if (value.trim().length < 2) {
                        return 'Nama minimal 2 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BF63),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                              'Simpan Perubahan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontFamily: 'Poppins',
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF00BF63),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color(0xFF00BF63).withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF00BF63),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: const Color(0xFF1A4A4B).withOpacity(0.3),
    );
  }
}