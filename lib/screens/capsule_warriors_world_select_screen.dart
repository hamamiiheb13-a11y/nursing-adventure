import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../models/game_progress.dart';
import '../models/gastro_world.dart';
import '../services/storage_service.dart';
import '../theme/capsule_theme.dart';
import '../widgets/capsule_parallax_background.dart';
import 'capsule_warriors_briefing_screen.dart';

class CapsuleWarriorsWorldSelectScreen extends StatefulWidget {
  final GameProgress progress;

  const CapsuleWarriorsWorldSelectScreen({
    super.key,
    required this.progress,
  });

  @override
  State<CapsuleWarriorsWorldSelectScreen> createState() =>
      _CapsuleWarriorsWorldSelectScreenState();
}

class _CapsuleWarriorsWorldSelectScreenState
    extends State<CapsuleWarriorsWorldSelectScreen> {
  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();
  late GameProgress _progress;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _reloadProgress() async {
    final updated = await _storage.loadProgress();
    if (mounted) {
      setState(() {
        _progress = updated;
      });
    }
  }

  int get _completedStagesCount {
    int count = 0;
    for (final world in GastroWorld.worlds) {
      if (_progress.isWorldCompleted(world.id)) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _completedStagesCount;
    final totalStages = GastroWorld.worlds.length;
    final completionRatio = totalStages > 0 ? (completedCount / totalStages).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: CapsuleColors.darkNavy,
      body: CapsuleParallaxBackground(
        showHeroCapsule: false,
        showEnemySilhouettes: true,
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Header Bar (RETOUR button, Title, Total XP)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    // RETOUR Button
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

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'CHOISISSEZ VOTRE MISSION',
                            style: GoogleFonts.orbitron(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.2,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: CapsuleColors.cyanGlow.withValues(alpha: 0.8),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '7 ÉTAPES DU TRACTUS DIGESTIF • 33 QUESTIONS CLINIQUES',
                            style: GoogleFonts.inter(
                              color: CapsuleColors.turquoise,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Total XP & Score Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CapsuleColors.gold.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt_rounded, color: CapsuleColors.gold, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${_progress.totalXP} XP',
                            style: GoogleFonts.orbitron(
                              color: CapsuleColors.gold,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Horizontal Scrollable 7 Stage Cards
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 290,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: GastroWorld.worlds.length,
                      itemBuilder: (context, index) {
                        final world = GastroWorld.worlds[index];
                        return _buildStageCard(world);
                      },
                    ),
                  ),
                ),
              ),

              // 3. Bottom Progress Bar & Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      '$completedCount/7 STAGES COMPLÉTÉS',
                      style: GoogleFonts.orbitron(
                        color: CapsuleColors.cyanGlow,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: completionRatio,
                          backgroundColor: const Color(0xFF1E293B),
                          valueColor: const AlwaysStoppedAnimation<Color>(CapsuleColors.cyanGlow),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${(completionRatio * 100).toInt()}%',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageCard(GastroWorld world) {
    final isUnlocked = _progress.isWorldUnlocked(world.id);
    final isCompleted = _progress.isWorldCompleted(world.id);
    final stars = _progress.getStars(world.id);

    return Container(
      width: 215,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: isUnlocked ? 0.90 : 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? CapsuleColors.successGreen
              : isUnlocked
                  ? world.primaryColor.withValues(alpha: 0.8)
                  : const Color(0xFF334155),
          width: isUnlocked ? 2.0 : 1.0,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: world.primaryColor.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isUnlocked
              ? () {
                  _audio.playClick();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CapsuleWarriorsBriefingScreen(
                        world: world,
                        progress: _progress,
                      ),
                    ),
                  ).then((_) => _reloadProgress());
                }
              : null,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top: Stage Number & Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'STAGE 0${world.id}',
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isUnlocked ? world.primaryColor : CapsuleColors.textSubtle,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Text(
                            '${world.questionIds.length} Q',
                            style: GoogleFonts.orbitron(
                              fontSize: 9.5,
                              color: CapsuleColors.turquoise,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Canvas Illustration Thumbnail
                    Center(
                      child: Container(
                        width: 175,
                        height: 76,
                        decoration: BoxDecoration(
                          color: const Color(0xFF030712),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: world.primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CustomPaint(
                            painter: _StageThumbnailPainter(worldId: world.id, color: world.primaryColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Stage Name & Subtitle
                    Text(
                      world.name,
                      style: GoogleFonts.orbitron(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isUnlocked ? Colors.white : CapsuleColors.textSubtle,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        world.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: CapsuleColors.textSubtle,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Star Rating (1-3 stars)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (starIdx) {
                        final isEarned = starIdx < stars;
                        return Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: isEarned ? CapsuleColors.gold : const Color(0xFF334155),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Locked Overlay if stage is locked
              if (!isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_rounded, color: CapsuleColors.dangerRed, size: 36),
                          const SizedBox(height: 6),
                          Text(
                            'VERROUILLÉ',
                            style: GoogleFonts.orbitron(
                              color: CapsuleColors.dangerRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Finissez le Stage ${world.id - 1}',
                            style: GoogleFonts.inter(
                              color: CapsuleColors.textSubtle,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
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
}

/// Canvas painter for stage preview thumbnail illustrations
class _StageThumbnailPainter extends CustomPainter {
  final int worldId;
  final Color color;

  _StageThumbnailPainter({required this.worldId, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF030712);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final pCenter = Offset(size.width / 2, size.height / 2);

    switch (worldId) {
      case 1:
        // Stage 1: Anatomical folds & crypts
        final wavePath = Path()..moveTo(0, size.height * 0.7);
        for (double x = 0; x <= size.width; x += 15) {
          final y = size.height * 0.5 + math.sin(x * 0.08) * 12;
          wavePath.lineTo(x, y);
        }
        wavePath.lineTo(size.width, size.height);
        wavePath.lineTo(0, size.height);
        wavePath.close();
        canvas.drawPath(wavePath, Paint()..color = color.withValues(alpha: 0.35));
        canvas.drawCircle(pCenter, 14, Paint()..color = color.withValues(alpha: 0.6));
        break;

      case 2:
        // Stage 2: Inflammatory flames / cytokines
        final flamePaint = Paint()..color = color.withValues(alpha: 0.5);
        for (int i = 0; i < 5; i++) {
          final fx = size.width * (0.2 + i * 0.15);
          final fy = size.height * 0.7;
          canvas.drawCircle(Offset(fx, fy - (i % 2 == 0 ? 10 : 0)), 8, flamePaint);
        }
        canvas.drawCircle(pCenter, 16, Paint()..color = CapsuleColors.dangerOrange.withValues(alpha: 0.7));
        break;

      case 3:
        // Stage 3: Medication / Syringe / Pill
        final pillRect = Rect.fromCenter(center: pCenter, width: 44, height: 20);
        canvas.drawRRect(
          RRect.fromRectAndRadius(pillRect, const Radius.circular(10)),
          Paint()..color = color.withValues(alpha: 0.7),
        );
        canvas.drawCircle(pCenter, 5, Paint()..color = Colors.white);
        break;

      case 4:
        // Stage 4: Lab / Biomarkers / Microscope flask
        final flaskPath = Path()
          ..moveTo(pCenter.dx - 12, pCenter.dy + 14)
          ..lineTo(pCenter.dx + 12, pCenter.dy + 14)
          ..lineTo(pCenter.dx + 4, pCenter.dy - 6)
          ..lineTo(pCenter.dx + 4, pCenter.dy - 14)
          ..lineTo(pCenter.dx - 4, pCenter.dy - 14)
          ..lineTo(pCenter.dx - 4, pCenter.dy - 6)
          ..close();
        canvas.drawPath(flaskPath, Paint()..color = color.withValues(alpha: 0.75));
        break;

      case 5:
        // Stage 5: Lifestyle & Nutrition
        canvas.drawCircle(pCenter, 18, Paint()..color = color.withValues(alpha: 0.6));
        canvas.drawCircle(Offset(pCenter.dx + 6, pCenter.dy - 6), 14, Paint()..color = const Color(0xFF030712));
        break;

      case 6:
        // Stage 6: Family & DNA Helix
        final dnaPaint = Paint()
          ..color = color.withValues(alpha: 0.7)
          ..strokeWidth = 2.0;
        for (double x = 20; x <= size.width - 20; x += 10) {
          final y1 = pCenter.dy + math.sin(x * 0.1) * 12;
          final y2 = pCenter.dy - math.sin(x * 0.1) * 12;
          canvas.drawLine(Offset(x, y1), Offset(x, y2), dnaPaint);
          canvas.drawCircle(Offset(x, y1), 2.5, Paint()..color = Colors.white);
          canvas.drawCircle(Offset(x, y2), 2.5, Paint()..color = color);
        }
        break;

      case 7:
        // Stage 7: Nursing mission finale (Caduceus / Cross)
        final crossPaint = Paint()..color = color.withValues(alpha: 0.8);
        canvas.drawRect(Rect.fromCenter(center: pCenter, width: 34, height: 10), crossPaint);
        canvas.drawRect(Rect.fromCenter(center: pCenter, width: 10, height: 34), crossPaint);
        canvas.drawCircle(pCenter, 6, Paint()..color = Colors.white);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _StageThumbnailPainter oldDelegate) =>
      oldDelegate.worldId != worldId || oldDelegate.color != color;
}
