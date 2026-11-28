import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../models/game_progress.dart';
import '../models/gastro_world.dart';
import '../services/storage_service.dart';
import '../theme/capsule_theme.dart';
import '../widgets/capsule_parallax_background.dart';
import 'capsule_warriors_how_to_play_screen.dart';
import 'capsule_warriors_intro_screen.dart';
import 'capsule_warriors_review_screen.dart';
import 'capsule_warriors_settings_screen.dart';
import 'capsule_warriors_world_select_screen.dart';
import 'home_screen.dart';

class CapsuleWarriorsHomeScreen extends StatefulWidget {
  const CapsuleWarriorsHomeScreen({super.key});

  @override
  State<CapsuleWarriorsHomeScreen> createState() =>
      _CapsuleWarriorsHomeScreenState();
}

class _CapsuleWarriorsHomeScreenState extends State<CapsuleWarriorsHomeScreen>
    with TickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  final AudioService _audio = AudioService();

  late final AnimationController _pulseController;
  late final AnimationController _entranceController;
  late final Animation<double> _pulseAnimation;

  GameProgress _progress = GameProgress();
  bool _hasSave = false;
  List<PlayerProfile> _savedPlayers = [];

  @override
  void initState() {
    super.initState();

    _progress = _storageService.currentProgress;
    _hasSave = _progress.hasPlayableProgress;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.045).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _loadSaveData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _loadSaveData() async {
    final hasSave = await _storageService.hasExistingProgress();
    final progress = await _storageService.loadProgress();
    final savedPlayers = await _storageService.listSavedPlayers();
    if (mounted) {
      setState(() {
        _hasSave = hasSave && progress.hasPlayableProgress;
        _progress = progress;
        _savedPlayers = savedPlayers;
      });
    }
  }

  List<PlayerProfile> get _returningPlayersWithProgress => _savedPlayers
      .where((p) =>
          p.completedStages > 0 || p.totalScore > 0 || p.totalXP > 0)
      .toList();

  void _onPlay() {
    _audio.playClick();
    if (!_hasSave) {
      Navigator.of(context)
          .push(
            buildCapsuleRoute(
              CapsuleWarriorsIntroScreen(
                progress: _progress,
                onContinue: () {
                  Navigator.of(context).pushReplacement(
                    buildCapsuleRoute(
                      CapsuleWarriorsWorldSelectScreen(progress: _progress),
                    ),
                  );
                },
              ),
            ),
          )
          .then((_) => _loadSaveData());
    } else {
      Navigator.of(context)
          .push(
            buildCapsuleRoute(
              CapsuleWarriorsWorldSelectScreen(progress: _progress),
            ),
          )
          .then((_) => _loadSaveData());
    }
  }

  void _onResume() {
    _audio.playClick();
    if (_hasSave) {
      Navigator.of(context)
          .push(
            buildCapsuleRoute(
                CapsuleWarriorsWorldSelectScreen(progress: _progress)),
          )
          .then((_) => _loadSaveData());
    } else if (_returningPlayersWithProgress.isNotEmpty) {
      _openPlayerProfilesDialog();
    } else {
      _onPlay();
    }
  }

  void _onNewGameConfirm() {
    _audio.playClick();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: CapsuleColors.oceanSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: CapsuleColors.amberGold, width: 1.6),
        ),
        title: Row(
          children: [
            const Icon(Icons.restart_alt_rounded,
                color: CapsuleColors.amberGold, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'NOUVELLE PARTIE',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Voulez-vous réinitialiser la progression actuelle de « ${_progress.playerName} » et recommencer au Stage 1 ?\n\nLes sauvegardes des autres joueurs restent indépendantes.',
          style: GoogleFonts.inter(
            color: CapsuleColors.textSubtle,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'ANNULER',
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CapsuleColors.amberGold,
              foregroundColor: CapsuleColors.deepOcean,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await _storageService.clearProgress();
              await _loadSaveData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: CapsuleColors.oceanSurface,
                    content: Text(
                      'Progression réinitialisée • Nouveau départ au Stage 1 !',
                      style: GoogleFonts.plusJakartaSans(
                        color: CapsuleColors.cyanGlow,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }
            },
            child: Text(
              'CONFIRMER',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  void _openPlayerProfilesDialog() {
    _audio.playClick();
    final nameController = TextEditingController(text: _progress.playerName);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: CapsuleColors.oceanSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: CapsuleColors.cyanGlow, width: 1.6),
        ),
        title: Row(
          children: [
            const Icon(Icons.person_pin_rounded,
                color: CapsuleColors.cyanGlow, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'PROFIL & JOUEURS',
                style: GoogleFonts.orbitron(
                  color: CapsuleColors.cyanGlow,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Joueur actuel (session isolée) :',
                  style: GoogleFonts.inter(
                      color: CapsuleColors.textSubtle, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          hintText: 'Votre prénom / pseudo',
                          hintStyle:
                              const TextStyle(color: CapsuleColors.textMuted),
                          filled: true,
                          fillColor: CapsuleColors.deepOcean,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: CapsuleColors.cardBorder),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CapsuleColors.cyanGlow,
                        foregroundColor: CapsuleColors.deepOcean,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        await _storageService
                            .renameCurrentPlayer(nameController.text);
                        await _loadSaveData();
                        if (dialogCtx.mounted) {
                          Navigator.of(dialogCtx).pop();
                        }
                      },
                      child: const Text('OK',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CapsuleColors.mintGreen,
                    side: const BorderSide(color: CapsuleColors.mintGreen),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: Text(
                    'Nouveau joueur indépendant (Stage 1)',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  onPressed: () async {
                    Navigator.of(dialogCtx).pop();
                    await _storageService.startNewPlayerSession();
                    await _loadSaveData();
                  },
                ),
                if (_returningPlayersWithProgress.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Joueurs sauvegardés (${_returningPlayersWithProgress.length}) :',
                    style: GoogleFonts.plusJakartaSans(
                      color: CapsuleColors.gold,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ..._returningPlayersWithProgress.map((profile) {
                    final isActive = profile.id == _progress.playerId;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          Navigator.of(dialogCtx).pop();
                          await _storageService.switchPlayer(profile.id);
                          await _loadSaveData();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 8),
                          decoration: BoxDecoration(
                            color: CapsuleColors.deepOcean,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isActive
                                  ? CapsuleColors.cyanGlow
                                  : CapsuleColors.cardBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isActive
                                    ? Icons.check_circle_rounded
                                    : Icons.account_circle_rounded,
                                color: isActive
                                    ? CapsuleColors.cyanGlow
                                    : CapsuleColors.gold,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    Text(
                                      'Stage ${profile.currentStage} • ${profile.totalXP} XP • ${profile.totalScore} PTS',
                                      style: const TextStyle(
                                        color: CapsuleColors.textSubtle,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isActive)
                                const Icon(Icons.login_rounded,
                                    color: CapsuleColors.gold, size: 17),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('FERMER',
                style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _onHowToPlay() {
    _audio.playClick();
    Navigator.of(context).push(
      buildCapsuleRoute(const CapsuleWarriorsHowToPlayScreen()),
    );
  }

  void _onSettings() {
    _audio.playClick();
    Navigator.of(context)
        .push(
          buildCapsuleRoute(
            CapsuleWarriorsSettingsScreen(
              progress: _progress,
              onProgressReset: _loadSaveData,
            ),
          ),
        )
        .then((_) => _loadSaveData());
  }

  void _onProgression() {
    _audio.playClick();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => _ProgressionRewardsDialog(
        progress: _progress,
        onOpenFiches: () {
          Navigator.of(dialogCtx).pop();
          Navigator.of(context).push(
            buildCapsuleRoute(CapsuleWarriorsReviewScreen(progress: _progress)),
          );
        },
      ),
    );
  }

  void _onHospitalServices() {
    _audio.playClick();
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        )
        .then((_) => _loadSaveData());
  }

  Widget _stagger(double start, double end, Widget child) {
    final anim = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.04, 0.03),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortraitMobile = size.width < 680 && size.height > size.width;
    final isCompact = size.height < 640 || size.width < 880;

    return Scaffold(
      backgroundColor: CapsuleColors.deepOcean,
      body: CapsuleParallaxBackground(
        showHeroCapsule: true,
        showEnemySilhouettes: true,
        capsuleScale: isPortraitMobile ? 1.05 : (isCompact ? 1.18 : 1.55),
        capsuleCenterFraction: isPortraitMobile
            ? const Offset(0.52, 0.14)
            : (isCompact ? const Offset(0.76, 0.48) : const Offset(0.71, 0.46)),
        child: SafeArea(
          child: Stack(
            children: [
              // Top-right subtle Hospital Services / Endoscopy Module access (unchanged & isolated)
              Positioned(
                top: isCompact ? 10 : 16,
                right: isPortraitMobile ? 14 : (isCompact ? 22 : 36),
                child: _HospitalServicesPill(
                  onTap: _onHospitalServices,
                ),
              ),

              // Main Left/Center Composition
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isPortraitMobile ? 20 : (isCompact ? 28 : 52),
                    isPortraitMobile ? 96 : (isCompact ? 16 : 24),
                    isPortraitMobile ? 20 : (isCompact ? 28 : 52),
                    isCompact ? 28 : 36,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: isPortraitMobile ? 10 : (isCompact ? 6 : 5),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _stagger(0.0, 0.35, _buildTopPillBadge()),
                              const SizedBox(height: 10),
                              _stagger(0.10, 0.50, _buildGameLogo(isCompact)),
                              const SizedBox(height: 6),
                              _stagger(0.18, 0.60, _buildSubtitle(isCompact)),
                              const SizedBox(height: 10),
                              _stagger(0.22, 0.72, _buildPlayerSessionBar(isCompact)),
                              SizedBox(height: isCompact ? 12 : 18),
                              _stagger(0.28, 0.95, _buildMenuButtons(isCompact)),
                            ],
                          ),
                        ),
                      ),
                      if (!isPortraitMobile)
                        Expanded(
                          flex: isCompact ? 4 : 5,
                          child: const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom discreet watermark
              Positioned(
                bottom: 8,
                left: 16,
                right: 16,
                child: Center(
                  child: Text(
                    'v2.0 | Éducation Médicale MICI • ISSIT PFE',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: CapsuleColors.textSubtle.withValues(alpha: 0.72),
                      fontSize: 10.5,
                      letterSpacing: 0.9,
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
        color: CapsuleColors.cardOcean.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CapsuleColors.cyanGlow.withValues(alpha: 0.65),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.biotech_rounded, color: CapsuleColors.cyanGlow, size: 14),
          const SizedBox(width: 6),
          Text(
            'EXPÉDITION NANO-ROBOTIQUE GASTRIQUE',
            style: GoogleFonts.orbitron(
              color: CapsuleColors.cyanGlow,
              fontSize: 9.8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
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
                ..color = CapsuleColors.cyanGlow.withValues(alpha: 0.30),
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFF4F8FC),
                CapsuleColors.cyanGlow,
                CapsuleColors.turquoise,
              ],
              stops: [0.0, 0.55, 1.0],
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
              gradient: const LinearGradient(
                colors: [CapsuleColors.gold, CapsuleColors.cyanGlow],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'CAPSULE WARRIORS • EXPÉDITION DIGESTIVE',
            maxLines: 1,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isCompact ? 12.2 : 14.0,
              fontWeight: FontWeight.w800,
              color: CapsuleColors.mintGreen,
              letterSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSessionBar(bool isCompact) {
    final buttonWidth = isCompact ? 295.0 : 340.0;
    final returningCount = _returningPlayersWithProgress.length;
    return SizedBox(
      width: buttonWidth,
      child: Wrap(
        spacing: 7,
        runSpacing: 6,
        alignment: WrapAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(11),
            onTap: _openPlayerProfilesDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: CapsuleColors.oceanSurface.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: CapsuleColors.cyanGlow.withValues(alpha: 0.55),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_rounded,
                      color: CapsuleColors.cyanGlow, size: 15),
                  const SizedBox(width: 5),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: Text(
                      _progress.playerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (returningCount > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '($returningCount)',
                      style: GoogleFonts.inter(
                        color: CapsuleColors.gold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  const SizedBox(width: 3),
                  const Icon(Icons.swap_horiz_rounded,
                      color: CapsuleColors.cyanGlow, size: 14),
                ],
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(11),
            onTap: _onNewGameConfirm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: CapsuleColors.oceanSurface.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: CapsuleColors.amberGold.withValues(alpha: 0.65),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.restart_alt_rounded,
                      color: CapsuleColors.amberGold, size: 15),
                  const SizedBox(width: 5),
                  Text(
                    'NOUVELLE PARTIE',
                    style: GoogleFonts.plusJakartaSans(
                      color: CapsuleColors.amberGold,
                      fontSize: 10.8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButtons(bool isCompact) {
    final gap = isCompact ? 7.0 : 9.0;
    final buttonWidth = isCompact ? 295.0 : 340.0;
    final returningCount = _returningPlayersWithProgress.length;
    final bool canResume = _hasSave || returningCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. JOUER
        ScaleTransition(
          scale: _pulseAnimation,
          child: _InteractiveHomeButton(
            title: 'JOUER',
            subtitle: _hasSave
                ? 'Choisir une mission (Stage ${_progress.currentStage})'
                : 'Commencer au Stage 1',
            icon: Icons.play_arrow_rounded,
            isPrimary: true,
            accentColor: CapsuleColors.cyanGlow,
            width: buttonWidth,
            isCompact: isCompact,
            onTap: _onPlay,
          ),
        ),
        SizedBox(height: gap),

        // 2. REPRENDRE
        _InteractiveHomeButton(
          title: 'REPRENDRE',
          subtitle: _hasSave
              ? '${_progress.playerName} • Stage ${_progress.currentStage} • ${_progress.totalXP} XP'
              : (returningCount > 0
                  ? 'Reprendre un joueur ($returningCount)'
                  : 'Aucune mission en cours'),
          icon: Icons.restore_rounded,
          isPrimary: false,
          accentColor: canResume ? CapsuleColors.gold : CapsuleColors.textMuted,
          width: buttonWidth,
          isCompact: isCompact,
          onTap: _onResume,
        ),
        SizedBox(height: gap),

        // 3. COMMENT JOUER
        _InteractiveHomeButton(
          title: 'COMMENT JOUER',
          subtitle: 'Commandes & règles de mission',
          icon: Icons.help_outline_rounded,
          isPrimary: false,
          accentColor: CapsuleColors.turquoise,
          width: buttonWidth,
          isCompact: isCompact,
          onTap: _onHowToPlay,
        ),
        SizedBox(height: gap),

        // 4. PARAMÈTRES
        _InteractiveHomeButton(
          title: 'PARAMÈTRES',
          subtitle: 'Audio, musique & préférences',
          icon: Icons.tune_rounded,
          isPrimary: false,
          accentColor: CapsuleColors.cyanGlow,
          width: buttonWidth,
          isCompact: isCompact,
          onTap: _onSettings,
        ),
        SizedBox(height: gap),

        // 5. PROGRESSION
        _InteractiveHomeButton(
          title: 'PROGRESSION',
          subtitle: 'Stages terminés (${_progress.completedCount}/7+) & récompenses',
          icon: Icons.emoji_events_rounded,
          isPrimary: false,
          accentColor: CapsuleColors.gold,
          width: buttonWidth,
          isCompact: isCompact,
          onTap: _onProgression,
        ),
      ],
    );
  }
}

class _InteractiveHomeButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
  final Color accentColor;
  final double width;
  final bool isCompact;
  final VoidCallback onTap;

  const _InteractiveHomeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
    required this.accentColor,
    required this.width,
    required this.isCompact,
    required this.onTap,
  });

  @override
  State<_InteractiveHomeButton> createState() => _InteractiveHomeButtonState();
}

class _InteractiveHomeButtonState extends State<_InteractiveHomeButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _pressed ? 0.96 : (_hovered ? 1.022 : 1.0);
    final double minHeight = widget.isCompact ? 44.0 : 50.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: widget.width,
          constraints: BoxConstraints(minHeight: minHeight),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isPrimary
                  ? const [Color(0xFF20D5E8), Color(0xFF20C9B0)]
                  : [
                      CapsuleColors.oceanSurface.withValues(alpha: _hovered ? 0.98 : 0.92),
                      CapsuleColors.cardOcean.withValues(alpha: _hovered ? 0.95 : 0.88),
                    ],
            ),
            border: Border.all(
              color: widget.isPrimary
                  ? const Color(0xFFF4F8FC).withValues(alpha: 0.7)
                  : widget.accentColor.withValues(alpha: _hovered ? 0.95 : 0.50),
              width: widget.isPrimary ? 1.8 : (_hovered ? 1.6 : 1.2),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(
                  alpha: widget.isPrimary ? (_hovered ? 0.45 : 0.30) : (_hovered ? 0.25 : 0.10),
                ),
                blurRadius: widget.isPrimary ? 16 : 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              onTap: widget.onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: widget.isCompact ? 5 : 7,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: widget.isPrimary
                            ? CapsuleColors.deepOcean.withValues(alpha: 0.16)
                            : widget.accentColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.isPrimary ? CapsuleColors.deepOcean : widget.accentColor,
                        size: widget.isCompact ? 18 : 20,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.orbitron(
                              color: widget.isPrimary
                                  ? CapsuleColors.deepOcean
                                  : CapsuleColors.textWhite,
                              fontSize: widget.isCompact ? 12.5 : 14.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            widget.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: widget.isPrimary
                                  ? CapsuleColors.deepOcean.withValues(alpha: 0.85)
                                  : CapsuleColors.textSubtle,
                              fontSize: widget.isCompact ? 9.8 : 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: widget.isPrimary ? CapsuleColors.deepOcean : widget.accentColor,
                      size: 13,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HospitalServicesPill extends StatelessWidget {
  final VoidCallback onTap;

  const _HospitalServicesPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: CapsuleColors.oceanSurface.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: CapsuleColors.mintGreen.withValues(alpha: 0.60),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_hospital_rounded, color: CapsuleColors.mintGreen, size: 15),
            const SizedBox(width: 6),
            Text(
              'SERVICES HOSPITALIERS',
              style: GoogleFonts.plusJakartaSans(
                color: CapsuleColors.textWhite,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressionRewardsDialog extends StatelessWidget {
  final GameProgress progress;
  final VoidCallback onOpenFiches;

  const _ProgressionRewardsDialog({
    required this.progress,
    required this.onOpenFiches,
  });

  String get _rankTitle {
    final c = progress.completedCount;
    if (c >= 7) return 'Commandant Bio-Digestif';
    if (c >= 5) return 'Praticien Senior MICI';
    if (c >= 3) return 'Explorateur Clinique';
    if (c >= 1) return 'Apprenti Soignant';
    return 'Recrue Médicale';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CapsuleColors.oceanSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: CapsuleColors.gold, width: 1.6),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: CapsuleColors.gold, size: 24),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PROGRESSION & RÉCOMPENSES',
                          style: GoogleFonts.orbitron(
                            color: CapsuleColors.gold,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Titre : $_rankTitle • ${progress.totalXP} XP',
                          style: GoogleFonts.inter(
                            color: CapsuleColors.cyanGlow,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: CapsuleColors.textSubtle),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stages list
              ...GastroWorld.worlds.map((w) {
                final done = progress.isWorldCompleted(w.id);
                final stars = progress.getStars(w.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                    decoration: BoxDecoration(
                      color: CapsuleColors.deepOcean.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: done
                            ? CapsuleColors.mintGreen.withValues(alpha: 0.65)
                            : CapsuleColors.cardBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: done ? CapsuleColors.mintGreen : CapsuleColors.textMuted,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Stage ${w.id} • ${w.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: CapsuleColors.textWhite,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            3,
                            (i) => Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: i < stars ? CapsuleColors.gold : CapsuleColors.textMuted.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              if (progress.revisionStageResults.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'STAGES DE RÉVISION (${progress.revisionStageResults.length})',
                  style: GoogleFonts.plusJakartaSans(
                    color: CapsuleColors.gold,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                ...progress.revisionStageResults.values.map((rev) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        color: CapsuleColors.deepOcean.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: rev.completed
                              ? CapsuleColors.gold.withValues(alpha: 0.65)
                              : CapsuleColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_stories_rounded,
                              color: CapsuleColors.gold, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Révision ${rev.revisionNumber} (Stages ${rev.cycleStartStage}–${rev.cycleEndStage})',
                              style: GoogleFonts.plusJakartaSans(
                                color: CapsuleColors.textWhite,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            rev.isBonusChallenge
                                ? 'Bonus • ${rev.correctCount}/${rev.totalCount}'
                                : '${rev.correctCount}/${rev.totalCount} • ${rev.score} PTS',
                            style: GoogleFonts.inter(
                              color: CapsuleColors.cyanGlow,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 8),
              Text(
                'ARSENAL DÉBLOQUÉ (${progress.unlockedWeapons.length}/8)',
                style: GoogleFonts.plusJakartaSans(
                  color: CapsuleColors.cyanGlow,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: progress.unlockedWeapons
                    .map(
                      (w) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: CapsuleColors.cardOcean,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.45)),
                        ),
                        child: Text(
                          w,
                          style: GoogleFonts.inter(
                            color: CapsuleColors.textWhite,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CapsuleColors.cyanGlow,
                  foregroundColor: CapsuleColors.deepOcean,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: Text(
                  'VOIR LES 27 FICHES CLINIQUES',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 12),
                ),
                onPressed: onOpenFiches,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
