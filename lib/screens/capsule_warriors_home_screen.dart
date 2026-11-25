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
import 'home_screen.dart';

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

  void _onHospitalServices() {
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    ).then((_) => _loadSaveData());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: CapsuleColors.deepOcean,
        body: Center(
          child: CircularProgressIndicator(color: CapsuleColors.cyanGlow),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final isPortraitMobile = size.width < 680 && size.height > size.width;
    final isCompact = size.height < 650 || size.width < 850;

    return Scaffold(
      backgroundColor: CapsuleColors.deepOcean,
      body: CapsuleParallaxBackground(
        showHeroCapsule: true,
        showEnemySilhouettes: true,
        capsuleScale: isPortraitMobile ? 0.92 : (isCompact ? 1.05 : 1.35),
        capsuleCenterFraction: isPortraitMobile
            ? const Offset(0.78, 0.16)
            : (isCompact ? const Offset(0.82, 0.5) : const Offset(0.76, 0.45)),
        child: SafeArea(
          child: Stack(
            children: [
              // Left / Center Main Game Arcade Menu
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isPortraitMobile ? 20 : (isCompact ? 24 : 48),
                    isCompact ? 12 : 24,
                    isPortraitMobile ? 20 : (isCompact ? 24 : 48),
                    isCompact ? 32 : 40,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Menu Column
                      Expanded(
                        flex: isPortraitMobile ? 10 : (isCompact ? 6 : 5),
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

                      // Spacer for the hero capsule area on landscape/desktop
                      if (!isPortraitMobile)
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
                bottom: 10,
                left: 16,
                right: 16,
                child: Center(
                  child: Text(
                    'v2.0 | Éducation Médicale MICI • ISSIT PFE',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: CapsuleColors.textSubtle.withValues(alpha: 0.72),
                      fontSize: 11,
                      letterSpacing: 1.0,
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
        color: CapsuleColors.electricBlue.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.7), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: CapsuleColors.cyanGlow.withValues(alpha: 0.22),
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
    final fontSize = isCompact ? 32.0 : 44.0;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          // Soft Cyan-Teal Halo
          Text(
            'GASTRO QUEST',
            maxLines: 1,
            style: GoogleFonts.orbitron(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4
                ..color = CapsuleColors.cyanGlow.withValues(alpha: 0.35),
            ),
          ),
          // Crisp White -> Cyan -> Turquoise -> Soft Violet Gradient
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Colors.white,
                CapsuleColors.cyanGlow,
                CapsuleColors.turquoise,
                CapsuleColors.softViolet,
              ],
              stops: [0.0, 0.42, 0.72, 1.0],
            ).createShader(bounds),
            child: Text(
              'GASTRO QUEST',
              maxLines: 1,
              style: GoogleFonts.orbitron(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(bool isCompact) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 2.5,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [CapsuleColors.gold, CapsuleColors.cyanGlow]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'CAPSULE WARRIORS • EXPÉDITION DIGESTIVE',
            maxLines: 1,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isCompact ? 12.5 : 14.5,
              fontWeight: FontWeight.w800,
              color: CapsuleColors.mintGreen,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButtons(bool isCompact) {
    final gap = isCompact ? 8.0 : 10.0;
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
        SizedBox(height: gap),

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
          SizedBox(height: gap),
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
        SizedBox(height: gap),

        // 4. PARAMÈTRES
        _buildArcadeButton(
          title: '⚙ PARAMÈTRES',
          subtitle: 'AUDIO & CONFIGURATION',
          isPrimary: false,
          accentColor: CapsuleColors.purple,
          isCompact: isCompact,
          onTap: _onSettings,
        ),
        SizedBox(height: gap),

        // 5. SERVICES HOSPITALIERS & SIMULATION CLINIQUE
        _buildArcadeButton(
          title: '🏥 SERVICES HOSPITALIERS',
          subtitle: 'SIMULATION CLINIQUE & ENDOSCOPIE',
          isPrimary: false,
          accentColor: const Color(0xFF10B981),
          isCompact: isCompact,
          onTap: _onHospitalServices,
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
    final width = isCompact ? 280.0 : 330.0;
    final minHeight = isCompact ? 46.0 : 54.0;

    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPrimary
              ? [
                  CapsuleColors.electricBlue,
                  CapsuleColors.softViolet,
                ]
              : [
                  CapsuleColors.oceanSurface.withValues(alpha: 0.94),
                  CapsuleColors.cardOcean.withValues(alpha: 0.90),
                ],
        ),
        border: Border.all(
          color: isPrimary ? CapsuleColors.cyanGlow : effectiveAccent.withValues(alpha: 0.55),
          width: isPrimary ? 1.8 : 1.2,
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
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: isCompact ? 5 : 7),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: isCompact ? 12.5 : 14.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          color: isPrimary
                              ? Colors.white.withValues(alpha: 0.85)
                              : CapsuleColors.textSubtle,
                          fontSize: isCompact ? 9.5 : 10.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
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
