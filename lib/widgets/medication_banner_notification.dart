import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/models/data_models.dart';

class MedicationBannerNotification extends StatefulWidget {
  final List<MedicationModel> medications;
  final Function(String, int)? onMarkAsTaken;
  final VoidCallback? onDismiss;

  const MedicationBannerNotification({
    super.key,
    required this.medications,
    this.onMarkAsTaken,
    this.onDismiss,
  });

  @override
  State<MedicationBannerNotification> createState() =>
      _MedicationBannerNotificationState();
}

class _MedicationBannerNotificationState
    extends State<MedicationBannerNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isVisible = true;
  List<MedicationNotification> _pendingNotifications = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _updateNotifications();
    _animationController.forward();

    // Auto-dismiss after 5 seconds if no interaction
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isVisible) {
        _dismiss();
      }
    });
  }

  @override
  void didUpdateWidget(MedicationBannerNotification oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateNotifications();
  }

  void _updateNotifications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notifications = <MedicationNotification>[];

    for (var medication in widget.medications) {
      for (int i = 0; i < medication.times.length; i++) {
        final timeString = medication.times[i];
        final isCompleted = i < medication.isCompleted.length
            ? medication.isCompleted[i]
            : false;

        if (!isCompleted) {
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
    }

    setState(() {
      _pendingNotifications = notifications;
    });
  }

  void _dismiss() async {
    setState(() {
      _isVisible = false;
    });
    await _animationController.reverse();
    widget.onDismiss?.call();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingNotifications.isEmpty || !_isVisible) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary.withOpacity(0.95),
                primaryLight.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Medication Reminder',
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Bold',
                        ),
                        TextWidget(
                          text:
                              'You have ${_pendingNotifications.length} pending medication${_pendingNotifications.length > 1 ? 's' : ''}',
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'Regular',
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Show first 2 pending medications
              ..._pendingNotifications
                  .take(2)
                  .map((notification) => _buildMedicationItem(notification)),
              if (_pendingNotifications.length > 2) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    // Navigate to medication screen or show more details
                    _dismiss();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: TextWidget(
                        text:
                            'View all ${_pendingNotifications.length} medications',
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: 'Medium',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationItem(MedicationNotification notification) {
    final isOverdue = notification.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning : Icons.access_time,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: notification.medicationName,
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: 'Bold',
                ),
                TextWidget(
                  text:
                      '${notification.dosage} • ${notification.scheduledTime}',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                  fontFamily: 'Regular',
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.onMarkAsTaken
                  ?.call(notification.medicationId, notification.timeIndex);
              _dismiss();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextWidget(
                text: 'Take',
                fontSize: 12,
                color: Colors.white,
                fontFamily: 'Bold',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Medication Notification Model (reusing from the other widget)
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
