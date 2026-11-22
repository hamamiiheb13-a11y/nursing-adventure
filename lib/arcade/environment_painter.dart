import 'dart:math' as math;
import 'package:flutter/material.dart';

class StageEnvironmentPalette {
  final Color deepBg;
  final Color wallColor;
  final Color foldColor;
  final Color veinColor;
  final Color bubbleColor;
  final Color particleColor;

  const StageEnvironmentPalette({
    required this.deepBg,
    required this.wallColor,
    required this.foldColor,
    required this.veinColor,
    required this.bubbleColor,
    required this.particleColor,
  });

  factory StageEnvironmentPalette.forStage(int stageId) {
    switch (stageId) {
      case 1: // Stage 1: Deep red/maroon (blood/anatomical)
        return const StageEnvironmentPalette(
          deepBg: Color(0xFF1A0505),
          wallColor: Color(0xFF880E17),
          foldColor: Color(0xFFC62828),
          veinColor: Color(0x55E53935),
          bubbleColor: Color(0x44FF8A80),
          particleColor: Color(0xFFFF5252),
        );
      case 2: // Stage 2: Purple/dark orange (inflammation)
        return const StageEnvironmentPalette(
          deepBg: Color(0xFF14051E),
          wallColor: Color(0xFF4A148C),
          foldColor: Color(0xFFE65100),
          veinColor: Color(0x55AB47BC),
          bubbleColor: Color(0x44FF9800),
          particleColor: Color(0xFFFFAB40),
        );
      case 3: // Stage 3: Blue/teal (treatment/medicine)
        return const StageEnvironmentPalette(
          deepBg: Color(0xFF02171A),
          wallColor: Color(0xFF004D40),
          foldColor: Color(0xFF00897B),
          veinColor: Color(0x5500B4D8),
          bubbleColor: Color(0x4480CBC4),
          particleColor: Color(0xFF4DD0E1),
        );
      case 4: // Stage 4: Cyan/green (lab/analysis)
        return const StageEnvironmentPalette(
          deepBg: Color(0xFF021921),
          wallColor: Color(0xFF006064),
          foldColor: Color(0xFF00B0FF),
          veinColor: Color(0x5500E676),
          bubbleColor: Color(0x4469F0AE),
          particleColor: Color(0xFF18FFFF),
        );
      case 5: // Stage 5: Warm amber/yellow (lifestyle/food)
        return const StageEnvironmentPalette(
          deepBg: Color(0xFF1E1002),
          wallColor: Color(0xFFE65100),
          foldColor: Color(0xFFFFA000),
          veinColor: Color(0x55FFB300),
          bubbleColor: Color(0x44FFE082),
          particleColor: Color(0xFFFFD54F),
        );
      case 6: // Stage 6: Pink/rose/soft purple (family/fertility)
        return const StageEnvironmentPalette(
          deepBg: Color(0xFF1E0517),
          wallColor: Color(0xFF880E4F),
          foldColor: Color(0xFFD81B60),
          veinColor: Color(0x55BA68C8),
          bubbleColor: Color(0x44F48FB1),
          particleColor: Color(0xFFFF80AB),
        );
      case 7: // Stage 7: Blue/white/professional (nursing)
      default:
        return const StageEnvironmentPalette(
          deepBg: Color(0xFF031626),
          wallColor: Color(0xFF01579B),
          foldColor: Color(0xFF0288D1),
          veinColor: Color(0x5580DEEA),
          bubbleColor: Color(0x44B2EBF2),
          particleColor: Color(0xFFE0F7FA),
        );
    }
  }
}

class EnvironmentPainter extends CustomPainter {
  final double scrollX;
  final int stageId;
  final double animTime;

  EnvironmentPainter({
    required this.scrollX,
    required this.stageId,
    required this.animTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final palette = StageEnvironmentPalette.forStage(stageId);

    // Deep base fill
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.deepBg,
            palette.deepBg.withValues(alpha: 0.8),
            palette.deepBg,
          ],
        ).createShader(Offset.zero & size),
    );

    // LAYER 1 (Slowest): Deep background vein patterns & organic cell discs
    _drawLayer1DeepVeinsAndCells(canvas, size, palette);

    // LAYER 2 (Medium): Mid-ground gastric walls, tissue folds, bubbles, villi
    _drawLayer2TissueWallsAndFolds(canvas, size, palette);

    // LAYER 3 (Fastest): Foreground details — floating particles, glow dots
    _drawLayer3ForegroundParticles(canvas, size, palette);
  }

  void _drawLayer1DeepVeinsAndCells(Canvas canvas, Size size, StageEnvironmentPalette palette) {
    final layerScroll = scrollX * 0.15;

    // 1. Organic vein capillary network
    final veinPaint = Paint()
      ..color = palette.veinColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    for (int i = 0; i < 4; i++) {
      final baseY = size.height * (0.2 + i * 0.22);
      final path = Path();
      path.moveTo(-40, baseY);

      for (double x = -40; x <= size.width + 80; x += 90) {
        final worldX = x + layerScroll;
        final waveY = math.sin(worldX * 0.008 + i * 1.5) * 25.0 + math.cos(animTime * 0.5 + i) * 6.0;
        path.lineTo(x, baseY + waveY);
      }
      canvas.drawPath(path, veinPaint);
    }

    // 2. Large translucent cellular discs (erythrocytes / macrophages)
    final cellPaint = Paint()
      ..color = palette.wallColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    for (int k = 0; k < 6; k++) {
      final worldCellX = (k * 240.0) - (layerScroll % 1440.0);
      final cellX = worldCellX < -60 ? worldCellX + 1440.0 : worldCellX;
      final cellY = size.height * (0.25 + (math.sin(k * 2.1) * 0.25 + 0.25));
      final cellR = 28.0 + math.sin(animTime + k) * 3.0;

      canvas.drawCircle(Offset(cellX, cellY), cellR, cellPaint);
      canvas.drawCircle(
        Offset(cellX, cellY),
        cellR * 0.55,
        Paint()
          ..color = palette.deepBg.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawLayer2TissueWallsAndFolds(Canvas canvas, Size size, StageEnvironmentPalette palette) {
    final layerScroll = scrollX * 0.45;

    // Ceiling & Floor Tissue Folds
    final ceilingPath = Path()..moveTo(0, 0);
    final floorPath = Path()..moveTo(0, size.height);

    const step = 20.0;
    final points = (size.width / step).ceil() + 2;

    // Ceiling wall contour
    for (int i = 0; i <= points; i++) {
      final x = i * step;
      final worldX = x + layerScroll;
      final wallY = 55.0 + math.sin(worldX * 0.012) * 18.0 + math.cos(worldX * 0.025 + animTime * 1.2) * 8.0;
      ceilingPath.lineTo(x, wallY);
    }
    ceilingPath.lineTo(size.width, 0);
    ceilingPath.close();

    // Floor wall contour
    for (int i = 0; i <= points; i++) {
      final x = i * step;
      final worldX = x + layerScroll;
      final wallY = size.height - 65.0 - math.sin(worldX * 0.014 + 1.2) * 20.0 - math.cos(worldX * 0.022 + animTime * 1.2) * 8.0;
      floorPath.lineTo(x, wallY);
    }
    floorPath.lineTo(size.width, size.height);
    floorPath.close();

    // Wall shaders
    final wallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [palette.wallColor, palette.wallColor.withValues(alpha: 0.6)],
      ).createShader(Offset.zero & size);

    canvas.drawPath(ceilingPath, wallPaint);
    canvas.drawPath(floorPath, wallPaint);

    // Glowing mucous fringe outlines
    final fringePaint = Paint()
      ..color = palette.foldColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(ceilingPath, fringePaint);
    canvas.drawPath(floorPath, fringePaint);

    // Undulating villi protrusions on floor and ceiling
    final villiPaint = Paint()
      ..color = palette.foldColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (double x = 0; x <= size.width; x += 35.0) {
      final worldX = x + layerScroll;
      final sway = math.sin(animTime * 3.0 + worldX * 0.03) * 8.0;

      // Ceiling villi
      final cBaseY = 55.0 + math.sin(worldX * 0.012) * 18.0;
      canvas.drawLine(
        Offset(x, cBaseY),
        Offset(x + sway, cBaseY + 16.0),
        villiPaint,
      );

      // Floor villi
      final fBaseY = size.height - 65.0 - math.sin(worldX * 0.014 + 1.2) * 20.0;
      canvas.drawLine(
        Offset(x, fBaseY),
        Offset(x + sway, fBaseY - 18.0),
        villiPaint,
      );
    }

    // Midground floating bubbles
    final bubblePaint = Paint()
      ..color = palette.bubbleColor
      ..style = PaintingStyle.fill;
    final bubbleRim = Paint()
      ..color = palette.particleColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int b = 0; b < 10; b++) {
      final bx = ((b * 160.0) - (layerScroll * 1.2 % (size.width + 200))) + size.width + 100;
      final actualBx = bx % (size.width + 200) - 100;
      final by = size.height * (0.2 + (b * 0.07) % 0.6) + math.sin(animTime * 2.0 + b) * 12.0;
      final br = 8.0 + (b % 4) * 3.0;

      canvas.drawCircle(Offset(actualBx, by), br, bubblePaint);
      canvas.drawCircle(Offset(actualBx, by), br, bubbleRim);
    }
  }

  void _drawLayer3ForegroundParticles(Canvas canvas, Size size, StageEnvironmentPalette palette) {
    final layerScroll = scrollX * 0.9;
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 28; i++) {
      final seed = i * 47;
      final wx = (seed * 31.0 - layerScroll) % (size.width + 100);
      final px = wx < -20 ? wx + size.width + 100 : wx;
      final py = (seed * 19.0 + math.sin(animTime * 3.0 + i) * 15.0) % size.height;
      final pr = 1.5 + (i % 3) * 1.0;
      final alpha = (0.3 + math.sin(animTime * 4.0 + i) * 0.3).clamp(0.1, 0.85);

      particlePaint.color = palette.particleColor.withValues(alpha: alpha);
      canvas.drawCircle(Offset(px, py), pr, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant EnvironmentPainter oldDelegate) {
    return oldDelegate.scrollX != scrollX ||
        oldDelegate.stageId != stageId ||
        oldDelegate.animTime != animTime;
  }
}
