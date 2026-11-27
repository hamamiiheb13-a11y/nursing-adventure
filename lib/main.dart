import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'audio/audio_service.dart';
import 'screens/capsule_warriors_final_screen.dart';
import 'screens/capsule_warriors_home_screen.dart';
import 'screens/capsule_warriors_how_to_play_screen.dart';
import 'screens/capsule_warriors_intro_screen.dart';
import 'screens/capsule_warriors_review_screen.dart';
import 'screens/capsule_warriors_settings_screen.dart';
import 'screens/capsule_warriors_world_select_screen.dart';
import 'services/storage_service.dart';
import 'theme/capsule_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Apply cached defaults synchronously if available so the first frame renders immediately
  final cached = StorageService().currentProgress;
  AudioService().applySettings(
    masterVolume: cached.masterVolume,
    musicVolume: cached.musicVolume,
    sfxVolume: cached.sfxVolume,
    musicEnabled: cached.musicEnabled,
    sfxEnabled: cached.sfxEnabled,
    isMuted: cached.isMuted,
  );

  runApp(const CapsuleWarriorsApp());

  // Non-blocking background orientation hint & persistent save hydration
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  StorageService().loadProgress().then((progress) {
    AudioService().applySettings(
      masterVolume: progress.masterVolume,
      musicVolume: progress.musicVolume,
      sfxVolume: progress.sfxVolume,
      musicEnabled: progress.musicEnabled,
      sfxEnabled: progress.sfxEnabled,
      isMuted: progress.isMuted,
    );
  });
}

class CapsuleWarriorsApp extends StatelessWidget {
  const CapsuleWarriorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GASTRO QUEST — 2D Arcade Médical',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: CapsuleColors.deepOcean,
        primaryColor: CapsuleColors.cyanGlow,
        canvasColor: CapsuleColors.deepOcean,
        cardColor: CapsuleColors.cardOcean,
        colorScheme: const ColorScheme.dark(
          primary: CapsuleColors.cyanGlow,
          secondary: CapsuleColors.electricBlue,
          surface: CapsuleColors.oceanSurface,
          error: CapsuleColors.dangerRed,
          onPrimary: CapsuleColors.deepOcean,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: CapsuleColors.oceanSurface,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.plusJakartaSans(
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
