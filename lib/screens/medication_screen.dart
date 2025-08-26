import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:amuma/services/firebase_service.dart';
import 'package:amuma/models/data_models.dart';
import 'package:intl/intl.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  List<String> _medicationTimes = [];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: TextWidget(
          text: 'Medications',
          fontSize: 20,
          color: textLight,
          fontFamily: 'Bold',
        ),
        actions: [
          IconButton(
            onPressed: _showAddMedicationDialog,
            icon: const Icon(Icons.add, color: primary),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Overview
            FutureBuilder<Map<String, dynamic>>(
              future: _firebaseService.getMedicationStats(),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? {};
                final taken = stats['completedDoses'] ?? 0;
                final total = stats['totalDoses'] ?? 0;
                final progress = total > 0 ? taken / total : 0.0;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryLight.withOpacity(0.3),
                        primaryLight.withOpacity(0.1)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Today\'s Progress',
                        fontSize: 16,
                        color: primary,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildProgressIndicator(progress),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: '$taken/$total doses taken',
                                fontSize: 14,
                                color: textLight,
                                fontFamily: 'Medium',
                              ),
                              TextWidget(
                                text: DateFormat('EEEE, MMM d')
                                    .format(DateTime.now()),
                                fontSize: 12,
                                color: textGrey,
                                fontFamily: 'Regular',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Medications List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: 'Today\'s Schedule',
                  fontSize: 18,
                  color: textLight,
                  fontFamily: 'Bold',
                ),
                TextButton(
                  onPressed: _showLanguageToggle,
                  child: TextWidget(
                    text: 'EN/CEB',
                    fontSize: 12,
                    color: primary,
                    fontFamily: 'Medium',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<List<MedicationModel>>(
                stream: _firebaseService.getMedications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: healthRed,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          TextWidget(
                            text: 'Error loading medications',
                            fontSize: 16,
                            color: textSecondary,
                            fontFamily: 'Medium',
                          ),
                        ],
                      ),
                    );
                  }

                  final medications = snapshot.data ?? [];

                  if (medications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            color: textSecondary,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          TextWidget(
                            text: 'No medications added yet',
                            fontSize: 18,
                            color: textSecondary,
                            fontFamily: 'Bold',
                          ),
                          const SizedBox(height: 8),
                          TextWidget(
                            text:
                                'Tap the + button to add your first medication',
                            fontSize: 14,
                            color: textLight,
                            fontFamily: 'Regular',
                          ),
                          const SizedBox(height: 24),
                          ButtonWidget(
                            label: 'Add Medication',
                            onPressed: _showAddMedicationDialog,
                            color: primary,
                            width: 200,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: medications.length,
                    itemBuilder: (context, index) {
                      return _buildMedicationCard(medications[index], index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: primary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(primary),
            strokeWidth: 6,
          ),
          Center(
            child: TextWidget(
              text: '${(progress * 100).round()}%',
              fontSize: 12,
              color: primary,
              fontFamily: 'Bold',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(MedicationModel medication, int medIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication,
                  color: primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: medication.name,
                      fontSize: 16,
                      color: textLight,
                      fontFamily: 'Bold',
                    ),
                    TextWidget(
                      text: medication.dosage,
                      fontSize: 14,
                      color: textGrey,
                      fontFamily: 'Regular',
                    ),
                  ],
                ),
              ),
              // Delete medication button
              IconButton(
                onPressed: () => _showDeleteConfirmation(medication.id),
                icon: const Icon(Icons.delete_outline, color: healthRed),
                iconSize: 20,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Time slots
          ...medication.times.asMap().entries.map((entry) {
            final timeIndex = entry.key;
            final time = entry.value;
            final isCompleted = timeIndex < medication.isCompleted.length
                ? medication.isCompleted[timeIndex]
                : false;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompleted
                      ? Colors.green.shade300
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: isCompleted ? Colors.green : textGrey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextWidget(
                      text: time,
                      fontSize: 14,
                      color: isCompleted ? Colors.green.shade700 : textLight,
                      fontFamily: 'Medium',
                    ),
                  ),
                  if (!isCompleted) ...[
                    GestureDetector(
                      onTap: () => _markAsTaken(medication.id, timeIndex),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextWidget(
                          text: 'Taken',
                          fontSize: 12,
                          color: buttonText,
                          fontFamily: 'Medium',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _markAsMissed(medication.name),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextWidget(
                          text: 'Missed',
                          fontSize: 12,
                          color: buttonText,
                          fontFamily: 'Medium',
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, color: buttonText, size: 12),
                          const SizedBox(width: 4),
                          TextWidget(
                            text: 'Completed',
                            fontSize: 12,
                            color: buttonText,
                            fontFamily: 'Medium',
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _markAsTaken(String medicationId, int timeIndex) async {
    try {
      // Get current medication data
      final medications = await _firebaseService.getMedications().first;
      final medication =
          medications.firstWhere((med) => med.id == medicationId);

      // Update completion status
      List<bool> newCompletionStatus = List.from(medication.isCompleted);
      if (timeIndex < newCompletionStatus.length) {
        newCompletionStatus[timeIndex] = true;
      }

      // Update in Firebase
      final success = await _firebaseService.updateMedicationCompletion(
        medicationId,
        newCompletionStatus,
      );

      if (success) {
        // Log activity
        await _firebaseService.logActivity(
          'medication',
          'Medication taken: ${medication.name}',
          data: {
            'medicationId': medicationId,
            'dosage': medication.dosage,
            'time': medication.times[timeIndex],
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${medication.name} marked as taken'),
            backgroundColor: healthGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update medication status'),
            backgroundColor: healthRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating medication status'),
          backgroundColor: healthRed,
        ),
      );
    }
  }

  void _markAsMissed(String medicationName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Missed Dose',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Don\'t worry! Remember to take your next dose on time.',
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

  Future<void> _showDeleteConfirmation(String medicationId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Delete Medication',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Are you sure you want to delete this medication?',
          fontSize: 14,
          color: textGrey,
          fontFamily: 'Regular',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              color: textSecondary,
              fontFamily: 'Medium',
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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

    if (confirm == true) {
      final success = await _firebaseService.deleteMedication(medicationId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medication deleted successfully'),
            backgroundColor: healthGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete medication'),
            backgroundColor: healthRed,
          ),
        );
      }
    }
  }

  void _showAddMedicationDialog() {
    _nameController.clear();
    _dosageController.clear();
    _medicationTimes.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Add Medication',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Medication Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Medication Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dosage
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: 'Dosage (e.g., 500mg)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Times
              Row(
                children: [
                  TextWidget(
                    text: 'Times:',
                    fontSize: 14,
                    color: textLight,
                    fontFamily: 'Medium',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _addMedicationTime,
                    child: TextWidget(
                      text: 'Add Time',
                      fontSize: 12,
                      color: primary,
                      fontFamily: 'Medium',
                    ),
                  ),
                ],
              ),

              // Display added times
              ..._medicationTimes
                  .map((time) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.schedule, color: primary, size: 16),
                            const SizedBox(width: 8),
                            Text(time),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _medicationTimes.remove(time);
                                });
                              },
                              icon: const Icon(Icons.close, size: 16),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              color: textSecondary,
              fontFamily: 'Medium',
            ),
          ),
          TextButton(
            onPressed: _saveMedication,
            child: TextWidget(
              text: 'Save',
              fontSize: 14,
              color: primary,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addMedicationTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _medicationTimes.add(time.format(context));
      });
    }
  }

  Future<void> _saveMedication() async {
    if (_nameController.text.isEmpty ||
        _dosageController.text.isEmpty ||
        _medicationTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and add at least one time'),
          backgroundColor: healthRed,
        ),
      );
      return;
    }

    final medication = MedicationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      times: _medicationTimes,
      isCompleted: List.filled(_medicationTimes.length, false),
      createdAt: DateTime.now(),
    );

    final success = await _firebaseService.addMedication(medication);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medication.name} added successfully'),
          backgroundColor: healthGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add medication'),
          backgroundColor: healthRed,
        ),
      );
    }
  }

  void _showLanguageToggle() {
    // Placeholder for language toggle
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Language / Pinulongan',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: TextWidget(
                text: 'English',
                fontSize: 16,
                color: textLight,
                fontFamily: 'Regular',
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: TextWidget(
                text: 'Cebuano',
                fontSize: 16,
                color: textLight,
                fontFamily: 'Regular',
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
