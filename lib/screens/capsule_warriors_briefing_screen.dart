import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../arcade/gastro_arcade_screen.dart';
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
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final stage = widget.stageId ?? widget.world?.id ?? 1;
    _world = widget.world ??
        GastroWorld.worlds.firstWhere(
          (w) => w.id == stage,
          orElse: () => GastroWorld.worlds.first,
        );

    _progress = widget.progress ?? _storage.currentProgress;

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _startMission() {
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GastroArcadeScreen(
          stageId: _world.id,
          progress: _progress,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isCompact = media.size.height < 520;

    return Scaffold(
      backgroundColor: CapsuleColors.darkNavy,
      body: CapsuleParallaxBackground(
        showHeroCapsule: false,
        showEnemySilhouettes: false,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 20 : 36,
              vertical: isCompact ? 10 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Bar: RETOUR button + Header
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _audio.playClick();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_rounded, color: CapsuleColors.cyanGlow, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'RETOUR',
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STAGE ${_world.id} : ${_world.name.toUpperCase()}',
                          style: GoogleFonts.orbitron(
                            fontSize: isCompact ? 16 : 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: _world.primaryColor.withValues(alpha: 0.7),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _world.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: CapsuleColors.turquoise,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Question Count Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: CapsuleColors.purple.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CapsuleColors.purple.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.menu_book_rounded, color: CapsuleColors.cyanGlow, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${_world.questionIds.length} questions à résoudre',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Middle Content Grid
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left Column: Environment description & Objectives
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Theme / Environment Card
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF1E293B)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.terrain_rounded, color: _world.primaryColor, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'ENVIRONNEMENT GASTRIQUE',
                                          style: GoogleFonts.orbitron(
                                            color: _world.primaryColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _world.description,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 12,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _world.environmentDescription,
                                      style: GoogleFonts.inter(
                                        color: CapsuleColors.textSubtle,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Mission Objectives
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF1E293B)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'OBJECTIFS DE LA MISSION',
                                      style: GoogleFonts.orbitron(
                                        color: CapsuleColors.gold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildObjectiveItem('1. Naviguer et neutraliser les pathogènes digestifs.'),
                                    _buildObjectiveItem('2. Répondre aux ${_world.questionIds.length} checkpoints cliniques MICI.'),
                                    _buildObjectiveItem('3. Terrasser le Boss : ${_world.bossName}.'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Right Column: Enemy Previews + Weapon Loadout
                      Expanded(
                        flex: 6,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Enemy Preview (3 canvas illustrations)
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: CapsuleColors.dangerRed.withValues(alpha: 0.4)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'MENACES DÉTECTÉES DANS CE SECTEUR',
                                          style: GoogleFonts.orbitron(
                                            color: CapsuleColors.dangerRed,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        Text(
                                          'BOSS: ${_world.bossName.toUpperCase()}',
                                          style: GoogleFonts.orbitron(
                                            color: CapsuleColors.dangerOrange,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(child: _buildEnemyPreviewItem(type: 0, name: 'Helico-Grub', desc: 'Flagellé spiralé')),
                                        const SizedBox(width: 8),
                                        Expanded(child: _buildEnemyPreviewItem(type: 1, name: 'Spike-Virion', desc: 'Capside perforante')),
                                        const SizedBox(width: 8),
                                        Expanded(child: _buildEnemyPreviewItem(type: 2, name: 'Cytokine-Blob', desc: 'Acide corrosif')),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Weapon Loadout Card
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: CapsuleColors.cyanGlow.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: CapsuleColors.cyanGlow),
                                      ),
                                      child: const Icon(Icons.flash_on_rounded, color: CapsuleColors.cyanGlow, size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ARSENAL ÉQUIPÉ : ${_progress.equippedWeapon.toUpperCase()}',
                                            style: GoogleFonts.orbitron(
                                              color: Colors.white,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Récompense stage : Déblocage ${_world.unlockedWeaponName}',
                                            style: GoogleFonts.inter(
                                              color: CapsuleColors.turquoise,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 3. Large "COMMENCER LA MISSION" Glowing Button
                Center(
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 480),
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [
                              CapsuleColors.electricBlue,
                              CapsuleColors.cyanGlow,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CapsuleColors.cyanGlow.withValues(
                                alpha: 0.35 * _glowAnimation.value,
                              ),
                              blurRadius: 18 * _glowAnimation.value,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _startMission,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.rocket_launch_rounded, color: Colors.black, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  'COMMENCER LA MISSION',
                                  style: GoogleFonts.orbitron(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildObjectiveItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: CapsuleColors.successGreen, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnemyPreviewItem({
    required int type,
    required String name,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF030712),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CustomPaint(
              painter: _EnemyBriefingPainter(enemyType: type),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            desc,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: CapsuleColors.textSubtle,
              fontSize: 8.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnemyBriefingPainter extends CustomPainter {
  final int enemyType;

  _EnemyBriefingPainter({required this.enemyType});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (enemyType == 0) {
      // Helicobacter (curved body with flagella)
      final bodyPaint = Paint()..color = CapsuleColors.dangerRed;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: 24, height: 12),
          const Radius.circular(6),
        ),
        bodyPaint,
      );
      final flagPaint = Paint()
        ..color = CapsuleColors.dangerOrange
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      for (int i = -1; i <= 1; i++) {
        final p = Path()
          ..moveTo(center.dx + 12, center.dy + i * 3)
          ..quadraticBezierTo(center.dx + 18, center.dy + i * 6, center.dx + 22, center.dy + i * 4);
        canvas.drawPath(p, flagPaint);
      }
    } else if (enemyType == 1) {
      // Spike Virion
      final virPaint = Paint()..color = CapsuleColors.purple;
      canvas.drawCircle(center, 10, virPaint);
      final spikePaint = Paint()
        ..color = CapsuleColors.dangerOrange
        ..strokeWidth = 2.0;
      for (int i = 0; i < 6; i++) {
        final angle = i * math.pi / 3;
        canvas.drawLine(
          Offset(center.dx + math.cos(angle) * 10, center.dy + math.sin(angle) * 10),
          Offset(center.dx + math.cos(angle) * 16, center.dy + math.sin(angle) * 16),
          spikePaint,
        );
      }
    } else {
      // Cytokine Blob
      final blobPaint = Paint()..color = CapsuleColors.dangerOrange;
      canvas.drawCircle(center, 12, blobPaint);
      canvas.drawCircle(Offset(center.dx + 6, center.dy - 6), 5, blobPaint);
      canvas.drawCircle(Offset(center.dx - 5, center.dy + 6), 4, blobPaint);
      canvas.drawCircle(center, 5, Paint()..color = Colors.white.withValues(alpha: 0.6));
    }
  }

  @override
  bool shouldRepaint(covariant _EnemyBriefingPainter oldDelegate) =>
      oldDelegate.enemyType != enemyType;
}
