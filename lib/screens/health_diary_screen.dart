import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:amuma/services/firebase_service.dart';
import 'package:amuma/models/data_models.dart';
import 'package:intl/intl.dart';

class HealthDiaryScreen extends StatefulWidget {
  const HealthDiaryScreen({super.key});

  @override
  State<HealthDiaryScreen> createState() => _HealthDiaryScreenState();
}

class _HealthDiaryScreenState extends State<HealthDiaryScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  List<String> availableTags = [
    "Exercise",
    "Good mood",
    "Stress",
    "Work",
    "Sleep",
    "Energy",
    "Headache",
    "Tired",
    "Happy",
    "Anxious",
    "Relaxed",
    "Productive"
  ];

  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _bloodSugarController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _bloodSugarController.dispose();
    _weightController.dispose();
    _notesController.dispose();
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
          text: 'Health Diary',
          fontSize: 20,
          color: textLight,
          fontFamily: 'Bold',
        ),
        actions: [
          IconButton(
            onPressed: _showAddEntryDialog,
            icon: const Icon(Icons.add, color: primary),
          ),
        ],
      ),
      body: StreamBuilder<List<HealthEntryModel>>(
        stream: _firebaseService.getHealthEntries(limit: 30),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: healthRed, size: 48),
                  const SizedBox(height: 16),
                  TextWidget(
                    text: 'Error loading health entries',
                    fontSize: 16,
                    color: textSecondary,
                    fontFamily: 'Medium',
                  ),
                ],
              ),
            );
          }

          final healthEntries = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickStats(healthEntries),
                const SizedBox(height: 24),
                _buildWriteDiarySection(),
                const SizedBox(height: 24),
                _buildRecentEntriesSection(healthEntries),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(List<HealthEntryModel> entries) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    'Blood Pressure',
                    entries.isNotEmpty
                        ? '${entries.first.bloodPressureSystolic ?? '--'}/${entries.first.bloodPressureDiastolic ?? '--'}'
                        : '--/--',
                    'mmHg',
                    Icons.favorite,
                    healthRed)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard(
                    'Blood Sugar',
                    entries.isNotEmpty
                        ? '${entries.first.bloodSugar ?? '--'}'
                        : '--',
                    'mg/dL',
                    Icons.bloodtype,
                    primary)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    'Weight',
                    entries.isNotEmpty
                        ? '${entries.first.weight ?? '--'}'
                        : '--',
                    'kg',
                    Icons.monitor_weight,
                    accent)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard('Entries', '${entries.length}', 'total',
                    Icons.assignment, accentDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
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
              const Spacer(),
              TextWidget(
                  text: unit,
                  fontSize: 12,
                  color: textGrey,
                  fontFamily: 'Regular'),
            ],
          ),
          const SizedBox(height: 12),
          TextWidget(
              text: value, fontSize: 20, color: textLight, fontFamily: 'Bold'),
          TextWidget(
              text: title,
              fontSize: 12,
              color: textGrey,
              fontFamily: 'Regular'),
        ],
      ),
    );
  }

  Widget _buildWriteDiarySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.2)),
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
              Icon(Icons.edit, color: primary, size: 20),
              const SizedBox(width: 8),
              TextWidget(
                  text: 'Write diary',
                  fontSize: 16,
                  color: textPrimary,
                  fontFamily: 'Bold'),
              const Spacer(),
              GestureDetector(
                onTap: _showDiaryEntryDialog,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.add, color: white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showDiaryEntryDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextWidget(
                text: 'Write something about your day...',
                fontSize: 14,
                color: textLight,
                fontFamily: 'Regular',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntriesSection(List<HealthEntryModel> entries) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
                text: 'Recent Entries',
                fontSize: 18,
                color: textLight,
                fontFamily: 'Bold'),
            TextButton(
              onPressed: () => _showAllEntries(entries),
              child: TextWidget(
                  text: 'View All',
                  fontSize: 12,
                  color: primary,
                  fontFamily: 'Medium'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        entries.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.take(3).length,
                itemBuilder: (context, index) =>
                    _buildEntryCard(entries[index]),
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, color: textSecondary, size: 64),
          const SizedBox(height: 16),
          TextWidget(
              text: 'No health entries yet',
              fontSize: 18,
              color: textSecondary,
              fontFamily: 'Bold'),
          const SizedBox(height: 8),
          TextWidget(
              text: 'Start tracking your health by adding your first entry',
              fontSize: 14,
              color: textLight,
              fontFamily: 'Regular'),
          const SizedBox(height: 24),
          ButtonWidget(
            label: 'Add Health Entry',
            onPressed: _showAddEntryDialog,
            color: primary,
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(HealthEntryModel entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(
                text: DateFormat('MMM d, yyyy').format(entry.date),
                fontSize: 14,
                color: textLight,
                fontFamily: 'Bold',
              ),
              Row(
                children: [
                  TextWidget(
                    text: DateFormat('h:mm a').format(entry.createdAt),
                    fontSize: 12,
                    color: textGrey,
                    fontFamily: 'Regular',
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _deleteHealthEntry(entry.id),
                    child:
                        Icon(Icons.delete_outline, color: healthRed, size: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildEntryItem(
                      'BP',
                      '${entry.bloodPressureSystolic ?? '--'}/${entry.bloodPressureDiastolic ?? '--'}',
                      Icons.favorite,
                      Colors.red.shade400)),
              Expanded(
                  child: _buildEntryItem('Sugar', '${entry.bloodSugar ?? '--'}',
                      Icons.bloodtype, Colors.blue.shade400)),
              Expanded(
                  child: _buildEntryItem('Weight', '${entry.weight ?? '--'}',
                      Icons.monitor_weight, Colors.green.shade400)),
            ],
          ),
          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit, color: primary, size: 14),
                      const SizedBox(width: 4),
                      TextWidget(
                          text: 'Notes',
                          fontSize: 12,
                          color: primary,
                          fontFamily: 'Bold'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextWidget(
                      text: entry.notes!,
                      fontSize: 12,
                      color: textLight,
                      fontFamily: 'Regular'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEntryItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        TextWidget(
            text: value, fontSize: 12, color: textLight, fontFamily: 'Bold'),
        TextWidget(
            text: label, fontSize: 10, color: textGrey, fontFamily: 'Regular'),
      ],
    );
  }

  void _showAddEntryDialog() {
    _systolicController.clear();
    _diastolicController.clear();
    _bloodSugarController.clear();
    _weightController.clear();
    _notesController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
            text: 'Add Health Entry',
            fontSize: 18,
            color: textLight,
            fontFamily: 'Bold'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _systolicController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Systolic BP',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _diastolicController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Diastolic BP',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bloodSugarController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Blood Sugar (mg/dL)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
                text: 'Cancel',
                fontSize: 14,
                color: textGrey,
                fontFamily: 'Medium'),
          ),
          TextButton(
            onPressed: () {
              _addHealthEntry();
              Navigator.pop(context);
            },
            child: TextWidget(
                text: 'Save',
                fontSize: 14,
                color: primary,
                fontFamily: 'Medium'),
          ),
        ],
      ),
    );
  }

  Future<void> _addHealthEntry() async {
    if (_systolicController.text.isEmpty &&
        _diastolicController.text.isEmpty &&
        _bloodSugarController.text.isEmpty &&
        _weightController.text.isEmpty &&
        _notesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill at least one field'),
          backgroundColor: healthRed,
        ),
      );
      return;
    }

    final entry = HealthEntryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      bloodPressureSystolic: _systolicController.text.isNotEmpty
          ? int.tryParse(_systolicController.text)
          : null,
      bloodPressureDiastolic: _diastolicController.text.isNotEmpty
          ? int.tryParse(_diastolicController.text)
          : null,
      bloodSugar: _bloodSugarController.text.isNotEmpty
          ? int.tryParse(_bloodSugarController.text)
          : null,
      weight: _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: DateTime.now(),
    );

    final success = await _firebaseService.addHealthEntry(entry);

    if (success) {
      await _firebaseService.logActivity('health_entry', 'Health entry added');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Health entry saved successfully'),
            backgroundColor: healthGreen),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to save health entry'),
            backgroundColor: healthRed),
      );
    }
  }

  Future<void> _deleteHealthEntry(String entryId) async {
    final success = await _firebaseService.deleteHealthEntry(entryId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Health entry deleted'),
            backgroundColor: healthGreen),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to delete entry'),
            backgroundColor: healthRed),
      );
    }
  }

  void _showDiaryEntryDialog() {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
            text: 'Write Diary Entry',
            fontSize: 18,
            color: textLight,
            fontFamily: 'Bold'),
        content: TextField(
          controller: notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write something about your day...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
                text: 'Cancel',
                fontSize: 14,
                color: textGrey,
                fontFamily: 'Medium'),
          ),
          TextButton(
            onPressed: () {
              if (notesController.text.isNotEmpty) {
                _addDiaryEntry(notesController.text);
              }
              Navigator.pop(context);
            },
            child: TextWidget(
                text: 'Save',
                fontSize: 14,
                color: primary,
                fontFamily: 'Medium'),
          ),
        ],
      ),
    );
  }

  Future<void> _addDiaryEntry(String notes) async {
    final entry = HealthEntryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      notes: notes,
      createdAt: DateTime.now(),
    );

    final success = await _firebaseService.addHealthEntry(entry);

    if (success) {
      await _firebaseService.logActivity('diary_entry', 'Diary entry added');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Diary entry saved successfully'),
            backgroundColor: healthGreen),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to save diary entry'),
            backgroundColor: healthRed),
      );
    }
  }

  void _showAllEntries(List<HealthEntryModel> entries) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
            text: 'All Health Entries',
            fontSize: 18,
            color: textLight,
            fontFamily: 'Bold'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: entries.isEmpty
              ? const Center(child: Text('No entries found'))
              : ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) =>
                      _buildEntryCard(entries[index]),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
                text: 'Close',
                fontSize: 14,
                color: primary,
                fontFamily: 'Medium'),
          ),
        ],
      ),
    );
  }
}
