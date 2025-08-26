import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:amuma/services/firebase_service.dart';
import 'package:amuma/models/data_models.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late TabController _tabController;

  List<MedicationNotification> _pendingNotifications = [];
  List<MedicationNotification> _todayNotifications = [];
  List<MedicationNotification> _historyNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final medications = await _firebaseService.getMedications().first;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      List<MedicationNotification> allNotifications = [];

      for (var medication in medications) {
        for (int i = 0; i < medication.times.length; i++) {
          final timeString = medication.times[i];
          final isCompleted = i < medication.isCompleted.length
              ? medication.isCompleted[i]
              : false;

          final notification = MedicationNotification(
            id: '${medication.id}_$i',
            medicationId: medication.id,
            medicationName: medication.name,
            dosage: medication.dosage,
            scheduledTime: timeString,
            isCompleted: isCompleted,
            date: today,
            timeIndex: i,
          );

          allNotifications.add(notification);
        }
      }

      // Sort notifications by time
      allNotifications.sort((a, b) =>
          _parseTime(a.scheduledTime).compareTo(_parseTime(b.scheduledTime)));

      setState(() {
        _todayNotifications = allNotifications;
        _pendingNotifications =
            allNotifications.where((n) => !n.isCompleted).toList();
        _historyNotifications =
            allNotifications.where((n) => n.isCompleted).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  DateTime _parseTime(String timeString) {
    try {
      final parts = timeString.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      } else if (parts.length > 1 &&
          parts[1].toUpperCase() == 'AM' &&
          hour == 12) {
        hour = 0;
      }

      return DateTime(2023, 1, 1, hour, minute);
    } catch (e) {
      return DateTime(2023, 1, 1, 0, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: textLight),
        ),
        title: TextWidget(
          text: 'Notifications',
          fontSize: 20,
          color: textLight,
          fontFamily: 'Bold',
        ),
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all, color: primary),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primary,
          unselectedLabelColor: textGrey,
          indicatorColor: primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_active, size: 16),
                  const SizedBox(width: 4),
                  Text('Pending (${_pendingNotifications.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.today, size: 16),
                  const SizedBox(width: 4),
                  Text('Today (${_todayNotifications.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history, size: 16),
                  const SizedBox(width: 4),
                  Text('History (${_historyNotifications.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Header
                _buildSummaryHeader(),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNotificationsList(_pendingNotifications,
                          isPending: true),
                      _buildNotificationsList(_todayNotifications,
                          isToday: true),
                      _buildNotificationsList(_historyNotifications,
                          isHistory: true),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryHeader() {
    final pendingCount = _pendingNotifications.length;
    final completedToday = _historyNotifications.length;
    final totalToday = _todayNotifications.length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pendingCount > 0
              ? [Colors.orange.shade100, Colors.orange.shade50]
              : [Colors.green.shade100, Colors.green.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              pendingCount > 0 ? Colors.orange.shade300 : Colors.green.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: pendingCount > 0
                  ? Colors.orange.shade200
                  : Colors.green.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              pendingCount > 0
                  ? Icons.notification_important
                  : Icons.check_circle,
              color: pendingCount > 0
                  ? Colors.orange.shade700
                  : Colors.green.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: pendingCount > 0
                      ? 'You have $pendingCount pending medications'
                      : 'All medications completed today!',
                  fontSize: 16,
                  color: pendingCount > 0
                      ? Colors.orange.shade700
                      : Colors.green.shade700,
                  fontFamily: 'Bold',
                ),
                const SizedBox(height: 4),
                TextWidget(
                  text: 'Progress: $completedToday of $totalToday doses taken',
                  fontSize: 14,
                  color: pendingCount > 0
                      ? Colors.orange.shade600
                      : Colors.green.shade600,
                  fontFamily: 'Regular',
                ),
              ],
            ),
          ),
          if (pendingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextWidget(
                text: '$pendingCount',
                fontSize: 12,
                color: Colors.white,
                fontFamily: 'Bold',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    List<MedicationNotification> notifications, {
    bool isPending = false,
    bool isToday = false,
    bool isHistory = false,
  }) {
    if (notifications.isEmpty) {
      return _buildEmptyState(isPending, isToday, isHistory);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationCard(
          notifications[index],
          isPending: isPending,
          isHistory: isHistory,
        );
      },
    );
  }

  Widget _buildEmptyState(bool isPending, bool isToday, bool isHistory) {
    IconData icon;
    String title;
    String subtitle;
    Color color;

    if (isPending) {
      icon = Icons.check_circle_outline;
      title = 'No Pending Medications';
      subtitle = 'Great job! You\'ve taken all your scheduled medications.';
      color = healthGreen;
    } else if (isToday) {
      icon = Icons.medication_outlined;
      title = 'No Medications Today';
      subtitle = 'You have no medications scheduled for today.';
      color = primary;
    } else {
      icon = Icons.history;
      title = 'No History';
      subtitle = 'Completed medications will appear here.';
      color = textGrey;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 64),
          const SizedBox(height: 16),
          TextWidget(
            text: title,
            fontSize: 18,
            color: color,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextWidget(
              text: subtitle,
              fontSize: 14,
              color: textGrey,
              fontFamily: 'Regular',
              align: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    MedicationNotification notification, {
    bool isPending = false,
    bool isHistory = false,
  }) {
    final now = DateTime.now();
    final scheduledTime = _parseTimeToDateTime(notification.scheduledTime);
    final isOverdue = isPending && now.isAfter(scheduledTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
              ? healthRed.withOpacity(0.3)
              : isHistory
                  ? healthGreen.withOpacity(0.3)
                  : primary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? healthRed.withOpacity(0.1)
                        : isHistory
                            ? healthGreen.withOpacity(0.1)
                            : primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isHistory ? Icons.check_circle : Icons.medication,
                    color: isOverdue
                        ? healthRed
                        : isHistory
                            ? healthGreen
                            : primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: notification.medicationName,
                        fontSize: 16,
                        color: textLight,
                        fontFamily: 'Bold',
                      ),
                      TextWidget(
                        text: notification.dosage,
                        fontSize: 14,
                        color: textGrey,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextWidget(
                      text: notification.scheduledTime,
                      fontSize: 14,
                      color: isOverdue ? healthRed : primary,
                      fontFamily: 'Bold',
                    ),
                    if (isOverdue)
                      TextWidget(
                        text: 'OVERDUE',
                        fontSize: 10,
                        color: healthRed,
                        fontFamily: 'Bold',
                      ),
                    if (isHistory)
                      TextWidget(
                        text: 'COMPLETED',
                        fontSize: 10,
                        color: healthGreen,
                        fontFamily: 'Bold',
                      ),
                  ],
                ),
              ],
            ),
            if (!isHistory) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ButtonWidget(
                      label: 'Mark as Taken',
                      onPressed: () => _markAsTaken(notification),
                      color: healthGreen,
                      height: 36,
                      fontSize: 12,
                      icon:
                          const Icon(Icons.check, color: buttonText, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ButtonWidget(
                      label: 'Mark as Missed',
                      onPressed: () => _markAsMissed(notification),
                      color: healthRed,
                      height: 36,
                      fontSize: 12,
                      icon:
                          const Icon(Icons.close, color: buttonText, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  DateTime _parseTimeToDateTime(String timeString) {
    try {
      final now = DateTime.now();
      final parts = timeString.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      } else if (parts.length > 1 &&
          parts[1].toUpperCase() == 'AM' &&
          hour == 12) {
        hour = 0;
      }

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return DateTime.now();
    }
  }

  Future<void> _markAsTaken(MedicationNotification notification) async {
    try {
      final medications = await _firebaseService.getMedications().first;
      final medication = medications.firstWhere(
        (med) => med.id == notification.medicationId,
      );

      List<bool> newCompletionStatus = List.from(medication.isCompleted);
      if (notification.timeIndex < newCompletionStatus.length) {
        newCompletionStatus[notification.timeIndex] = true;
      }

      final success = await _firebaseService.updateMedicationCompletion(
        notification.medicationId,
        newCompletionStatus,
      );

      if (success) {
        await _firebaseService.logActivity(
          'medication',
          'Medication taken: ${notification.medicationName}',
          data: {
            'medicationId': notification.medicationId,
            'dosage': notification.dosage,
            'time': notification.scheduledTime,
            'source': 'notification_screen',
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${notification.medicationName} marked as taken'),
            backgroundColor: healthGreen,
          ),
        );

        _loadNotifications(); // Refresh the notifications
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update medication status'),
          backgroundColor: healthRed,
        ),
      );
    }
  }

  Future<void> _markAsMissed(MedicationNotification notification) async {
    await _firebaseService.logActivity(
      'medication',
      'Medication missed: ${notification.medicationName}',
      data: {
        'medicationId': notification.medicationId,
        'dosage': notification.dosage,
        'time': notification.scheduledTime,
        'source': 'notification_screen',
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${notification.medicationName} marked as missed'),
        backgroundColor: healthRed,
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Mark All as Read',
          fontSize: 18,
          color: textLight,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text:
              'This will mark all pending medications as taken. Are you sure?',
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
              color: textGrey,
              fontFamily: 'Medium',
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _markAllPendingAsTaken();
            },
            child: TextWidget(
              text: 'Mark All',
              fontSize: 14,
              color: primary,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAllPendingAsTaken() async {
    try {
      for (var notification in _pendingNotifications) {
        await _markAsTaken(notification);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All pending medications marked as taken'),
          backgroundColor: healthGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update all medications'),
          backgroundColor: healthRed,
        ),
      );
    }
  }
}

// Medication Notification Model
class MedicationNotification {
  final String id;
  final String medicationId;
  final String medicationName;
  final String dosage;
  final String scheduledTime;
  final bool isCompleted;
  final DateTime date;
  final int timeIndex;

  MedicationNotification({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.scheduledTime,
    required this.isCompleted,
    required this.date,
    required this.timeIndex,
  });
}
