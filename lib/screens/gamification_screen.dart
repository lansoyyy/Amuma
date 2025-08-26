import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:intl/intl.dart';
import 'package:amuma/services/firebase_service.dart';
import 'package:amuma/models/data_models.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: TextWidget(
          text: 'Your Health Journey',
          fontSize: 20,
          color: textLight,
          fontFamily: 'Bold',
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: textLight),
        ),
      ),
      body: StreamBuilder<List<StreakModel>>(
        stream: _firebaseService.getStreaks(),
        builder: (context, streakSnapshot) {
          if (streakSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (streakSnapshot.hasError) {
            return Center(
              child: TextWidget(
                text: 'Error loading data: ${streakSnapshot.error}',
                fontSize: 14,
                color: healthRed,
                fontFamily: 'Regular',
              ),
            );
          }

          final streaks = streakSnapshot.data ?? [];
          final medicationStreak = _getStreakCount(streaks, 'medication');
          final healthDiaryStreak = _getStreakCount(streaks, 'health_diary');
          final appointmentStreak = _getStreakCount(streaks, 'appointment');

          return StreamBuilder<List<BadgeModel>>(
            stream: _firebaseService.getBadges(),
            builder: (context, badgeSnapshot) {
              if (badgeSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final badges = badgeSnapshot.data ?? [];
              final earnedBadges =
                  badges.where((badge) => badge.dateEarned != null).toList();
              final availableBadges =
                  badges.where((badge) => badge.dateEarned == null).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main streak card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accent, accentDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: buttonText,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          TextWidget(
                            text: '$medicationStreak',
                            fontSize: 36,
                            color: buttonText,
                            fontFamily: 'Bold',
                          ),
                          TextWidget(
                            text: 'Day Medication Streak',
                            fontSize: 16,
                            color: buttonText.withOpacity(0.9),
                            fontFamily: 'Medium',
                          ),
                          const SizedBox(height: 8),
                          TextWidget(
                            text: 'Keep it up! You\'re doing amazing!',
                            fontSize: 12,
                            color: buttonText.withOpacity(0.8),
                            fontFamily: 'Regular',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Other streaks
                    Row(
                      children: [
                        Expanded(
                          child: _buildStreakCard(
                            'Health Diary',
                            healthDiaryStreak,
                            Icons.favorite,
                            accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStreakCard(
                            'Appointments',
                            appointmentStreak,
                            Icons.calendar_today,
                            primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Earned Badges Section
                    TextWidget(
                      text: 'Earned Badges',
                      fontSize: 18,
                      color: textLight,
                      fontFamily: 'Bold',
                    ),
                    const SizedBox(height: 16),

                    if (earnedBadges.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              color: textGrey,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            TextWidget(
                              text: 'No badges earned yet',
                              fontSize: 16,
                              color: textGrey,
                              fontFamily: 'Medium',
                            ),
                            TextWidget(
                              text: 'Keep tracking to earn your first badge!',
                              fontSize: 12,
                              color: textGrey,
                              fontFamily: 'Regular',
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: earnedBadges.length,
                          itemBuilder: (context, index) {
                            return _buildEarnedBadgeCard(earnedBadges[index]);
                          },
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Available Badges Section
                    TextWidget(
                      text: 'Available Badges',
                      fontSize: 18,
                      color: textLight,
                      fontFamily: 'Bold',
                    ),
                    const SizedBox(height: 16),

                    ...availableBadges
                        .map((badge) => _buildAvailableBadgeCard(badge))
                        .toList(),

                    const SizedBox(height: 32),

                    // Motivational section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.psychology,
                            color: primary,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          TextWidget(
                            text: 'Today\'s Motivation',
                            fontSize: 16,
                            color: primary,
                            fontFamily: 'Bold',
                          ),
                          const SizedBox(height: 8),
                          TextWidget(
                            text: _getMotivationalMessage(),
                            fontSize: 14,
                            color: textLight,
                            fontFamily: 'Regular',
                            align: TextAlign.center,
                          ),
                        ],
                      ),
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

  int _getStreakCount(List<StreakModel> streaks, String type) {
    final streak = streaks.firstWhere(
      (s) => s.type == type,
      orElse: () => StreakModel(
        id: '',
        type: type,
        count: 0,
        lastUpdate: DateTime.now(),
      ),
    );
    return streak.count;
  }

  Widget _buildStreakCard(
      String title, int streak, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          TextWidget(
            text: '$streak',
            fontSize: 24,
            color: textLight,
            fontFamily: 'Bold',
          ),
          TextWidget(
            text: title,
            fontSize: 12,
            color: textGrey,
            fontFamily: 'Regular',
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEarnedBadgeCard(BadgeModel badge) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBadgeColor(badge.color).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: _getBadgeColor(badge.color).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getBadgeColor(badge.color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getBadgeIcon(badge.icon),
                color: _getBadgeColor(badge.color), size: 24),
          ),
          const SizedBox(height: 8),
          TextWidget(
            text: badge.name,
            fontSize: 10,
            color: textLight,
            fontFamily: 'Bold',
            align: TextAlign.center,
          ),
          const SizedBox(height: 4),
          TextWidget(
            text: DateFormat('MMM d').format(badge.dateEarned!),
            fontSize: 8,
            color: textGrey,
            fontFamily: 'Regular',
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableBadgeCard(BadgeModel badge) {
    final progress = badge.progress / badge.target;

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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getBadgeColor(badge.color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getBadgeIcon(badge.icon),
                color: _getBadgeColor(badge.color), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: badge.name,
                  fontSize: 14,
                  color: textLight,
                  fontFamily: 'Bold',
                ),
                const SizedBox(height: 4),
                TextWidget(
                  text: badge.description,
                  fontSize: 12,
                  color: textGrey,
                  fontFamily: 'Regular',
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            _getBadgeColor(badge.color)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextWidget(
                      text: '${badge.progress}/${badge.target}',
                      fontSize: 12,
                      color: _getBadgeColor(badge.color),
                      fontFamily: 'Bold',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage() {
    final messages = [
      'Every day you track your health is a step towards a better you!',
      'Consistency is key to building healthy habits.',
      'You\'re investing in your future health today.',
      'Small steps every day lead to big changes over time.',
      'Your health journey is unique and valuable.',
      'Every medication taken on time is a victory!',
    ];

    return messages[DateTime.now().day % messages.length];
  }

  Color _getBadgeColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'amber':
        return Colors.amber;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'teal':
        return Colors.teal;
      case 'pink':
        return Colors.pink;
      default:
        return primary;
    }
  }

  IconData _getBadgeIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'favorite':
        return Icons.favorite;
      case 'military_tech':
        return Icons.military_tech;
      case 'star':
        return Icons.star;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'medical_services':
        return Icons.medical_services;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.emoji_events;
    }
  }
}
