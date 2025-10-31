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
    'Diabetes',
    'CKD',
    'Thyroid',
    'Goiter',
    'Respiratory',
    'Heart Disease',
    'Stroke',
    'Migraine',
    'Epilepsy',
    'Arthritis',
    'Osteoporosis',
    'Cancer',
    'TB',
    'Preventive Care',
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
            titleEn: 'Understanding Diabetes Mellitus',
            titleCeb: 'Pagsabot sa Diabetes Mellitus',
            contentEn:
                'Diabetes occurs when the body has trouble using sugar properly due to insufficient insulin or a lack of insulin response. This leads to high blood sugar. If not managed, it can cause heart attack, stroke, kidney damage, vision loss, and slow-healing wounds.',
            contentCeb:
                'Ang diabetes mahitabo kung ang lawas adunay problema sa paggamit sa asukal tungod sa kulang nga insulin o kakulang sa tubag sa insulin. Kini mosangpot sa taas nga blood sugar. Kung dili madumala, mahimong hinungdan sa heart attack, stroke, kidney damage, pagkawala sa panan-aw, ug hinay nga pag-ayo sa samad.',
            tipsEn: [
              'MYTH: Diabetes happens only because of eating too many sweets. FACT: Caused by genetics, being overweight, lack of physical activity, and poor diet overall.',
              'MYTH: If you don\'t feel sick, your diabetes is not serious. FACT: Diabetes can silently damage your heart, kidneys, eyes, and nerves even if you feel fine.',
              'MYTH: Once you start medicines or insulin, you will be dependent for life. FACT: Medicines help control blood sugar and prevent complications. Some may reduce medicines with lifestyle changes.',
              'MYTH: Eating fruits is always safe. FACT: Some fruits can raise blood sugar if eaten in large amounts. Portion control is key.',
              'MYTH: Herbal teas can cure diabetes. FACT: No herbal remedy can cure diabetes. Always consult your doctor.',
            ],
            tipsCeb: [
              'MITO: Ang diabetes mahitabo tungod sa sobrang pagkaon og tam-is. KAMATUORAN: Hinungdan sa genetics, sobra nga timbang, kakulang sa physical activity, ug dili maayo nga pagkaon.',
              'MITO: Kung dili ka masakiton, ang diabetes dili grabe. KAMATUORAN: Ang diabetes makadaot sa kasingkasing, kidney, mata, ug nerves bisan og maayo ang gibati.',
              'MITO: Kung magsugod og tambal o insulin, dependent na hangtod sa kinabuhi. KAMATUORAN: Ang tambal makatabang sa pagkontrol sa blood sugar ug pagpugong sa komplikasyon.',
              'MITO: Ang pagkaon og prutas kanunay safe. KAMATUORAN: Ang ubang prutas makapaas sa blood sugar kung daghan kaayo. Importante ang portion control.',
              'MITO: Ang herbal tea makaayo sa diabetes. KAMATUORAN: Walay herbal remedy nga makaayo sa diabetes. Konsultaha ang doktor.',
            ],
            category: 'diabetes',
            icon: 'bloodtype',
            color: 'red',
            createdAt: DateTime.now(),
          ),
          EducationContentModel(
            id: 'd2',
            titleEn: 'Healthy Lifestyle for Diabetes',
            titleCeb: 'Himsog nga Kinabuhi para sa Diabetes',
            contentEn:
                'Follow "Go, Grow, Glow" food groups daily. Eat more vegetables, fruits, fish, and whole grains. Limit processed foods, salty snacks, and sugary drinks. Example: rice + gulay (malunggay, kangkong) + isda or manok + prutas (saging, mangga).',
            contentCeb:
                'Sunda ang "Go, Grow, Glow" food groups kada adlaw. Kaon og daghan nga utanon, prutas, isda, ug whole grains. Limitaha ang processed foods, asin nga snacks, ug tam-is nga ilimnon. Pananglitan: bugas + gulay (malunggay, kangkong) + isda o manok + prutas (saging, mangga).',
            tipsEn: [
              'Physical Activity: 30 minutes brisk walking, dancing, or stretching daily. Check blood sugar before exercise if you feel dizzy.',
              'Hydration: 8-10 glasses a day. "1 baso kada pagkaon, 1 baso kada snack."',
              'Medication: Set alarms, use pillboxes, or take meds at the same time as meals. Avoid herbal remedies without doctor\'s advice.',
              'Monitoring: Track blood sugar, BP, and weight regularly. Record results in the app.',
              'Emergency: Go to hospital if sugar >300 mg/dL or <70 mg/dL, chest pain, dizziness, or blurred vision.',
            ],
            tipsCeb: [
              'Physical Activity: 30 minutos nga brisk walking, sayaw, o stretching kada adlaw. Susiha ang blood sugar una sa exercise kung naglibog.',
              'Hydration: 8-10 ka baso kada adlaw. "1 baso kada pagkaon, 1 baso kada snack."',
              'Tambal: Mag-set og alarm, gamit og pillbox, o inom sa tambal sa samang oras sa pagkaon. Likayi ang herbal remedies nga walay tambag sa doktor.',
              'Monitoring: Bantayi ang blood sugar, BP, ug timbang kanunay. I-record ang resulta sa app.',
              'Emergency: Adto sa hospital kung ang sugar >300 mg/dL o <70 mg/dL, sakit sa dughan, naglibog, o dili klaro ang panan-aw.',
            ],
            category: 'diabetes',
            icon: 'health_and_safety',
            color: 'blue',
            createdAt: DateTime.now(),
          ),
        ];

      case 'ckd':
        return [
          EducationContentModel(
            id: 'ckd1',
            titleEn: 'Understanding Chronic Kidney Disease',
            titleCeb: 'Pagsabot sa Chronic Kidney Disease',
            contentEn:
                'CKD happens when the kidneys slowly lose their ability to clean the blood and remove waste. This can be caused by high blood pressure, diabetes, or repeated kidney infections. If not managed, may lead to dialysis, heart disease, swelling, and severe anemia.',
            contentCeb:
                'Ang CKD mahitabo kung ang mga kidney hinay-hinay nga mawad-an sa ilang abilidad sa paglimpyo sa dugo ug pagtangtang sa basura. Mahimong hinungdan niini ang taas nga presyon sa dugo, diabetes, o balik-balik nga impeksyon sa kidney. Kung dili madumala, mahimong mosangpot sa dialysis, sakit sa kasingkasing, hubag, ug grabe nga anemia.',
            tipsEn: [
              'MYTH: CKD is caused only by drinking too many soft drinks. FACT: Main causes are uncontrolled diabetes, high blood pressure, infections, or long-term use of some painkillers.',
              'MYTH: People with CKD should drink lots of water to "wash out" the kidneys. FACT: Some need to limit fluids to prevent swelling. Follow your doctor\'s advice.',
              'MYTH: If you have CKD, you will always end up on dialysis. FACT: With early detection and proper treatment, kidney function can be preserved for many years.',
              'MYTH: CKD only happens to old people. FACT: Anyone can develop CKD, including younger adults and children.',
              'MYTH: Taking herbal "kidney cleansers" is safe. FACT: Some herbal products can worsen kidney damage. Always check with a doctor.',
            ],
            tipsCeb: [
              'MITO: Ang CKD hinungdan lang sa sobrang pag-inom og soft drinks. KAMATUORAN: Ang nag-unang hinungdan mao ang dili kontrolado nga diabetes, taas nga presyon sa dugo, impeksyon, o dugay nga paggamit sa ubang painkillers.',
              'MITO: Ang mga tawo nga adunay CKD kinahanglan mag-inom og daghan nga tubig aron "hugasan" ang kidney. KAMATUORAN: Ang uban kinahanglan limitahan ang tubig aron mapugngan ang hubag. Sunda ang tambag sa doktor.',
              'MITO: Kung adunay CKD, sigurado nga moabot sa dialysis. KAMATUORAN: Uban sa sayo nga pagkakita ug hustong tambal, ang kidney function mapanalipdan sulod sa daghang tuig.',
              'MITO: Ang CKD mahitabo lang sa tigulang. KAMATUORAN: Bisan kinsa mahimong makaangkon og CKD, lakip ang mga batan-on ug mga bata.',
              'MITO: Ang pag-inom og herbal "kidney cleansers" luwas. KAMATUORAN: Ang ubang herbal products makapasamot sa kidney damage. Kanunay susiha sa doktor.',
            ],
            category: 'ckd',
            icon: 'water_drop',
            color: 'cyan',
            createdAt: DateTime.now(),
          ),
          EducationContentModel(
            id: 'ckd2',
            titleEn: 'Managing CKD: Lifestyle & Monitoring',
            titleCeb: 'Pagdumala sa CKD: Kinabuhi ug Monitoring',
            contentEn:
                'Eat fresh vegetables, fruits (in moderation), fish, whole grains. Limit salty snacks, instant noodles, processed foods. CKD patients should avoid foods high in salt and sometimes limit potassium. Example: ½ rice, ¼ gulay (ampalaya, pechay), ¼ isda/manok, prutas (small portion).',
            contentCeb:
                'Kaon og presko nga utanon, prutas (dili sobra), isda, whole grains. Limitaha ang asin nga snacks, instant noodles, processed foods. Ang mga pasyente sa CKD kinahanglan likayi ang pagkaon nga daghan og asin ug usahay limitahan ang potassium. Pananglitan: ½ bugas, ¼ gulay (ampalaya, pechay), ¼ isda/manok, prutas (gamay nga bahin).',
            tipsEn: [
              'Physical Activity: 30 minutes walking, stretching, or dancing 5x a week. Avoid overexertion, check BP before exercise.',
              'Hydration: Usually 6-8 glasses unless your doctor says less. "1 baso kada pagkaon, 1 baso kada snack" – unless restricted.',
              'Medication: Medicines control BP, blood sugar, and protect kidneys. Use alarms or pillboxes. Avoid herbal "kidney cleansers".',
              'Monitoring: Keep track of BP, weight, and swelling. Seek help if BP >180/120 mmHg with headache or sudden swelling.',
              'Emergency: Go to hospital for severe shortness of breath, uncontrolled BP, extreme fatigue or confusion.',
            ],
            tipsCeb: [
              'Physical Activity: 30 minutos nga paglakaw, stretching, o sayaw 5x sa semana. Likayi ang sobrang kakapoy, susiha ang BP una sa exercise.',
              'Hydration: Kasagaran 6-8 ka baso gawas kon ang doktor moingon nga kulangan. "1 baso kada pagkaon, 1 baso kada snack" – gawas kon limitado.',
              'Tambal: Ang mga tambal nagkontrol sa BP, blood sugar, ug nagpanalipod sa kidney. Gamit og alarm o pillbox. Likayi ang herbal "kidney cleansers".',
              'Monitoring: Bantayi ang BP, timbang, ug hubag. Pangayo og tabang kung ang BP >180/120 mmHg uban sa sakit sa ulo o kalit nga hubag.',
              'Emergency: Adto sa hospital para sa grabe nga lisod sa pagginhawa, dili kontrolado nga BP, sobrang kakapoy o kalibog.',
            ],
            category: 'ckd',
            icon: 'health_and_safety',
            color: 'teal',
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

      case 'thyroid':
        return [
          EducationContentModel(
            id: 'thy1',
            titleEn: 'Hypothyroidism',
            titleCeb: 'Hypothyroidism',
            contentEn:
                'Hypothyroidism occurs when thyroid gland does not produce enough hormones. Symptoms: fatigue, weight gain, cold intolerance, constipation, dry skin, hair loss, depression. About 8.53% of Filipinos have thyroid abnormalities.',
            contentCeb:
                'Ang hypothyroidism mahitabo kung ang thyroid gland dili makahimo og igo nga hormones. Sintomas: kakapoy, pagsaka sa timbang, dili makaagwanta sa kabugnaw, constipation, uga nga panit, pagkahulog sa buhok, depresyon. Mga 8.53% sa mga Pilipino adunay thyroid abnormalities.',
            tipsEn: [
              'MYTH: Only older adults get hypothyroidism. FACT: Can occur at any age.',
              'MYTH: Herbal supplements can cure it. FACT: Lifelong hormone replacement therapy required.',
              'Nutrition: Balanced diet with seafood, lean meats, nuts, seeds, leafy greens, eggs, dairy. Limit goitrogenic foods.',
              'Medication: Take levothyroxine on empty stomach 30-60 min before breakfast. Set daily reminders.',
              'Emergency: Seek help for severe fatigue, unexplained weight gain, depression, cold intolerance.',
            ],
            tipsCeb: [
              'MITO: Ang mga tigulang ra makaangkon. KAMATUORAN: Mahitabo sa bisan unsang edad.',
              'MITO: Ang herbal supplements makaayo. KAMATUORAN: Kinahanglan ang lifelong hormone replacement therapy.',
              'Nutrisyon: Balanced nga pagkaon nga adunay seafood, lean meats, nuts, seeds, leafy greens, itlog, dairy. Limitaha ang goitrogenic foods.',
              'Tambal: Inom og levothyroxine sa walay sulod nga tiyan 30-60 min una sa pamahaw. Mag-set og daily reminders.',
              'Emergency: Pangayo og tabang para sa grabe nga kakapoy, dili mahibal-an nga pagsaka sa timbang, depresyon, dili makaagwanta sa kabugnaw.',
            ],
            category: 'thyroid',
            icon: 'healing',
            color: 'purple',
            createdAt: DateTime.now(),
          ),
        ];

      case 'goiter':
        return [
          EducationContentModel(
            id: 'goi1',
            titleEn: 'Understanding Goiter',
            titleCeb: 'Pagsabot sa Goiter',
            contentEn:
                'Goiter is abnormal enlargement of thyroid gland in the neck. Causes include iodine deficiency and autoimmune diseases. In Philippines, goiter prevalence is 10.12%. Can cause difficulty swallowing or breathing.',
            contentCeb:
                'Ang goiter mao ang dili normal nga pagdako sa thyroid gland sa liog. Ang hinungdan naglakip sa kakulang sa iodine ug autoimmune diseases. Sa Pilipinas, ang goiter prevalence kay 10.12%. Mahimong hinungdan sa lisod sa pagtulon o pagginhawa.',
            tipsEn: [
              'MYTH: Goiter only caused by iodine deficiency. FACT: Autoimmune diseases can also cause it.',
              'MYTH: If painless, no treatment needed. FACT: Can still cause complications.',
              'Nutrition: ½ plate vegetables/fruits, ¼ whole grains, ¼ lean protein. Include iodized salt in moderation.',
              'Physical Activity: 30 minutes brisk walking, dancing, stretching. Warm up before activity.',
              'Monitoring: Watch for difficulty swallowing, breathing, or neck swelling.',
            ],
            tipsCeb: [
              'MITO: Ang goiter hinungdan lang sa kakulang sa iodine. KAMATUORAN: Ang autoimmune diseases mahimo usab nga hinungdan.',
              'MITO: Kung walay sakit, dili kinahanglan og tambal. KAMATUORAN: Mahimong mosangpot gihapon sa komplikasyon.',
              'Nutrisyon: ½ plato utanon/prutas, ¼ whole grains, ¼ lean protein. Iapil ang iodized salt sa kasarangan.',
              'Physical Activity: 30 minutos brisk walking, sayaw, stretching. Mag-warm up una sa kalihokan.',
              'Monitoring: Bantayi ang lisod sa pagtulon, pagginhawa, o hubag sa liog.',
            ],
            category: 'goiter',
            icon: 'healing',
            color: 'teal',
            createdAt: DateTime.now(),
          ),
        ];

      case 'respiratory':
        return [
          EducationContentModel(
            id: 'resp1',
            titleEn: 'COPD & Asthma',
            titleCeb: 'COPD ug Asthma',
            contentEn:
                'COPD is progressive lung disease with breathing problems. Asthma is chronic inflammatory disease of airways. Both cause wheezing, breathlessness, and coughing. Risk factors: smoking, air pollution, allergens.',
            contentCeb:
                'Ang COPD usa ka progressive lung disease nga adunay problema sa pagginhawa. Ang asthma usa ka chronic inflammatory disease sa airways. Ang duha hinungdan sa wheezing, lisod sa pagginhawa, ug pag-ubo. Risk factors: pananigarilyo, air pollution, allergens.',
            tipsEn: [
              'MYTH: Just a cough, not serious. FACT: Can lead to respiratory failure if not managed.',
              'MYTH: Only elderly get COPD. FACT: Can affect adults of all ages with risk factors.',
              'Nutrition: ½ plate vegetables/fruits, ¼ whole grains, ¼ fish/chicken. Limit processed foods.',
              'Hydration: 8-10 cups/day helps thin mucus.',
              'Medication: Bronchodilators and steroids help open airways. Use pillbox, set alarms.',
              'Emergency: Severe shortness of breath, chest pain, bluish lips, confusion.',
            ],
            tipsCeb: [
              'MITO: Usa lang ka ubo, dili grabe. KAMATUORAN: Mahimong mosangpot sa respiratory failure kung dili madumala.',
              'MITO: Ang mga tigulang lang makaangkon og COPD. KAMATUORAN: Makaapekto sa hamtong sa tanang edad nga adunay risk factors.',
              'Nutrisyon: ½ plato utanon/prutas, ¼ whole grains, ¼ isda/manok. Limitaha ang processed foods.',
              'Hydration: 8-10 ka tasa/adlaw makatabang sa pag-nipis sa mucus.',
              'Tambal: Ang bronchodilators ug steroids makatabang sa pag-abli sa airways. Gamit og pillbox, mag-set og alarm.',
              'Emergency: Grabe nga lisod sa pagginhawa, sakit sa dughan, asul nga ngabil, kalibog.',
            ],
            category: 'respiratory',
            icon: 'air',
            color: 'blue',
            createdAt: DateTime.now(),
          ),
        ];

      case 'heart_disease':
        return [
          EducationContentModel(
            id: 'hd1',
            titleEn: 'Heart Disease',
            titleCeb: 'Sakit sa Kasingkasing',
            contentEn:
                'Ischemic heart disease occurs when coronary arteries become narrowed. Symptoms: chest pain, heart attack, shortness of breath. Hypertensive heart disease caused by persistent high BP. Both can lead to heart failure.',
            contentCeb:
                'Ang ischemic heart disease mahitabo kung ang coronary arteries mahimong pig-ot. Sintomas: sakit sa dughan, heart attack, lisod sa pagginhawa. Ang hypertensive heart disease hinungdan sa padayon nga taas nga BP. Ang duha mahimong mosangpot sa heart failure.',
            tipsEn: [
              'MYTH: Only affects elderly. FACT: Can affect younger adults with risk factors.',
              'Nutrition: ½ plate vegetables/fruits, ¼ whole grains, ¼ lean protein. Eat oily fish 2-3x/week.',
              'Physical Activity: 30 minutes brisk walking daily. Improves circulation and lowers BP.',
              'Medication: Antiplatelets, statins, beta-blockers reduce heart attack risk.',
              'Emergency: Chest pain/pressure, shortness of breath, dizziness, palpitations.',
            ],
            tipsCeb: [
              'MITO: Makaapekto lang sa tigulang. KAMATUORAN: Mahimong makaapekto sa batan-on nga adunay risk factors.',
              'Nutrisyon: ½ plato utanon/prutas, ¼ whole grains, ¼ lean protein. Kaon og oily fish 2-3x/semana.',
              'Physical Activity: 30 minutos brisk walking kada adlaw. Nagpauswag sa circulation ug nagpaubos sa BP.',
              'Tambal: Ang antiplatelets, statins, beta-blockers makakunhod sa heart attack risk.',
              'Emergency: Sakit sa dughan/pressure, lisod sa pagginhawa, naglibog, palpitations.',
            ],
            category: 'heart_disease',
            icon: 'favorite',
            color: 'red',
            createdAt: DateTime.now(),
          ),
        ];

      case 'stroke':
        return [
          EducationContentModel(
            id: 'str1',
            titleEn: 'Stroke Awareness',
            titleCeb: 'Kahibalo sa Stroke',
            contentEn:
                'Stroke occurs when blood supply to brain is interrupted. Warning signs BEFAST: Balance loss, Eye vision change, Face droop, Arm weakness, Speech slurred, Time to call emergency.',
            contentCeb:
                'Ang stroke mahitabo kung ang suplay sa dugo sa utok ma-interrupt. Warning signs BEFAST: Balance loss, Eye vision change, Face droop, Arm weakness, Speech slurred, Time to call emergency.',
            tipsEn: [
              'Nutrition: ½ plate vegetables/fruits, ¼ whole grains, ¼ lean protein. Limit salt <2,000 mg/day.',
              'Physical Activity: 30 minutes walking prevents second stroke.',
              'Medication: Antiplatelets, statins, BP meds cut recurrence risk.',
              'Emergency: New weakness, facial droop, severe headache, confusion, slurred speech.',
            ],
            tipsCeb: [
              'Nutrisyon: ½ plato utanon/prutas, ¼ whole grains, ¼ lean protein. Limitaha ang asin <2,000 mg/adlaw.',
              'Physical Activity: 30 minutos paglakaw nagpugong sa ikaduhang stroke.',
              'Tambal: Ang antiplatelets, statins, BP meds makakunhod sa recurrence risk.',
              'Emergency: Bag-ong kahuyang, facial droop, grabe nga sakit sa ulo, kalibog, slurred speech.',
            ],
            category: 'stroke',
            icon: 'emergency',
            color: 'red',
            createdAt: DateTime.now(),
          ),
        ];

      case 'migraine':
        return [
          EducationContentModel(
            id: 'mig1',
            titleEn: 'Migraine Management',
            titleCeb: 'Pagdumala sa Migraine',
            contentEn:
                'Migraine causes severe recurring headaches, often one-sided. Symptoms: throbbing pain, nausea, vomiting, sensitivity to light/sound. Triggers: stress, lack of sleep, certain foods, hormonal changes.',
            contentCeb:
                'Ang migraine hinungdan sa grabe nga balik-balik nga sakit sa ulo, kasagaran sa usa ka bahin. Sintomas: throbbing pain, pagkasuka, pagsuka, sensitivity sa kahayag/tingog. Triggers: stress, kakulang sa tulog, pipila ka pagkaon, hormonal changes.',
            tipsEn: [
              'Nutrition: Balanced meals at regular times. Avoid trigger foods. Stay hydrated.',
              'Medication: Preventive meds reduce frequency. Acute meds for attacks.',
              'Monitoring: Keep headache diary - date, time, symptoms, triggers.',
              'Emergency: Extremely severe headache, headache with vision changes, weakness.',
            ],
            tipsCeb: [
              'Nutrisyon: Balanced nga pagkaon sa regular nga oras. Likayi ang trigger foods. Magpabilin nga hydrated.',
              'Tambal: Ang preventive meds makakunhod sa frequency. Ang acute meds para sa attacks.',
              'Monitoring: Hupti ang headache diary - petsa, oras, sintomas, triggers.',
              'Emergency: Sobrang grabe nga sakit sa ulo, sakit sa ulo uban sa pagbag-o sa panan-aw, kahuyang.',
            ],
            category: 'migraine',
            icon: 'psychology',
            color: 'purple',
            createdAt: DateTime.now(),
          ),
        ];

      case 'epilepsy':
        return [
          EducationContentModel(
            id: 'epi1',
            titleEn: 'Epilepsy Care',
            titleCeb: 'Pag-atiman sa Epilepsy',
            contentEn:
                'Epilepsy is neurological disorder with repeated seizures. Not contagious - it\'s a brain problem. Caused by brain injury, infection, genetics.',
            contentCeb:
                'Ang epilepsy usa ka neurological disorder nga adunay balik-balik nga seizures. Dili makatak-tak - usa kini ka problema sa utok. Hinungdan sa brain injury, impeksyon, genetics.',
            tipsEn: [
              'MYTH: Epilepsy is contagious. FACT: Not contagious; it\'s a brain problem.',
              'Nutrition: Balanced meals. Protein important for brain health. Avoid excessive caffeine.',
              'Physical Activity: Walking 30 min, stretching. Ensure seizure control before high-risk activities.',
              'Medication: Anti-seizure meds prevent seizures. Use pillbox, set alarms.',
              'Emergency: Seizure >5 minutes, multiple seizures without recovery, breathing difficulty.',
            ],
            tipsCeb: [
              'MITO: Ang epilepsy makatak-tak. KAMATUORAN: Dili makatak-tak; usa kini ka problema sa utok.',
              'Nutrisyon: Balanced nga pagkaon. Importante ang protein para sa brain health. Likayi ang sobra nga caffeine.',
              'Physical Activity: Paglakaw 30 min, stretching. Siguroha ang seizure control una sa high-risk activities.',
              'Tambal: Ang anti-seizure meds nagpugong sa seizures. Gamit og pillbox, mag-set og alarm.',
              'Emergency: Seizure >5 minutos, daghang seizures nga walay recovery, lisod sa pagginhawa.',
            ],
            category: 'epilepsy',
            icon: 'medical_services',
            color: 'orange',
            createdAt: DateTime.now(),
          ),
        ];

      case 'arthritis':
        return [
          EducationContentModel(
            id: 'art1',
            titleEn: 'Arthritis & Joint Health',
            titleCeb: 'Arthritis ug Joint Health',
            contentEn:
                'Arthritis is inflammation of joints. Types: osteoarthritis, rheumatoid arthritis, gout. Symptoms: joint pain, stiffness, swelling. Over 5 million Filipinos affected.',
            contentCeb:
                'Ang arthritis mao ang inflammation sa joints. Mga tipo: osteoarthritis, rheumatoid arthritis, gout. Sintomas: sakit sa joints, stiffness, hubag. Sobra sa 5 million Filipinos ang apektado.',
            tipsEn: [
              'MYTH: Only affects elderly. FACT: Children and young adults can get arthritis.',
              'Nutrition: Eat fatty fish (omega-3), nuts, seeds. Limit processed foods.',
              'Physical Activity: 30 minutes walking, swimming, yoga, tai chi. Maintains joint flexibility.',
              'Monitoring: Track pain levels, stiffness, swelling. Seek help if severe pain or fever.',
            ],
            tipsCeb: [
              'MITO: Makaapekto lang sa tigulang. KAMATUORAN: Ang mga bata ug batan-on mahimong makaangkon og arthritis.',
              'Nutrisyon: Kaon og fatty fish (omega-3), nuts, seeds. Limitaha ang processed foods.',
              'Physical Activity: 30 minutos paglakaw, paglangoy, yoga, tai chi. Nagmintinar sa joint flexibility.',
              'Monitoring: Bantayi ang pain levels, stiffness, hubag. Pangayo og tabang kung grabe ang sakit o hilanat.',
            ],
            category: 'arthritis',
            icon: 'accessibility',
            color: 'green',
            createdAt: DateTime.now(),
          ),
        ];

      case 'osteoporosis':
        return [
          EducationContentModel(
            id: 'ost1',
            titleEn: 'Osteoporosis Prevention',
            titleCeb: 'Pagpugong sa Osteoporosis',
            contentEn:
                'Osteoporosis makes bones weak and brittle. Can cause fractures from minor falls. Risk factors: aging, low calcium/vitamin D, lack of exercise.',
            contentCeb:
                'Ang osteoporosis naghimo sa mga bukog nga huyang ug mabuak. Mahimong hinungdan sa fractures tungod sa gamay nga pagkapandol. Risk factors: pagkatigulang, ubos nga calcium/vitamin D, kakulang sa ehersisyo.',
            tipsEn: [
              'MYTH: Normal in elderly, nothing can be done. FACT: Lifestyle, diet, medicine can prevent bone loss.',
              'Nutrition: Eat dairy, small fish with bones, green leafy vegetables, nuts. Ensure calcium and vitamin D.',
              'Physical Activity: Weight-bearing exercises (walking, dancing, stairs) increase bone density.',
              'Monitoring: Bone density tests, track falls, fracture history.',
              'Emergency: After a fall with pain, suspected broken bone, severe back pain.',
            ],
            tipsCeb: [
              'MITO: Normal sa tigulang, walay mahimo. KAMATUORAN: Ang lifestyle, diet, tambal makapugong sa bone loss.',
              'Nutrisyon: Kaon og dairy, gamay nga isda nga adunay bukog, green leafy vegetables, nuts. Siguroha ang calcium ug vitamin D.',
              'Physical Activity: Ang weight-bearing exercises (paglakaw, sayaw, hagdan) nagdugang sa bone density.',
              'Monitoring: Bone density tests, bantayi ang pagkapandol, fracture history.',
              'Emergency: Human sa pagkapandol nga adunay sakit, suspetsang nabuak nga bukog, grabe nga sakit sa likod.',
            ],
            category: 'osteoporosis',
            icon: 'accessibility_new',
            color: 'cyan',
            createdAt: DateTime.now(),
          ),
        ];

      case 'cancer':
        return [
          EducationContentModel(
            id: 'can1',
            titleEn: 'Breast Cancer Awareness',
            titleCeb: 'Kahibalo sa Breast Cancer',
            contentEn:
                'Breast cancer is most common cancer in Filipino women. Early detection through self-check and mammogram is crucial. Treatment includes surgery, chemotherapy, radiation, hormonal therapy.',
            contentCeb:
                'Ang breast cancer mao ang labing kasagaran nga cancer sa mga Filipina. Importante ang sayo nga pagkakita pinaagi sa self-check ug mammogram. Ang tambal naglakip sa surgery, chemotherapy, radiation, hormonal therapy.',
            tipsEn: [
              'MYTH: Only with family history get breast cancer. FACT: Many cases have no family history.',
              'MYTH: If no lump, I\'m safe. FACT: Regular check-ups help detect early.',
              'Nutrition: Fresh fruits, green leafy vegetables, fatty fish, whole grains, nuts.',
              'Physical Activity: 30 minutes walking daily helps maintain healthy weight.',
              'Medication: Follow oncologist\'s treatment plan. Don\'t use herbal alternatives without doctor.',
              'Emergency: New lump, nipple discharge, redness, swelling, fever after surgery.',
            ],
            tipsCeb: [
              'MITO: Ang adunay family history lang makaangkon. KAMATUORAN: Daghan nga cases walay family history.',
              'MITO: Kung walay lump, safe ko. KAMATUORAN: Ang regular check-ups makatabang sa sayo nga pagkakita.',
              'Nutrisyon: Presko nga prutas, green leafy vegetables, fatty fish, whole grains, nuts.',
              'Physical Activity: 30 minutos paglakaw kada adlaw makatabang sa pagmintinar og healthy weight.',
              'Tambal: Sunda ang treatment plan sa oncologist. Ayaw gamita ang herbal alternatives nga walay doktor.',
              'Emergency: Bag-ong lump, discharge sa nipple, pula, hubag, hilanat human sa surgery.',
            ],
            category: 'cancer',
            icon: 'health_and_safety',
            color: 'pink',
            createdAt: DateTime.now(),
          ),
        ];

      case 'tb':
        return [
          EducationContentModel(
            id: 'tb1',
            titleEn: 'Tuberculosis (TB)',
            titleCeb: 'Tuberculosis (TB)',
            contentEn:
                'TB is infectious disease caused by bacteria affecting mainly lungs. Spreads through air when infected person coughs. About 591,000 Filipinos have TB. Treatment takes 6-9 months.',
            contentCeb:
                'Ang TB usa ka infectious disease nga hinungdan sa bakterya nga makaapekto sa baga. Mikaylap pinaagi sa hangin kung ang tawo nga adunay TB mo-ubo. Mga 591,000 Filipinos ang adunay TB. Ang tambal molungtad og 6-9 ka bulan.',
            tipsEn: [
              'MYTH: TB caused by fatigue or cold wind. FACT: Caused by bacteria, not fatigue or wind.',
              'MYTH: If I feel better, I can stop medicines. FACT: Must complete 6-9 months treatment to prevent drug-resistant TB.',
              'Nutrition: ½ plate vegetables/fruits, ¼ brown rice, ¼ lean protein. Good nutrition strengthens immune system.',
              'Hydration: 8-10 cups water daily helps maintain lung health.',
              'Medication: TB medicines critical for cure. Use pillbox, alarms. Don\'t miss doses.',
              'Emergency: Coughing up blood, high fever, severe shortness of breath, chest pain.',
            ],
            tipsCeb: [
              'MITO: Ang TB hinungdan sa kapoy o bugnaw nga hangin. KAMATUORAN: Hinungdan sa bakterya, dili kapoy o hangin.',
              'MITO: Kung maayo na ang gibati, mahimo nakong hunongon ang tambal. KAMATUORAN: Kinahanglan kompleto ang 6-9 ka bulan nga tambal aron mapugngan ang drug-resistant TB.',
              'Nutrisyon: ½ plato utanon/prutas, ¼ brown rice, ¼ lean protein. Ang maayo nga nutrisyon nagpalig-on sa immune system.',
              'Hydration: 8-10 ka tasa tubig kada adlaw makatabang sa pagmintinar sa lung health.',
              'Tambal: Ang TB medicines importante para sa pag-ayo. Gamit og pillbox, alarm. Ayaw kalimti ang doses.',
              'Emergency: Pag-ubo og dugo, taas nga hilanat, grabe nga lisod sa pagginhawa, sakit sa dughan.',
            ],
            category: 'tb',
            icon: 'coronavirus',
            color: 'red',
            createdAt: DateTime.now(),
          ),
        ];

      case 'preventive_care':
        return [
          EducationContentModel(
            id: 'prev1',
            titleEn: 'Preventive Care & Check-ups',
            titleCeb: 'Preventive Care ug Check-ups',
            contentEn:
                'Regular health checks, screenings, and vaccines prevent problems before they start. Preventive care reduces hospital visits and long-term costs.',
            contentCeb:
                'Ang regular health checks, screenings, ug vaccines nagpugong sa mga problema una pa kini magsugod. Ang preventive care makakunhod sa hospital visits ug dugay nga gasto.',
            tipsEn: [
              'Regular check-ups: Monitor disease control, adjust medicines, screen for complications.',
              'Vaccines: Annual flu vaccine, pneumococcal vaccines, COVID-19 boosters as advised.',
              'Lab tests: HbA1c every 3-6 months for diabetes, annual lipid panel, kidney function tests, eye exams.',
              'Home monitoring: Check BP daily/weekly, blood glucose as advised, track weight and symptoms.',
              'What to bring: Medication list, last lab results, symptom diary, questions for doctor.',
            ],
            tipsCeb: [
              'Regular check-ups: Bantayi ang disease control, adjust sa tambal, screen para sa komplikasyon.',
              'Vaccines: Annual flu vaccine, pneumococcal vaccines, COVID-19 boosters sumala sa tambag.',
              'Lab tests: HbA1c kada 3-6 ka bulan para sa diabetes, annual lipid panel, kidney function tests, eye exams.',
              'Home monitoring: Susiha ang BP kada adlaw/semana, blood glucose sumala sa tambag, bantayi ang timbang ug sintomas.',
              'Unsay dad-on: Listahan sa tambal, last lab results, symptom diary, mga pangutana para sa doktor.',
            ],
            category: 'preventive_care',
            icon: 'medical_information',
            color: 'blue',
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
        return 'diabetes';
      case 1:
        return 'ckd';
      case 2:
        return 'thyroid';
      case 3:
        return 'goiter';
      case 4:
        return 'respiratory';
      case 5:
        return 'heart_disease';
      case 6:
        return 'stroke';
      case 7:
        return 'migraine';
      case 8:
        return 'epilepsy';
      case 9:
        return 'arthritis';
      case 10:
        return 'osteoporosis';
      case 11:
        return 'cancer';
      case 12:
        return 'tb';
      case 13:
        return 'preventive_care';
      default:
        return 'faqs';
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
      case 'help':
        return Icons.help_outline;
      case 'question_answer':
        return Icons.question_answer;
      case 'support':
        return Icons.support_agent;
      case 'healing':
        return Icons.healing;
      case 'air':
        return Icons.air;
      case 'emergency':
        return Icons.emergency;
      case 'psychology':
        return Icons.psychology;
      case 'accessibility':
        return Icons.accessibility;
      case 'accessibility_new':
        return Icons.accessibility_new;
      case 'coronavirus':
        return Icons.coronavirus;
      case 'medical_information':
        return Icons.medical_information;
      case 'monitor_heart':
        return Icons.monitor_heart;
      default:
        return Icons.info;
    }
  }

  String _translateCategory(String category) {
    if (currentLanguage == 'EN') return category;

    switch (category) {
      case 'FAQs':
        return 'FAQs';
      case 'Diabetes':
        return 'Diabetes';
      case 'CKD':
        return 'CKD';
      case 'Thyroid':
        return 'Thyroid';
      case 'Goiter':
        return 'Goiter';
      case 'Respiratory':
        return 'Respiratory';
      case 'Heart Disease':
        return 'Sakit sa Kasingkasing';
      case 'Stroke':
        return 'Stroke';
      case 'Migraine':
        return 'Migraine';
      case 'Epilepsy':
        return 'Epilepsy';
      case 'Arthritis':
        return 'Arthritis';
      case 'Osteoporosis':
        return 'Osteoporosis';
      case 'Cancer':
        return 'Cancer';
      case 'TB':
        return 'TB';
      case 'Preventive Care':
        return 'Preventive Care';
      case 'Dietary Tips':
        return 'Tips sa Pagkaon';
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
