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
  String currentLanguage = 'EN';
  int selectedCategory = 0;

  final List<String> categories = [
    'Dietary Tips',
    'Diabetes',
    'Hypertension',
    'Heart Health',
    'Kidney Care',
  ];

  // Hardcoded education content
  List<EducationContentModel> get _getEducationContent {
    final categoryKey = _getCategoryKey(selectedCategory);

    switch (categoryKey) {
      case 'dietary_tips':
        return [
          EducationContentModel(
            id: 'dt1',
            titleEn: 'Healthy Eating Basics',
            titleCeb: 'Mga Basikong Pagkaon nga Himsog',
            contentEn:
                'A balanced diet provides your body with essential nutrients for optimal health and energy.',
            contentCeb:
                'Ang balanced nga pagkaon naghatag sa imong lawas og importante nga nutrients para sa maayong panglawas ug kusog.',
            tipsEn: [
              'Fill half your plate with fruits and vegetables',
              'Choose whole grains over refined grains',
              'Include lean proteins like fish, chicken, and beans',
              'Limit processed and sugary foods',
              'Stay hydrated with water'
            ],
            tipsCeb: [
              'Pun-a ang tunga sa imong plato og prutas ug utanon',
              'Pilia ang whole grains kay sa refined grains',
              'Iapil ang lean proteins sama sa isda, manok, ug beans',
              'Limitaha ang processed ug tam-is nga pagkaon',
              'Mag-inom og daghan nga tubig'
            ],
            category: 'dietary_tips',
            icon: 'restaurant',
            color: 'green',
            createdAt: DateTime.now(),
          ),
          EducationContentModel(
            id: 'dt2',
            titleEn: 'Portion Control',
            titleCeb: 'Pagkontrol sa Gidak-on sa Pagkaon',
            contentEn:
                'Managing portion sizes helps maintain a healthy weight and prevents overeating.',
            contentCeb:
                'Ang pagdumala sa gidak-on sa pagkaon makatabang sa pagmintinar og healthy nga timbang ug pagpugong sa sobra nga pagkaon.',
            tipsEn: [
              'Use smaller plates and bowls',
              'Listen to your hunger cues',
              'Eat slowly and mindfully',
              'Stop eating when you feel satisfied, not full'
            ],
            tipsCeb: [
              'Gamita ang mas gagmay nga plato ug bowl',
              'Paminawa ang imong gipangandoy nga pagkaon',
              'Kaon og hinay ug maampingon',
              'Hunong sa pagkaon kung busog na, dili sobra'
            ],
            category: 'dietary_tips',
            icon: 'set_meal',
            color: 'orange',
            createdAt: DateTime.now(),
          ),
        ];

      case 'diabetes':
        return [
          EducationContentModel(
            id: 'd1',
            titleEn: 'Understanding Diabetes',
            titleCeb: 'Pagsabot sa Diabetes',
            contentEn:
                'Diabetes is a condition where your blood sugar levels are higher than normal. Proper management is essential.',
            contentCeb:
                'Ang diabetes usa ka kondisyon diin ang imong blood sugar mas taas kay sa normal. Importante ang hustong pagdumala.',
            tipsEn: [
              'Monitor blood sugar levels regularly',
              'Take medications as prescribed',
              'Follow a diabetes-friendly meal plan',
              'Exercise regularly with doctor approval',
              'Keep regular check-ups with your healthcare team'
            ],
            tipsCeb: [
              'Bantayi ang blood sugar levels kanunay',
              'Inom-a ang tambal sumala sa gipreskribi',
              'Sunda ang diabetes-friendly nga meal plan',
              'Mag-ehersisyo kanunay uban sa approval sa doktor',
              'Padayon ang regular nga check-ups sa healthcare team'
            ],
            category: 'diabetes',
            icon: 'bloodtype',
            color: 'red',
            createdAt: DateTime.now(),
          ),
          EducationContentModel(
            id: 'd2',
            titleEn: 'Blood Sugar Management',
            titleCeb: 'Pagdumala sa Blood Sugar',
            contentEn:
                'Maintaining stable blood sugar levels prevents complications and helps you feel your best.',
            contentCeb:
                'Ang pagmintinar og stable nga blood sugar levels makapugong sa mga komplikasyon ug makatabang nimo nga mabati nga maayo.',
            tipsEn: [
              'Eat meals at regular times',
              'Choose complex carbohydrates',
              'Avoid sugary drinks and snacks',
              'Stay physically active',
              'Manage stress levels'
            ],
            tipsCeb: [
              'Kaon sa regular nga oras',
              'Pilia ang complex carbohydrates',
              'Likayi ang tam-is nga ilimnon ug snacks',
              'Magpabilin nga aktibo sa lawas',
              'Dumalahe ang stress levels'
            ],
            category: 'diabetes',
            icon: 'health_and_safety',
            color: 'blue',
            createdAt: DateTime.now(),
          ),
        ];

      case 'hypertension':
        return [
          EducationContentModel(
            id: 'h1',
            titleEn: 'Understanding High Blood Pressure',
            titleCeb: 'Pagsabot sa Taas nga Presyon sa Dugo',
            contentEn:
                'High blood pressure is when the force of blood against artery walls is consistently too high.',
            contentCeb:
                'Ang taas nga presyon sa dugo mao kung ang kusog sa dugo batok sa artery walls kanunay nga sobra ka taas.',
            tipsEn: [
              'Reduce sodium intake',
              'Maintain a healthy weight',
              'Exercise regularly',
              'Limit alcohol consumption',
              'Quit smoking',
              'Manage stress effectively'
            ],
            tipsCeb: [
              'Pagkunhod sa sodium intake',
              'Maintinar ang healthy nga timbang',
              'Mag-ehersisyo kanunay',
              'Limitahi ang pag-inom og alkohol',
              'Hunonga ang pananigarilyo',
              'Dumalahe ang stress sa epektibong paagi'
            ],
            category: 'hypertension',
            icon: 'favorite',
            color: 'red',
            createdAt: DateTime.now(),
          ),
          EducationContentModel(
            id: 'h2',
            titleEn: 'DASH Diet for Blood Pressure',
            titleCeb: 'DASH Diet para sa Presyon sa Dugo',
            contentEn:
                'The DASH diet emphasizes fruits, vegetables, whole grains, and lean proteins to help lower blood pressure.',
            contentCeb:
                'Ang DASH diet nag-emphasize sa prutas, utanon, whole grains, ug lean proteins aron makatabang sa pagkunhod sa presyon sa dugo.',
            tipsEn: [
              'Eat plenty of fruits and vegetables',
              'Choose low-fat dairy products',
              'Include nuts and seeds',
              'Reduce red meat consumption',
              'Use herbs and spices instead of salt'
            ],
            tipsCeb: [
              'Kaon og daghan nga prutas ug utanon',
              'Pilia ang low-fat dairy products',
              'Iapil ang nuts ug liso',
              'Pagkunhod sa pagkaon og pula nga karne',
              'Gamita ang herbs ug spices imbes nga asin'
            ],
            category: 'hypertension',
            icon: 'no_food',
            color: 'green',
            createdAt: DateTime.now(),
          ),
        ];

      case 'heart_health':
        return [
          EducationContentModel(
            id: 'hh1',
            titleEn: 'Heart-Healthy Living',
            titleCeb: 'Pagkinabuhi nga Maayo sa Kasingkasing',
            contentEn:
                'A healthy lifestyle can significantly reduce your risk of heart disease and improve overall cardiovascular health.',
            contentCeb:
                'Ang healthy nga lifestyle makahubad pag-ayo sa imong risgo sa sakit sa kasingkasing ug makapauswag sa kinatibuk-ang cardiovascular health.',
            tipsEn: [
              'Exercise for at least 30 minutes daily',
              'Eat a heart-healthy diet',
              'Maintain a healthy weight',
              'Don\'t smoke or quit if you do',
              'Get adequate sleep (7-9 hours)',
              'Manage stress and anxiety'
            ],
            tipsCeb: [
              'Mag-ehersisyo og labing menos 30 ka minuto kada adlaw',
              'Kaon og heart-healthy nga pagkaon',
              'Maintinar ang healthy nga timbang',
              'Ayaw pag-sigarilyo o hunonga kung nag-sigarilyo',
              'Makatulog og igo (7-9 ka oras)',
              'Dumalahe ang stress ug kabalaka'
            ],
            category: 'heart_health',
            icon: 'favorite',
            color: 'pink',
            createdAt: DateTime.now(),
          ),
          EducationContentModel(
            id: 'hh2',
            titleEn: 'Recognizing Heart Attack Symptoms',
            titleCeb: 'Pag-ila sa mga Simptomas sa Heart Attack',
            contentEn:
                'Knowing the warning signs of a heart attack can save lives. Seek immediate medical attention if symptoms occur.',
            contentCeb:
                'Ang pagkahibalo sa mga warning signs sa heart attack makaluwas og kinabuhi. Pangitag dali nga medical attention kung adunay mga simptomas.',
            tipsEn: [
              'Chest pain or pressure',
              'Pain in arms, neck, jaw, or back',
              'Shortness of breath',
              'Nausea or lightheadedness',
              'Cold sweats',
              'Call emergency services immediately if symptoms occur'
            ],
            tipsCeb: [
              'Kasakit sa dughan o pressure',
              'Kasakit sa mga bukton, liog, suwang, o likod',
              'Lisod sa pagginhawa',
              'Kasuka o pagkaluya',
              'Bugnaw nga singot',
              'Tawagan dayon ang emergency services kung adunay mga simptomas'
            ],
            category: 'heart_health',
            icon: 'medical_services',
            color: 'red',
            createdAt: DateTime.now(),
          ),
        ];

      case 'kidney_care':
        return [
          EducationContentModel(
            id: 'k1',
            titleEn: 'Kidney Health Basics',
            titleCeb: 'Mga Basikong Panglawas sa Kidney',
            contentEn:
                'Your kidneys filter waste from your blood and regulate fluid balance. Keeping them healthy is essential.',
            contentCeb:
                'Ang imong mga kidney nagsala sa basura gikan sa imong dugo ug nag-regulate sa fluid balance. Importante nga tipigan sila nga healthy.',
            tipsEn: [
              'Drink plenty of water daily',
              'Maintain healthy blood pressure',
              'Control blood sugar levels',
              'Limit salt intake',
              'Avoid excessive use of painkillers',
              'Get regular kidney function tests'
            ],
            tipsCeb: [
              'Mag-inom og daghan nga tubig kada adlaw',
              'Maintinar ang healthy nga blood pressure',
              'Kontrola ang blood sugar levels',
              'Limitahi ang pag-inom og asin',
              'Likayi ang sobra nga paggamit sa painkillers',
              'Makakuha og regular nga kidney function tests'
            ],
            category: 'kidney_care',
            icon: 'water_drop',
            color: 'cyan',
            createdAt: DateTime.now(),
          ),
          EducationContentModel(
            id: 'k2',
            titleEn: 'Chronic Kidney Disease Prevention',
            titleCeb: 'Pagpugong sa Chronic Kidney Disease',
            contentEn:
                'Preventing chronic kidney disease involves managing risk factors and maintaining overall health.',
            contentCeb:
                'Ang pagpugong sa chronic kidney disease naglakip sa pagdumala sa mga risk factors ug pagmintinar sa kinatibuk-ang panglawas.',
            tipsEn: [
              'Manage diabetes if you have it',
              'Control high blood pressure',
              'Maintain a healthy diet',
              'Exercise regularly',
              'Avoid smoking',
              'Limit alcohol consumption'
            ],
            tipsCeb: [
              'Dumalahe ang diabetes kung naa ka',
              'Kontrola ang taas nga blood pressure',
              'Maintinar ang healthy nga pagkaon',
              'Mag-ehersisyo kanunay',
              'Likayi ang pananigarilyo',
              'Limitahi ang pag-inom og alkohol'
            ],
            category: 'kidney_care',
            icon: 'health_and_safety',
            color: 'teal',
            createdAt: DateTime.now(),
          ),
        ];

      default:
        return [];
    }
  }

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
              child: _buildContentList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    final contents = _getEducationContent;

    if (contents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined, color: textGrey, size: 48),
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
