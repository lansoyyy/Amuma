import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:amuma/services/firebase_service.dart';
import 'package:amuma/models/data_models.dart';

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
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Edit Profile',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Profile editing coming soon!',
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

  void _callEmergency() {
    // In a real app, this would make an actual call
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Emergency Call',
          fontSize: 18,
          color: Colors.red.shade700,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Calling emergency services...',
          fontSize: 14,
          color: textGrey,
          fontFamily: 'Regular',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              color: primary,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }

  void _shareProfile() {
    // In a real app, this would share the profile information
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Share Profile',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Sharing emergency profile information...',
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

  void _addContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Add Emergency Contact',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Contact management coming soon!',
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

  void _callContact(String phone) {
    // In a real app, this would make an actual call
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Calling',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Calling $phone...',
          fontSize: 14,
          color: textGrey,
          fontFamily: 'Regular',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              color: primary,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }

  void _callEmergencyNumber(String number) {
    // In a real app, this would make an actual call
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Emergency Call',
          fontSize: 18,
          color: Colors.red.shade700,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Calling $number...',
          fontSize: 14,
          color: textGrey,
          fontFamily: 'Regular',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'Cancel',
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
