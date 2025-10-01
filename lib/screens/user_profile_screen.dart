import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:amuma/widgets/logout_widget.dart';
import 'package:amuma/services/auth_service.dart';
import 'package:amuma/services/firebase_service.dart';
import 'package:amuma/screens/auth_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isUploadingImage = false;
  Map<String, dynamic>? _userData;
  String? _profileImageUrl;
  File? _profileImageFile;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String? _selectedGender;
  List<String> _selectedConditions = [];
  List<String> _selectedGoals = [];

  final List<String> _chronicConditions = [
    'Diabetes Mellitus',
    'Hypertension',
    'Chronic Kidney Disease',
    'Cardiovascular Disease',
    'Asthma',
    'Arthritis',
    'Depression/Anxiety',
    'None',
  ];

  final List<String> _healthGoals = [
    'Medication Adherence',
    'Weight Management',
    'Blood Pressure Control',
    'Blood Sugar Control',
    'Regular Exercise',
    'Better Sleep',
    'Stress Management',
    'Regular Check-ups',
  ];

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _authService.getUserData();
      final user = _authService.currentUser;

      if (userData != null && user != null) {
        setState(() {
          _userData = userData;
          _nameController.text =
              userData['displayName'] ?? user.displayName ?? '';
          _emailController.text = user.email ?? '';
          _ageController.text = userData['age']?.toString() ?? '';
          _heightController.text = userData['height']?.toString() ?? '';
          _weightController.text = userData['weight']?.toString() ?? '';
          _selectedGender = userData['gender'];
          _selectedConditions =
              List<String>.from(userData['chronicConditions'] ?? []);
          _selectedGoals = List<String>.from(userData['healthGoals'] ?? []);
          _profileImageUrl = userData['profileImageUrl'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: healthRed,
          ),
        );
      }
    }
  }

  Future<String?> _uploadProfileImage() async {
    try {
      final user = _authService.currentUser;
      if (user == null || _profileImageFile == null) return null;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      final uploadTask = ref.putFile(_profileImageFile!);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: ${e.toString()}'),
            backgroundColor: healthRed,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: healthRed,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              text: 'Profile Picture',
              fontSize: 18,
              color: textPrimary,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () async {
                    Navigator.pop(context);
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _profileImageFile = File(image.path);
                      });
                    }
                  },
                ),
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage();
                  },
                ),
                if (_profileImageUrl != null || _profileImageFile != null)
                  _buildImagePickerOption(
                    icon: Icons.delete,
                    label: 'Remove',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _profileImageFile = null;
                        _profileImageUrl = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          TextWidget(
            text: label,
            fontSize: 12,
            color: textSecondary,
            fontFamily: 'Medium',
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Upload profile image if changed
      String? imageUrl;
      if (_profileImageFile != null) {
        imageUrl = await _uploadProfileImage();
      }

      final profileData = {
        'displayName': _nameController.text.trim(),
        'age': _ageController.text.isNotEmpty
            ? int.tryParse(_ageController.text)
            : null,
        'gender': _selectedGender,
        'height': _heightController.text.isNotEmpty
            ? double.tryParse(_heightController.text)
            : null,
        'weight': _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        'chronicConditions': _selectedConditions,
        'healthGoals': _selectedGoals,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add profile image URL if available
      if (imageUrl != null) {
        profileData['profileImageUrl'] = imageUrl;
      } else if (_profileImageUrl != null && _profileImageFile == null) {
        // Keep existing URL if no new image selected
        profileData['profileImageUrl'] = _profileImageUrl;
      }

      final success = await _authService.updateUserData(profileData);

      if (success) {
        // Update display name in Firebase Auth
        final user = _authService.currentUser;
        if (user != null && user.displayName != _nameController.text.trim()) {
          await user.updateDisplayName(_nameController.text.trim());
        }

        setState(() {
          _isEditing = false;
          _isLoading = false;
          _profileImageUrl = imageUrl ?? _profileImageUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: healthGreen,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile'),
              backgroundColor: healthRed,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: healthRed,
          ),
        );
      }
    }
  }

  void _toggleEditMode() {
    if (_isEditing) {
      // Cancel editing - reload original data
      _loadUserData();
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Delete Account',
          fontSize: 18,
          color: textPrimary,
          fontFamily: 'Bold',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: 'Are you sure you want to delete your account?',
              fontSize: 16,
              color: textSecondary,
              fontFamily: 'Regular',
            ),
            const SizedBox(height: 12),
            TextWidget(
              text: 'This action cannot be undone and will permanently delete:',
              fontSize: 14,
              color: healthRed,
              fontFamily: 'Medium',
            ),
            const SizedBox(height: 8),
            ...const [
              '• Your profile information',
              '• All health data and records',
              '• Medication history',
              '• App settings and preferences'
            ].map((item) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: TextWidget(
                    text: item,
                    fontSize: 13,
                    color: textSecondary,
                    fontFamily: 'Regular',
                  ),
                )),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              color: textSecondary,
              fontFamily: 'Medium',
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog first

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Perform account deletion
              final result = await _authService.deleteAccount();

              // Close loading indicator
              Navigator.of(context).pop();

              if (context.mounted) {
                if (result.isSuccess) {
                  // Navigate to auth screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: healthGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: healthRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: TextWidget(
              text: 'Delete',
              fontSize: 14,
              color: healthRed,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: TextWidget(
          text: 'My Profile',
          fontSize: 20,
          color: textPrimary,
          fontFamily: 'Bold',
        ),
        backgroundColor: surface,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: _toggleEditMode,
              icon: const Icon(Icons.edit, color: primary),
            )
          else
            IconButton(
              onPressed: _toggleEditMode,
              icon: const Icon(Icons.close, color: healthRed),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  _buildProfileHeader(),

                  const SizedBox(height: 32),

                  // Profile Information
                  _buildProfileInfo(),

                  const SizedBox(height: 32),

                  // Health Information
                  _buildHealthInfo(),

                  const SizedBox(height: 32),

                  // Action Buttons
                  if (!_isEditing) ...[
                    ButtonWidget(
                      label: 'Logout',
                      onPressed: () => LogoutWidget.showLogoutDialog(context),
                      width: double.infinity,
                      height: 56,
                      color: textSecondary,
                    ),
                    const SizedBox(height: 16),
                    ButtonWidget(
                      label: 'Delete Account',
                      onPressed: _showDeleteAccountDialog,
                      width: double.infinity,
                      height: 56,
                      color: healthRed,
                    ),
                  ] else ...[
                    ButtonWidget(
                      label: 'Save Changes',
                      onPressed: _saveProfile,
                      isLoading: _isLoading,
                      width: double.infinity,
                      height: 56,
                      color: primary,
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isEditing ? _showImagePickerOptions : null,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accentDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: _profileImageFile != null
                        ? Image.file(
                            _profileImageFile!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : _profileImageUrl != null
                            ? Image.network(
                                _profileImageUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    color: white,
                                    size: 50,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.person,
                                color: white,
                                size: 50,
                              ),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: primary,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextWidget(
            text:
                _nameController.text.isNotEmpty ? _nameController.text : 'User',
            fontSize: 24,
            color: white,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 4),
          TextWidget(
            text: _emailController.text,
            fontSize: 16,
            color: white.withOpacity(0.9),
            fontFamily: 'Regular',
          ),
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextWidget(
                text: 'Tap profile picture to change',
                fontSize: 12,
                color: white.withOpacity(0.7),
                fontFamily: 'Regular',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Profile Information',
          fontSize: 18,
          color: textPrimary,
          fontFamily: 'Bold',
        ),
        const SizedBox(height: 16),

        // Name
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person,
          enabled: _isEditing,
        ),

        const SizedBox(height: 16),

        // Email (read-only)
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email,
          enabled: false,
        ),

        const SizedBox(height: 16),

        // Age
        _buildTextField(
          controller: _ageController,
          label: 'Age',
          icon: Icons.calendar_today,
          keyboardType: TextInputType.number,
          enabled: _isEditing,
        ),

        const SizedBox(height: 16),

        // Gender
        _buildDropdownField(
          label: 'Gender',
          icon: Icons.person_outline,
          value: _selectedGender,
          items: ['Male', 'Female', 'Other', 'Prefer not to say'],
          onChanged: _isEditing
              ? (value) => setState(() => _selectedGender = value)
              : null,
          enabled: _isEditing,
        ),

        const SizedBox(height: 16),

        // Height
        _buildTextField(
          controller: _heightController,
          label: 'Height (cm)',
          icon: Icons.height,
          keyboardType: TextInputType.number,
          enabled: _isEditing,
        ),

        const SizedBox(height: 16),

        // Weight
        _buildTextField(
          controller: _weightController,
          label: 'Weight (kg)',
          icon: Icons.monitor_weight,
          keyboardType: TextInputType.number,
          enabled: _isEditing,
        ),
      ],
    );
  }

  Widget _buildHealthInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Health Information',
          fontSize: 18,
          color: textPrimary,
          fontFamily: 'Bold',
        ),
        const SizedBox(height: 16),

        // Health Conditions
        TextWidget(
          text: 'Chronic Conditions',
          fontSize: 16,
          color: textSecondary,
          fontFamily: 'Medium',
        ),
        const SizedBox(height: 12),

        _buildConditionGrid(),

        const SizedBox(height: 24),

        // Health Goals
        TextWidget(
          text: 'Health Goals',
          fontSize: 16,
          color: textSecondary,
          fontFamily: 'Medium',
        ),
        const SizedBox(height: 12),

        _buildGoalsGrid(),
      ],
    );
  }

  Widget _buildConditionGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: _chronicConditions.length,
      itemBuilder: (context, index) {
        final condition = _chronicConditions[index];
        final isSelected = _selectedConditions.contains(condition);

        return GestureDetector(
          onTap: _isEditing
              ? () {
                  setState(() {
                    if (condition == 'None') {
                      _selectedConditions.clear();
                      _selectedConditions.add(condition);
                    } else {
                      _selectedConditions.remove('None');
                      if (isSelected) {
                        _selectedConditions.remove(condition);
                      } else {
                        _selectedConditions.add(condition);
                      }
                    }
                  });
                }
              : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? primary.withOpacity(0.1) : surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? primary : primary.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: TextWidget(
                text: condition,
                fontSize: 12,
                color: isSelected ? primary : textSecondary,
                fontFamily: isSelected ? 'Medium' : 'Regular',
                align: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: _healthGoals.length,
      itemBuilder: (context, index) {
        final goal = _healthGoals[index];
        final isSelected = _selectedGoals.contains(goal);

        return GestureDetector(
          onTap: _isEditing
              ? () {
                  setState(() {
                    if (isSelected) {
                      _selectedGoals.remove(goal);
                    } else {
                      _selectedGoals.add(goal);
                    }
                  });
                }
              : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? accent.withOpacity(0.1) : surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? accent : accent.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: TextWidget(
                text: goal,
                fontSize: 12,
                color: isSelected ? accentDark : textSecondary,
                fontFamily: isSelected ? 'Medium' : 'Regular',
                align: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: const TextStyle(
        fontFamily: 'Regular',
        fontSize: 16,
        color: textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Regular',
          color: enabled ? textSecondary : textLight,
        ),
        prefixIcon: Icon(icon, color: enabled ? textSecondary : textLight),
        filled: true,
        fillColor: enabled ? surface : textLight.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textLight.withOpacity(0.2)),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: enabled ? onChanged : null,
      style: const TextStyle(
        fontFamily: 'Regular',
        fontSize: 16,
        color: textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Regular',
          color: enabled ? textSecondary : textLight,
        ),
        prefixIcon: Icon(icon, color: enabled ? textSecondary : textLight),
        filled: true,
        fillColor: enabled ? surface : textLight.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textLight.withOpacity(0.2)),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}
