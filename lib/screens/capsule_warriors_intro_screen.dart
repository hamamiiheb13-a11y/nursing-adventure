import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../models/game_progress.dart';
import '../theme/capsule_theme.dart';
import 'capsule_warriors_world_select_screen.dart';

class CapsuleWarriorsIntroScreen extends StatefulWidget {
  final GameProgress? progress;
  final VoidCallback? onContinue;

  const CapsuleWarriorsIntroScreen({
    super.key,
    this.progress,
    this.onContinue,
  });

  @override
  State<CapsuleWarriorsIntroScreen> createState() => _CapsuleWarriorsIntroScreenState();
}

class _CapsuleWarriorsIntroScreenState extends State<CapsuleWarriorsIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final AudioService _audio = AudioService();
  Timer? _failsafeTimer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Total sequence duration: 3.2 seconds (snappy launch) with automatic failsafe transition
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finishIntro();
      }
    });

    _animController.forward();
    // Failsafe guarantees player never remains stuck on intro even if browser throttles ticker
    _failsafeTimer = Timer(const Duration(milliseconds: 3600), _finishIntro);
  }

  @override
  void dispose() {
    _failsafeTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _finishIntro() {
    if (_finished || !mounted) return;
    _finished = true;
    _failsafeTimer?.cancel();
    _audio.playClick();

    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      Navigator.of(context).pushReplacement(
        buildCapsuleRoute(
          CapsuleWarriorsWorldSelectScreen(
            progress: widget.progress ?? GameProgress(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CapsuleColors.deepOcean,
      body: Stack(
        children: [
          // 1. Cinematic 2D Canvas Scene (GASTRO QUEST Logo + Animated Digestive Environment)
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _CinematicIntroPainter(progress: _animController.value),
                  );
                },
              ),
            ),
          ),

          // 2. Skip Button (Top Right) + Luminous Calibration Loading Bar (Bottom)
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: CapsuleColors.oceanSurface.withValues(alpha: 0.88),
                        foregroundColor: CapsuleColors.cyanGlow,
                        side: BorderSide(
                          color: CapsuleColors.cyanGlow.withValues(alpha: 0.65),
                          width: 1.3,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      icon: const Icon(Icons.fast_forward_rounded, size: 16),
                      label: Text(
                        'PASSER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      onPressed: _finishIntro,
                    ),
                  ),
                ),

                // Animated Loading & Capsule Calibration Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 22),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (context, _) {
                        final pct = (_animController.value * 100).clamp(0, 100).toInt();
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PRÉPARATION DU TRACTUS DIGESTIF...',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: CapsuleColors.textSubtle,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '$pct%',
                                  style: GoogleFonts.orbitron(
                                    color: CapsuleColors.gold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _animController.value.clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: CapsuleColors.oceanSurface,
                                valueColor: const AlwaysStoppedAnimation<Color>(CapsuleColors.cyanGlow),
                              ),
                            ),
                          ],
                        );
                      },
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
}

class _CinematicIntroPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 (over 4.2s)

  _CinematicIntroPainter({required this.progress});

  // Step ranges over 4.2s:
  // 0.0s -> 1.1s: Logo fades in smoothly with bio-particles & subtle capsule silhouette behind (never isolated!)
  // 1.1s -> 1.6s: Logo fades cleanly into Capsule awakening
  // 1.6s -> 2.1s: Propulsion lights up (orange/cyan energy trail)
  // 2.1s -> 2.9s: Capsule glides right as digestive mucosal walls slide in
  // 2.9s -> 3.6s: Pathogen appears, capsule fires laser, pathogen bursts cleanly
  // 3.6s -> 4.2s: "LA MISSION COMMENCE..." & smooth oceanic wipe transition

  @override
  void paint(Canvas canvas, Size size) {
    // Luminous ocean-teal biological backdrop
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          CapsuleColors.deepOcean,
          CapsuleColors.oceanSurface,
          Color(0xFF154E70),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle continuous floating bio-bubbles throughout intro (never a frozen flat screen)
    final bubblePaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2;
    for (int i = 0; i < 10; i++) {
      final bx = size.width * ((0.08 + i * 0.11 + progress * 0.14) % 1.0);
      final by = size.height * ((0.85 - i * 0.08 - progress * 0.35 + 1.0) % 1.0);
      bubblePaint.color = CapsuleColors.cyanGlow.withValues(alpha: 0.22);
      canvas.drawCircle(Offset(bx, by), 5.0 + (i % 4) * 3.0, bubblePaint);
    }

    final t = progress * 4.2;

    if (t < 1.6) {
      _paintStep1And2(canvas, size, t);
    } else if (t < 2.1) {
      _paintStep3(canvas, size, t);
    } else if (t < 2.9) {
      _paintStep4(canvas, size, t);
    } else if (t < 3.6) {
      _paintStep5(canvas, size, t);
    } else if (t < 4.0) {
      _paintStep6(canvas, size, t);
    } else {
      _paintStep7(canvas, size, t);
    }
  }

  void _paintStep1And2(Canvas canvas, Size size, double t) {
    // 0.0s -> 1.1s: Logo reveal with energetic particles
    // 1.1s -> 1.6s: Logo fades out smoothly while powered-down capsule fades in
    double logoAlpha = 0.0;
    if (t <= 0.45) {
      logoAlpha = (t / 0.45).clamp(0.0, 1.0);
    } else if (t <= 1.15) {
      logoAlpha = 1.0;
    } else {
      logoAlpha = (1.0 - (t - 1.15) / 0.45).clamp(0.0, 1.0);
    }

    if (logoAlpha > 0.01) {
      final pProgress = (t / 1.4).clamp(0.0, 1.0);
      final rand = math.Random(101);
      final burstPaint = Paint()..style = PaintingStyle.fill;
      for (int i = 0; i < 28; i++) {
        final angle = rand.nextDouble() * math.pi * 2;
        final speed = 70.0 + rand.nextDouble() * 170.0;
        final dist = pProgress * speed;
        final px = size.width / 2 + math.cos(angle) * dist;
        final py = size.height / 2 + math.sin(angle) * dist;
        final r = (3.4 - pProgress * 1.8).clamp(1.0, 4.0);

        final pAlpha = (logoAlpha * (1.0 - pProgress * 0.65)).clamp(0.0, 1.0);
        burstPaint.color = (i % 2 == 0 ? CapsuleColors.cyanGlow : CapsuleColors.turquoise)
            .withValues(alpha: pAlpha);
        canvas.drawCircle(Offset(px, py), r, burstPaint);
      }

      // Animated subtle capsule silhouette gliding softly during logo phase
      _drawCapsuleBody(
        canvas,
        Offset(size.width * (0.14 + (t / 1.6) * 0.06), size.height * 0.5),
        poweredOn: t > 0.9,
        thrusterIntensity: t > 0.9 ? ((t - 0.9) / 0.7).clamp(0.0, 0.5) : 0.0,
        alpha: 0.35 + 0.65 * ((t - 1.0) / 0.6).clamp(0.0, 1.0),
      );

      final titleSpan = TextSpan(
        text: 'GASTRO QUEST',
        style: GoogleFonts.orbitron(
          fontSize: (size.width < 600 ? 28.0 : 44.0),
          fontWeight: FontWeight.w900,
          letterSpacing: 3.5,
          color: Colors.white.withValues(alpha: logoAlpha),
          shadows: [
            Shadow(
              color: CapsuleColors.cyanGlow.withValues(alpha: logoAlpha),
              blurRadius: 14,
            ),
          ],
        ),
      );
      final tp = TextPainter(
        text: titleSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));
    } else {
      final capPos = Offset(size.width * 0.2, size.height * 0.5);
      _drawCapsuleBody(canvas, capPos, poweredOn: false, alpha: 1.0);
    }
  }

  void _paintStep3(Canvas canvas, Size size, double t) {
    final stepProgress = ((t - 1.6) / 0.5).clamp(0.0, 1.0);
    final capPos = Offset(size.width * 0.2, size.height * 0.5);

    _drawCapsuleBody(canvas, capPos, poweredOn: true, thrusterIntensity: stepProgress, alpha: 1.0);

    canvas.drawCircle(
      Offset(capPos.dx - 30, capPos.dy),
      35 * stepProgress,
      Paint()
        ..shader = RadialGradient(
          colors: [
            CapsuleColors.dangerOrange.withValues(alpha: 0.5 * stepProgress),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(capPos.dx - 30, capPos.dy), radius: math.max(1.0, 35 * stepProgress))),
    );
  }

  void _paintStep4(Canvas canvas, Size size, double t) {
    final stepProgress = ((t - 2.1) / 0.8).clamp(0.0, 1.0);
    _drawSlidingStomachWalls(canvas, size, stepProgress);

    final curX = size.width * (0.2 + 0.25 * Curves.easeInOut.transform(stepProgress));
    final curY = size.height * 0.5 + math.sin(stepProgress * math.pi * 3) * 8.0;
    _drawCapsuleBody(canvas, Offset(curX, curY), poweredOn: true, thrusterIntensity: 1.0, alpha: 1.0);
  }

  void _paintStep5(Canvas canvas, Size size, double t) {
    final stepProgress = ((t - 2.9) / 0.7).clamp(0.0, 1.0);
    _drawSlidingStomachWalls(canvas, size, 1.0);

    final capPos = Offset(size.width * 0.45, size.height * 0.5);
    _drawCapsuleBody(canvas, capPos, poweredOn: true, thrusterIntensity: 1.0, alpha: 1.0);

    final enemyPos = Offset(size.width * 0.78, size.height * 0.5);

    if (stepProgress < 0.55) {
      final enemyAlpha = (stepProgress / 0.2).clamp(0.0, 1.0);
      _drawEnemy(canvas, enemyPos, enemyAlpha);
    }

    if (stepProgress >= 0.30 && stepProgress <= 0.60) {
      final laserP = ((stepProgress - 0.30) / 0.25).clamp(0.0, 1.0);
      final lx1 = capPos.dx + 30;
      final lx2 = lx1 + (enemyPos.dx - lx1) * laserP;
      canvas.drawLine(
        Offset(lx1, capPos.dy),
        Offset(lx2, capPos.dy),
        Paint()
          ..color = CapsuleColors.electricBlue.withValues(alpha: 0.45)
          ..strokeWidth = 9.0
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(lx1, capPos.dy),
        Offset(lx2, capPos.dy),
        Paint()
          ..color = CapsuleColors.cyanGlow
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round,
      );
    }

    if (stepProgress > 0.55) {
      final expProgress = ((stepProgress - 0.55) / 0.45).clamp(0.0, 1.0);
      _drawExplosion(canvas, enemyPos, expProgress);
    }
  }

  void _paintStep6(Canvas canvas, Size size, double t) {
    final stepProgress = ((t - 3.6) / 0.4).clamp(0.0, 1.0);
    _drawSlidingStomachWalls(canvas, size, 1.0);

    final capX = size.width * (0.45 + 0.15 * stepProgress);
    _drawCapsuleBody(canvas, Offset(capX, size.height * 0.5), poweredOn: true, thrusterIntensity: 1.0, alpha: 1.0);

    final textAlpha = Curves.easeOut.transform(stepProgress);
    final textOffset = (1.0 - textAlpha) * 32.0;

    final missionSpan = TextSpan(
      text: 'LA MISSION COMMENCE...',
      style: GoogleFonts.orbitron(
        fontSize: size.width < 600 ? 22.0 : 36.0,
        fontWeight: FontWeight.w900,
        letterSpacing: 3.5,
        color: CapsuleColors.turquoise.withValues(alpha: textAlpha),
        shadows: [
          Shadow(
            color: CapsuleColors.cyanGlow.withValues(alpha: textAlpha),
            blurRadius: 16,
          ),
        ],
      ),
    );
    final tp = TextPainter(
      text: missionSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, size.height * 0.7 - textOffset),
    );
  }

  void _paintStep7(Canvas canvas, Size size, double t) {
    final stepProgress = ((t - 4.0) / 0.2).clamp(0.0, 1.0);

    _drawSlidingStomachWalls(canvas, size, 1.0);
    _drawCapsuleBody(canvas, Offset(size.width * 0.65, size.height * 0.5), poweredOn: true, thrusterIntensity: 1.0, alpha: 1.0);

    final wipePaint = Paint()..color = CapsuleColors.deepOcean.withValues(alpha: stepProgress * 0.85);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), wipePaint);

    final lineX = size.width * stepProgress;
    canvas.drawLine(
      Offset(lineX, 0),
      Offset(lineX, size.height),
      Paint()
        ..color = CapsuleColors.cyanGlow.withValues(alpha: (1.0 - stepProgress) * 0.75)
        ..strokeWidth = 5.0,
    );
  }

  void _drawSlidingStomachWalls(Canvas canvas, Size size, double progress) {
    final topY = size.height * 0.16 * progress;
    final botY = size.height - (size.height * 0.16 * progress);

    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, topY)
      ..quadraticBezierTo(size.width * 0.5, topY + 15 * math.sin(progress * 3), size.width, topY)
      ..lineTo(size.width, 0)
      ..close();

    final botPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, botY)
      ..quadraticBezierTo(size.width * 0.5, botY - 15 * math.sin(progress * 3), size.width, botY)
      ..lineTo(size.width, size.height)
      ..close();

    final wallPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFB7185), Color(0xFFBE185D)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(topPath, wallPaint);
    canvas.drawPath(botPath, wallPaint);
  }

  void _drawCapsuleBody(
    Canvas canvas,
    Offset pos, {
    required bool poweredOn,
    double thrusterIntensity = 0.0,
    required double alpha,
  }) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    // Propulsion Trail
    if (poweredOn && thrusterIntensity > 0) {
      final trailLength = 55.0 * thrusterIntensity;
      final trailPath = Path()
        ..moveTo(-26, -8)
        ..lineTo(-26 - trailLength, 0)
        ..lineTo(-26, 8)
        ..close();
      canvas.drawPath(
        trailPath,
        Paint()
          ..shader = LinearGradient(
            colors: [
              CapsuleColors.dangerOrange.withValues(alpha: alpha * thrusterIntensity),
              CapsuleColors.cyanGlow.withValues(alpha: alpha * thrusterIntensity * 0.6),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(-26 - trailLength, -8, trailLength, 16)),
      );
    }

    // Pill Body
    const bodyRect = Rect.fromLTWH(-26, -16, 52, 32);
    final rrect = RRect.fromRectAndRadius(bodyRect, const Radius.circular(16));

    final basePaint = Paint()
      ..color = (poweredOn ? const Color(0xFFCBD5E1) : const Color(0xFF475569))
          .withValues(alpha: alpha);
    canvas.drawRRect(rrect, basePaint);

    if (poweredOn) {
      // Front half cyan
      canvas.save();
      canvas.clipRect(const Rect.fromLTWH(0, -16, 26, 32));
      canvas.drawRRect(
        rrect,
        Paint()..color = CapsuleColors.cyanGlow.withValues(alpha: alpha),
      );
      canvas.restore();
    }

    // Visor
    final visorPaint = Paint()
      ..color = (poweredOn ? CapsuleColors.electricBlue : const Color(0xFF334155))
          .withValues(alpha: alpha);
    canvas.drawOval(const Rect.fromLTWH(4, -8, 14, 16), visorPaint);

    canvas.restore();
  }

  void _drawEnemy(Canvas canvas, Offset pos, double alpha) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    final enemyPaint = Paint()..color = CapsuleColors.dangerRed.withValues(alpha: alpha);
    canvas.drawCircle(Offset.zero, 20, enemyPaint);

    // Spikes
    final spikePaint = Paint()
      ..color = CapsuleColors.dangerOrange.withValues(alpha: alpha)
      ..strokeWidth = 2.5;
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      canvas.drawLine(
        Offset(math.cos(angle) * 20, math.sin(angle) * 20),
        Offset(math.cos(angle) * 28, math.sin(angle) * 28),
        spikePaint,
      );
    }
    canvas.restore();
  }

  void _drawExplosion(Canvas canvas, Offset pos, double expProgress) {
    // Expanding blast shockwave
    final radius = expProgress * 65.0;
    final expAlpha = (1.0 - expProgress).clamp(0.0, 1.0);

    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = CapsuleColors.dangerOrange.withValues(alpha: expAlpha * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );

    // Particle debris
    final rand = math.Random(77);
    final sparkPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 24; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 40.0 + rand.nextDouble() * 90.0;
      final dist = expProgress * speed;
      final px = pos.dx + math.cos(angle) * dist;
      final py = pos.dy + math.sin(angle) * dist;

      sparkPaint.color = (i % 2 == 0 ? CapsuleColors.gold : CapsuleColors.dangerRed)
          .withValues(alpha: expAlpha);
      canvas.drawCircle(Offset(px, py), 2.5 * (1.0 - expProgress * 0.5), sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CinematicIntroPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
