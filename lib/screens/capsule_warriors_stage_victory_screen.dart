import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../models/gastro_world.dart';
import '../theme/capsule_theme.dart';

class CapsuleWarriorsStageVictoryScreen extends StatefulWidget {
  final int stageId;
  final int? revisionNumber;
  final bool isBonusRevisionChallenge;
  final int score;
  final int? starsOverride;
  final int questionsCorrect;
  final int questionsTotal;
  final int deaths;
  final int collectibles;
  final int secondsElapsed;
  final String? unlockedWeapon;
  final VoidCallback onNextStage;
  final VoidCallback? onViewDiploma;
  final VoidCallback onReplay;
  final VoidCallback onStageMap;

  const CapsuleWarriorsStageVictoryScreen({
    super.key,
    required this.stageId,
    this.revisionNumber,
    this.isBonusRevisionChallenge = false,
    required this.score,
    this.starsOverride,
    this.questionsCorrect = 4,
    this.questionsTotal = 4,
    this.deaths = 0,
    this.collectibles = 15,
    this.secondsElapsed = 65,
    this.unlockedWeapon,
    required this.onNextStage,
    this.onViewDiploma,
    required this.onReplay,
    required this.onStageMap,
  });

  @override
  State<CapsuleWarriorsStageVictoryScreen> createState() =>
      _CapsuleWarriorsStageVictoryScreenState();
}

class _CapsuleWarriorsStageVictoryScreenState
    extends State<CapsuleWarriorsStageVictoryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _particleController;
  late final AnimationController _starController;
  late final AnimationController _weaponPreviewController;
  final AudioService _audio = AudioService();

  late final int _starsEarned;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final int incorrectCount = math.max(0, widget.questionsTotal - widget.questionsCorrect);
    if (widget.starsOverride != null) {
      _starsEarned = widget.starsOverride!.clamp(1, 3);
    } else if (incorrectCount == 0 &&
        widget.questionsTotal > 0 &&
        widget.questionsCorrect >= widget.questionsTotal) {
      _starsEarned = 3;
    } else if (widget.questionsTotal > 0 &&
        (widget.questionsCorrect / widget.questionsTotal) >= 0.5) {
      _starsEarned = 2;
    } else {
      _starsEarned = 1;
    }

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _weaponPreviewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _audio.playStageComplete();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _starController.dispose();
    _weaponPreviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRevision = widget.revisionNumber != null;
    final bool triggersRevisionNext = !isRevision && widget.stageId >= 7;
    final world = isRevision
        ? GastroWorld.revisionWorld
        : GastroWorld.getWorldForLevel(widget.stageId);
    final nextStageId = (widget.stageId + 1).clamp(1, 7);
    final nextWorld = (isRevision || triggersRevisionNext)
        ? null
        : GastroWorld.getWorldForLevel(nextStageId);
    final weaponUnlocked = widget.unlockedWeapon ?? world.unlockedWeaponName;
    final earnedXp = _starsEarned * 100 + widget.questionsCorrect * 50;
    final incorrectCount = math.max(0, widget.questionsTotal - widget.questionsCorrect);

    final media = MediaQuery.of(context);
    final isCompact = media.size.height < 520;

    return Scaffold(
      backgroundColor: CapsuleColors.deepOcean,
      body: Stack(
        children: [
          // Luminous Ocean-Teal Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    CapsuleColors.oceanSurface.withValues(alpha: 0.92),
                    CapsuleColors.deepOcean,
                  ],
                ),
              ),
            ),
          ),

          // 1. Animated Particle Confetti Canvas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _VictoryExplosionPainter(progress: _particleController.value),
                );
              },
            ),
          ),

          // 2. Clean Victory Modal Card
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: isCompact ? 8 : 16,
              ),
              child: Container(
                width: math.min(media.size.width * 0.94, 580),
                padding: EdgeInsets.all(isCompact ? 14 : 20),
                decoration: BoxDecoration(
                  color: CapsuleColors.oceanSurface.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: CapsuleColors.gold, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 24, offset: Offset(0, 8)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.military_tech_rounded,
                      color: CapsuleColors.gold,
                      size: isCompact ? 38 : 48,
                    ),
                    const SizedBox(height: 4),

                    Text(
                      isRevision
                          ? (widget.isBonusRevisionChallenge
                              ? 'DÉFI BONUS VALIDÉ !'
                              : 'RÉVISION SPÉCIALE ACCOMPLIE !')
                          : 'MISSION ACCOMPLIE !',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        fontSize: isCompact ? 18 : 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: CapsuleColors.gold.withValues(alpha: 0.85),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isRevision
                          ? 'STAGE SPÉCIAL DE RÉVISION • CONSOLIDATION FINALE'
                          : 'STAGE ${widget.stageId} • ${world.organZone.toUpperCase()}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: world.primaryColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Defeated Boss Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                      decoration: BoxDecoration(
                        color: CapsuleColors.mintGreen.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: CapsuleColors.mintGreen.withValues(alpha: 0.55)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, color: CapsuleColors.mintGreen, size: 14),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Boss vaincu : ${world.bossName}',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                color: CapsuleColors.mintGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isCompact ? 8 : 11),

                    // Star Rating (1-3 stars with animation)
                    AnimatedBuilder(
                      animation: _starController,
                      builder: (context, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            final filled = index < _starsEarned;
                            final starProgress = (_starController.value * 3 - index).clamp(0.0, 1.0);
                            return Transform.scale(
                              scale: 0.7 + 0.3 * starProgress,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.star_rounded,
                                  color: filled
                                      ? CapsuleColors.gold.withValues(alpha: starProgress)
                                      : const Color(0xFF334155),
                                  size: isCompact ? 32 : 38,
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    SizedBox(height: isCompact ? 8 : 12),

                    // Score Breakdown Stats Grid (explicit Correct & Incorrect counts + Score + XP + Time)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isCompact ? 9 : 11),
                      decoration: BoxDecoration(
                        color: CapsuleColors.deepOcean.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: CapsuleColors.cardBorder),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceAround,
                        spacing: 12,
                        runSpacing: 7,
                        children: [
                          _buildStatItem(
                            'BONNES RÉP.',
                            '${widget.questionsCorrect}/${widget.questionsTotal}',
                            CapsuleColors.mintGreen,
                          ),
                          _buildStatItem(
                            'ERREURS',
                            '$incorrectCount',
                            incorrectCount == 0 ? CapsuleColors.mintGreen : CapsuleColors.amberGold,
                          ),
                          _buildStatItem('SCORE', '${widget.score} PTS', CapsuleColors.gold),
                          _buildStatItem('XP GAGNÉS', '+$earnedXp XP', CapsuleColors.turquoise),
                          _buildStatItem('TEMPS', '${widget.secondsElapsed}s', Colors.white),
                        ],
                      ),
                    ),
                    SizedBox(height: isCompact ? 8 : 11),

                    // Animated Unlocked Weapon Preview Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CapsuleColors.electricBlue.withValues(alpha: 0.28),
                            CapsuleColors.turquoise.withValues(alpha: 0.18),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.65)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 58,
                            height: 36,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: AnimatedBuilder(
                                animation: _weaponPreviewController,
                                builder: (context, _) => CustomPaint(
                                  painter: _WeaponUnlockPreviewPainter(
                                    progress: _weaponPreviewController.value,
                                    accent: world.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NOUVEL ARSENAL DÉBLOQUÉ !',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    color: CapsuleColors.cyanGlow,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                                Text(
                                  weaponUnlocked,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Acquired Clinical Skills
                    if (world.acquiredSkills.isNotEmpty) ...[
                      SizedBox(height: isCompact ? 8 : 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                        decoration: BoxDecoration(
                          color: CapsuleColors.deepOcean.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CapsuleColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'COMPÉTENCES CLINIQUES ACQUISES',
                              style: GoogleFonts.plusJakartaSans(
                                color: CapsuleColors.mintGreen,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.7,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 6,
                              runSpacing: 5,
                              children: world.acquiredSkills
                                  .map(
                                    (skill) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                      decoration: BoxDecoration(
                                        color: CapsuleColors.mintGreen.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: CapsuleColors.mintGreen.withValues(alpha: 0.45)),
                                      ),
                                      child: Text(
                                        '✓ $skill',
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
                          ],
                        ),
                      ),
                    ],

                    // Next Stage / Revision Stage Teaser
                    if (triggersRevisionNext) ...[
                      SizedBox(height: isCompact ? 8 : 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                        decoration: BoxDecoration(
                          color: CapsuleColors.gold.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CapsuleColors.gold.withValues(alpha: 0.55)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_stories_rounded, color: CapsuleColors.gold, size: 17),
                            const SizedBox(width: 8),
                            Expanded(
                            child: Text(
                              'Étape spéciale débloquée : Stage de Révision Finale (notions à consolider des Stages 1 à 7)',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: CapsuleColors.textWhite,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (nextWorld != null) ...[
                    SizedBox(height: isCompact ? 8 : 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                      decoration: BoxDecoration(
                        color: nextWorld.primaryColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: nextWorld.primaryColor.withValues(alpha: 0.45)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.explore_rounded, color: nextWorld.primaryColor, size: 17),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Prochain secteur (Stage $nextStageId) : ${nextWorld.organZone} — ${nextWorld.name} (Boss : ${nextWorld.bossName})',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: CapsuleColors.textWhite,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: isCompact ? 12 : 16),

                  // Buttons: "STAGE SUIVANT" / "STAGE RÉVISION" / "DIPLÔME" / "REJOUER" / "CARTE"
                  Row(
                    children: [
                      // Primary Advance Button
                      Expanded(
                        flex: 3,
                        child: _buildActionButton(
                          label: triggersRevisionNext
                              ? 'STAGE RÉVISION'
                              : (isRevision ? 'VOIR DIPLÔME' : 'STAGE SUIVANT'),
                          icon: triggersRevisionNext
                              ? Icons.auto_stories_rounded
                              : (isRevision
                                  ? Icons.workspace_premium_rounded
                                  : Icons.arrow_forward_rounded),
                          isPrimary: true,
                          onTap: () {
                            _audio.playClick();
                            widget.onNextStage();
                          },
                        ),
                      ),
                        const SizedBox(width: 8),

                        // REJOUER
                        Expanded(
                          flex: 2,
                          child: _buildActionButton(
                            label: 'REJOUER',
                            icon: Icons.replay_rounded,
                            accentColor: CapsuleColors.softViolet,
                            onTap: () {
                              _audio.playClick();
                              widget.onReplay();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // CARTE DES STAGES (or Diplôme when applicable)
                        Expanded(
                          flex: 2,
                          child: _buildActionButton(
                            label: widget.onViewDiploma != null && isRevision
                                ? 'DIPLÔME'
                                : 'CARTE',
                            icon: widget.onViewDiploma != null && isRevision
                                ? Icons.workspace_premium_rounded
                                : Icons.map_rounded,
                            accentColor: CapsuleColors.turquoise,
                            onTap: () {
                              _audio.playClick();
                              if (widget.onViewDiploma != null && isRevision) {
                                widget.onViewDiploma!();
                              } else {
                                widget.onStageMap();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            color: CapsuleColors.textSubtle,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    bool isPrimary = false,
    Color? accentColor,
    required VoidCallback onTap,
  }) {
    final col = isPrimary ? CapsuleColors.cyanGlow : (accentColor ?? CapsuleColors.electricBlue);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isPrimary ? CapsuleColors.electricBlue : CapsuleColors.cardOcean,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? CapsuleColors.cyanGlow : col.withValues(alpha: 0.65),
          width: isPrimary ? 2.0 : 1.3,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: CapsuleColors.cyanGlow.withValues(alpha: 0.35),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 5),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VictoryExplosionPainter extends CustomPainter {
  final double progress;

  _VictoryExplosionPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.45);
    final rand = math.Random(1337);

    // Blast rings
    for (int r = 0; r < 3; r++) {
      final ringProgress = (progress * 1.5 - r * 0.2).clamp(0.0, 1.0);
      final radius = ringProgress * (size.width * 0.45);
      final alpha = (1.0 - ringProgress).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = (r % 2 == 0 ? CapsuleColors.gold : CapsuleColors.cyanGlow)
              .withValues(alpha: alpha * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );
    }

    // Exploding star particles
    final sparkPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 70; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 80.0 + rand.nextDouble() * 320.0;
      final dist = progress * speed;
      final px = center.dx + math.cos(angle) * dist;
      final py = center.dy + math.sin(angle) * dist;

      final alpha = (1.0 - progress * 0.85).clamp(0.0, 1.0);
      final isGold = i % 3 == 0;
      final isCyan = i % 3 == 1;
      sparkPaint.color = (isGold
              ? CapsuleColors.gold
              : isCyan
                  ? CapsuleColors.cyanGlow
                  : CapsuleColors.purple)
          .withValues(alpha: alpha);
      canvas.drawCircle(Offset(px, py), 2.5 + rand.nextDouble() * 2.0, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VictoryExplosionPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _WeaponUnlockPreviewPainter extends CustomPainter {
  final double progress;
  final Color accent;

  const _WeaponUnlockPreviewPainter({
    required this.progress,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgRect = Offset.zero & size;
    canvas.drawRect(
      bgRect,
      Paint()..color = CapsuleColors.deepOcean.withValues(alpha: 0.92),
    );

    final cy = size.height * 0.5;
    // Mini medical capsule body firing animated projectiles
    final capsulePaint = Paint()..color = CapsuleColors.cyanGlow;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(15, cy), width: 16, height: 10),
        const Radius.circular(5),
      ),
      capsulePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(7, cy - 5, 8, 10),
        const Radius.circular(4),
      ),
      Paint()..color = accent,
    );

    // Animated flying dual beams + energy aura
    for (int i = 0; i < 2; i++) {
      final t = (progress + i * 0.5) % 1.0;
      final bx = 24.0 + t * (size.width - 28.0);
      final alpha = (1.0 - t * 0.7).clamp(0.0, 1.0);
      final beamPaint = Paint()
        ..color = CapsuleColors.gold.withValues(alpha: alpha)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(bx, cy - 4), Offset(bx + 7, cy - 4), beamPaint);
      canvas.drawLine(Offset(bx, cy + 4), Offset(bx + 7, cy + 4), beamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeaponUnlockPreviewPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}
