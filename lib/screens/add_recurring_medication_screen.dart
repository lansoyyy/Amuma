import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:amuma/services/firebase_service.dart';
import 'package:amuma/models/data_models.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddRecurringMedicationScreen extends StatefulWidget {
  const AddRecurringMedicationScreen({super.key});

  @override
  State<AddRecurringMedicationScreen> createState() =>
      _AddRecurringMedicationScreenState();
}

class _AddRecurringMedicationScreenState
    extends State<AddRecurringMedicationScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = Uuid();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  List<String> _medicationTimes = [];
  String _recurringType = 'daily';
  List<int> _selectedDays = [];
  DateTime? _startDate;
  DateTime? _endDate;

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
          text: 'Add Recurring Medication',
          fontSize: 20,
          color: textLight,
          fontFamily: 'Bold',
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: textLight),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication Name
            TextWidget(
              text: 'Medication Name',
              fontSize: 16,
              color: textLight,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g., Aspirin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primary),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 20),

            // Dosage
            TextWidget(
              text: 'Dosage',
              fontSize: 16,
              color: textLight,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dosageController,
              decoration: InputDecoration(
                hintText: 'e.g., 500mg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primary),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 20),

            // Medication Times
            TextWidget(
              text: 'Medication Times',
              fontSize: 16,
              color: textLight,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextWidget(
                    text: 'Add times when you need to take this medication',
                    fontSize: 14,
                    color: textGrey,
                    fontFamily: 'Regular',
                  ),
                ),
                ButtonWidget(
                  label: 'Add Time',
                  onPressed: _addMedicationTime,
                  color: primary,
                  width: 120,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Display added times
            ..._medicationTimes
                .map((time) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.schedule, color: primary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextWidget(
                                text: time,
                                fontSize: 14,
                                color: textLight,
                                fontFamily: 'Medium',
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _medicationTimes.remove(time);
                                });
                              },
                              icon: const Icon(Icons.close, size: 16),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),

            const SizedBox(height: 20),

            // Recurring Type
            TextWidget(
              text: 'Recurring Schedule',
              fontSize: 16,
              color: textLight,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildRecurringOption('daily', 'Every Day'),
                  _buildRecurringOption('weekdays', 'Weekdays (Mon-Fri)'),
                  _buildRecurringOption('specific_days', 'Specific Days'),
                ],
              ),
            ),

            // Specific days selection
            if (_recurringType == 'specific_days') ...[
              const SizedBox(height: 16),
              TextWidget(
                text: 'Select Days',
                fontSize: 16,
                color: textLight,
                fontFamily: 'Bold',
              ),
              const SizedBox(height: 12),
              _buildDaySelector(),
            ],

            const SizedBox(height: 20),

            // Date Range
            TextWidget(
              text: 'Date Range (Optional)',
              fontSize: 16,
              color: textLight,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectStartDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: 'Start Date',
                            fontSize: 12,
                            color: textGrey,
                            fontFamily: 'Regular',
                          ),
                          const SizedBox(height: 4),
                          TextWidget(
                            text: _startDate != null
                                ? DateFormat('MMM d, y').format(_startDate!)
                                : 'Select start date',
                            fontSize: 14,
                            color: textLight,
                            fontFamily: 'Medium',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectEndDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: 'End Date',
                            fontSize: 12,
                            color: textGrey,
                            fontFamily: 'Regular',
                          ),
                          const SizedBox(height: 4),
                          TextWidget(
                            text: _endDate != null
                                ? DateFormat('MMM d, y').format(_endDate!)
                                : 'No end date',
                            fontSize: 14,
                            color: textLight,
                            fontFamily: 'Medium',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ButtonWidget(
                label: 'Save Recurring Medication',
                onPressed: _saveRecurringMedication,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringOption(String value, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _recurringType = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _recurringType == value
              ? primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _recurringType == value ? primary : Colors.grey.shade300,
            width: _recurringType == value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _recurringType == value
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: _recurringType == value ? primary : Colors.grey,
            ),
            const SizedBox(width: 12),
            TextWidget(
              text: label,
              fontSize: 14,
              color: textLight,
              fontFamily: 'Medium',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final dayIndex = index;
              final isSelected = _selectedDays.contains(dayIndex);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDays.remove(dayIndex);
                    } else {
                      _selectedDays.add(dayIndex);
                    }
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? primary : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: TextWidget(
                      text: days[index],
                      fontSize: 12,
                      color: isSelected ? Colors.white : textLight,
                      fontFamily: 'Medium',
                    ),
                  ),
                ),
              );
            }),
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

  Future<void> _selectStartDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _saveRecurringMedication() async {
    if (_nameController.text.isEmpty ||
        _dosageController.text.isEmpty ||
        _medicationTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_recurringType == 'specific_days' && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final medication = MedicationModel(
      id: _uuid.v4(),
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      times: _medicationTimes,
      isCompleted: List.filled(_medicationTimes.length, false),
      createdAt: DateTime.now(),
      isRecurring: true,
      recurringDays: _selectedDays,
      recurringType: _recurringType,
      startDate: _startDate,
      endDate: _endDate,
    );

    final success = await _firebaseService.saveRecurringMedication(medication);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${medication.name} recurring medication added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add recurring medication'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
