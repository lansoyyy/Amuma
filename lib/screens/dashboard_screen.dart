import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/screens/medication_screen.dart';
import 'package:amuma/screens/health_diary_screen.dart';
import 'package:amuma/screens/education_screen.dart';
import 'package:amuma/screens/emergency_profile_screen.dart';
import 'package:amuma/screens/appointment_screen.dart';
import 'package:amuma/screens/gamification_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
        HomeTabScreen(
            onTabSelected: (index) => setState(() => _currentIndex = index)),
        const MedicationScreen(),
        const HealthDiaryScreen(),
        const EducationScreen(),
        const EmergencyProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textGrey,
        selectedLabelStyle: const TextStyle(fontFamily: 'Medium'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Regular'),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication_outlined),
            activeIcon: Icon(Icons.medication),
            label: 'Medications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency_outlined),
            activeIcon: Icon(Icons.emergency),
            label: 'Emergency',
          ),
        ],
      ),
    );
  }
}

class HomeTabScreen extends StatelessWidget {
  final Function(int) onTabSelected;

  const HomeTabScreen({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Good morning!';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon!';
    } else if (hour >= 17) {
      greeting = 'Good evening!';
    }

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header with User Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // User Avatar
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accent, accentDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            color: white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Greeting and Welcome Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: greeting,
                                fontSize: 16,
                                color: textSecondary,
                                fontFamily: 'Medium',
                              ),
                              TextWidget(
                                text: 'Welcome to Amuma',
                                fontSize: 20,
                                color: textPrimary,
                                fontFamily: 'Bold',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification Bell with Badge
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primary.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: primary,
                          size: 24,
                        ),
                      ),
                      // Notification Badge
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: healthRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Enhanced Tagline Card with Health Icon and Stats
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: 'Rooted. Ready. Right Here.',
                                fontSize: 20,
                                color: buttonText,
                                fontFamily: 'Bold',
                              ),
                              const SizedBox(height: 4),
                              TextWidget(
                                text:
                                    'Your health journey, simplified and personalized.',
                                fontSize: 14,
                                color: buttonText.withOpacity(0.9),
                                fontFamily: 'Regular',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Quick Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickStat(
                              '7', 'Day Streak', Icons.local_fire_department),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: white.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildQuickStat(
                              '85', 'Health Score', Icons.trending_up),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: white.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildQuickStat(
                              '12', 'Goals Met', Icons.emoji_events),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Health Summary Cards
              Row(
                children: [
                  TextWidget(
                    text: 'Today\'s Overview',
                    fontSize: 18,
                    color: textPrimary,
                    fontFamily: 'Bold',
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _navigateToTab(context, 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accent.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextWidget(
                            text: 'View All',
                            fontSize: 12,
                            color: accent,
                            fontFamily: 'Medium',
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: accent,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Health Summary Cards Row
              Row(
                children: [
                  Expanded(
                    child: _buildHealthSummaryCard(
                      'Medications',
                      '2/3',
                      'taken today',
                      Icons.medication,
                      primary,
                      0.67,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHealthSummaryCard(
                      'Health Score',
                      '85',
                      'points',
                      Icons.trending_up,
                      healthGreen,
                      0.85,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Recent Activity Section
              Row(
                children: [
                  Icon(Icons.history, color: textPrimary, size: 20),
                  const SizedBox(width: 8),
                  TextWidget(
                    text: 'Recent Activity',
                    fontSize: 18,
                    color: textPrimary,
                    fontFamily: 'Bold',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Recent Activity Cards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primary.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildActivityItem(
                      'Medication taken',
                      'Paracetamol 500mg',
                      '30 minutes ago',
                      Icons.medication,
                      healthGreen,
                    ),
                    const Divider(height: 24),
                    _buildActivityItem(
                      'Health data logged',
                      'Blood pressure: 120/80',
                      '2 hours ago',
                      Icons.favorite,
                      accent,
                    ),
                    const Divider(height: 24),
                    _buildActivityItem(
                      'Appointment reminder',
                      'Dr. Santos - Tomorrow 2PM',
                      '4 hours ago',
                      Icons.calendar_today,
                      primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Health Tip of the Day
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentLight.withOpacity(0.1),
                      accent.withOpacity(0.05)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline,
                            color: accentDark,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextWidget(
                          text: 'Health Tip of the Day',
                          fontSize: 16,
                          color: textPrimary,
                          fontFamily: 'Bold',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextWidget(
                      text:
                          'Drink at least 8 glasses of water daily to stay hydrated and maintain optimal body function.',
                      fontSize: 14,
                      color: textSecondary,
                      fontFamily: 'Regular',
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _navigateToTab(context, 3),
                      child: Row(
                        children: [
                          TextWidget(
                            text: 'Learn more',
                            fontSize: 12,
                            color: accentDark,
                            fontFamily: 'Medium',
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: accentDark,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Quick Actions Section
              Row(
                children: [
                  Icon(Icons.dashboard, color: textPrimary, size: 20),
                  const SizedBox(width: 8),
                  TextWidget(
                    text: 'Quick Actions',
                    fontSize: 18,
                    color: textPrimary,
                    fontFamily: 'Bold',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Enhanced Quick Actions Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _buildEnhancedQuickActionCard(
                    'Log Medication',
                    'Track your pills',
                    Icons.medication,
                    primary,
                    () => _navigateToTab(context, 1),
                  ),
                  _buildEnhancedQuickActionCard(
                    'Health Diary',
                    'Record vitals',
                    Icons.favorite,
                    accent,
                    () => _navigateToTab(context, 2),
                  ),
                  _buildEnhancedQuickActionCard(
                    'Appointments',
                    'Manage schedule',
                    Icons.calendar_today,
                    primaryLight,
                    () => _showAppointments(context),
                  ),
                  _buildEnhancedQuickActionCard(
                    'Health Tips',
                    'Learn & grow',
                    Icons.school,
                    accentDark,
                    () => _navigateToTab(context, 3),
                  ),
                  _buildEnhancedQuickActionCard(
                    'Emergency Info',
                    'Quick access',
                    Icons.emergency,
                    healthRed,
                    () => _navigateToTab(context, 4),
                  ),
                  _buildEnhancedQuickActionCard(
                    'Streak Tracker',
                    'View progress',
                    Icons.emoji_events,
                    healthYellow,
                    () => _showStreakTracker(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            TextWidget(
              text: title,
              fontSize: 14,
              color: textLight,
              fontFamily: 'Medium',
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    onTabSelected(index);
  }

  void _showAppointments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppointmentScreen()),
    );
  }

  void _showStreakTracker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GamificationScreen()),
    );
  }

  Widget _buildHealthSummaryCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextWidget(
                  text: title,
                  fontSize: 12,
                  color: textSecondary,
                  fontFamily: 'Medium',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextWidget(
                text: value,
                fontSize: 24,
                color: textPrimary,
                fontFamily: 'Bold',
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: TextWidget(
                  text: subtitle,
                  fontSize: 10,
                  color: textSecondary,
                  fontFamily: 'Regular',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const Spacer(),
            TextWidget(
              text: title,
              fontSize: 14,
              color: textPrimary,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 4),
            TextWidget(
              text: subtitle,
              fontSize: 11,
              color: textSecondary,
              fontFamily: 'Regular',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: title,
                fontSize: 14,
                color: textPrimary,
                fontFamily: 'Medium',
              ),
              const SizedBox(height: 2),
              TextWidget(
                text: subtitle,
                fontSize: 12,
                color: textSecondary,
                fontFamily: 'Regular',
              ),
            ],
          ),
        ),
        TextWidget(
          text: time,
          fontSize: 11,
          color: textLight,
          fontFamily: 'Regular',
        ),
      ],
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: white.withOpacity(0.8),
          size: 16,
        ),
        const SizedBox(height: 4),
        TextWidget(
          text: value,
          fontSize: 16,
          color: white,
          fontFamily: 'Bold',
        ),
        TextWidget(
          text: label,
          fontSize: 10,
          color: white.withOpacity(0.8),
          fontFamily: 'Regular',
        ),
      ],
    );
  }
}
