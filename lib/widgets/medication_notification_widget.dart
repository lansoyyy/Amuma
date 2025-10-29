import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/models/data_models.dart';
import 'package:intl/intl.dart';

class MedicationNotificationWidget extends StatelessWidget {
  final List<MedicationModel> medications;
  final Function(String, int)? onMarkAsTaken;
  final Function(String)? onDismiss;

  const MedicationNotificationWidget({
    super.key,
    required this.medications,
    this.onMarkAsTaken,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Get today's notifications
    final notifications = _getTodayNotifications(medications);

    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'Today\'s Medication Reminders',
            fontSize: 16,
            color: textLight,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 12),
          ...notifications
              .map((notification) => _buildNotificationCard(notification)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(MedicationNotification notification) {
    final isOverdue = notification.isOverdue;
    final isCompleted = notification.isCompleted;

    Color cardColor;
    Color borderColor;
    IconData iconData;
    Color iconColor;
    String statusText;
    Color statusColor;

    if (isCompleted) {
      cardColor = Colors.green.shade50;
      borderColor = Colors.green.shade300;
      iconData = Icons.check_circle;
      iconColor = Colors.green.shade600;
      statusText = 'Completed';
      statusColor = Colors.green.shade600;
    } else if (isOverdue) {
      cardColor = Colors.red.shade50;
      borderColor = Colors.red.shade300;
      iconData = Icons.notification_important;
      iconColor = Colors.red.shade600;
      statusText = 'Overdue';
      statusColor = Colors.red.shade600;
    } else {
      cardColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade300;
      iconData = Icons.notifications_active;
      iconColor = Colors.orange.shade600;
      statusText = 'Upcoming';
      statusColor = Colors.orange.shade600;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
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
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
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
                    color: iconColor,
                    fontFamily: 'Bold',
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextWidget(
                      text: statusText,
                      fontSize: 10,
                      color: statusColor,
                      fontFamily: 'Bold',
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onMarkAsTaken?.call(
                        notification.medicationId, notification.timeIndex),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: healthGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, color: buttonText, size: 16),
                          const SizedBox(width: 4),
                          TextWidget(
                            text: 'Mark as Taken',
                            fontSize: 12,
                            color: buttonText,
                            fontFamily: 'Medium',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => onDismiss?.call(notification.id),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.close,
                      color: textGrey,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<MedicationNotification> _getTodayNotifications(
      List<MedicationModel> medications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notifications = <MedicationNotification>[];

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

        notifications.add(notification);
      }
    }

    // Sort notifications by time
    notifications.sort((a, b) =>
        _parseTime(a.scheduledTime).compareTo(_parseTime(b.scheduledTime)));

    return notifications;
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

  bool get isOverdue {
    if (isCompleted) return false;

    final now = DateTime.now();
    final scheduledDateTime = _parseTimeToDateTime(scheduledTime);
    return now.isAfter(scheduledDateTime);
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
}
