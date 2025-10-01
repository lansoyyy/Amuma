import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:amuma/services/firebase_service.dart';
import 'package:amuma/models/data_models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class EmergencyProfileScreen extends StatefulWidget {
  const EmergencyProfileScreen({super.key});

  @override
  State<EmergencyProfileScreen> createState() => _EmergencyProfileScreenState();
}

class _EmergencyProfileScreenState extends State<EmergencyProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: TextWidget(
          text: 'Emergency Profile',
          fontSize: 20,
          color: textLight,
          fontFamily: 'Bold',
        ),
        actions: [
          IconButton(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit, color: primary),
          ),
        ],
      ),
      body: FutureBuilder<UserProfileModel?>(
        future: _firebaseService.getUserProfile(),
        builder: (context, profileSnapshot) {
          return StreamBuilder<List<EmergencyContactModel>>(
            stream: _firebaseService.getEmergencyContacts(),
            builder: (context, contactsSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting ||
                  contactsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (profileSnapshot.hasError || contactsSnapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: healthRed, size: 48),
                      const SizedBox(height: 16),
                      TextWidget(
                        text: 'Error loading profile',
                        fontSize: 16,
                        color: healthRed,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 8),
                      TextWidget(
                        text: 'Please check your connection and try again',
                        fontSize: 12,
                        color: textGrey,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                );
              }

              final profile = profileSnapshot.data;
              final emergencyContacts = contactsSnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Emergency Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.emergency,
                            color: Colors.red.shade600,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          TextWidget(
                            text: 'MEDICAL EMERGENCY ID',
                            fontSize: 16,
                            color: Colors.red.shade700,
                            fontFamily: 'Bold',
                          ),
                          const SizedBox(height: 4),
                          TextWidget(
                            text: 'Show this to medical personnel',
                            fontSize: 12,
                            color: Colors.red.shade600,
                            fontFamily: 'Regular',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Check if profile exists
                    if (profile == null) ...[
                      _buildNoProfileCard(),
                      const SizedBox(height: 16),
                    ] else ...[
                      // Patient Information
                      _buildSectionCard(
                        'Patient Information',
                        Icons.person,
                        primary,
                        [
                          _buildInfoRow(
                              'Full Name', profile.name ?? 'Not specified'),
                          _buildInfoRow('Date of Birth',
                              profile.dateOfBirth ?? 'Not specified'),
                          _buildInfoRow(
                              'Gender', profile.gender ?? 'Not specified'),
                          _buildInfoRow('Blood Type',
                              profile.bloodType ?? 'Not specified'),
                          _buildInfoRow(
                              'Known Allergies',
                              profile.allergies?.join(', ') ??
                                  'None specified'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Medical Conditions
                      if (profile.chronicConditions != null &&
                          profile.chronicConditions!.isNotEmpty)
                        _buildSectionCard(
                          'Medical Conditions',
                          Icons.medical_services,
                          Colors.orange.shade600,
                          profile.chronicConditions!
                              .map((condition) => _buildBulletPoint(condition))
                              .toList(),
                        ),

                      if (profile.chronicConditions != null &&
                          profile.chronicConditions!.isNotEmpty)
                        const SizedBox(height: 16),
                    ],

                    // Current Medications (from Firebase)
                    StreamBuilder<List<MedicationModel>>(
                      stream: _firebaseService.getMedications(),
                      builder: (context, medicationSnapshot) {
                        if (medicationSnapshot.hasData &&
                            medicationSnapshot.data!.isNotEmpty) {
                          return Column(
                            children: [
                              _buildSectionCard(
                                'Current Medications',
                                Icons.medication,
                                Colors.blue.shade600,
                                medicationSnapshot.data!
                                    .map((medication) => _buildBulletPoint(
                                        '${medication.name} - ${medication.dosage}'))
                                    .toList(),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Emergency Contacts
                    _buildContactsSection(emergencyContacts),

                    const SizedBox(height: 16),

                    // Emergency Numbers
                    _buildEmergencyNumbers(),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ButtonWidget(
                            label: 'Call 911',
                            onPressed: _callEmergency,
                            color: Colors.red.shade600,
                            icon: const Icon(Icons.phone, color: buttonText),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ButtonWidget(
                            label: 'Share Profile',
                            onPressed: _shareProfile,
                            color: primary,
                            icon: const Icon(Icons.share, color: buttonText),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(
      String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextWidget(
                  text: title,
                  fontSize: 16,
                  color: textLight,
                  fontFamily: 'Bold',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: TextWidget(
              text: '$label:',
              fontSize: 14,
              color: textGrey,
              fontFamily: 'Medium',
            ),
          ),
          Expanded(
            child: TextWidget(
              text: value,
              fontSize: 14,
              color: textLight,
              fontFamily: 'Regular',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: const BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: TextWidget(
              text: text,
              fontSize: 14,
              color: textLight,
              fontFamily: 'Regular',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_outlined,
            color: Colors.orange.shade600,
            size: 32,
          ),
          const SizedBox(height: 8),
          TextWidget(
            text: 'Profile Not Complete',
            fontSize: 16,
            color: Colors.orange.shade700,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 4),
          TextWidget(
            text:
                'Please complete your medical profile for emergency situations',
            fontSize: 12,
            color: Colors.orange.shade600,
            fontFamily: 'Regular',
            align: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ButtonWidget(
            label: 'Complete Profile',
            onPressed: _editProfile,
            color: Colors.orange.shade600,
            height: 36,
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildContactsSection(List<EmergencyContactModel> contacts) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.contacts,
                    color: Colors.green.shade600, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextWidget(
                  text: 'Emergency Contacts',
                  fontSize: 16,
                  color: textLight,
                  fontFamily: 'Bold',
                ),
              ),
              IconButton(
                onPressed: _addContact,
                icon: Icon(Icons.add, color: Colors.green.shade600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (contacts.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: textGrey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextWidget(
                      text: 'No emergency contacts added yet',
                      fontSize: 12,
                      color: textGrey,
                      fontFamily: 'Regular',
                    ),
                  ),
                ],
              ),
            )
          else
            ...contacts.map((contact) => _buildContactCard(contact)).toList(),
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContactModel contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: contact.name,
                  fontSize: 14,
                  color: textLight,
                  fontFamily: 'Bold',
                ),
                TextWidget(
                  text: contact.relationship,
                  fontSize: 12,
                  color: textGrey,
                  fontFamily: 'Regular',
                ),
                TextWidget(
                  text: contact.phone,
                  fontSize: 12,
                  color: primary,
                  fontFamily: 'Medium',
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _callContact(contact.phone),
            icon: const Icon(Icons.phone, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyNumbers() {
    final emergencyNumbers = [
      {'name': 'Emergency Hotline', 'number': '911'},
      {'name': 'DOH Hotline', 'number': '1555'},
      {'name': 'Red Cross', 'number': '143'},
      {'name': 'NDRRMC', 'number': '(02) 8911-1406'},
      {'name': 'Health Center', 'number': '2537734'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emergency_share, color: Colors.red.shade600, size: 20),
              const SizedBox(width: 8),
              TextWidget(
                text: 'Emergency Hotlines',
                fontSize: 16,
                color: Colors.red.shade700,
                fontFamily: 'Bold',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...emergencyNumbers
              .map(
                (emergency) => GestureDetector(
                  onTap: () => _callEmergencyNumber(emergency['number']!),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextWidget(
                            text: emergency['name']!,
                            fontSize: 14,
                            color: textLight,
                            fontFamily: 'Medium',
                          ),
                        ),
                        TextWidget(
                          text: emergency['number']!,
                          fontSize: 14,
                          color: Colors.red.shade600,
                          fontFamily: 'Bold',
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.phone, color: Colors.red.shade600, size: 16),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => _EditProfileDialog(
        firebaseService: _firebaseService,
        onProfileUpdated: () => setState(() {}),
      ),
    );
  }

  Future<void> _callEmergency() async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: '911');
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorDialog('Unable to make call', 'Phone app not available');
      }
    } catch (e) {
      _showErrorDialog('Call Failed', 'Unable to make emergency call');
    }
  }

  Future<void> _shareProfile() async {
    try {
      final profile = await _firebaseService.getUserProfile();
      final medications = await _firebaseService.getMedications().first;
      final contacts = await _firebaseService.getEmergencyContacts().first;

      String profileText = '🆘 EMERGENCY MEDICAL PROFILE 🆘\n\n';

      if (profile != null) {
        profileText += '👤 PATIENT INFORMATION:\n';
        profileText += 'Name: ${profile.name ?? "Not specified"}\n';
        profileText += 'DOB: ${profile.dateOfBirth ?? "Not specified"}\n';
        profileText += 'Gender: ${profile.gender ?? "Not specified"}\n';
        profileText += 'Blood Type: ${profile.bloodType ?? "Not specified"}\n';

        if (profile.allergies != null && profile.allergies!.isNotEmpty) {
          profileText += 'Allergies: ${profile.allergies!.join(", ")}\n';
        }

        if (profile.chronicConditions != null &&
            profile.chronicConditions!.isNotEmpty) {
          profileText += '\n🏥 MEDICAL CONDITIONS:\n';
          for (String condition in profile.chronicConditions!) {
            profileText += '• $condition\n';
          }
        }
      }

      if (medications.isNotEmpty) {
        profileText += '\n💊 CURRENT MEDICATIONS:\n';
        for (var medication in medications) {
          profileText += '• ${medication.name} - ${medication.dosage}\n';
        }
      }

      if (contacts.isNotEmpty) {
        profileText += '\n📞 EMERGENCY CONTACTS:\n';
        for (var contact in contacts) {
          profileText +=
              '• ${contact.name} (${contact.relationship}): ${contact.phone}\n';
        }
      }

      profileText += '\n🚨 EMERGENCY NUMBERS:\n';
      profileText += '• Emergency Hotline: 911\n';
      profileText += '• DOH Hotline: 1555\n';
      profileText += '• Red Cross: 143\n';
      profileText += '• NDRRMC: (02) 8911-1406\n';

      await Share.share(
        profileText,
        subject: 'Emergency Medical Profile',
      );
    } catch (e) {
      _showErrorDialog('Share Failed', 'Unable to share profile information');
    }
  }

  void _addContact() {
    showDialog(
      context: context,
      builder: (context) => _AddContactDialog(
        firebaseService: _firebaseService,
        onContactAdded: () => setState(() {}),
      ),
    );
  }

  Future<void> _callContact(String phone) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorDialog('Unable to make call', 'Phone app not available');
      }
    } catch (e) {
      _showErrorDialog('Call Failed', 'Unable to call $phone');
    }
  }

  Future<void> _callEmergencyNumber(String number) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorDialog('Unable to make call', 'Phone app not available');
      }
    } catch (e) {
      _showErrorDialog('Call Failed', 'Unable to call $number');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: title,
          fontSize: 18,
          color: Colors.red.shade700,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: message,
          fontSize: 14,
          color: textGrey,
          fontFamily: 'Regular',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'OK',
              fontSize: 14,
              color: primary,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }
}

// Edit Profile Dialog Widget
class _EditProfileDialog extends StatefulWidget {
  final FirebaseService firebaseService;
  final VoidCallback onProfileUpdated;

  const _EditProfileDialog({
    required this.firebaseService,
    required this.onProfileUpdated,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();

  String? _selectedGender;
  List<String> _selectedConditions = [];
  bool _isLoading = false;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say'
  ];
  final List<String> _conditions = [
    'Diabetes Mellitus',
    'Hypertension',
    'Chronic Kidney Disease',
    'Cardiovascular Disease',
    'Asthma',
    'Arthritis',
    'Depression/Anxiety',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final profile = await widget.firebaseService.getUserProfile();
    if (profile != null) {
      setState(() {
        _nameController.text = profile.name ?? '';
        _dobController.text = profile.dateOfBirth ?? '';
        _bloodTypeController.text = profile.bloodType ?? '';
        _selectedGender = profile.gender;
        _allergiesController.text = profile.allergies?.join(', ') ?? '';
        _selectedConditions = profile.chronicConditions ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextWidget(
        text: 'Edit Emergency Profile',
        fontSize: 18,
        color: textLight,
        fontFamily: 'Bold',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date of Birth
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                    hintText: '1990-01-15',
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now()
                          .subtract(const Duration(days: 365 * 25)),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      _dobController.text =
                          pickedDate.toIso8601String().split('T')[0];
                    }
                  },
                  readOnly: true,
                ),
                const SizedBox(height: 16),

                // Gender
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: _genders
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
                const SizedBox(height: 16),

                // Blood Type
                DropdownButtonFormField<String>(
                  value: _bloodTypes.contains(_bloodTypeController.text)
                      ? _bloodTypeController.text
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Blood Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _bloodTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) => _bloodTypeController.text = value ?? '',
                ),
                const SizedBox(height: 16),

                // Allergies
                TextFormField(
                  controller: _allergiesController,
                  decoration: const InputDecoration(
                    labelText: 'Known Allergies (comma-separated)',
                    border: OutlineInputBorder(),
                    hintText: 'Penicillin, Peanuts, Shellfish',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Medical Conditions
                TextWidget(
                  text: 'Medical Conditions:',
                  fontSize: 14,
                  color: textLight,
                  fontFamily: 'Medium',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _conditions.map((condition) {
                    final isSelected = _selectedConditions.contains(condition);
                    return FilterChip(
                      label: Text(
                        condition,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : textGrey,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: primary,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedConditions.add(condition);
                          } else {
                            _selectedConditions.remove(condition);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: TextWidget(
            text: 'Cancel',
            fontSize: 14,
            color: textGrey,
            fontFamily: 'Medium',
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _saveProfile,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextWidget(
                  text: 'Save',
                  fontSize: 14,
                  color: primary,
                  fontFamily: 'Medium',
                ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profile = UserProfileModel(
        name: _nameController.text.trim(),
        dateOfBirth:
            _dobController.text.isNotEmpty ? _dobController.text : null,
        gender: _selectedGender,
        bloodType: _bloodTypeController.text.isNotEmpty
            ? _bloodTypeController.text
            : null,
        chronicConditions:
            _selectedConditions.isNotEmpty ? _selectedConditions : null,
        allergies: _allergiesController.text.isNotEmpty
            ? _allergiesController.text.split(',').map((e) => e.trim()).toList()
            : null,
        preferredLanguage: 'EN',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await widget.firebaseService.saveUserProfile(profile);

      if (success) {
        widget.onProfileUpdated();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: healthGreen,
          ),
        );
      } else {
        throw Exception('Failed to save profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: ${e.toString()}'),
          backgroundColor: healthRed,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }
}

// Add Contact Dialog Widget
class _AddContactDialog extends StatefulWidget {
  final FirebaseService firebaseService;
  final VoidCallback onContactAdded;

  const _AddContactDialog({
    required this.firebaseService,
    required this.onContactAdded,
  });

  @override
  State<_AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<_AddContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController();
  bool _isPrimary = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextWidget(
        text: 'Add Emergency Contact',
        fontSize: 18,
        color: textLight,
        fontFamily: 'Bold',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contact Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name*',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Contact name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number*',
                border: OutlineInputBorder(),
                hintText: '+63 912 345 6789',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Phone number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Relationship
            TextFormField(
              controller: _relationshipController,
              decoration: const InputDecoration(
                labelText: 'Relationship*',
                border: OutlineInputBorder(),
                hintText: 'Spouse, Parent, Sibling, Friend, etc.',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Relationship is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Primary Contact Checkbox
            Row(
              children: [
                Checkbox(
                  value: _isPrimary,
                  onChanged: (value) =>
                      setState(() => _isPrimary = value ?? false),
                ),
                Expanded(
                  child: TextWidget(
                    text: 'Primary Emergency Contact',
                    fontSize: 14,
                    color: textLight,
                    fontFamily: 'Regular',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: TextWidget(
            text: 'Cancel',
            fontSize: 14,
            color: textGrey,
            fontFamily: 'Medium',
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _saveContact,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextWidget(
                  text: 'Add Contact',
                  fontSize: 14,
                  color: primary,
                  fontFamily: 'Medium',
                ),
        ),
      ],
    );
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final contact = EmergencyContactModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        relationship: _relationshipController.text.trim(),
        isPrimary: _isPrimary,
      );

      final success = await widget.firebaseService.addEmergencyContact(contact);

      if (success) {
        widget.onContactAdded();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency contact added successfully'),
            backgroundColor: healthGreen,
          ),
        );
      } else {
        throw Exception('Failed to save contact');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding contact: ${e.toString()}'),
          backgroundColor: healthRed,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }
}
