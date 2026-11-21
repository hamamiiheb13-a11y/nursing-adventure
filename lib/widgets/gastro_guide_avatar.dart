import 'dart:math' as math;
import 'package:flutter/material.dart';

enum GuideMood {
  neutral,
  happy,
  teaching,
  encouraging,
  celebrating,
}

class GastroGuideAvatar extends StatefulWidget {
  final double size;
  final GuideMood mood;
  final bool animate;
  final VoidCallback? onTap;

  const GastroGuideAvatar({
    super.key,
    this.size = 120,
    this.mood = GuideMood.neutral,
    this.animate = true,
    this.onTap,
  });

  @override
  State<GastroGuideAvatar> createState() => _GastroGuideAvatarState();
}

class _GastroGuideAvatarState extends State<GastroGuideAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.animate) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant GastroGuideAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_animController.isAnimating) {
      _animController.repeat(reverse: true);
    } else if (!widget.animate && _animController.isAnimating) {
      _animController.stop();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final floatOffset = widget.animate
              ? math.sin(_animController.value * math.pi) * 4.0
              : 0.0;
          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _DoctorPainter(
                  mood: widget.mood,
                  animProgress: _animController.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DoctorPainter extends CustomPainter {
  final GuideMood mood;
  final double animProgress;

  _DoctorPainter({
    required this.mood,
    required this.animProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer Aura / Glow
    final glowPaint = Paint()
      ..color = _getMoodGlowColor().withOpacity(0.25 + 0.15 * math.sin(animProgress * math.pi))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(center, radius * 0.92, glowPaint);

    // Background Circle with Gradient
    final bgGradient = RadialGradient(
      colors: [
        const Color(0xFF142948),
        const Color(0xFF071224),
      ],
      stops: const [0.6, 1.0],
    );
    final bgPaint = Paint()
      ..shader = bgGradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius * 0.92, bgPaint);

    // Border Ring
    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00E5FF),
          _getMoodGlowColor(),
          const Color(0xFF00E5FF).withOpacity(0.3),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, radius * 0.92, borderPaint);

    // Clip to circle for doctor illustration
    canvas.save();
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius * 0.89));
    canvas.clipPath(clipPath);

    // Doctor Body & Medical Coat (White with Cyan Accents)
    final coatPaint = Paint()..color = const Color(0xFFF1F5F9);
    final coatShadow = Paint()..color = const Color(0xFFCBD5E1);
    final scrubPaint = Paint()..color = const Color(0xFF0284C7); // Medical Teal Scrub

    // Neck & Face Base
    final skinPaint = Paint()..color = const Color(0xFFFFDBAC);
    final skinShadow = Paint()..color = const Color(0xFFF1C27D);

    // Scrub V-neck
    final scrubPath = Path();
    scrubPath.moveTo(size.width * 0.35, size.height * 0.70);
    scrubPath.lineTo(size.width * 0.50, size.height * 0.88);
    scrubPath.lineTo(size.width * 0.65, size.height * 0.70);
    scrubPath.lineTo(size.width * 0.65, size.height);
    scrubPath.lineTo(size.width * 0.35, size.height);
    scrubPath.close();
    canvas.drawPath(scrubPath, scrubPaint);

    // White Lab Coat (Shoulders & Lapels)
    final leftCoat = Path();
    leftCoat.moveTo(0, size.height * 0.82);
    leftCoat.lineTo(size.width * 0.38, size.height * 0.68);
    leftCoat.lineTo(size.width * 0.45, size.height * 0.95);
    leftCoat.lineTo(size.width * 0.32, size.height);
    leftCoat.lineTo(0, size.height);
    leftCoat.close();
    canvas.drawPath(leftCoat, coatPaint);

    final rightCoat = Path();
    rightCoat.moveTo(size.width, size.height * 0.82);
    rightCoat.lineTo(size.width * 0.62, size.height * 0.68);
    rightCoat.lineTo(size.width * 0.55, size.height * 0.95);
    rightCoat.lineTo(size.width * 0.68, size.height);
    rightCoat.lineTo(size.width, size.height);
    rightCoat.close();
    canvas.drawPath(rightCoat, coatPaint);

    // Lapel shadows
    final lapelShadow = Path();
    lapelShadow.moveTo(size.width * 0.38, size.height * 0.68);
    lapelShadow.lineTo(size.width * 0.44, size.height * 0.95);
    lapelShadow.lineTo(size.width * 0.40, size.height * 0.95);
    lapelShadow.close();
    canvas.drawPath(lapelShadow, coatShadow);

    // Stethoscope (Cyan Tubing around Neck)
    final stethoPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    final stethoPath = Path();
    stethoPath.moveTo(size.width * 0.36, size.height * 0.70);
    stethoPath.cubicTo(
      size.width * 0.34, size.height * 0.90,
      size.width * 0.54, size.height * 0.96,
      size.width * 0.52, size.height * 0.86,
    );
    canvas.drawPath(stethoPath, stethoPaint);

    // Stethoscope Bell (Metallic Gold & Silver)
    final bellPaint = Paint()..color = const Color(0xFFFFD166);
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.86), size.width * 0.045, bellPaint);
    final bellInner = Paint()..color = const Color(0xFF0A1F38);
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.86), size.width * 0.025, bellInner);

    // Neck
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.62),
        width: size.width * 0.22,
        height: size.height * 0.18,
      ),
      skinPaint,
    );

    // Head / Face
    final faceRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.44),
      width: size.width * 0.46,
      height: size.height * 0.48,
    );
    canvas.drawOval(faceRect, skinPaint);

    // Ears
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.26, size.height * 0.45),
        width: size.width * 0.09,
        height: size.height * 0.14,
      ),
      skinPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.74, size.height * 0.45),
        width: size.width * 0.09,
        height: size.height * 0.14,
      ),
      skinPaint,
    );

    // Modern Hair (Dark Brown / Styled)
    final hairPaint = Paint()..color = const Color(0xFF2C1810);
    final hairPath = Path();
    hairPath.moveTo(size.width * 0.24, size.height * 0.42);
    hairPath.cubicTo(
      size.width * 0.22, size.height * 0.20,
      size.width * 0.38, size.height * 0.12,
      size.width * 0.52, size.height * 0.14,
    );
    hairPath.cubicTo(
      size.width * 0.70, size.height * 0.12,
      size.width * 0.80, size.height * 0.26,
      size.width * 0.76, size.height * 0.42,
    );
    hairPath.lineTo(size.width * 0.68, size.height * 0.32);
    hairPath.lineTo(size.width * 0.54, size.height * 0.28);
    hairPath.lineTo(size.width * 0.38, size.height * 0.32);
    hairPath.close();
    canvas.drawPath(hairPath, hairPaint);

    // Glasses (Smart Medical Look)
    final glassFrame = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final glassLens = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.12);

    final leftGlass = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.40, size.height * 0.42),
        width: size.width * 0.15,
        height: size.height * 0.12,
      ),
      const Radius.circular(6),
    );
    final rightGlass = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.60, size.height * 0.42),
        width: size.width * 0.15,
        height: size.height * 0.12,
      ),
      const Radius.circular(6),
    );

    canvas.drawRRect(leftGlass, glassLens);
    canvas.drawRRect(rightGlass, glassLens);
    canvas.drawRRect(leftGlass, glassFrame);
    canvas.drawRRect(rightGlass, glassFrame);

    // Bridge of glasses
    canvas.drawLine(
      Offset(size.width * 0.475, size.height * 0.42),
      Offset(size.width * 0.525, size.height * 0.42),
      glassFrame,
    );

    // Eyes (Animated based on Mood)
    _drawEyes(canvas, size);

    // Smile / Mouth based on mood
    _drawMouth(canvas, size);

    // Cheeks glow
    final blushPaint = Paint()
      ..color = const Color(0xFFFF85A1).withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.49), size.width * 0.04, blushPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.49), size.width * 0.04, blushPaint);

    // Medical Cap Cross Badge (Top)
    final badgePaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.22), size.width * 0.05, badgePaint);
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.19),
      Offset(size.width * 0.5, size.height * 0.25),
      crossPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.47, size.height * 0.22),
      Offset(size.width * 0.53, size.height * 0.22),
      crossPaint,
    );

    canvas.restore();
  }

  void _drawEyes(Canvas canvas, Size size) {
    final eyePaint = Paint()..color = const Color(0xFF1E293B);
    final eyeHighlight = Paint()..color = Colors.white;

    if (mood == GuideMood.happy || mood == GuideMood.celebrating) {
      // Arc eyes (happy closed smile)
      final happyEyePaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size.width * 0.40, size.height * 0.42),
          width: size.width * 0.08,
          height: size.height * 0.06,
        ),
        math.pi,
        math.pi,
        false,
        happyEyePaint,
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size.width * 0.60, size.height * 0.42),
          width: size.width * 0.08,
          height: size.height * 0.06,
        ),
        math.pi,
        math.pi,
        false,
        happyEyePaint,
      );
    } else {
      // Open alert eyes
      canvas.drawCircle(Offset(size.width * 0.40, size.height * 0.42), size.width * 0.032, eyePaint);
      canvas.drawCircle(Offset(size.width * 0.60, size.height * 0.42), size.width * 0.032, eyePaint);

      // Sparkle reflection
      canvas.drawCircle(Offset(size.width * 0.39, size.height * 0.41), size.width * 0.012, eyeHighlight);
      canvas.drawCircle(Offset(size.width * 0.59, size.height * 0.41), size.width * 0.012, eyeHighlight);
    }
  }

  void _drawMouth(Canvas canvas, Size size) {
    final mouthPaint = Paint()
      ..color = const Color(0xFFE11D48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    if (mood == GuideMood.celebrating || mood == GuideMood.happy) {
      // Big open smile
      final openMouth = Path();
      openMouth.moveTo(size.width * 0.44, size.height * 0.51);
      openMouth.quadraticBezierTo(
        size.width * 0.50, size.height * 0.57,
        size.width * 0.56, size.height * 0.51,
      );
      openMouth.close();
      canvas.drawPath(openMouth, Paint()..color = const Color(0xFFE11D48));
    } else {
      // Gentle confident smile
      final smilePath = Path();
      smilePath.moveTo(size.width * 0.45, size.height * 0.52);
      smilePath.quadraticBezierTo(
        size.width * 0.50, size.height * 0.555,
        size.width * 0.55, size.height * 0.52,
      );
      canvas.drawPath(smilePath, mouthPaint);
    }
  }

  Color _getMoodGlowColor() {
    switch (mood) {
      case GuideMood.happy:
      case GuideMood.celebrating:
        return const Color(0xFFFFD166);
      case GuideMood.teaching:
        return const Color(0xFF10B981);
      case GuideMood.encouraging:
        return const Color(0xFF38BDF8);
      case GuideMood.neutral:
      default:
        return const Color(0xFF00E5FF);
    }
  }

  @override
  bool shouldRepaint(covariant _DoctorPainter oldDelegate) {
    return oldDelegate.mood != mood || oldDelegate.animProgress != animProgress;
  }
}
