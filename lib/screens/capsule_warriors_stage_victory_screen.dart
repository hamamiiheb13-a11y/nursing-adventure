import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../models/gastro_world.dart';
import '../theme/capsule_theme.dart';

class CapsuleWarriorsStageVictoryScreen extends StatefulWidget {
  final int stageId;
  final int score;
  final int questionsCorrect;
  final int questionsTotal;
  final int deaths;
  final int collectibles;
  final int secondsElapsed;
  final String? unlockedWeapon;
  final VoidCallback onNextStage;
  final VoidCallback onReplay;
  final VoidCallback onStageMap;

  const CapsuleWarriorsStageVictoryScreen({
    super.key,
    required this.stageId,
    required this.score,
    this.questionsCorrect = 4,
    this.questionsTotal = 4,
    this.deaths = 0,
    this.collectibles = 15,
    this.secondsElapsed = 65,
    this.unlockedWeapon,
    required this.onNextStage,
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
  final AudioService _audio = AudioService();

  late final int _starsEarned;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Calculate stars:
    // 3 stars: >80% questions correct + no deaths
    // 2 stars: >60% correct OR 1-2 deaths
    // 1 star: completed but struggled
    final accuracy = widget.questionsTotal > 0
        ? (widget.questionsCorrect / widget.questionsTotal)
        : 1.0;
    if (accuracy >= 0.8 && widget.deaths == 0) {
      _starsEarned = 3;
    } else if (accuracy >= 0.6 || widget.deaths <= 2) {
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

    _audio.playStageComplete();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final world = GastroWorld.getWorldForLevel(widget.stageId);
    final weaponUnlocked = widget.unlockedWeapon ?? world.unlockedWeaponName;
    final earnedXp = _starsEarned * 100 + widget.questionsCorrect * 50;

    final media = MediaQuery.of(context);
    final isCompact = media.size.height < 520;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Spectacular Animated Particle Explosion Canvas
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

          // 2. Victory Modal Card
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: isCompact ? 10 : 20,
              ),
              child: Container(
                width: 520,
                padding: EdgeInsets.all(isCompact ? 18 : 26),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: CapsuleColors.gold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: CapsuleColors.gold.withValues(alpha: 0.35),
                      blurRadius: 36,
                      spreadRadius: 2,
                    ),
                    const BoxShadow(color: Colors.black, blurRadius: 28),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy Icon
                    const Icon(
                      Icons.military_tech_rounded,
                      color: CapsuleColors.gold,
                      size: 52,
                    ),
                    const SizedBox(height: 6),

                    // "MISSION ACCOMPLIE!" Title with glow
                    Text(
                      'MISSION ACCOMPLIE !',
                      style: GoogleFonts.orbitron(
                        fontSize: isCompact ? 20 : 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: CapsuleColors.gold.withValues(alpha: 0.9),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'STAGE ${widget.stageId} • ${world.name}',
                      style: GoogleFonts.inter(
                        color: world.primaryColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),

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
                                  size: 40,
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // Score Breakdown Stats Grid
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF030712).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('QUESTIONS', '${widget.questionsCorrect}/${widget.questionsTotal}', CapsuleColors.cyanGlow),
                          _buildStatItem('SCORE TOTAL', '${widget.score} PTS', CapsuleColors.gold),
                          _buildStatItem('XP GAGNÉS', '+$earnedXp XP', CapsuleColors.turquoise),
                          _buildStatItem('TEMPS', '${widget.secondsElapsed}s', Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Unlocked Weapon or Bonus Display (Animated Reveal)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CapsuleColors.purple.withValues(alpha: 0.3),
                            CapsuleColors.electricBlue.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: CapsuleColors.cyanGlow.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.flash_on_rounded, color: CapsuleColors.cyanGlow, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NOUVEL ARSENAL DÉBLOQUÉ !',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 10,
                                    color: CapsuleColors.cyanGlow,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  weaponUnlocked,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
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
                    const SizedBox(height: 18),

                    // Buttons: "STAGE SUIVANT" / "REJOUER" / "CARTE DES STAGES"
                    Row(
                      children: [
                        // STAGE SUIVANT (Primary)
                        Expanded(
                          flex: 3,
                          child: _buildActionButton(
                            label: widget.stageId < 7 ? 'STAGE SUIVANT' : 'RÉSULTATS FINAUX',
                            icon: Icons.arrow_forward_rounded,
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
                            accentColor: CapsuleColors.purple,
                            onTap: () {
                              _audio.playClick();
                              widget.onReplay();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // CARTE DES STAGES
                        Expanded(
                          flex: 2,
                          child: _buildActionButton(
                            label: 'CARTE',
                            icon: Icons.map_rounded,
                            accentColor: CapsuleColors.turquoise,
                            onTap: () {
                              _audio.playClick();
                              widget.onStageMap();
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
        color: isPrimary ? CapsuleColors.electricBlue : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? CapsuleColors.cyanGlow : col.withValues(alpha: 0.6),
          width: isPrimary ? 2.0 : 1.2,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
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
