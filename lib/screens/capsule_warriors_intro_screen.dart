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
  bool _finished = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Total sequence duration: 6.1 seconds
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6100),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finishIntro();
      }
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _finishIntro() {
    if (_finished) return;
    _finished = true;
    _audio.playClick();

    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CapsuleWarriorsWorldSelectScreen(
            progress: widget.progress ?? GameProgress(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Cinematic 2D Canvas Scene (7 Animated Steps)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _CinematicIntroPainter(progress: _animController.value),
                );
              },
            ),
          ),

          // 2. Skip Button (Top Right, Always Visible)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.75),
                    foregroundColor: CapsuleColors.cyanGlow,
                    side: BorderSide(
                      color: CapsuleColors.cyanGlow.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  icon: const Icon(Icons.fast_forward_rounded, size: 16),
                  label: Text(
                    'PASSER',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  onPressed: _finishIntro,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CinematicIntroPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 (over 6.1s)

  _CinematicIntroPainter({required this.progress});

  // Step ranges:
  // 1: 0.000 -> 0.246 (1.5s): Black screen -> Logo fades in with particle burst
  // 2: 0.246 -> 0.377 (0.8s): Logo fades out -> Capsule appears powered down
  // 3: 0.377 -> 0.459 (0.5s): Propulsion lights up: orange glow trail
  // 4: 0.459 -> 0.623 (1.0s): Capsule moves right, stomach walls slide in
  // 5: 0.623 -> 0.787 (1.0s): Enemy appears, capsule fires, enemy explodes
  // 6: 0.787 -> 0.918 (0.8s): "LA MISSION COMMENCE..." slides in
  // 7: 0.918 -> 1.000 (0.5s): Transition wipe

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

    final t = progress * 6.1; // Elapsed seconds

    if (t < 2.3) {
      _paintStep1And2(canvas, size, t);
    } else if (t < 2.8) {
      _paintStep3(canvas, size, t);
    } else if (t < 3.8) {
      _paintStep4(canvas, size, t);
    } else if (t < 4.8) {
      _paintStep5(canvas, size, t);
    } else if (t < 5.6) {
      _paintStep6(canvas, size, t);
    } else {
      _paintStep7(canvas, size, t);
    }
  }

  void _paintStep1And2(Canvas canvas, Size size, double t) {
    // 0.0s to 1.5s: Logo fades in with particle burst.
    // 1.5s to 2.3s: Logo fades out, capsule appears at left powered down.
    double logoAlpha = 0.0;
    if (t <= 1.2) {
      logoAlpha = (t / 1.0).clamp(0.0, 1.0);
    } else if (t <= 1.5) {
      logoAlpha = 1.0;
    } else {
      logoAlpha = (1.0 - (t - 1.5) / 0.8).clamp(0.0, 1.0);
    }

    if (logoAlpha > 0.01) {
      // Particle burst behind logo
      final pProgress = (t / 1.8).clamp(0.0, 1.0);
      final rand = math.Random(101);
      final burstPaint = Paint()..style = PaintingStyle.fill;
      for (int i = 0; i < 40; i++) {
        final angle = rand.nextDouble() * math.pi * 2;
        final speed = 80.0 + rand.nextDouble() * 180.0;
        final dist = pProgress * speed;
        final px = size.width / 2 + math.cos(angle) * dist;
        final py = size.height / 2 + math.sin(angle) * dist;
        final r = (3.5 - pProgress * 2.0).clamp(1.0, 4.0);

        final pAlpha = (logoAlpha * (1.0 - pProgress * 0.7)).clamp(0.0, 1.0);
        burstPaint.color = (i % 2 == 0 ? CapsuleColors.cyanGlow : CapsuleColors.turquoise)
            .withValues(alpha: pAlpha);
        canvas.drawCircle(Offset(px, py), r, burstPaint);
      }

      // Draw "CAPSULE WARRIORS" Title
      final titleSpan = TextSpan(
        text: 'CAPSULE WARRIORS',
        style: GoogleFonts.orbitron(
          fontSize: (size.width < 600 ? 28.0 : 44.0),
          fontWeight: FontWeight.w900,
          letterSpacing: 4.0,
          color: Colors.white.withValues(alpha: logoAlpha),
          shadows: [
            Shadow(
              color: CapsuleColors.cyanGlow.withValues(alpha: logoAlpha),
              blurRadius: 24,
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
    }

    // Logo fading out, capsule appears at left powered down (t in 1.5 -> 2.3)
    if (t > 1.5) {
      final capAlpha = ((t - 1.5) / 0.8).clamp(0.0, 1.0);
      final capPos = Offset(size.width * 0.2, size.height * 0.5);
      _drawCapsuleBody(canvas, capPos, poweredOn: false, alpha: capAlpha);
    }
  }

  void _paintStep3(Canvas canvas, Size size, double t) {
    // 2.3s -> 2.8s: Propulsion lights up: orange glow trail appears
    final stepProgress = ((t - 2.3) / 0.5).clamp(0.0, 1.0);
    final capPos = Offset(size.width * 0.2, size.height * 0.5);

    // Thruster ignition flash
    _drawCapsuleBody(canvas, capPos, poweredOn: true, thrusterIntensity: stepProgress, alpha: 1.0);

    // Flash glow
    canvas.drawCircle(
      Offset(capPos.dx - 30, capPos.dy),
      35 * stepProgress,
      Paint()
        ..color = CapsuleColors.dangerOrange.withValues(alpha: 0.4 * stepProgress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
  }

  void _paintStep4(Canvas canvas, Size size, double t) {
    // 2.8s -> 3.8s: Capsule starts moving right, stomach walls slide in from edges
    final stepProgress = ((t - 2.8) / 1.0).clamp(0.0, 1.0);

    // Stomach walls slide in from top and bottom
    _drawSlidingStomachWalls(canvas, size, stepProgress);

    // Capsule moves from 0.2 to 0.45 width
    final curX = size.width * (0.2 + 0.25 * Curves.easeInOut.transform(stepProgress));
    final curY = size.height * 0.5 + math.sin(stepProgress * math.pi * 3) * 8.0;
    _drawCapsuleBody(canvas, Offset(curX, curY), poweredOn: true, thrusterIntensity: 1.0, alpha: 1.0);
  }

  void _paintStep5(Canvas canvas, Size size, double t) {
    // 3.8s -> 4.8s: First enemy appears on right, capsule fires, enemy explodes
    final stepProgress = ((t - 3.8) / 1.0).clamp(0.0, 1.0);

    // Stomach walls visible
    _drawSlidingStomachWalls(canvas, size, 1.0);

    final capPos = Offset(size.width * 0.45, size.height * 0.5);
    _drawCapsuleBody(canvas, capPos, poweredOn: true, thrusterIntensity: 1.0, alpha: 1.0);

    final enemyPos = Offset(size.width * 0.78, size.height * 0.5);

    // Sub-phases:
    // 0.0 -> 0.35: Enemy enters from right
    // 0.35 -> 0.55: Laser shoots from capsule to enemy
    // 0.55 -> 1.00: Enemy explodes into shockwave and sparks!
    if (stepProgress < 0.55) {
      final enemyAlpha = (stepProgress / 0.2).clamp(0.0, 1.0);
      _drawEnemy(canvas, enemyPos, enemyAlpha);
    }

    if (stepProgress >= 0.30 && stepProgress <= 0.60) {
      // Laser beam flying
      final laserP = ((stepProgress - 0.30) / 0.25).clamp(0.0, 1.0);
      final lx1 = capPos.dx + 30;
      final lx2 = lx1 + (enemyPos.dx - lx1) * laserP;
      final laserPaint = Paint()
        ..color = CapsuleColors.cyanGlow
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(lx1, capPos.dy), Offset(lx2, capPos.dy), laserPaint);

      // Glow around beam
      canvas.drawLine(
        Offset(lx1, capPos.dy),
        Offset(lx2, capPos.dy),
        Paint()
          ..color = CapsuleColors.electricBlue.withValues(alpha: 0.6)
          ..strokeWidth = 8.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    if (stepProgress > 0.55) {
      // Enemy explosion
      final expProgress = ((stepProgress - 0.55) / 0.45).clamp(0.0, 1.0);
      _drawExplosion(canvas, enemyPos, expProgress);
    }
  }

  void _paintStep6(Canvas canvas, Size size, double t) {
    // 4.8s -> 5.6s: Text: "LA MISSION COMMENCE..." slides in
    final stepProgress = ((t - 4.8) / 0.8).clamp(0.0, 1.0);

    _drawSlidingStomachWalls(canvas, size, 1.0);

    // Capsule continues gliding
    final capX = size.width * (0.45 + 0.15 * stepProgress);
    _drawCapsuleBody(canvas, Offset(capX, size.height * 0.5), poweredOn: true, thrusterIntensity: 1.0, alpha: 1.0);

    // Text slides in with glow
    final textAlpha = Curves.easeOut.transform(stepProgress);
    final textOffset = (1.0 - textAlpha) * 40.0;

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
            blurRadius: 20,
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
    // 5.6s -> 6.1s: Transition wipe (iris wipe / cyan curtain)
    final stepProgress = ((t - 5.6) / 0.5).clamp(0.0, 1.0);

    _drawSlidingStomachWalls(canvas, size, 1.0);
    _drawCapsuleBody(canvas, Offset(size.width * 0.65, size.height * 0.5), poweredOn: true, thrusterIntensity: 1.0, alpha: 1.0);

    // Fullscreen Wipe Overlay
    final wipePaint = Paint()..color = CapsuleColors.deepOcean.withValues(alpha: stepProgress);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), wipePaint);

    // Cyan wipe scanline
    final lineX = size.width * stepProgress;
    canvas.drawLine(
      Offset(lineX, 0),
      Offset(lineX, size.height),
      Paint()
        ..color = CapsuleColors.cyanGlow.withValues(alpha: (1.0 - stepProgress) * 0.8)
        ..strokeWidth = 6.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
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
