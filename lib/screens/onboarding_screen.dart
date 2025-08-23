import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:amuma/screens/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Amuma',
      description:
          'Your personalized health companion designed to support your wellness journey with culturally relevant guidance.',
      icon: Icons.favorite,
      color: primary,
      image: 'health_heart',
    ),
    OnboardingPage(
      title: 'Track Your Health',
      description:
          'Monitor your medications, vital signs, symptoms, and daily health activities all in one place.',
      icon: Icons.analytics,
      color: accent,
      image: 'health_tracking',
    ),
    OnboardingPage(
      title: 'Stay Informed',
      description:
          'Access educational content, cultural dietary tips, and evidence-based health information tailored for you.',
      icon: Icons.school,
      color: healthGreen,
      image: 'education',
    ),
    OnboardingPage(
      title: 'Emergency Ready',
      description:
          'Keep your medical information and emergency contacts accessible when you need them most.',
      icon: Icons.emergency,
      color: healthRed,
      image: 'emergency',
    ),
    OnboardingPage(
      title: 'Rooted. Ready. Right Here.',
      description:
          'Start your health journey with confidence. We\'re here to support you every step of the way.',
      icon: Icons.emoji_events,
      color: accentDark,
      image: 'journey',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToAuth();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToAuth() {
    _navigateToAuth();
  }

  void _navigateToAuth() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: _previousPage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: primary.withOpacity(0.2)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: primary,
                          size: 16,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 32),

                  // Page Indicator
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pages[_currentPage].color
                              : _pages[_currentPage].color.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Skip Button
                  if (_currentPage < _pages.length - 1)
                    GestureDetector(
                      onTap: _skipToAuth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: TextWidget(
                          text: 'Skip',
                          fontSize: 14,
                          color: textSecondary,
                          fontFamily: 'Medium',
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 32),
                ],
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_pages[index]);
                },
              ),
            ),

            // Bottom Navigation
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Next/Get Started Button
                  ButtonWidget(
                    label: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: _nextPage,
                    color: _pages[_currentPage].color,
                    width: double.infinity,
                    height: 56,
                    fontSize: 16,
                  ),

                  const SizedBox(height: 16),

                  // Progress Text
                  TextWidget(
                    text: '${_currentPage + 1} of ${_pages.length}',
                    fontSize: 12,
                    color: textLight,
                    fontFamily: 'Regular',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // Illustration/Icon
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  page.color.withOpacity(0.1),
                  page.color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: page.color.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: page.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  page.icon,
                  size: 80,
                  color: page.color,
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title
          TextWidget(
            text: page.title,
            fontSize: 28,
            color: textPrimary,
            fontFamily: 'Bold',
            align: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextWidget(
              text: page.description,
              fontSize: 16,
              color: textSecondary,
              fontFamily: 'Regular',
              align: TextAlign.center,
              maxLines: 4,
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String image;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.image,
  });
}
