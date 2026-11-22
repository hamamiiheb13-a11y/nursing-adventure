import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Palette configuration for each of the 7 stages
class StageBackgroundTheme {
  final Color deepBg;
  final Color vesselColor;
  final Color cellColor;
  final Color wallColor;
  final Color villiColor;
  final Color bubbleColor;
  final Color particleGlow;

  const StageBackgroundTheme({
    required this.deepBg,
    required this.vesselColor,
    required this.cellColor,
    required this.wallColor,
    required this.villiColor,
    required this.bubbleColor,
    required this.particleGlow,
  });

  /// Factory by stage ID (1-7)
  factory StageBackgroundTheme.forStage(int stageId) {
    switch (stageId) {
      case 1: // Stage 1: Red / Maroon (Anatomy & mucosal lesions)
        return const StageBackgroundTheme(
          deepBg: Color(0xFF150408),
          vesselColor: Color(0xFF4A0E17),
          cellColor: Color(0xFF9E2A2B),
          wallColor: Color(0xFFC1121F),
          villiColor: Color(0xFFE63946),
          bubbleColor: Color(0xFFFF758F),
          particleGlow: Color(0xFFFFB3C1),
        );
      case 2: // Stage 2: Purple / Orange (Symptoms & manifestations)
        return const StageBackgroundTheme(
          deepBg: Color(0xFF14081E),
          vesselColor: Color(0xFF3B125B),
          cellColor: Color(0xFF6B21A8),
          wallColor: Color(0xFF9333EA),
          villiColor: Color(0xFFEA580C),
          bubbleColor: Color(0xFFF97316),
          particleGlow: Color(0xFFFDBA74),
        );
      case 3: // Stage 3: Blue / Teal (Pharmacology & treatments)
        return const StageBackgroundTheme(
          deepBg: Color(0xFF04141E),
          vesselColor: Color(0xFF083344),
          cellColor: Color(0xFF0E7490),
          wallColor: Color(0xFF06B6D4),
          villiColor: Color(0xFF14B8A6),
          bubbleColor: Color(0xFF2DD4BF),
          particleGlow: Color(0xFF67E8F9),
        );
      case 4: // Stage 4: Emerald / Green (Lab exams & markers)
        return const StageBackgroundTheme(
          deepBg: Color(0xFF04170E),
          vesselColor: Color(0xFF064E3B),
          cellColor: Color(0xFF047857),
          wallColor: Color(0xFF059669),
          villiColor: Color(0xFF10B981),
          bubbleColor: Color(0xFF34D399),
          particleGlow: Color(0xFF6EE7B7),
        );
      case 5: // Stage 5: Gold / Amber / Coral (Lifestyle & nutrition)
        return const StageBackgroundTheme(
          deepBg: Color(0xFF1C1304),
          vesselColor: Color(0xFF451A03),
          cellColor: Color(0xFF78350F),
          wallColor: Color(0xFFD97706),
          villiColor: Color(0xFFF59E0B),
          bubbleColor: Color(0xFFFBBF24),
          particleGlow: Color(0xFFFDE68A),
        );
      case 6: // Stage 6: Violet / Rose (Heredity, genetics & pregnancy)
        return const StageBackgroundTheme(
          deepBg: Color(0xFF1A051A),
          vesselColor: Color(0xFF4A044E),
          cellColor: Color(0xFF86198F),
          wallColor: Color(0xFFC026D3),
          villiColor: Color(0xFFDB2777),
          bubbleColor: Color(0xFFF472B6),
          particleGlow: Color(0xFFFBCFE8),
        );
      case 7: // Stage 7: Electric Cyan / Deep Navy (Nursing mission finale)
      default:
        return const StageBackgroundTheme(
          deepBg: Color(0xFF030A1A),
          vesselColor: Color(0xFF0C2461),
          cellColor: Color(0xFF1E3799),
          wallColor: Color(0xFF4A69BD),
          villiColor: Color(0xFF00E5FF),
          bubbleColor: Color(0xFF00D2D3),
          particleGlow: Color(0xFF81ECEC),
        );
    }
  }
}

/// 3-Layer Parallax Background System
/// All drawn purely via Flutter Canvas API with 0 image assets.
class ParallaxBackgroundSystem {
  final int stageId;
  late final StageBackgroundTheme theme;

  ParallaxBackgroundSystem({required this.stageId}) {
    theme = StageBackgroundTheme.forStage(stageId);
  }

  /// Draw complete 3-layer parallax background
  /// [scrollX] is the camera horizontal distance
  /// [time] is the elapsed game time in seconds
  void render(Canvas canvas, Size size, double scrollX, double time) {
    // 0. Base deep ambient biological gradient
    _renderDeepGradient(canvas, size);

    // Layer 1 (speed x 0.2): Large organic cells & branching vascular vessel patterns
    _renderLayer1DeepVesselsAndCells(canvas, size, scrollX * 0.2, time);

    // Layer 2 (speed x 0.5): Gastric wall folds, mucosal villi, tissue texture
    _renderLayer2GastricFoldsAndVilli(canvas, size, scrollX * 0.5, time);

    // Layer 3 (speed x 1.0): Foreground micro-particles, glowing acid bubbles & flares
    _renderLayer3ForegroundParticlesAndBubbles(canvas, size, scrollX * 1.0, time);
  }

  // --------------------------------------------------------------------------
  // LAYER 0: BASE GRADIENT
  // --------------------------------------------------------------------------
  void _renderDeepGradient(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.deepBg,
          theme.vesselColor.withValues(alpha: 0.4),
          theme.deepBg,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  // --------------------------------------------------------------------------
  // LAYER 1 (speed x 0.2): Large Organic Cells & Blood Vessel Patterns
  // --------------------------------------------------------------------------
  void _renderLayer1DeepVesselsAndCells(Canvas canvas, Size size, double offset, double time) {
    final vesselPaint = Paint()
      ..color = theme.vesselColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round;

    final cellPaint = Paint()
      ..style = PaintingStyle.fill;

    final cellRimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw 3 continuous branching blood vessels
    final step = 380.0;
    final startIdx = (offset / step).floor() - 1;
    final endIdx = ((offset + size.width) / step).ceil() + 1;

    for (int i = startIdx; i <= endIdx; i++) {
      final baseX = (i * step) - offset;

      // Deep vessel branch
      final path = Path()
        ..moveTo(baseX - 60, -30)
        ..cubicTo(
          baseX + 100, size.height * 0.35 + math.sin(i * 1.5) * 40,
          baseX + 220, size.height * 0.65 + math.cos(i * 1.7) * 40,
          baseX + step + 60, size.height + 30,
        );
      canvas.drawPath(path, vesselPaint);

      // Large organic erythrocytes / cells (biconcave disc look)
      final cellX = baseX + 140.0 + math.sin(i * 3.1 + time * 0.5) * 20.0;
      final cellY = (size.height * 0.25) + ((i * 73) % (size.height * 0.55).toInt()) +
          math.cos(i * 2.3 + time * 0.6) * 15.0;
      final radius = 28.0 + ((i * 17) % 20);

      // Outer cell body
      cellPaint.color = theme.cellColor.withValues(alpha: 0.22);
      canvas.drawCircle(Offset(cellX, cellY), radius, cellPaint);

      // Inner biconcave center dimple
      cellPaint.color = theme.deepBg.withValues(alpha: 0.35);
      canvas.drawCircle(Offset(cellX, cellY), radius * 0.45, cellPaint);

      // Cell border
      cellRimPaint.color = theme.cellColor.withValues(alpha: 0.45);
      canvas.drawCircle(Offset(cellX, cellY), radius, cellRimPaint);
    }
  }

  // --------------------------------------------------------------------------
  // LAYER 2 (speed x 0.5): Gastric Wall Folds, Villi & Tissue Texture
  // --------------------------------------------------------------------------
  void _renderLayer2GastricFoldsAndVilli(Canvas canvas, Size size, double offset, double time) {
    final foldPaint = Paint()
      ..color = theme.wallColor.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;

    final villiPaint = Paint()
      ..color = theme.villiColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final step = 240.0;
    final startIdx = (offset / step).floor() - 1;
    final endIdx = ((offset + size.width) / step).ceil() + 1;

    // Top and Bottom undulating mucosal wall folds
    final topFold = Path()..moveTo(-50, 0);
    final bottomFold = Path()..moveTo(-50, size.height);

    for (int i = startIdx; i <= endIdx; i++) {
      final x = (i * step) - offset;
      final topWave = 35.0 + math.sin(i * 1.8 + time * 0.8) * 18.0;
      final bottomWave = size.height - 35.0 - math.cos(i * 1.8 + time * 0.8) * 18.0;

      topFold.lineTo(x, topWave);
      bottomFold.lineTo(x, bottomWave);

      // Micro Villi finger-like protrusions
      for (int v = 0; v < 4; v++) {
        final vx = x + (v * (step / 4));
        final vh = 16.0 + math.sin(vx * 0.05 + time * 1.5) * 8.0;

        // Top villi hanging down
        canvas.drawLine(Offset(vx, 0), Offset(vx + math.sin(time + vx) * 4, topWave + vh), villiPaint);

        // Bottom villi sticking up
        canvas.drawLine(
          Offset(vx, size.height),
          Offset(vx + math.cos(time + vx) * 4, bottomWave - vh),
          villiPaint,
        );
      }
    }

    topFold.lineTo(size.width + 50, 0);
    topFold.close();
    bottomFold.lineTo(size.width + 50, size.height);
    bottomFold.close();

    canvas.drawPath(topFold, foldPaint);
    canvas.drawPath(bottomFold, foldPaint);
  }

  // --------------------------------------------------------------------------
  // LAYER 3 (speed x 1.0): Foreground Micro-Particles, Acid Bubbles & Glow Flares
  // --------------------------------------------------------------------------
  void _renderLayer3ForegroundParticlesAndBubbles(
      Canvas canvas, Size size, double offset, double time) {
    final bubbleFill = Paint()..style = PaintingStyle.fill;
    final bubbleHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    final bubbleStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final particlePaint = Paint()..style = PaintingStyle.fill;

    final step = 160.0;
    final startIdx = (offset / step).floor() - 1;
    final endIdx = ((offset + size.width) / step).ceil() + 1;

    for (int i = startIdx; i <= endIdx; i++) {
      // Acid Bubble (Floating upward with wobble)
      final rawX = (i * step) + ((i * 37) % 80);
      final bx = rawX - offset;
      final phase = (time * 1.8 + (i * 1.3)) % 1.0;
      final by = size.height - (phase * (size.height + 60.0));
      final bubbleRadius = 6.0 + ((i * 13) % 10);

      // Bubble Body
      bubbleFill.color = theme.bubbleColor.withValues(alpha: 0.28);
      canvas.drawCircle(Offset(bx, by), bubbleRadius, bubbleFill);

      // Bubble Rim
      bubbleStroke.color = theme.bubbleColor.withValues(alpha: 0.75);
      canvas.drawCircle(Offset(bx, by), bubbleRadius, bubbleStroke);

      // Bubble Specular Reflection Dot
      canvas.drawCircle(
        Offset(bx - bubbleRadius * 0.35, by - bubbleRadius * 0.35),
        bubbleRadius * 0.25,
        bubbleHighlight,
      );

      // Bioluminescent Foreground Micro-particle (Glowing spark)
      final px = (i * step * 0.7 + math.sin(time * 2.0 + i) * 30.0) - offset;
      final py = ((i * 89) % size.height.toInt()) + math.cos(time * 1.5 + i) * 20.0;

      particlePaint.color = theme.particleGlow.withValues(alpha: 0.55);
      canvas.drawCircle(Offset(px, py), 2.5, particlePaint);

      // Subtle particle halo
      particlePaint.color = theme.particleGlow.withValues(alpha: 0.15);
      canvas.drawCircle(Offset(px, py), 6.5, particlePaint);
    }
  }
}
