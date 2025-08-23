import 'package:amuma/screens/dashboard_screen.dart';
import 'package:amuma/services/local_storage_service.dart';
import 'package:amuma/utils/colors.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage service
  await LocalStorageService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amuma',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: accent,
          surface: surface,
          background: background,
        ),
        primarySwatch: MaterialColor(0xFF00537A, {
          50: primaryLight,
          100: Color(0xFF80D4E8),
          200: Color(0xFF4FC3E0),
          300: Color(0xFF1FB2D8),
          400: Color(0xFF00A1CF),
          500: primary,
          600: Color(0xFF004A6B),
          700: Color(0xFF00415C),
          800: Color(0xFF00384D),
          900: primaryDark,
        }),
        fontFamily: 'Regular',
        appBarTheme: AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: textOnPrimary,
          ),
        ),
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
