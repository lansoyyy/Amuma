import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> with TickerProviderStateMixin {
  // Sample FAQ data - this can be replaced with actual data from a service
  final List<Map<String, String>> _faqData = [
    {
      'question': 'How do I track my medications?',
      'answer':
          'Navigate to the Medications tab in the bottom navigation bar. Here you can add new medications, set reminders, and track your daily intake. You can also view your medication history and upcoming doses.'
    },
    {
      'question': 'How do I log my health vitals?',
      'answer':
          'Go to the Health Diary tab to record your blood pressure, blood sugar levels, weight, and other health metrics. You can set reminders to log these regularly and view your progress over time in the charts section.'
    },
    {
      'question': 'Can I set appointment reminders?',
      'answer':
          'Yes, in the Appointments tab, you can add upcoming medical appointments and set reminders. The app will send you notifications before your scheduled appointments to ensure you don\'t miss them.'
    },
    {
      'question': 'How do I access health education content?',
      'answer':
          'The Learn tab provides curated health education articles and tips. You can browse by category or search for specific topics. Content is regularly updated with the latest health information.'
    },
    {
      'question': 'How is my data protected?',
      'answer':
          'All your health data is securely stored and encrypted. We follow industry-standard security practices to protect your personal information. You can review our full privacy policy in the settings section.'
    },
    {
      'question': 'How do I update my profile information?',
      'answer':
          'Go to your profile by tapping the user icon in the top right corner of the Home screen. From there, you can update your personal information, health details, and emergency contacts.'
    },
    {
      'question': 'What should I do if I miss a medication dose?',
      'answer':
          'If you miss a dose, take it as soon as you remember. However, if it\'s almost time for your next dose, skip the missed dose and continue with your regular schedule. Log the missed dose in the app for your records and consult your healthcare provider if you\'re unsure.'
    },
    {
      'question': 'How do I contact support?',
      'answer':
          'You can reach our support team by going to Settings > Help & Support > Contact Us. Fill out the form with your query and our team will respond within 24-48 hours.'
    },
  ];

  late AnimationController _mascotController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _initMascotAnimation();
  }

  void _initMascotAnimation() {
    _mascotController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mascotController,
      curve: Curves.easeInOut,
    ));

    // Repeat the animation indefinitely
    _mascotController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mascotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: surface,
        title: TextWidget(
          text: 'Frequently Asked Questions',
          fontSize: 18,
          color: textPrimary,
          fontFamily: 'Bold',
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _faqData.length,
                itemBuilder: (context, index) {
                  return _buildFAQItem(
                    _faqData[index]['question']!,
                    _faqData[index]['answer']!,
                    index,
                  );
                },
              ),
            ),
            // Mascot with animation
            _buildAnimatedMascot(),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          title: TextWidget(
            text: question,
            fontSize: 16,
            color: textPrimary,
            fontFamily: 'Medium',
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextWidget(
                text: answer,
                fontSize: 14,
                color: textSecondary,
                fontFamily: 'Regular',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedMascot() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _mascotController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 10 * (1 - _bounceAnimation.value)),
                child: Image.asset(
                  'assets/images/nurse.png',
                  width: 80,
                  height: 80,
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextWidget(
                text: 'Need more help?',
                fontSize: 14,
                color: textPrimary,
                fontFamily: 'Medium',
              ),
              TextWidget(
                text: 'Check out our health resources!',
                fontSize: 14,
                color: textPrimary,
                fontFamily: 'Medium',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
