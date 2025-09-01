import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimationSequence() async {
    // Start logo animation
    await _logoController.forward();

    // Wait a bit then start text animation
    await Future.delayed(const Duration(milliseconds: 300));
    await _textController.forward();

    // Wait before navigating to onboarding
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primary,
              primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated Logo
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 250,
                        height: 250,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Animated App Name and Tagline
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _textSlideAnimation,
                    child: FadeTransition(
                      opacity: _textOpacityAnimation,
                      child: Column(
                        children: [
                          // App Name
                          TextWidget(
                            text: 'Amuma',
                            fontSize: 42,
                            color: white,
                            fontFamily: 'Bold',
                          ),

                          const SizedBox(height: 8),

                          // Tagline
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: TextWidget(
                              text: 'Rooted. Ready. Right Here.',
                              fontSize: 16,
                              color: white,
                              fontFamily: 'Medium',
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Subtitle
                          TextWidget(
                            text: 'Your Health Journey Starts Here',
                            fontSize: 14,
                            color: white.withOpacity(0.8),
                            fontFamily: 'Regular',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Spacer(flex: 3),

              // Loading indicator
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textOpacityAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextWidget(
                          text: 'Loading...',
                          fontSize: 12,
                          color: white.withOpacity(0.7),
                          fontFamily: 'Regular',
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
