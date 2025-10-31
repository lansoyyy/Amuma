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
      'question': 'What is Pag-Amuma?',
      'answer':
          'Pag-Amuma: A Culturally Tailored Mobile Health Application for Chronic Disease Self-Management Among Filipino Patients in Cebu City. It is a mobile health app designed to help Filipino patients with chronic illnesses manage their health through culturally tailored tools, education, and support.'
    },
    {
      'question': 'Who can use Pag-Amuma?',
      'answer':
          'Individuals with chronic illnesses (diabetes, hypertension, kidney disease, respiratory problems, etc.), their families, and caregivers can use Pag-Amuma.'
    },
    {
      'question': 'Is Pag-Amuma free?',
      'answer':
          'Yes, Pag-Amuma is free to download and use. Some features may require internet connection.'
    },
    {
      'question': 'What languages are available in Pag-Amuma?',
      'answer': 'Pag-Amuma is available in English and Sinugbuanong Binisaya.'
    },
    {
      'question': 'How can this app help with health management?',
      'answer':
          'Pag-Amuma provides reminders for medications, health education modules, symptom trackers, lifestyle tips, and resources to support your self-care.'
    },
    {
      'question': 'Does Pag-Amuma replace my doctor?',
      'answer':
          'No. Pag-Amuma is a support tool for self-management but does not replace medical advice, diagnosis, or treatment. Always consult your healthcare provider.'
    },
    {
      'question': 'Can I track symptoms and medications?',
      'answer':
          'Yes, you can record your medications, daily symptoms, and vital signs like blood pressure, sugar levels, or weight.'
    },
    {
      'question': 'How do I create an account?',
      'answer':
          'Sign up using your email or phone number. Follow the guided registration steps.'
    },
    {
      'question': 'How is my data protected?',
      'answer':
          'Your data is securely stored and follows privacy standards. Only you can access your records.'
    },
    {
      'question': 'What if I forgot my password?',
      'answer':
          'Tap "Forgot Password" on the login screen and follow the instructions to reset it.'
    },
    {
      'question': 'Who developed Pag-Amuma?',
      'answer':
          'Pag-Amuma was developed by a research team in Cebu City to support Filipino patients with chronic diseases through culturally appropriate health technology.'
    },
    {
      'question': 'How do I report problems with the app?',
      'answer':
          'Use the "Help & Support" section of the app or email the support team.'
    },
    {
      'question': 'How can I suggest improvements?',
      'answer':
          'We welcome your feedback! Please use the "Feedback" button in the app.'
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
