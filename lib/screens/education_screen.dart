import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';
import 'package:amuma/services/firebase_service.dart';
import 'package:amuma/models/data_models.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String currentLanguage = 'EN';
  int selectedCategory = 0;

  final List<String> categories = [
    'Dietary Tips',
    'Diabetes',
    'Hypertension',
    'Heart Health',
    'Kidney Care',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: TextWidget(
          text: currentLanguage == 'EN'
              ? 'Health Education'
              : 'Edukasyon sa Panglawas',
          fontSize: 20,
          color: textLight,
          fontFamily: 'Bold',
        ),
        actions: [
          TextButton(
            onPressed: _toggleLanguage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: primary),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextWidget(
                text: currentLanguage == 'EN' ? 'CEB' : 'ENG',
                fontSize: 12,
                color: primary,
                fontFamily: 'Medium',
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Tabs
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = selectedCategory == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primary),
                    ),
                    child: Center(
                      child: TextWidget(
                        text: _translateCategory(categories[index]),
                        fontSize: 12,
                        color: isSelected ? buttonText : primary,
                        fontFamily: 'Medium',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StreamBuilder<List<EducationContentModel>>(
                stream: _firebaseService.getEducationContent(
                  category: _getCategoryKey(selectedCategory),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: healthRed, size: 48),
                          const SizedBox(height: 16),
                          TextWidget(
                            text: 'Error loading content',
                            fontSize: 16,
                            color: healthRed,
                            fontFamily: 'Bold',
                          ),
                          const SizedBox(height: 8),
                          TextWidget(
                            text: 'Please check your connection and try again',
                            fontSize: 12,
                            color: textGrey,
                            fontFamily: 'Regular',
                          ),
                        ],
                      ),
                    );
                  }

                  final contents = snapshot.data ?? [];

                  if (contents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.library_books_outlined,
                              color: textGrey, size: 48),
                          const SizedBox(height: 16),
                          TextWidget(
                            text: currentLanguage == 'EN'
                                ? 'No content available'
                                : 'Walay sulod nga makita',
                            fontSize: 16,
                            color: textGrey,
                            fontFamily: 'Bold',
                          ),
                          const SizedBox(height: 8),
                          TextWidget(
                            text: currentLanguage == 'EN'
                                ? 'Content for this category will be available soon'
                                : 'Ang sulod para niini nga kategorya ania na soon',
                            fontSize: 12,
                            color: textGrey,
                            fontFamily: 'Regular',
                            align: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: contents.length,
                    itemBuilder: (context, index) {
                      final content = contents[index];
                      return _buildContentCard(content);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryKey(int index) {
    switch (index) {
      case 0:
        return 'dietary_tips';
      case 1:
        return 'diabetes';
      case 2:
        return 'hypertension';
      case 3:
        return 'heart_health';
      case 4:
        return 'kidney_care';
      default:
        return 'dietary_tips';
    }
  }

  Widget _buildContentCard(EducationContentModel content) {
    final title = currentLanguage == 'EN' ? content.titleEn : content.titleCeb;
    final description =
        currentLanguage == 'EN' ? content.contentEn : content.contentCeb;
    final tips = currentLanguage == 'EN' ? content.tipsEn : content.tipsCeb;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: _getContentColor(content.color).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: _getContentColor(content.color).withOpacity(0.1),
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
                  color: _getContentColor(content.color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getContentIcon(content.icon),
                  color: _getContentColor(content.color),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextWidget(
                  text: title,
                  fontSize: 16,
                  color: textLight,
                  fontFamily: 'Bold',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextWidget(
            text: description,
            fontSize: 14,
            color: textGrey,
            fontFamily: 'Regular',
          ),
          if (tips != null && tips.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        decoration: BoxDecoration(
                          color: _getContentColor(content.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: TextWidget(
                          text: tip,
                          fontSize: 14,
                          color: textLight,
                          fontFamily: 'Regular',
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Color _getContentColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return Colors.green.shade400;
      case 'orange':
        return Colors.orange.shade400;
      case 'blue':
        return Colors.blue.shade400;
      case 'red':
        return Colors.red.shade400;
      case 'pink':
        return Colors.pink.shade400;
      case 'cyan':
        return Colors.cyan.shade400;
      case 'purple':
        return Colors.purple.shade400;
      case 'teal':
        return Colors.teal.shade400;
      default:
        return primary;
    }
  }

  IconData _getContentIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'thumb_up':
        return Icons.thumb_up;
      case 'warning':
        return Icons.warning;
      case 'savings':
        return Icons.savings;
      case 'bloodtype':
        return Icons.bloodtype;
      case 'restaurant':
        return Icons.restaurant;
      case 'no_food':
        return Icons.no_food;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'set_meal':
        return Icons.set_meal;
      case 'water_drop':
        return Icons.water_drop;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'favorite':
        return Icons.favorite;
      case 'medical_services':
        return Icons.medical_services;
      default:
        return Icons.info;
    }
  }

  String _translateCategory(String category) {
    if (currentLanguage == 'EN') return category;

    switch (category) {
      case 'Dietary Tips':
        return 'Tips sa Pagkaon';
      case 'Diabetes':
        return 'Diabetes';
      case 'Hypertension':
        return 'Taas nga Presyon';
      case 'Heart Health':
        return 'Panglawas sa Kasingkasing';
      case 'Kidney Care':
        return 'Pag-atiman sa Kidney';
      default:
        return category;
    }
  }

  void _toggleLanguage() {
    setState(() {
      currentLanguage = currentLanguage == 'EN' ? 'CEB' : 'EN';
    });
  }
}
