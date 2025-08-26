import 'package:amuma/firebase_options.dart';
import 'package:amuma/screens/splash_screen.dart';
import 'package:amuma/screens/dashboard_screen.dart';
import 'package:amuma/screens/profile_setup_screen.dart';
import 'package:amuma/services/local_storage_service.dart';
import 'package:amuma/services/auth_service.dart';
import 'package:amuma/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'amuma-202b8',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LocalStorageService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const AuthStateWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthStateWrapper extends StatelessWidget {
  const AuthStateWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Show splash screen while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // User is not authenticated - show splash screen (which will navigate to onboarding/auth)
        if (!snapshot.hasData || snapshot.data == null) {
          return const SplashScreen();
        }

        // User is authenticated - check if profile is complete
        return FutureBuilder<bool>(
          future: AuthService().isProfileComplete(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            // Navigate based on profile completion status
            if (profileSnapshot.data == true) {
              return const DashboardScreen();
            } else {
              return const ProfileSetupScreen();
            }
          },
        );
      },
    );
  }
}
