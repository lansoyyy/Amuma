import 'package:flutter/material.dart';
import 'package:amuma/utils/colors.dart';
import 'package:amuma/widgets/text_widget.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
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
              child: _buildCategoryContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent() {
    switch (selectedCategory) {
      case 0:
        return _buildDietaryTips();
      case 1:
        return _buildDiabetesContent();
      case 2:
        return _buildHypertensionContent();
      case 3:
        return _buildHeartHealthContent();
      case 4:
        return _buildKidneyCareContent();
      default:
        return _buildDietaryTips();
    }
  }

  Widget _buildDietaryTips() {
    final tips = currentLanguage == 'EN'
        ? _getEnglishDietaryTips()
        : _getCebuanoDietaryTips();

    return ListView(
      children: [
        _buildSectionHeader(currentLanguage == 'EN'
            ? 'Filipino Foods for Better Health'
            : 'Mga Pagkaon nga Maayo para sa Panglawas'),

        const SizedBox(height: 16),

        // Recommended Foods
        _buildTipCard(
          currentLanguage == 'EN'
              ? 'Recommended Foods'
              : 'Girekomenda nga Pagkaon',
          tips['recommended']!,
          Colors.green.shade400,
          Icons.thumb_up,
        ),

        const SizedBox(height: 16),

        // Foods to Limit
        _buildTipCard(
          currentLanguage == 'EN' ? 'Foods to Limit' : 'Pagkaon nga Limitahan',
          tips['restricted']!,
          Colors.orange.shade400,
          Icons.warning,
        ),

        const SizedBox(height: 16),

        // Budget-Friendly Tips
        _buildTipCard(
          currentLanguage == 'EN'
              ? 'Budget-Friendly Tips'
              : 'Tips para sa Budget',
          tips['budget']!,
          Colors.blue.shade400,
          Icons.savings,
        ),
      ],
    );
  }

  Widget _buildDiabetesContent() {
    return ListView(
      children: [
        _buildSectionHeader(currentLanguage == 'EN'
            ? 'Managing Diabetes'
            : 'Pagdumala sa Diabetes'),
        const SizedBox(height: 16),
        _buildEducationModule(
          currentLanguage == 'EN'
              ? 'Blood Sugar Monitoring'
              : 'Pagsubaybay sa Blood Sugar',
          currentLanguage == 'EN'
              ? 'Check your blood sugar regularly as advised by your doctor. Keep a log of your readings.'
              : 'Susiha ang imong blood sugar kanunay sama sa gisugo sa doctor. Ihot ang imong mga reading.',
          Icons.bloodtype,
          Colors.red.shade400,
        ),
        _buildEducationModule(
          currentLanguage == 'EN' ? 'Healthy Eating' : 'Linom nga Pagkaon',
          currentLanguage == 'EN'
              ? 'Choose whole grains, vegetables, and lean proteins. Limit sugary foods and drinks.'
              : 'Pilia ang whole grains, utanon, ug lean proteins. Limitahi ang mga tam-is nga pagkaon.',
          Icons.restaurant,
          Colors.green.shade400,
        ),
      ],
    );
  }

  Widget _buildHypertensionContent() {
    return ListView(
      children: [
        _buildSectionHeader(currentLanguage == 'EN'
            ? 'Managing High Blood Pressure'
            : 'Pagdumala sa Taas nga Presyon'),
        const SizedBox(height: 16),
        _buildEducationModule(
          currentLanguage == 'EN' ? 'Reduce Sodium' : 'Pakunhura ang Asin',
          currentLanguage == 'EN'
              ? 'Limit salt and processed foods. Use herbs and spices for flavor instead.'
              : 'Limitahi ang asin ug processed foods. Gamita ang herbs ug spices para sa lami.',
          Icons.no_food,
          Colors.orange.shade400,
        ),
        _buildEducationModule(
          currentLanguage == 'EN' ? 'Stay Active' : 'Mag-exercise',
          currentLanguage == 'EN'
              ? 'Regular physical activity helps lower blood pressure. Try walking for 30 minutes daily.'
              : 'Ang regular nga exercise makatabang sa pagkunhod sa presyon. Sulayi ang paglakaw og 30 minutos.',
          Icons.directions_walk,
          Colors.blue.shade400,
        ),
      ],
    );
  }

  Widget _buildHeartHealthContent() {
    return ListView(
      children: [
        _buildSectionHeader(currentLanguage == 'EN'
            ? 'Heart Health Tips'
            : 'Tips para sa Kasingkasing'),
        const SizedBox(height: 16),
        _buildEducationModule(
          currentLanguage == 'EN' ? 'Healthy Fats' : 'Linom nga Tambok',
          currentLanguage == 'EN'
              ? 'Choose fish, nuts, and olive oil. Avoid trans fats and limit saturated fats.'
              : 'Pilia ang isda, nuts, ug olive oil. Likayi ang trans fats ug limitahi ang saturated fats.',
          Icons.set_meal,
          Colors.pink.shade400,
        ),
      ],
    );
  }

  Widget _buildKidneyCareContent() {
    return ListView(
      children: [
        _buildSectionHeader(
            currentLanguage == 'EN' ? 'Kidney Care' : 'Pag-atiman sa Kidney'),
        const SizedBox(height: 16),
        _buildEducationModule(
          currentLanguage == 'EN' ? 'Stay Hydrated' : 'Mag-inom og Tubig',
          currentLanguage == 'EN'
              ? 'Drink plenty of water daily. Limit sugary drinks and alcohol.'
              : 'Mag-inom og daghang tubig kada adlaw. Limitahi ang tam-is nga ilimnon ug alkohol.',
          Icons.water_drop,
          Colors.cyan.shade400,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextWidget(
        text: title,
        fontSize: 18,
        color: buttonText,
        fontFamily: 'Bold',
      ),
    );
  }

  Widget _buildTipCard(
      String title, List<String> tips, Color color, IconData icon) {
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
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
          ...tips
              .map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 6, right: 8),
                          decoration: BoxDecoration(
                            color: color,
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
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildEducationModule(
      String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                child: Icon(icon, color: color, size: 20),
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
            text: content,
            fontSize: 14,
            color: textGrey,
            fontFamily: 'Regular',
          ),
        ],
      ),
    );
  }

  Map<String, List<String>> _getEnglishDietaryTips() {
    return {
      'recommended': [
        'Brown rice (bigas nga brown) - better than white rice',
        'Fresh vegetables - malunggay, kangkong, ampalaya',
        'Fresh fruits - banana, papaya, guava',
        'Fish - bangus, tilapia, tuna',
        'Lean meats - chicken breast without skin',
        'Legumes - mongo, sitaw, patani',
      ],
      'restricted': [
        'Lechon and other fatty pork dishes',
        'Processed meats - hotdog, spam, tocino',
        'Fried foods - pritong manok, lumpia',
        'Sweet desserts - halo-halo, leche flan',
        'Sugary drinks - softdrinks, sweet iced tea',
        'Excessive white rice consumption',
      ],
      'budget': [
        'Buy vegetables from local markets (cheaper than malls)',
        'Choose seasonal fruits and vegetables',
        'Cook more fish than meat (often cheaper)',
        'Grow your own herbs - luya, tanglad, dahon ng sili',
        'Buy rice in bulk to save money',
        'Use less oil when cooking to save and be healthier',
      ],
    };
  }

  Map<String, List<String>> _getCebuanoDietaryTips() {
    return {
      'recommended': [
        'Brown rice - mas maayo kay sa puti nga bugas',
        'Presko nga utanon - malunggay, kangkong, ampalaya',
        'Presko nga prutas - saging, papaya, bayabas',
        'Isda - bangus, tilapia, tuna',
        'Lean nga karne - puso sa manok nga walay panit',
        'Legumes - monggo, sitaw, patani',
      ],
      'restricted': [
        'Lechon ug uban pang tambok nga baboy',
        'Processed nga karne - hotdog, spam, tocino',
        'Mga pritong pagkaon - pritong manok, lumpia',
        'Tam-is nga dessert - halo-halo, leche flan',
        'Tam-is nga ilimnon - softdrinks, tam-is nga tea',
        'Sobrang pagkaon og puti nga bugas',
      ],
      'budget': [
        'Palit og utanon sa merkado (mas barato kay sa mall)',
        'Pilia ang seasonal nga prutas ug utanon',
        'Luto og mas daghang isda kay sa karne',
        'Tanum og kaugalingon nga herbs - luya, tanglad',
        'Palit og bugas nga dako para makatipid',
        'Gamita og dyutay nga mantika sa pagluto',
      ],
    };
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
