import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/widgets/button_widget.dart';
import 'package:amuma/screens/dashboard_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Form controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // Form data
  String? _selectedGender;
  List<String> _selectedConditions = [];
  List<String> _selectedGoals = [];

  final List<String> _chronicConditions = [
    'Diabetes Mellitus',
    'Hypertension',
    'Chronic Kidney Disease',
    'Cardiovascular Disease',
    'Asthma',
    'Arthritis',
    'Depression/Anxiety',
    'None',
  ];

  final List<String> _healthGoals = [
    'Medication Adherence',
    'Weight Management',
    'Blood Pressure Control',
    'Blood Sugar Control',
    'Regular Exercise',
    'Better Sleep',
    'Stress Management',
    'Regular Check-ups',
  ];

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeSetup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _completeSetup() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate saving profile data
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Navigate to dashboard
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DashboardScreen(),
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
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _buildStepContent(),
              ),
            ),

            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back button (only show after first step)
              if (_currentStep > 0)
                GestureDetector(
                  onTap: _previousStep,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
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

              const Spacer(),

              // Step indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextWidget(
                  text: 'Step ${_currentStep + 1} of 3',
                  fontSize: 12,
                  color: primary,
                  fontFamily: 'Medium',
                ),
              ),

              const Spacer(),

              const SizedBox(width: 32),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: primary.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(primary),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildHealthConditionsStep();
      case 2:
        return _buildHealthGoalsStep();
      default:
        return Container();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        TextWidget(
          text: 'Basic Information',
          fontSize: 28,
          color: textPrimary,
          fontFamily: 'Bold',
        ),

        const SizedBox(height: 8),

        TextWidget(
          text: 'Help us personalize your health experience',
          fontSize: 16,
          color: textSecondary,
          fontFamily: 'Regular',
        ),

        const SizedBox(height: 32),

        // Age
        _buildTextField(
          controller: _ageController,
          label: 'Age',
          icon: Icons.calendar_today,
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 16),

        // Gender
        _buildDropdownField(
          label: 'Gender',
          icon: Icons.person_outline,
          value: _selectedGender,
          items: ['Male', 'Female', 'Other', 'Prefer not to say'],
          onChanged: (value) => setState(() => _selectedGender = value),
        ),

        const SizedBox(height: 16),

        // Height
        _buildTextField(
          controller: _heightController,
          label: 'Height (cm)',
          icon: Icons.height,
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 16),

        // Weight
        _buildTextField(
          controller: _weightController,
          label: 'Weight (kg)',
          icon: Icons.monitor_weight_outlined,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildHealthConditionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        TextWidget(
          text: 'Health Conditions',
          fontSize: 28,
          color: textPrimary,
          fontFamily: 'Bold',
        ),

        const SizedBox(height: 8),

        TextWidget(
          text: 'Select any chronic conditions you have (optional)',
          fontSize: 16,
          color: textSecondary,
          fontFamily: 'Regular',
        ),

        const SizedBox(height: 32),

        // Conditions grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: _chronicConditions.length,
          itemBuilder: (context, index) {
            final condition = _chronicConditions[index];
            final isSelected = _selectedConditions.contains(condition);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (condition == 'None') {
                    _selectedConditions.clear();
                    _selectedConditions.add(condition);
                  } else {
                    _selectedConditions.remove('None');
                    if (isSelected) {
                      _selectedConditions.remove(condition);
                    } else {
                      _selectedConditions.add(condition);
                    }
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? primary.withOpacity(0.1) : surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primary : primary.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: TextWidget(
                    text: condition,
                    fontSize: 12,
                    color: isSelected ? primary : textSecondary,
                    fontFamily: isSelected ? 'Medium' : 'Regular',
                    align: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHealthGoalsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        TextWidget(
          text: 'Health Goals',
          fontSize: 28,
          color: textPrimary,
          fontFamily: 'Bold',
        ),

        const SizedBox(height: 8),

        TextWidget(
          text: 'What would you like to focus on?',
          fontSize: 16,
          color: textSecondary,
          fontFamily: 'Regular',
        ),

        const SizedBox(height: 32),

        // Goals grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: _healthGoals.length,
          itemBuilder: (context, index) {
            final goal = _healthGoals[index];
            final isSelected = _selectedGoals.contains(goal);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedGoals.remove(goal);
                  } else {
                    _selectedGoals.add(goal);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? accent.withOpacity(0.1) : surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? accent : accent.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: TextWidget(
                    text: goal,
                    fontSize: 12,
                    color: isSelected ? accentDark : textSecondary,
                    fontFamily: isSelected ? 'Medium' : 'Regular',
                    align: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
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
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          ButtonWidget(
            label: _currentStep == 2 ? 'Complete Setup' : 'Continue',
            onPressed: _nextStep,
            isLoading: _isLoading,
            width: double.infinity,
            height: 56,
            color: _currentStep == 2 ? accent : primary,
          ),
          if (_currentStep < 2) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                // Skip to dashboard
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DashboardScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: TextWidget(
                  text: 'Skip for now',
                  fontSize: 14,
                  color: textSecondary,
                  fontFamily: 'Regular',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
