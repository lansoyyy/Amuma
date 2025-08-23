import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:intl/intl.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  List<Medication> medications = [
    Medication(
      name: 'Metformin',
      dosage: '500mg',
      times: ['8:00 AM', '8:00 PM'],
      isCompleted: [false, false],
    ),
    Medication(
      name: 'Lisinopril',
      dosage: '10mg',
      times: ['9:00 AM'],
      isCompleted: [false],
    ),
  ];

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
            Container(
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
                      _buildProgressIndicator(),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text:
                                '${_getTakenCount()}/${_getTotalCount()} doses taken',
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
              child: ListView.builder(
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  return _buildMedicationCard(medications[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final taken = _getTakenCount();
    final total = _getTotalCount();
    final progress = total > 0 ? taken / total : 0.0;

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

  Widget _buildMedicationCard(Medication medication, int medIndex) {
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
            ],
          ),

          const SizedBox(height: 16),

          // Time slots
          ...medication.times.asMap().entries.map((entry) {
            final timeIndex = entry.key;
            final time = entry.value;
            final isCompleted = medication.isCompleted[timeIndex];

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
                      onTap: () => _markAsTaken(medIndex, timeIndex),
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
                      onTap: () => _markAsMissed(medIndex, timeIndex),
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

  int _getTakenCount() {
    int count = 0;
    for (var medication in medications) {
      count += medication.isCompleted.where((completed) => completed).length;
    }
    return count;
  }

  int _getTotalCount() {
    int count = 0;
    for (var medication in medications) {
      count += medication.times.length;
    }
    return count;
  }

  void _markAsTaken(int medIndex, int timeIndex) {
    setState(() {
      medications[medIndex].isCompleted[timeIndex] = true;
    });
    // Here you would save to local storage
  }

  void _markAsMissed(int medIndex, int timeIndex) {
    // Handle missed medication logic
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

  void _showAddMedicationDialog() {
    // Placeholder for add medication dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Add Medication',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Medication management coming soon!',
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

class Medication {
  final String name;
  final String dosage;
  final List<String> times;
  final List<bool> isCompleted;

  Medication({
    required this.name,
    required this.dosage,
    required this.times,
    required this.isCompleted,
  });
}
