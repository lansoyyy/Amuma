import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:amuma/widgets/app_text_form_field.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthDiaryScreen extends StatefulWidget {
  const HealthDiaryScreen({super.key});

  @override
  State<HealthDiaryScreen> createState() => _HealthDiaryScreenState();
}

class _HealthDiaryScreenState extends State<HealthDiaryScreen> {
  List<HealthEntry> healthEntries = [
    HealthEntry(
      date: DateTime.now().subtract(const Duration(days: 1)),
      bloodPressureSystolic: 120,
      bloodPressureDiastolic: 80,
      bloodSugar: 95,
      weight: 70.5,
      diaryNotes:
          "Feeling good today! Had a healthy breakfast and went for a 30-minute walk.",
      customTags: ["Exercise", "Good mood"],
    ),
    HealthEntry(
      date: DateTime.now().subtract(const Duration(days: 2)),
      bloodPressureSystolic: 125,
      bloodPressureDiastolic: 85,
      bloodSugar: 100,
      weight: 70.8,
      diaryNotes:
          "Had some stress at work today. Need to practice more relaxation techniques.",
      customTags: ["Stress", "Work"],
    ),
  ];

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Blood Pressure',
                    '${healthEntries.isNotEmpty ? healthEntries.first.bloodPressureSystolic : '--'}/${healthEntries.isNotEmpty ? healthEntries.first.bloodPressureDiastolic : '--'}',
                    'mmHg',
                    Icons.favorite,
                    healthRed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Blood Sugar',
                    '${healthEntries.isNotEmpty ? healthEntries.first.bloodSugar : '--'}',
                    'mg/dL',
                    Icons.bloodtype,
                    primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Weight',
                    '${healthEntries.isNotEmpty ? healthEntries.first.weight : '--'}',
                    'kg',
                    Icons.monitor_weight,
                    accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Entries',
                    '${healthEntries.length}',
                    'total',
                    Icons.assignment,
                    accentDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Chart Section
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text: 'Trends (7 days)',
                        fontSize: 16,
                        color: primary,
                        fontFamily: 'Bold',
                      ),
                      GestureDetector(
                        onTap: _showDetailedChart,
                        child: TextWidget(
                          text: 'View Details',
                          fontSize: 12,
                          color: primary,
                          fontFamily: 'Medium',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildLineChart(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Write Diary Section
            Container(
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
                        fontFamily: 'Bold',
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _showDiaryEntryDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: white,
                            size: 16,
                          ),
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
                  const SizedBox(height: 16),

                  // Custom Tags Section
                  Row(
                    children: [
                      TextWidget(
                        text: 'Create my own tags',
                        fontSize: 14,
                        color: textPrimary,
                        fontFamily: 'Bold',
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _showAddTagDialog,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextWidget(
                    text: 'Add any tag you want to track',
                    fontSize: 12,
                    color: textLight,
                    fontFamily: 'Regular',
                  ),
                  const SizedBox(height: 12),
                  _buildCustomTags(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Entries List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: 'Recent Entries',
                  fontSize: 18,
                  color: textLight,
                  fontFamily: 'Bold',
                ),
                TextButton(
                  onPressed: _showAllEntries,
                  child: TextWidget(
                    text: 'View All',
                    fontSize: 12,
                    color: primary,
                    fontFamily: 'Medium',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: healthEntries.take(3).length,
              itemBuilder: (context, index) {
                return _buildEntryCard(healthEntries[index]);
              },
            ),
          ],
        ),
      ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              TextWidget(
                text: unit,
                fontSize: 10,
                color: textGrey,
                fontFamily: 'Regular',
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextWidget(
            text: value,
            fontSize: 18,
            color: textLight,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 4),
          TextWidget(
            text: title,
            fontSize: 12,
            color: textGrey,
            fontFamily: 'Regular',
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    if (healthEntries.isEmpty) {
      return Center(
        child: TextWidget(
          text: 'No data to display',
          fontSize: 14,
          color: textGrey,
          fontFamily: 'Regular',
        ),
      );
    }

    // Prepare data for the last 7 days
    final last7Days = healthEntries.take(7).toList().reversed.toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: primary.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < last7Days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('M/d').format(last7Days[value.toInt()].date),
                      style: TextStyle(
                        color: textGrey,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 40,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: textGrey,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: primary.withOpacity(0.2), width: 1),
        ),
        minX: 0,
        maxX: (last7Days.length - 1).toDouble(),
        minY: 60,
        maxY: 180,
        lineBarsData: [
          // Blood Pressure Systolic Line
          LineChartBarData(
            spots: last7Days.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(),
                  entry.value.bloodPressureSystolic.toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.red.shade400,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.red.shade400,
                  strokeWidth: 2,
                  strokeColor: surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.shade400.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(HealthEntry entry) {
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
              TextWidget(
                text: DateFormat('h:mm a').format(entry.date),
                fontSize: 12,
                color: textGrey,
                fontFamily: 'Regular',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEntryItem(
                  'BP',
                  '${entry.bloodPressureSystolic}/${entry.bloodPressureDiastolic}',
                  Icons.favorite,
                  Colors.red.shade400,
                ),
              ),
              Expanded(
                child: _buildEntryItem(
                  'Sugar',
                  '${entry.bloodSugar}',
                  Icons.bloodtype,
                  Colors.blue.shade400,
                ),
              ),
              Expanded(
                child: _buildEntryItem(
                  'Weight',
                  '${entry.weight}',
                  Icons.monitor_weight,
                  Colors.green.shade400,
                ),
              ),
            ],
          ),

          // Display diary notes if available
          if (entry.diaryNotes != null && entry.diaryNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryLight.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit, color: primary, size: 14),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: 'Diary Notes',
                        fontSize: 12,
                        color: primary,
                        fontFamily: 'Bold',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextWidget(
                    text: entry.diaryNotes!,
                    fontSize: 12,
                    color: textLight,
                    fontFamily: 'Regular',
                  ),
                ],
              ),
            ),
          ],

          // Display custom tags if available
          if (entry.customTags != null && entry.customTags!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entry.customTags!.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withOpacity(0.4)),
                  ),
                  child: TextWidget(
                    text: tag,
                    fontSize: 10,
                    color: accentDark,
                    fontFamily: 'Medium',
                  ),
                );
              }).toList(),
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
          text: value,
          fontSize: 12,
          color: textLight,
          fontFamily: 'Bold',
        ),
        TextWidget(
          text: label,
          fontSize: 10,
          color: textGrey,
          fontFamily: 'Regular',
        ),
      ],
    );
  }

  void _showAddEntryDialog() {
    final bpSystolicController = TextEditingController();
    final bpDiastolicController = TextEditingController();
    final bloodSugarController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Add Health Entry',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: bpSystolicController,
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
                      controller: bpDiastolicController,
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
                controller: bloodSugarController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Blood Sugar (mg/dL)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
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
              fontFamily: 'Medium',
            ),
          ),
          TextButton(
            onPressed: () {
              _addHealthEntry(
                bpSystolicController.text,
                bpDiastolicController.text,
                bloodSugarController.text,
                weightController.text,
              );
              Navigator.pop(context);
            },
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

  void _addHealthEntry(
      String systolic, String diastolic, String bloodSugar, String weight) {
    if (systolic.isNotEmpty ||
        diastolic.isNotEmpty ||
        bloodSugar.isNotEmpty ||
        weight.isNotEmpty) {
      setState(() {
        healthEntries.insert(
            0,
            HealthEntry(
              date: DateTime.now(),
              bloodPressureSystolic: int.tryParse(systolic) ?? 0,
              bloodPressureDiastolic: int.tryParse(diastolic) ?? 0,
              bloodSugar: int.tryParse(bloodSugar) ?? 0,
              weight: double.tryParse(weight) ?? 0.0,
              diaryNotes:
                  null, // Health entries can be created without diary notes
              customTags: null, // Health entries can be created without tags
            ));
      });
      // Here you would save to local storage
    }
  }

  void _showAllEntries() {
    // Navigate to detailed entries view
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'All Entries',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Detailed entries view coming soon!',
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

  void _showDetailedChart() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: 'Health Trends',
                    fontSize: 20,
                    color: textLight,
                    fontFamily: 'Bold',
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: textGrey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildDetailedChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedChart() {
    if (healthEntries.isEmpty) {
      return Center(
        child: TextWidget(
          text: 'No data available',
          fontSize: 16,
          color: textGrey,
          fontFamily: 'Regular',
        ),
      );
    }

    final last30Days = healthEntries.take(30).toList().reversed.toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 20,
          verticalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: primary.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: primary.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < last30Days.length &&
                    value.toInt() % 5 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('M/d').format(last30Days[value.toInt()].date),
                      style: TextStyle(
                        color: textGrey,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 40,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: textGrey,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: primary.withOpacity(0.2), width: 1),
        ),
        minX: 0,
        maxX: (last30Days.length - 1).toDouble(),
        minY: 60,
        maxY: 200,
        lineBarsData: [
          // Blood Pressure Systolic
          LineChartBarData(
            spots: last30Days.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(),
                  entry.value.bloodPressureSystolic.toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.red.shade400,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
          ),
          // Blood Pressure Diastolic
          LineChartBarData(
            spots: last30Days.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(),
                  entry.value.bloodPressureDiastolic.toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.orange.shade400,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
          ),
          // Blood Sugar (scaled down to fit)
          LineChartBarData(
            spots: last30Days.asMap().entries.map((entry) {
              return FlSpot(
                  entry.key.toDouble(), entry.value.bloodSugar.toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.blue.shade400,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTags.map((tag) {
        return GestureDetector(
          onTap: () => _toggleTag(tag),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isTagSelected(tag) ? accent : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isTagSelected(tag) ? accent : Colors.grey.shade300,
              ),
            ),
            child: TextWidget(
              text: tag,
              fontSize: 12,
              color: _isTagSelected(tag) ? white : textLight,
              fontFamily: 'Medium',
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _isTagSelected(String tag) {
    // Check if tag is used in any recent entry (simplified logic)
    return healthEntries.any(
        (entry) => entry.customTags != null && entry.customTags!.contains(tag));
  }

  void _toggleTag(String tag) {
    // For now, just show the diary dialog when tag is tapped
    _showDiaryEntryDialog();
  }

  void _showDiaryEntryDialog() {
    final notesController = TextEditingController();
    List<String> selectedTags = [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Write Diary Entry',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date selector
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: primary, size: 16),
                    const SizedBox(width: 8),
                    TextWidget(
                      text: DateFormat('MMM d, yyyy').format(DateTime.now()),
                      fontSize: 14,
                      color: textLight,
                      fontFamily: 'Medium',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Notes input
                TextField(
                  controller: notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Write something about your day...',
                    hintStyle: TextStyle(color: textLight.withOpacity(0.6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tags section
                TextWidget(
                  text: 'How are you feeling?',
                  fontSize: 14,
                  color: textLight,
                  fontFamily: 'Bold',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableTags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          if (isSelected) {
                            selectedTags.remove(tag);
                          } else {
                            selectedTags.add(tag);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? accent : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? accent : Colors.grey.shade300,
                          ),
                        ),
                        child: TextWidget(
                          text: tag,
                          fontSize: 12,
                          color: isSelected ? white : textLight,
                          fontFamily: 'Medium',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              color: textGrey,
              fontFamily: 'Medium',
            ),
          ),
          TextButton(
            onPressed: () {
              if (notesController.text.isNotEmpty || selectedTags.isNotEmpty) {
                _addDiaryEntry(notesController.text, selectedTags);
              }
              Navigator.pop(context);
            },
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

  void _showAddTagDialog() {
    final tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Add Custom Tag',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: TextField(
          controller: tagController,
          decoration: InputDecoration(
            hintText: 'Enter tag name...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              color: textGrey,
              fontFamily: 'Medium',
            ),
          ),
          TextButton(
            onPressed: () {
              if (tagController.text.isNotEmpty) {
                setState(() {
                  if (!availableTags.contains(tagController.text)) {
                    availableTags.add(tagController.text);
                  }
                });
              }
              Navigator.pop(context);
            },
            child: TextWidget(
              text: 'Add',
              fontSize: 14,
              color: primary,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }

  void _addDiaryEntry(String notes, List<String> tags) {
    setState(() {
      // Create a new health entry with diary notes and tags
      healthEntries.insert(
          0,
          HealthEntry(
            date: DateTime.now(),
            bloodPressureSystolic: 0,
            bloodPressureDiastolic: 0,
            bloodSugar: 0,
            weight: 0.0,
            diaryNotes: notes,
            customTags: tags,
          ));
    });
    // Here you would save to local storage
  }
}

class HealthEntry {
  final DateTime date;
  final int bloodPressureSystolic;
  final int bloodPressureDiastolic;
  final int bloodSugar;
  final double weight;
  final String? diaryNotes; // Added diary notes field
  final List<String>? customTags; // Added custom tags field

  HealthEntry({
    required this.date,
    required this.bloodPressureSystolic,
    required this.bloodPressureDiastolic,
    required this.bloodSugar,
    required this.weight,
    this.diaryNotes,
    this.customTags,
  });
}
