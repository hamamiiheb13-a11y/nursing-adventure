import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/capsule_warriors_final_screen.dart';
import 'screens/capsule_warriors_home_screen.dart';
import 'screens/capsule_warriors_how_to_play_screen.dart';
import 'screens/capsule_warriors_intro_screen.dart';
import 'screens/capsule_warriors_review_screen.dart';
import 'screens/capsule_warriors_settings_screen.dart';
import 'screens/capsule_warriors_world_select_screen.dart';
import 'services/storage_service.dart';
import 'theme/capsule_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prefer landscape orientation for full arcade game immersion
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Preload progress
  await StorageService().loadProgress();

  runApp(const CapsuleWarriorsApp());
}

class CapsuleWarriorsApp extends StatelessWidget {
  const CapsuleWarriorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CAPSULE WARRIORS : THE STOMACH MISSION',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: CapsuleColors.darkNavy,
        primaryColor: CapsuleColors.cyanGlow,
        canvasColor: CapsuleColors.darkNavy,
        cardColor: CapsuleColors.cardNavy,
        colorScheme: const ColorScheme.dark(
          primary: CapsuleColors.cyanGlow,
          secondary: CapsuleColors.electricBlue,
          surface: CapsuleColors.surfaceNavy,
          error: CapsuleColors.dangerRed,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: CapsuleColors.surfaceNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const CapsuleWarriorsHomeScreen(),
        '/home': (context) => const CapsuleWarriorsHomeScreen(),
        '/intro': (context) => CapsuleWarriorsIntroScreen(
              progress: StorageService().currentProgress,
              onContinue: () {
                Navigator.of(context).pushReplacementNamed('/world-select');
              },
            ),
        '/world-select': (context) => CapsuleWarriorsWorldSelectScreen(
              progress: StorageService().currentProgress,
            ),
        '/how-to-play': (context) => const CapsuleWarriorsHowToPlayScreen(),
        '/settings': (context) => CapsuleWarriorsSettingsScreen(
              progress: StorageService().currentProgress,
            ),
        '/review': (context) => CapsuleWarriorsReviewScreen(
              progress: StorageService().currentProgress,
            ),
        '/final': (context) => CapsuleWarriorsFinalScreen(
              progress: StorageService().currentProgress,
            ),
      },
    );
  }
}
