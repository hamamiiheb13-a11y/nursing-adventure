import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../arcade/gastro_arcade_screen.dart';
import '../arcade/weapon_system.dart';
import '../audio/audio_service.dart';
import '../models/game_progress.dart';
import '../models/gastro_world.dart';
import '../services/storage_service.dart';
import '../theme/capsule_theme.dart';
import '../widgets/capsule_parallax_background.dart';

class CapsuleWarriorsBriefingScreen extends StatefulWidget {
  final GastroWorld? world;
  final int? stageId;
  final GameProgress? progress;

  const CapsuleWarriorsBriefingScreen({
    super.key,
    this.world,
    this.stageId,
    this.progress,
  });

  @override
  State<CapsuleWarriorsBriefingScreen> createState() =>
      _CapsuleWarriorsBriefingScreenState();
}

class _CapsuleWarriorsBriefingScreenState
    extends State<CapsuleWarriorsBriefingScreen>
    with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();

  late final GastroWorld _world;
  late GameProgress _progress;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);

    final stage = widget.stageId ?? widget.world?.id ?? 1;
    _world = widget.world ??
        GastroWorld.worlds.firstWhere(
          (w) => w.id == stage,
          orElse: () => GastroWorld.worlds.first,
        );

    _progress = widget.progress ?? _storage.currentProgress;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _cycleWeapon() {
    final unlocked = _progress.unlockedWeapons;
    if (unlocked.length <= 1) return;
    _audio.playClick();
    final idx = unlocked.indexOf(_progress.equippedWeapon);
    final nextName = unlocked[(idx + 1) % unlocked.length];
    setState(() {
      _progress.equipWeapon(nextName);
    });
    _storage.saveProgress(_progress);
  }

  int get _effectiveStageId => widget.stageId ?? widget.world?.id ?? 1;

  void _startMission() {
    _audio.playClick();
    _storage.saveProgress(_progress);
    Navigator.of(context)
        .push(
          buildCapsuleRoute(
            GastroArcadeScreen(
              stageId: _effectiveStageId,
              progress: _progress,
            ),
          ),
        )
        .then((_) {
          if (mounted) setState(() {});
        });
  }

  int get _checkpointCount {
    final sectorId = ((_effectiveStageId - 1) % 7) + 1;
    if (sectorId == 7) {
      return 3;
    }
    return _world.questionIds.length;
  }

  @override
  Widget build(BuildContext context) {
    final equippedConfig = WeaponConfig.getByName(_progress.equippedWeapon);
    final nextWorld = _world.id < 7 ? GastroWorld.getWorldForLevel(_world.id + 1) : null;

    return Scaffold(
      backgroundColor: CapsuleColors.deepOcean,
      body: CapsuleParallaxBackground(
        showHeroCapsule: false,
        showEnemySilhouettes: false,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrowPortrait = constraints.maxWidth < 620;
              final bool isShortLandscape = constraints.maxHeight < 460;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isNarrowPortrait ? 16 : 26,
                      vertical: isShortLandscape ? 6 : 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. En-tête épuré : Retour • Stage & Monde • Progression
                        _buildTopBar(isNarrowPortrait, isShortLandscape),
                        SizedBox(height: isShortLandscape ? 8 : 12),

                        // 2. Corps principal aéré (Illustration généreuse + blocs synthétiques)
                        Expanded(
                          child: isNarrowPortrait
                              ? SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildEnvironmentBanner(height: 145),
                                      const SizedBox(height: 10),
                                      _buildOverviewAndGoalCard(isShortLandscape: false),
                                      const SizedBox(height: 10),
                                      _buildKeyInfoRow(isNarrow: true),
                                      const SizedBox(height: 10),
                                      _buildCompactLoadoutBar(equippedConfig),
                                      if (nextWorld != null) ...[
                                        const SizedBox(height: 10),
                                        _buildNextEnvironmentCard(nextWorld),
                                      ],
                                    ],
                                  ),
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Colonne Gauche (48%) : Grande illustration anatomique + Présentation
                                    Expanded(
                                      flex: 48,
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            _buildEnvironmentBanner(
                                              height: isShortLandscape ? 132 : 178,
                                            ),
                                            SizedBox(height: isShortLandscape ? 8 : 10),
                                            _buildOverviewAndGoalCard(
                                              isShortLandscape: isShortLandscape,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Colonne Droite (52%) : Infos clés + Arme active (compacte) + Prochain monde
                                    Expanded(
                                      flex: 52,
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            _buildKeyInfoRow(isNarrow: false),
                                            SizedBox(height: isShortLandscape ? 8 : 10),
                                            _buildCompactLoadoutBar(equippedConfig),
                                            if (nextWorld != null) ...[
                                              SizedBox(height: isShortLandscape ? 8 : 10),
                                              _buildNextEnvironmentCard(nextWorld),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        SizedBox(height: isShortLandscape ? 8 : 12),

                        // 3. Bouton d'action principal : COMMENCER LA MISSION
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 460),
                            child: SizedBox(
                              width: double.infinity,
                              height: isShortLandscape ? 44 : 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CapsuleColors.cyanGlow,
                                  foregroundColor: CapsuleColors.inkDark,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.rocket_launch_rounded, size: 21),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'COMMENCER LA MISSION',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: isShortLandscape ? 14 : 15.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                onPressed: _startMission,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isNarrow, bool isShort) {
    final backBtn = InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        _audio.playClick();
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: CapsuleColors.oceanSurface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CapsuleColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_rounded, color: CapsuleColors.cyanGlow, size: 17),
            const SizedBox(width: 5),
            Text(
              'RETOUR',
              style: GoogleFonts.plusJakartaSans(
                color: CapsuleColors.textWhite,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );

    final progressRatio = (_progress.completedCount / 7.0).clamp(0.0, 1.0);
    final progressWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CapsuleColors.oceanSurface.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CapsuleColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_progress.completedCount}/7',
            style: GoogleFonts.orbitron(
              color: CapsuleColors.cyanGlow,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 7),
          SizedBox(
            width: isNarrow ? 54 : 76,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressRatio,
                minHeight: 6,
                backgroundColor: CapsuleColors.cardOcean,
                valueColor: const AlwaysStoppedAnimation<Color>(CapsuleColors.mintGreen),
              ),
            ),
          ),
        ],
      ),
    );

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'MISSION $_effectiveStageId • ${_world.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isNarrow ? 16.5 : (isShort ? 16.5 : 20),
            fontWeight: FontWeight.w900,
            color: CapsuleColors.textWhite,
          ),
        ),
        Text(
          _world.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: CapsuleColors.cyanGlow,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [backBtn, progressWidget],
          ),
          const SizedBox(height: 8),
          titleBlock,
        ],
      );
    }

    return Row(
      children: [
        backBtn,
        const SizedBox(width: 14),
        Expanded(child: titleBlock),
        const SizedBox(width: 10),
        progressWidget,
      ],
    );
  }

  Widget _buildEnvironmentBanner({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: _world.tunnelDeepColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _world.primaryColor.withValues(alpha: 0.60), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.5),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _MissionEnvironmentPreviewPainter(
                    world: _world,
                    anim: _animController.value,
                  ),
                );
              },
            ),
            // Zone digestive en haut à gauche
            Positioned(
              left: 10,
              top: 9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: CapsuleColors.deepOcean.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.55)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.biotech_rounded, color: CapsuleColors.cyanGlow, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      _world.organZone,
                      style: GoogleFonts.plusJakartaSans(
                        color: CapsuleColors.textWhite,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Boss en bas à gauche
            Positioned(
              left: 10,
              bottom: 9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CapsuleColors.deepOcean.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _world.primaryColor.withValues(alpha: 0.65)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_world.icon, color: _world.primaryColor, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      'Boss : ${_world.bossName}',
                      style: GoogleFonts.plusJakartaSans(
                        color: CapsuleColors.textWhite,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewAndGoalCard({required bool isShortLandscape}) {
    return Container(
      padding: EdgeInsets.all(isShortLandscape ? 10 : 13),
      decoration: BoxDecoration(
        color: CapsuleColors.oceanSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CapsuleColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _world.description,
            style: GoogleFonts.inter(
              color: CapsuleColors.textWhite,
              fontSize: isShortLandscape ? 11.8 : 12.8,
              height: 1.38,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: CapsuleColors.deepOcean.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_rounded, color: CapsuleColors.mintGreen, size: 15),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Objectif : Valider $_checkpointCount checkpoints et vaincre ${_world.bossName}.',
                    style: GoogleFonts.inter(
                      color: CapsuleColors.mintGreen,
                      fontSize: 11.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInfoRow({required bool isNarrow}) {
    final checkpointsChip = _buildInfoChip(
      icon: Icons.quiz_rounded,
      color: CapsuleColors.cyanGlow,
      label: 'CHECKPOINTS',
      value: '$_checkpointCount Questions MICI',
    );
    final rewardChip = _buildInfoChip(
      icon: Icons.card_giftcard_rounded,
      color: CapsuleColors.gold,
      label: 'RÉCOMPENSE',
      value: _world.unlockedWeaponName,
    );

    if (isNarrow) {
      return Column(
        children: [
          checkpointsChip,
          const SizedBox(height: 8),
          rewardChip,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: checkpointsChip),
        const SizedBox(width: 10),
        Expanded(child: rewardChip),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CapsuleColors.oceanSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: CapsuleColors.textSubtle,
                    fontSize: 9.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: CapsuleColors.textWhite,
                    fontSize: 11.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Barre compacte affichant uniquement l'arme active (avec changement rapide si > 1 arme)
  Widget _buildCompactLoadoutBar(WeaponConfig equippedConfig) {
    final unlocked = _progress.unlockedWeapons;
    final canSwitch = unlocked.length > 1;
    final idx = math.max(0, unlocked.indexOf(equippedConfig.name));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CapsuleColors.oceanSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CapsuleColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: equippedConfig.glowColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(equippedConfig.icon, color: equippedConfig.glowColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ÉQUIPEMENT ACTIF : ${equippedConfig.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: CapsuleColors.textWhite,
                    fontSize: 11.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  equippedConfig.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: CapsuleColors.textSubtle,
                    fontSize: 10.8,
                  ),
                ),
              ],
            ),
          ),
          if (canSwitch) ...[
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: _cycleWeapon,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: CapsuleColors.cardOcean,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.60)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.swap_horiz_rounded, color: CapsuleColors.cyanGlow, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      '${idx + 1}/${unlocked.length}',
                      style: GoogleFonts.orbitron(
                        color: CapsuleColors.cyanGlow,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextEnvironmentCard(GastroWorld nextWorld) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CapsuleColors.oceanSurface.withValues(alpha: 0.94),
            nextWorld.primaryColor.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CapsuleColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [nextWorld.primaryColor, nextWorld.secondaryColor],
              ),
              border: Border.all(color: Colors.white54),
            ),
            child: const Icon(Icons.explore_rounded, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'APERÇU DU PROCHAIN ENVIRONNEMENT',
                  style: GoogleFonts.plusJakartaSans(
                    color: CapsuleColors.gold,
                    fontSize: 9.2,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
                Text(
                  'Stage ${nextWorld.id} : ${nextWorld.organZone} — ${nextWorld.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: CapsuleColors.textWhite,
                    fontSize: 11.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'À découvrir : ${nextWorld.bossName} • ${nextWorld.unlockedWeaponName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: CapsuleColors.textSubtle,
                    fontSize: 10.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionEnvironmentPreviewPainter extends CustomPainter {
  final GastroWorld world;
  final double anim;

  _MissionEnvironmentPreviewPainter({required this.world, required this.anim});

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim * math.pi * 2;

    // Soft layered mucosal wall contours (smooth waves)
    final wallPaint = Paint()..color = world.tunnelWallColor.withValues(alpha: 0.58);
    final rimPaint = Paint()
      ..color = const Color(0xFF20D5E8).withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final topPath = Path()..moveTo(0, 0);
    final topRim = Path();
    for (double x = 0; x <= size.width; x += 20) {
      final y = size.height * 0.22 + math.sin(x * 0.025 + t) * 8.0;
      if (x == 0) {
        topRim.moveTo(x, y);
      } else {
        topRim.lineTo(x, y);
      }
      topPath.lineTo(x, y);
    }
    topPath.lineTo(size.width, 0);
    topPath.close();
    canvas.drawPath(topPath, wallPaint);
    canvas.drawPath(topRim, rimPaint);

    final botPath = Path()..moveTo(0, size.height);
    final botRim = Path();
    for (double x = 0; x <= size.width; x += 20) {
      final y = size.height * 0.78 + math.cos(x * 0.025 + t) * 8.0;
      if (x == 0) {
        botRim.moveTo(x, y);
      } else {
        botRim.lineTo(x, y);
      }
      botPath.lineTo(x, y);
    }
    botPath.lineTo(size.width, size.height);
    botPath.close();
    canvas.drawPath(botPath, wallPaint);
    canvas.drawPath(botRim, rimPaint);

    // Organ-specific subtle anatomical cues
    final accentPaint = Paint()
      ..color = world.secondaryColor.withValues(alpha: 0.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    for (int i = 0; i < 4; i++) {
      final bx = (size.width * ((i + 1) / 5) + math.sin(t + i) * 14.0);
      final by = size.height * 0.5 + math.cos(t * 1.1 + i * 1.4) * 14.0;
      canvas.drawCircle(
        Offset(bx, by),
        5.0 + (i % 3) * 2.5,
        Paint()..color = world.secondaryColor.withValues(alpha: 0.32),
      );
      canvas.drawCircle(Offset(bx, by), 7.5 + (i % 2) * 3.0, accentPaint);
    }

    // Mini capsule pod gliding through the anatomical canal
    final capX = size.width * 0.44;
    final capY = size.height * 0.5 + math.sin(t * 2.0) * 6.0;
    // Soft trail
    canvas.drawLine(
      Offset(capX - 38, capY),
      Offset(capX - 16, capY),
      Paint()
        ..color = const Color(0xFF20D5E8).withValues(alpha: 0.50)
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(capX, capY), width: 38, height: 22),
        const Radius.circular(11),
      ),
      Paint()..color = const Color(0xFFF4F8FC),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(capX - 3, capY), width: 5, height: 21),
        const Radius.circular(2.5),
      ),
      Paint()..color = const Color(0xFF20C9B0),
    );
    canvas.drawCircle(
      Offset(capX + 10, capY),
      7.0,
      Paint()..color = const Color(0xFF20D5E8),
    );
  }

  @override
  bool shouldRepaint(covariant _MissionEnvironmentPreviewPainter oldDelegate) =>
      oldDelegate.anim != anim || oldDelegate.world.id != world.id;
}
