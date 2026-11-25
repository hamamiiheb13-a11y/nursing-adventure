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

  void _selectWeapon(String weaponName) {
    _audio.playClick();
    setState(() {
      _progress.equipWeapon(weaponName);
    });
    _storage.saveProgress(_progress);
  }

  void _startMission() {
    _audio.playClick();
    _storage.saveProgress(_progress);
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => GastroArcadeScreen(
              stageId: _world.id,
              progress: _progress,
            ),
          ),
        )
        .then((_) {
          if (mounted) setState(() {});
        });
  }

  int get _checkpointCount {
    if (_world.id == 7) {
      return _progress.revisionQueue.isNotEmpty
          ? math.min(7, _progress.revisionQueue.length)
          : 3;
    }
    return _world.questionIds.length;
  }

  @override
  Widget build(BuildContext context) {
    final equippedConfig = WeaponConfig.getByName(_progress.equippedWeapon);

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
                      horizontal: isNarrowPortrait ? 16 : 28,
                      vertical: isShortLandscape ? 8 : 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Clean Responsive Header (RETOUR + Nom de mission)
                        _buildTopBar(isNarrowPortrait, isShortLandscape),
                        SizedBox(height: isShortLandscape ? 8 : 14),

                        // 2. Clean Main Presentation Card
                        Expanded(
                          child: isNarrowPortrait
                              ? SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildEnvironmentBanner(height: 120),
                                      const SizedBox(height: 12),
                                      _buildOverviewAndGoalCard(isShortLandscape: false),
                                      const SizedBox(height: 12),
                                      _buildKeyInfoRow(equippedConfig, isNarrow: true),
                                      const SizedBox(height: 10),
                                      _buildWeaponSelectorCard(),
                                    ],
                                  ),
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Left 46%: Animated Environment Preview + Short Intro
                                    Expanded(
                                      flex: 46,
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            _buildEnvironmentBanner(
                                              height: isShortLandscape ? 105 : 148,
                                            ),
                                            SizedBox(height: isShortLandscape ? 8 : 12),
                                            _buildOverviewAndGoalCard(
                                              isShortLandscape: isShortLandscape,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Right 54%: Key Specs (Checkpoints, Boss Reward, Armed Weapon Selector)
                                    Expanded(
                                      flex: 54,
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            _buildKeyInfoRow(equippedConfig, isNarrow: false),
                                            SizedBox(height: isShortLandscape ? 8 : 12),
                                            _buildWeaponSelectorCard(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        SizedBox(height: isShortLandscape ? 8 : 14),

                        // 3. Single Primary CTA Button
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 460),
                            child: SizedBox(
                              width: double.infinity,
                              height: isShortLandscape ? 46 : 52,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CapsuleColors.cyanGlow,
                                  foregroundColor: CapsuleColors.deepOcean,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.rocket_launch_rounded, size: 22),
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
          color: CapsuleColors.oceanSurface.withValues(alpha: 0.90),
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
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );

    final titleBlock = Column(
      crossAxisAlignment: isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'MISSION ${_world.id} • ${_world.name}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: isNarrow ? 17 : (isShort ? 17 : 21),
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          _world.subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
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
          backBtn,
          const SizedBox(height: 10),
          titleBlock,
        ],
      );
    }

    return Row(
      children: [
        backBtn,
        const SizedBox(width: 14),
        Expanded(child: titleBlock),
      ],
    );
  }

  Widget _buildEnvironmentBanner({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: _world.tunnelDeepColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _world.primaryColor.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
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
            Positioned(
              left: 12,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CapsuleColors.deepOcean.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_world.icon, color: _world.primaryColor, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'BOSS : ${_world.bossName}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
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
      padding: EdgeInsets.all(isShortLandscape ? 11 : 14),
      decoration: BoxDecoration(
        color: CapsuleColors.oceanSurface.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CapsuleColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _world.description,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: isShortLandscape ? 12 : 13,
              height: 1.38,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: CapsuleColors.deepOcean.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_rounded, color: CapsuleColors.mintGreen, size: 16),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Objectif : Réussir les $_checkpointCount checkpoints cliniques et vaincre ${_world.bossName}.',
                    style: GoogleFonts.inter(
                      color: CapsuleColors.mintGreen,
                      fontSize: 11.5,
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

  Widget _buildKeyInfoRow(WeaponConfig equippedConfig, {required bool isNarrow}) {
    final checkpointsChip = _buildInfoChip(
      icon: Icons.quiz_rounded,
      color: CapsuleColors.cyanGlow,
      label: 'CHECKPOINTS',
      value: '$_checkpointCount Questions MICI',
    );
    final rewardChip = _buildInfoChip(
      icon: Icons.card_giftcard_rounded,
      color: CapsuleColors.gold,
      label: 'RÉCOMPENSE STAGE',
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
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: CapsuleColors.oceanSurface.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
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
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 12,
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

  Widget _buildWeaponSelectorCard() {
    final unlocked = _progress.unlockedWeapons;
    final equippedConfig = WeaponConfig.getByName(_progress.equippedWeapon);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CapsuleColors.oceanSurface.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CapsuleColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(equippedConfig.icon, color: equippedConfig.glowColor, size: 17),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'ARME ÉQUIPÉE : ${equippedConfig.name}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            equippedConfig.description,
            style: GoogleFonts.inter(
              color: CapsuleColors.textSubtle,
              fontSize: 11,
            ),
          ),
          if (unlocked.length > 1) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: unlocked.map((wName) {
                final cfg = WeaponConfig.getByName(wName);
                final isSelected = cfg.name == equippedConfig.name;
                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _selectWeapon(wName),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cfg.glowColor.withValues(alpha: 0.25)
                          : CapsuleColors.deepOcean.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? cfg.glowColor : CapsuleColors.cardBorder,
                      ),
                    ),
                    child: Text(
                      cfg.shortName,
                      style: GoogleFonts.plusJakartaSans(
                        color: isSelected ? Colors.white : CapsuleColors.textSubtle,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
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
    // Soft digestive corridor walls
    final wallPaint = Paint()..color = world.tunnelWallColor.withValues(alpha: 0.65);

    final topPath = Path()..moveTo(0, 0);
    for (double x = 0; x <= size.width; x += 12) {
      topPath.lineTo(x, size.height * 0.20 + math.sin(x * 0.03 + t) * 7.0);
    }
    topPath.lineTo(size.width, 0);
    topPath.close();
    canvas.drawPath(topPath, wallPaint);

    final botPath = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 12) {
      botPath.lineTo(x, size.height * 0.78 + math.cos(x * 0.03 + t) * 7.0);
    }
    botPath.lineTo(size.width, size.height);
    botPath.close();
    canvas.drawPath(botPath, wallPaint);

    // Floating bubbles
    for (int i = 0; i < 6; i++) {
      final bx = (size.width * ((i + 1) / 7) + math.sin(t + i) * 14.0);
      final by = size.height * 0.5 + math.cos(t * 1.2 + i * 1.5) * 16.0;
      canvas.drawCircle(
        Offset(bx, by),
        5.0 + (i % 3) * 3.0,
        Paint()..color = world.secondaryColor.withValues(alpha: 0.50),
      );
    }

    // Mini capsule silhouette swimming smoothly in center-left
    final capX = size.width * 0.34;
    final capY = size.height * 0.5 + math.sin(t * 2.0) * 6.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(capX, capY), width: 34, height: 18),
        const Radius.circular(9),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(capX + 8, capY),
      6,
      Paint()..color = CapsuleColors.cyanGlow,
    );
  }

  @override
  bool shouldRepaint(covariant _MissionEnvironmentPreviewPainter oldDelegate) => true;
}
