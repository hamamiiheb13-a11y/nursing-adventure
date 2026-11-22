import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../models/game_progress.dart';
import '../services/storage_service.dart';
import '../theme/capsule_theme.dart';
import '../widgets/capsule_parallax_background.dart';
import 'capsule_warriors_how_to_play_screen.dart';
import 'capsule_warriors_intro_screen.dart';
import 'capsule_warriors_settings_screen.dart';
import 'capsule_warriors_world_select_screen.dart';

class CapsuleWarriorsHomeScreen extends StatefulWidget {
  const CapsuleWarriorsHomeScreen({super.key});

  @override
  State<CapsuleWarriorsHomeScreen> createState() => _CapsuleWarriorsHomeScreenState();
}

class _CapsuleWarriorsHomeScreenState extends State<CapsuleWarriorsHomeScreen>
    with SingleTickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  final AudioService _audio = AudioService();

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  GameProgress _progress = GameProgress();
  bool _hasSave = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Prefer landscape for arcade experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadSaveData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSaveData() async {
    final hasSave = await _storageService.hasExistingProgress();
    final progress = await _storageService.loadProgress();
    if (mounted) {
      setState(() {
        _hasSave = hasSave && (progress.totalScore > 0 || progress.stageResults.isNotEmpty);
        _progress = progress;
        _isLoading = false;
      });
    }
  }

  void _onPlay() {
    _audio.playClick();
    if (!_hasSave) {
      // First visit -> Intro screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CapsuleWarriorsIntroScreen(
            progress: _progress,
            onContinue: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => CapsuleWarriorsWorldSelectScreen(progress: _progress),
                ),
              );
            },
          ),
        ),
      ).then((_) => _loadSaveData());
    } else {
      // Returning player -> World select
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CapsuleWarriorsWorldSelectScreen(progress: _progress),
        ),
      ).then((_) => _loadSaveData());
    }
  }

  void _onResume() {
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CapsuleWarriorsWorldSelectScreen(progress: _progress),
      ),
    ).then((_) => _loadSaveData());
  }

  void _onHowToPlay() {
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CapsuleWarriorsHowToPlayScreen(),
      ),
    );
  }

  void _onSettings() {
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CapsuleWarriorsSettingsScreen(
          progress: _progress,
          onProgressReset: _loadSaveData,
        ),
      ),
    ).then((_) => _loadSaveData());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: CapsuleColors.darkNavy,
        body: Center(
          child: CircularProgressIndicator(color: CapsuleColors.cyanGlow),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 500 || size.width < 700;

    return Scaffold(
      backgroundColor: CapsuleColors.darkNavy,
      body: CapsuleParallaxBackground(
        showHeroCapsule: true,
        showEnemySilhouettes: true,
        capsuleScale: isCompact ? 1.05 : 1.35,
        capsuleCenterFraction: isCompact ? const Offset(0.82, 0.5) : const Offset(0.76, 0.45),
        child: SafeArea(
          child: Stack(
            children: [
              // Left / Center Main Game Arcade Menu
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 24 : 48,
                    vertical: isCompact ? 12 : 24,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Menu Column
                      Expanded(
                        flex: isCompact ? 6 : 5,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTopPillBadge(),
                              const SizedBox(height: 12),
                              _buildGameLogo(isCompact),
                              const SizedBox(height: 6),
                              _buildSubtitle(isCompact),
                              SizedBox(height: isCompact ? 18 : 28),
                              _buildMenuButtons(isCompact),
                            ],
                          ),
                        ),
                      ),

                      // Spacer for the hero capsule area on the right
                      Expanded(
                        flex: isCompact ? 4 : 5,
                        child: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom footer watermark
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'v2.0 | Éducation Médicale MICI • ISSIT PFE',
                    style: GoogleFonts.orbitron(
                      color: CapsuleColors.textSubtle.withValues(alpha: 0.6),
                      fontSize: 10.5,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopPillBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: CapsuleColors.purple.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: CapsuleColors.cyanGlow.withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flash_on_rounded, color: CapsuleColors.cyanGlow, size: 14),
          const SizedBox(width: 6),
          Text(
            'EXPÉDITION NANO-ROBOTIQUE GASTRIQUE',
            style: GoogleFonts.orbitron(
              color: CapsuleColors.cyanGlow,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameLogo(bool isCompact) {
    final fontSize = isCompact ? 32.0 : 48.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // Cyan Outer Glow Text Shadow
            Text(
              'CAPSULE WARRIORS',
              style: GoogleFonts.orbitron(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.0,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 5
                  ..color = CapsuleColors.cyanGlow.withValues(alpha: 0.5)
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
              ),
            ),
            // White / Electric Blue Foreground Gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Colors.white,
                  CapsuleColors.cyanGlow,
                  CapsuleColors.electricBlue,
                ],
                stops: [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: Text(
                'CAPSULE WARRIORS',
                style: GoogleFonts.orbitron(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubtitle(bool isCompact) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 2,
          color: CapsuleColors.turquoise,
        ),
        const SizedBox(width: 8),
        Text(
          'THE STOMACH MISSION',
          style: GoogleFonts.orbitron(
            fontSize: isCompact ? 13.0 : 16.0,
            fontWeight: FontWeight.w800,
            color: CapsuleColors.turquoise,
            letterSpacing: 4.0,
            shadows: [
              Shadow(
                color: CapsuleColors.turquoise.withValues(alpha: 0.8),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButtons(bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. JOUER (Primary pulsing CTA)
        ScaleTransition(
          scale: _pulseAnimation,
          child: _buildArcadeButton(
            title: '🎮 JOUER',
            subtitle: _hasSave ? 'NOUVELLE MISSION OU SÉLECTION' : 'COMMENCER LA MISSION',
            isPrimary: true,
            isCompact: isCompact,
            onTap: _onPlay,
          ),
        ),
        const SizedBox(height: 12),

        // 2. REPRENDRE (Only visible if save exists)
        if (_hasSave) ...[
          _buildArcadeButton(
            title: '▶ REPRENDRE',
            subtitle: 'CONTINUER L\'AVENTURE',
            isPrimary: false,
            accentColor: CapsuleColors.gold,
            isCompact: isCompact,
            onTap: _onResume,
          ),
          const SizedBox(height: 12),
        ],

        // 3. COMMENT JOUER
        _buildArcadeButton(
          title: '❓ COMMENT JOUER',
          subtitle: 'COMMANDES & ARSENAL',
          isPrimary: false,
          accentColor: CapsuleColors.turquoise,
          isCompact: isCompact,
          onTap: _onHowToPlay,
        ),
        const SizedBox(height: 12),

        // 4. PARAMÈTRES
        _buildArcadeButton(
          title: '⚙ PARAMÈTRES',
          subtitle: 'AUDIO & CONFIGURATION',
          isPrimary: false,
          accentColor: CapsuleColors.purple,
          isCompact: isCompact,
          onTap: _onSettings,
        ),
      ],
    );
  }

  Widget _buildArcadeButton({
    required String title,
    required String subtitle,
    required bool isPrimary,
    Color? accentColor,
    required bool isCompact,
    required VoidCallback onTap,
  }) {
    final effectiveAccent = isPrimary ? CapsuleColors.cyanGlow : (accentColor ?? CapsuleColors.electricBlue);
    final width = isCompact ? 280.0 : 340.0;
    final height = isCompact ? 50.0 : 58.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPrimary
              ? [
                  CapsuleColors.electricBlue,
                  CapsuleColors.purple,
                ]
              : [
                  const Color(0xFF0F172A).withValues(alpha: 0.9),
                  const Color(0xFF1E293B).withValues(alpha: 0.8),
                ],
        ),
        border: Border.all(
          color: isPrimary ? CapsuleColors.cyanGlow : effectiveAccent.withValues(alpha: 0.6),
          width: isPrimary ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveAccent.withValues(alpha: isPrimary ? 0.35 : 0.15),
            blurRadius: isPrimary ? 16 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          splashColor: effectiveAccent.withValues(alpha: 0.3),
          highlightColor: effectiveAccent.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: isCompact ? 13.5 : 15.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          color: isPrimary
                              ? Colors.white.withValues(alpha: 0.85)
                              : CapsuleColors.textSubtle,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isPrimary ? Colors.white : effectiveAccent,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
