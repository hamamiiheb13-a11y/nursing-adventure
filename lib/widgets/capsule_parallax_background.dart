import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/capsule_theme.dart';

class CapsuleParallaxBackground extends StatefulWidget {
  final Widget? child;
  final bool showHeroCapsule;
  final bool showEnemySilhouettes;
  final double capsuleScale;
  final Offset? capsuleCenterFraction;

  const CapsuleParallaxBackground({
    super.key,
    this.child,
    this.showHeroCapsule = false,
    this.showEnemySilhouettes = true,
    this.capsuleScale = 1.0,
    this.capsuleCenterFraction,
  });

  @override
  State<CapsuleParallaxBackground> createState() => _CapsuleParallaxBackgroundState();
}

class _CapsuleParallaxBackgroundState extends State<CapsuleParallaxBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _StomachCosmicPainter(
                  progress: _controller.value,
                  showHeroCapsule: widget.showHeroCapsule,
                  showEnemySilhouettes: widget.showEnemySilhouettes,
                  capsuleScale: widget.capsuleScale,
                  capsuleFraction: widget.capsuleCenterFraction ?? const Offset(0.78, 0.45),
                ),
              );
            },
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _StomachCosmicPainter extends CustomPainter {
  final double progress;
  final bool showHeroCapsule;
  final bool showEnemySilhouettes;
  final double capsuleScale;
  final Offset capsuleFraction;

  _StomachCosmicPainter({
    required this.progress,
    required this.showHeroCapsule,
    required this.showEnemySilhouettes,
    required this.capsuleScale,
    required this.capsuleFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    // 1. Base deep space-like cosmic stomach background gradient
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          CapsuleColors.darkNavy,
          Color(0xFF0F172A),
          Color(0xFF1E1035), // Deep purple tint
          Color(0xFF2A0815), // Deep organic crimson
          CapsuleColors.darkNavy,
        ],
        stops: [0.0, 0.3, 0.6, 0.85, 1.0],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // 2. Pulsing Glow Spheres in the background
    final pulse1 = (math.sin(t * 1.5) + 1.0) * 0.5; // 0..1
    final pulse2 = (math.cos(t * 2.0) + 1.0) * 0.5;

    final glowPaint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          CapsuleColors.purple.withValues(alpha: 0.18 + 0.1 * pulse1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.25, size.height * 0.35),
        radius: size.width * 0.35,
      ));
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.35), size.width * 0.35, glowPaint1);

    final glowPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          CapsuleColors.cyanGlow.withValues(alpha: 0.12 + 0.08 * pulse2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.75, size.height * 0.65),
        radius: size.width * 0.4,
      ));
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.65), size.width * 0.4, glowPaint2);

    // 3. Floating particle system (small cosmic/digestive dots moving randomly)
    final rand = math.Random(42);
    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 45; i++) {
      final seedX = rand.nextDouble();
      final seedY = rand.nextDouble();
      final speed = 0.05 + rand.nextDouble() * 0.15;
      final sizeDot = 1.0 + rand.nextDouble() * 2.8;

      final px = (seedX * size.width + math.sin(t * speed * 3 + i) * 35.0) % size.width;
      final py = (seedY * size.height - progress * size.height * speed * 2 + size.height) % size.height;

      final alpha = (0.2 + 0.5 * math.sin(t + i)).clamp(0.15, 0.75);
      final isCyan = i % 2 == 0;
      particlePaint.color = (isCyan ? CapsuleColors.cyanGlow : CapsuleColors.turquoise).withValues(alpha: alpha);
      canvas.drawCircle(Offset(px, py), sizeDot, particlePaint);
    }

    // 4. Floating bubbles rising from bottom
    final bubblePaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2;
    for (int b = 0; b < 18; b++) {
      final bSeedX = rand.nextDouble();
      final bSeedY = rand.nextDouble();
      final bRadius = 5.0 + rand.nextDouble() * 14.0;
      final bSpeed = 0.2 + rand.nextDouble() * 0.4;

      final bx = (bSeedX * size.width + math.sin(t * 2.0 + b) * 25.0) % size.width;
      final by = (size.height - ((progress * bSpeed * size.height * 1.5 + bSeedY * size.height) % (size.height + 60))) - 20;

      final bAlpha = (0.15 + 0.25 * math.sin(t + b)).clamp(0.1, 0.45);
      bubblePaint.color = CapsuleColors.cyanGlow.withValues(alpha: bAlpha);
      canvas.drawCircle(Offset(bx, by), bRadius, bubblePaint);

      // Bubble highlight shine
      final shinePaint = Paint()..color = Colors.white.withValues(alpha: bAlpha * 0.7);
      canvas.drawCircle(Offset(bx - bRadius * 0.35, by - bRadius * 0.35), bRadius * 0.25, shinePaint);
    }

    // 5. Drifting Organic Cells (erythrocytes and biological vesicles)
    for (int c = 0; c < 14; c++) {
      final cSeedX = rand.nextDouble();
      final cSeedY = rand.nextDouble();
      final depth = 0.3 + rand.nextDouble() * 0.7;
      final cellR = (16.0 + rand.nextDouble() * 26.0) * depth;

      final cx = (cSeedX * size.width + progress * size.width * (0.2 + depth * 0.3)) % (size.width + 120) - 60;
      final cy = cSeedY * size.height + math.sin(t * 1.2 + c * 2.0) * 24.0;

      // Cell outer rim
      final cellPaint = Paint()
        ..color = Color(0xFFEF4444).withValues(alpha: 0.12 * depth)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), cellR, cellPaint);

      // Cell biconcave inner dent
      final dentPaint = Paint()
        ..color = Color(0xFF7F1D1D).withValues(alpha: 0.18 * depth)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), cellR * 0.48, dentPaint);

      // Subtle cyan bio-fluorescence border
      final rimPaint = Paint()
        ..color = CapsuleColors.purple.withValues(alpha: 0.15 * depth)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(Offset(cx, cy), cellR, rimPaint);
    }

    // 6. Stomach Peristaltic Wall Contours (Organic gastric ridges at top & bottom)
    _drawGastricWalls(canvas, size, t);

    // 7. Enemy silhouettes gliding in background
    if (showEnemySilhouettes) {
      _drawEnemySilhouettes(canvas, size, t);
    }

    // 8. Animated Hero Capsule
    if (showHeroCapsule) {
      final capX = size.width * capsuleFraction.dx;
      final capY = size.height * capsuleFraction.dy + math.sin(t * 1.5) * 16.0;
      _drawCapsuleHero(canvas, Offset(capX, capY), t, capsuleScale);
    }
  }

  void _drawGastricWalls(Canvas canvas, Size size, double t) {
    // Upper organic wall
    final topWall = Path()..moveTo(0, 0);
    topWall.lineTo(0, size.height * 0.12 + math.sin(t * 0.8) * 12.0);
    for (double x = 0; x <= size.width; x += 30) {
      final y = size.height * 0.11 +
          math.sin(t + x * 0.008) * 14.0 +
          math.cos(t * 0.5 + x * 0.015) * 8.0;
      topWall.lineTo(x, y);
    }
    topWall.lineTo(size.width, 0);
    topWall.close();

    final wallPaintTop = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF881337).withValues(alpha: 0.45),
          Color(0xFF4C0519).withValues(alpha: 0.20),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.2));
    canvas.drawPath(topWall, wallPaintTop);

    // Lower organic wall with subtle glowing gastric fluid edge
    final botWall = Path()..moveTo(0, size.height);
    botWall.lineTo(0, size.height * 0.88 + math.sin(t + 1.5) * 14.0);
    for (double x = 0; x <= size.width; x += 30) {
      final y = size.height * 0.89 +
          math.cos(t * 0.9 + x * 0.007) * 14.0 +
          math.sin(t * 0.4 + x * 0.014) * 8.0;
      botWall.lineTo(x, y);
    }
    botWall.lineTo(size.width, size.height);
    botWall.close();

    final wallPaintBot = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xFF4C0519).withValues(alpha: 0.5),
          Color(0xFF1E1035).withValues(alpha: 0.25),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2));
    canvas.drawPath(botWall, wallPaintBot);
  }

  void _drawEnemySilhouettes(Canvas canvas, Size size, double t) {
    // Enemy 1: Gliding Helicobacter flagella silhouette (top right drifting left)
    final e1X = ((size.width * 0.9 - progress * size.width * 0.4) % (size.width + 100)) - 50;
    final e1Y = size.height * 0.24 + math.sin(t * 2.0) * 18.0;
    _drawHelicoSilhouette(canvas, Offset(e1X, e1Y), t);

    // Enemy 2: Spiked virion floating (mid bottom left)
    final e2X = ((size.width * 0.15 + progress * size.width * 0.3) % (size.width + 100)) - 50;
    final e2Y = size.height * 0.72 + math.cos(t * 1.8) * 15.0;
    _drawVirionSilhouette(canvas, Offset(e2X, e2Y), t);

    // Enemy 3: Cytokine blob silhouette (distant background)
    final e3X = ((size.width * 0.5 + progress * size.width * 0.25) % (size.width + 100)) - 50;
    final e3Y = size.height * 0.40 + math.sin(t * 1.3) * 20.0;
    _drawBlobSilhouette(canvas, Offset(e3X, e3Y), t);
  }

  void _drawHelicoSilhouette(Canvas canvas, Offset pos, double t) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(0.2 + math.sin(t) * 0.1);

    final silPaint = Paint()
      ..color = CapsuleColors.purple.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    // Curved body
    final rect = Rect.fromLTWH(-28, -8, 56, 16);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), silPaint);

    // Trailing flagella tails
    final flagPaint = Paint()
      ..color = CapsuleColors.purple.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int f = 0; f < 3; f++) {
      final p = Path()..moveTo(28, (f - 1) * 5.0);
      p.quadraticBezierTo(
        42,
        (f - 1) * 8.0 + math.sin(t * 4.0 + f) * 10.0,
        60,
        (f - 1) * 6.0 + math.cos(t * 4.0 + f) * 12.0,
      );
      canvas.drawPath(p, flagPaint);
    }
    canvas.restore();
  }

  void _drawVirionSilhouette(Canvas canvas, Offset pos, double t) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(t * 0.8);

    final virPaint = Paint()
      ..color = CapsuleColors.dangerRed.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 18, virPaint);

    // Spikes
    final spikePaint = Paint()
      ..color = CapsuleColors.dangerOrange.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final x1 = math.cos(angle) * 18.0;
      final y1 = math.sin(angle) * 18.0;
      final x2 = math.cos(angle) * 28.0;
      final y2 = math.sin(angle) * 28.0;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), spikePaint);
      canvas.drawCircle(Offset(x2, y2), 2.5, Paint()..color = CapsuleColors.dangerOrange.withValues(alpha: 0.3));
    }
    canvas.restore();
  }

  void _drawBlobSilhouette(Canvas canvas, Offset pos, double t) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    final blobPaint = Paint()
      ..color = CapsuleColors.electricBlue.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final r = 20.0 + math.sin(t * 3.0 + i) * 6.0;
      final x = math.cos(angle) * r;
      final y = math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, blobPaint);
    canvas.restore();
  }

  void _drawCapsuleHero(Canvas canvas, Offset pos, double t, double scale) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);
    canvas.rotate(math.sin(t * 1.5) * 0.05);

    // 1. Forward scanning headlight beam
    final lightPath = Path()
      ..moveTo(30, -8)
      ..lineTo(180, -60)
      ..lineTo(180, 60)
      ..lineTo(30, 8)
      ..close();
    final lightPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          CapsuleColors.cyanGlow.withValues(alpha: 0.4),
          CapsuleColors.electricBlue.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(const Rect.fromLTWH(30, -60, 150, 120));
    canvas.drawPath(lightPath, lightPaint);

    // 2. Animated Propulsion Flame & Trail (orange/cyan plasma glow)
    final flamePulse = math.sin(t * 12.0) * 8.0;
    final flameOuter = Path()
      ..moveTo(-30, -10)
      ..lineTo(-75 + flamePulse * 1.5, 0)
      ..lineTo(-30, 10)
      ..close();
    canvas.drawPath(
      flameOuter,
      Paint()
        ..shader = const LinearGradient(
          colors: [CapsuleColors.dangerOrange, CapsuleColors.cyanGlow, Colors.transparent],
        ).createShader(const Rect.fromLTWH(-75, -12, 50, 24)),
    );

    final flameInner = Path()
      ..moveTo(-28, -5)
      ..lineTo(-55 + flamePulse, 0)
      ..lineTo(-28, 5)
      ..close();
    canvas.drawPath(
      flameInner,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );

    // Thruster exhaust particles
    for (int p = 0; p < 5; p++) {
      final pDist = 40.0 + (p * 18.0) + (t * 20.0) % 25.0;
      final pY = math.sin(t * 8.0 + p) * 6.0;
      canvas.drawCircle(
        Offset(-30 - pDist, pY),
        (3.5 - p * 0.5).clamp(1.0, 4.0),
        Paint()..color = CapsuleColors.cyanGlow.withValues(alpha: (0.7 - p * 0.12).clamp(0.1, 0.9)),
      );
    }

    // 3. Capsule Main Body (Futuristic Medical Pill: Front Cyan, Rear White/Silver)
    // Left half (Silver/White base)
    const bodyRect = Rect.fromLTWH(-32, -20, 64, 40);
    final rrect = RRect.fromRectAndRadius(bodyRect, const Radius.circular(20));

    // Outer glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-36, -24, 72, 48), const Radius.circular(24)),
      Paint()
        ..color = CapsuleColors.cyanGlow.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Body Gradient
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Color(0xFFE2E8F0),
          Color(0xFF94A3B8),
          Color(0xFF0F172A),
        ],
      ).createShader(bodyRect);
    canvas.drawRRect(rrect, bodyPaint);

    // Medical Front Shell (Electric Blue / Cyan Glow)
    final frontClip = Path()
      ..addRect(const Rect.fromLTWH(0, -22, 36, 44));
    canvas.save();
    canvas.clipPath(frontClip);
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = const LinearGradient(
          colors: [CapsuleColors.cyanGlow, CapsuleColors.electricBlue],
        ).createShader(bodyRect),
    );
    canvas.restore();

    // Center divider ring
    canvas.drawLine(
      const Offset(0, -20),
      const Offset(0, 20),
      Paint()
        ..color = CapsuleColors.darkNavy
        ..strokeWidth = 3.0,
    );

    // 4. Cockpit Visor / Glass Window
    const visorRect = Rect.fromLTWH(6, -11, 20, 22);
    final visorPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.white, CapsuleColors.cyanGlow, CapsuleColors.electricBlue],
      ).createShader(visorRect);
    canvas.drawOval(visorRect, visorPaint);

    // 5. Winglet Fins
    final topFin = Path()
      ..moveTo(-12, -20)
      ..lineTo(-22, -32)
      ..lineTo(-6, -20)
      ..close();
    canvas.drawPath(topFin, Paint()..color = CapsuleColors.electricBlue);

    final botFin = Path()
      ..moveTo(-12, 20)
      ..lineTo(-22, 32)
      ..lineTo(-6, 20)
      ..close();
    canvas.drawPath(botFin, Paint()..color = CapsuleColors.electricBlue);

    // 6. Laser Cannon Barrel
    final barrelRect = const Rect.fromLTWH(26, -3, 14, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barrelRect, const Radius.circular(2)),
      Paint()..color = const Color(0xFF64748B),
    );
    canvas.drawCircle(
      const Offset(40, 0),
      3,
      Paint()..color = CapsuleColors.cyanGlow,
    );

    // 7. Pulsing Energy Shield Bubble around Capsule
    final shieldPulse = (math.sin(t * 3.0) + 1.0) * 0.5;
    canvas.drawCircle(
      const Offset(2, 0),
      38 + shieldPulse * 4.0,
      Paint()
        ..color = CapsuleColors.cyanGlow.withValues(alpha: 0.15 + 0.1 * shieldPulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StomachCosmicPainter oldDelegate) => true;
}
