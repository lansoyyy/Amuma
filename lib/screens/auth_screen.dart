import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:amuma/widgets/forgot_password_dialog.dart';
import 'package:amuma/screens/dashboard_screen.dart';
import 'package:amuma/screens/profile_setup_screen.dart';
import 'package:amuma/services/auth_service.dart';
import 'package:amuma/widgets/logout_widget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Form keys
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Terms and privacy
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user agreed to terms for signup
    if (!_isLogin && !_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'You must agree to the Terms and Privacy Policy to create an account'),
          backgroundColor: healthRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      AuthResult result;

      if (_isLogin) {
        // Sign in
        result = await AuthService().signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Sign up
        result = await AuthService().signUpWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
      }

      if (mounted) {
        if (result.isSuccess) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: healthGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate to appropriate screen
          if (_isLogin) {
            // Check if profile is complete
            final isProfileComplete = await AuthService().isProfileComplete();
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    isProfileComplete
                        ? const DashboardScreen()
                        : const ProfileSetupScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
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
          } else {
            // New user goes to profile setup
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ProfileSetupScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
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
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: healthRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
            backgroundColor: healthRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header
                _buildHeader(),

                const SizedBox(height: 40),

                // Auth Form
                _buildAuthForm(),

                const SizedBox(height: 24),

                // Action Button
                ButtonWidget(
                  label: _isLogin ? 'Sign In' : 'Create Account',
                  onPressed: _handleAuth,
                  isLoading: _isLoading,
                  width: double.infinity,
                  height: 56,
                  color: primary,
                ),

                const SizedBox(height: 24),

                // Toggle Auth Mode
                _buildToggleSection(),

                const SizedBox(height: 20),

                // Logout option (for users who are logged in but reached this screen)
                if (AuthService().isLoggedIn)
                  Center(
                    child: GestureDetector(
                      onTap: () => LogoutWidget.showLogoutDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: healthRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.logout,
                              color: healthRed,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            TextWidget(
                              text: 'Logout',
                              fontSize: 14,
                              color: healthRed,
                              fontFamily: 'Medium',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.asset(
            'assets/images/logo.png',
            width: 180,
          ),
        ),

        const SizedBox(height: 24),

        // Title
        TextWidget(
          text: _isLogin ? 'Welcome Back!' : 'Create Account',
          fontSize: 32,
          color: textPrimary,
          fontFamily: 'Bold',
        ),

        const SizedBox(height: 8),

        // Subtitle
        TextWidget(
          text: _isLogin
              ? 'Sign in to continue your health journey'
              : 'Start your personalized health journey today',
          fontSize: 16,
          color: textSecondary,
          fontFamily: 'Regular',
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    return Column(
      children: [
        // Name field (only for signup)
        if (!_isLogin) ...[
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            validator: _validateName,
          ),
          const SizedBox(height: 16),
        ],

        // Email field
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),

        const SizedBox(height: 16),

        // Password field
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          validator: _validatePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: textSecondary,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),

        // Confirm Password field (only for signup)
        if (!_isLogin) ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            icon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            validator: _validateConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: textSecondary,
              ),
              onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
        ],

        // Forgot Password (only for login)
        if (_isLogin) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                showForgotPasswordDialog(context);
              },
              child: TextWidget(
                text: 'Forgot Password?',
                fontSize: 14,
                color: primary,
                fontFamily: 'Medium',
              ),
            ),
          ),
        ],

        // Terms and Privacy (only for signup)
        if (!_isLogin) ...[
          const SizedBox(height: 16),
          _buildTermsAndPrivacy(),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Regular',
        fontSize: 16,
        color: textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Regular',
          color: textSecondary,
        ),
        prefixIcon: Icon(icon, color: textSecondary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: healthRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: healthRed, width: 2),
        ),
      ),
    );
  }

  Widget _buildToggleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextWidget(
          text: _isLogin
              ? 'Don\'t have an account? '
              : 'Already have an account? ',
          fontSize: 14,
          color: textSecondary,
          fontFamily: 'Regular',
        ),
        GestureDetector(
          onTap: _toggleAuthMode,
          child: TextWidget(
            text: _isLogin ? 'Sign Up' : 'Sign In',
            fontSize: 14,
            color: primary,
            fontFamily: 'Bold',
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _agreeToTerms = !_agreeToTerms;
                  });
                },
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: _agreeToTerms ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _agreeToTerms ? primary : textSecondary,
                      width: 2,
                    ),
                  ),
                  child: _agreeToTerms
                      ? const Icon(
                          Icons.check,
                          color: white,
                          size: 14,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'I agree to the',
                      fontSize: 14,
                      color: textPrimary,
                      fontFamily: 'Regular',
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              _showTermsAndPrivacyDialog('Terms of Service'),
                          child: TextWidget(
                            text: 'Terms of Service',
                            fontSize: 14,
                            color: primary,
                            fontFamily: 'Medium',
                          ),
                        ),
                        TextWidget(
                          text: ' and ',
                          fontSize: 14,
                          color: textPrimary,
                          fontFamily: 'Regular',
                        ),
                        GestureDetector(
                          onTap: () =>
                              _showTermsAndPrivacyDialog('Privacy Policy'),
                          child: TextWidget(
                            text: 'Privacy Policy',
                            fontSize: 14,
                            color: primary,
                            fontFamily: 'Medium',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextWidget(
                      text:
                          'governed by the Data Privacy Act of 2012 (Republic Act No. 10173)',
                      fontSize: 12,
                      color: textSecondary,
                      fontFamily: 'Regular',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTermsAndPrivacyDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: title,
          fontSize: 18,
          color: textPrimary,
          fontFamily: 'Bold',
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title == 'Terms of Service') ...[
                _buildTermsContent(),
              ] else ...[
                _buildPrivacyContent(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: TextWidget(
              text: 'Close',
              fontSize: 14,
              color: primary,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Amuma Health App Terms of Service',
          fontSize: 16,
          color: textPrimary,
          fontFamily: 'Bold',
        ),
        const SizedBox(height: 12),
        TextWidget(
          text: 'Last updated: October 2023',
          fontSize: 12,
          color: textSecondary,
          fontFamily: 'Regular',
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('1. Acceptance of Terms'),
        _buildSectionText(
            'By accessing and using the Amuma Health App, you accept and agree to be bound by the terms and provision of this agreement.'),
        _buildSectionTitle('2. Use License'),
        _buildSectionText(
            'Permission is granted to temporarily download one copy of Amuma Health App per device for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title.'),
        _buildSectionTitle('3. Disclaimer'),
        _buildSectionText(
            'The information on this app is provided on an as is basis. To the fullest extent permitted by law, this Company excludes all representations and warranties relating to this app.'),
        _buildSectionTitle('4. Health Information'),
        _buildSectionText(
            'Amuma is designed to help you track your health information and medication adherence. This app is not a substitute for professional medical advice, diagnosis, or treatment.'),
        _buildSectionTitle('5. User Responsibilities'),
        _buildSectionText(
            'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account or password.'),
        _buildSectionTitle('6. Governing Law'),
        _buildSectionText(
            'These terms and conditions are governed by and construed in accordance with the laws of the Philippines and you irrevocably submit to the exclusive jurisdiction of the courts in that State or location.'),
      ],
    );
  }

  Widget _buildPrivacyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Amuma Health App Privacy Policy',
          fontSize: 16,
          color: textPrimary,
          fontFamily: 'Bold',
        ),
        const SizedBox(height: 12),
        TextWidget(
          text: 'Last updated: October 2023',
          fontSize: 12,
          color: textSecondary,
          fontFamily: 'Regular',
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Data Privacy Act of 2012 Compliance'),
        _buildSectionText(
            'This Privacy Policy is compliant with the Data Privacy Act of 2012 (Republic Act No. 10173) of the Philippines and its implementing rules and regulations.'),
        _buildSectionTitle('1. Information We Collect'),
        _buildSectionText(
            'We collect information you provide directly to us, such as when you create an account, update your profile, or use our services. This includes personal information, health data, and usage information.'),
        _buildSectionTitle('2. How We Use Your Information'),
        _buildSectionText(
            'We use the information we collect to provide, maintain, and improve our services, process transactions, communicate with you, and personalize your experience.'),
        _buildSectionTitle('3. Information Sharing'),
        _buildSectionText(
            'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this Privacy Policy or as required by law.'),
        _buildSectionTitle('4. Data Security'),
        _buildSectionText(
            'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.'),
        _buildSectionTitle('5. Your Rights'),
        _buildSectionText(
            'Under the Data Privacy Act of 2012, you have the right to know, access, object, rectify, erase, or port your personal data. You may exercise these rights by contacting us.'),
        _buildSectionTitle('6. Data Retention'),
        _buildSectionText(
            'We retain your personal information only as long as necessary to fulfill the purposes for which it was collected, or as required by law.'),
        _buildSectionTitle('7. Contact Information'),
        _buildSectionText(
            'If you have any questions about this Privacy Policy or our data practices, please contact our Data Protection Officer at privacy@amuma.health'),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: TextWidget(
        text: title,
        fontSize: 14,
        color: textPrimary,
        fontFamily: 'Bold',
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextWidget(
        text: text,
        fontSize: 13,
        color: textSecondary,
        fontFamily: 'Regular',
      ),
    );
  }
}
