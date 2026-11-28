import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Luminous biological palette configuration for each of the 7 digestive stages
class StageBackgroundTheme {
  final Color topSkyBg;
  final Color midLumenBg;
  final Color vesselColor;
  final Color cellColor;
  final Color wallColor;
  final Color villiColor;
  final Color bubbleColor;
  final Color particleGlow;

  const StageBackgroundTheme({
    required this.topSkyBg,
    required this.midLumenBg,
    required this.vesselColor,
    required this.cellColor,
    required this.wallColor,
    required this.villiColor,
    required this.bubbleColor,
    required this.particleGlow,
  });

  /// Factory by stage ID (1-7) — bright, colorful, clean contrast (zero black voids!)
  factory StageBackgroundTheme.forStage(int stageId) {
    switch (stageId) {
      case 1: // Stage 1: Œsophage & Cardia — Luminous Ocean-Rose & Pearl Teal
        return const StageBackgroundTheme(
          topSkyBg: Color(0xFF163D5E),
          midLumenBg: Color(0xFF225A7D),
          vesselColor: Color(0xFFE15B72),
          cellColor: Color(0xFFFB7185),
          wallColor: Color(0xFF287494),
          villiColor: Color(0xFFFDA4AF),
          bubbleColor: Color(0xFFBAE6FD),
          particleGlow: Color(0xFFFDE68A),
        );
      case 2: // Stage 2: Estomac & Muqueuse — Ocean Teal & Warm Apricot Gold
        return const StageBackgroundTheme(
          topSkyBg: Color(0xFF154363),
          midLumenBg: Color(0xFF1E5D85),
          vesselColor: Color(0xFF0E7490),
          cellColor: Color(0xFF38BDF8),
          wallColor: Color(0xFF0E7490),
          villiColor: Color(0xFFFB923C),
          bubbleColor: Color(0xFFFDBA74),
          particleGlow: Color(0xFF7DD3FC),
        );
      case 3: // Stage 3: Intestin Grêle — Turquoise & Mint Emerald Therapy
        return const StageBackgroundTheme(
          topSkyBg: Color(0xFF0E454C),
          midLumenBg: Color(0xFF15676E),
          vesselColor: Color(0xFF0F766E),
          cellColor: Color(0xFF2DD4BF),
          wallColor: Color(0xFF14B8A6),
          villiColor: Color(0xFF6EE7B7),
          bubbleColor: Color(0xFFA7F3D0),
          particleGlow: Color(0xFF5EEAD4),
        );
      case 4: // Stage 4: Iléon Terminal — Azure Sky & Probiotic Green
        return const StageBackgroundTheme(
          topSkyBg: Color(0xFF113C6B),
          midLumenBg: Color(0xFF1D5B99),
          vesselColor: Color(0xFF0369A1),
          cellColor: Color(0xFF38BDF8),
          wallColor: Color(0xFF0EA5E9),
          villiColor: Color(0xFF34D399),
          bubbleColor: Color(0xFF7DD3FC),
          particleGlow: Color(0xFFA78BFA),
        );
      case 5: // Stage 5: Côlon Transverse — Soft Violet & Coral Rose
        return const StageBackgroundTheme(
          topSkyBg: Color(0xFF2D2666),
          midLumenBg: Color(0xFF433794),
          vesselColor: Color(0xFF6D28D9),
          cellColor: Color(0xFFA78BFA),
          wallColor: Color(0xFF8B5CF6),
          villiColor: Color(0xFFFB7185),
          bubbleColor: Color(0xFFFBCFE8),
          particleGlow: Color(0xFFC4B5FD),
        );
      case 6: // Stage 6: Rectum & Urgences — Cobalt Clinical Blue & Sunny Gold
        return const StageBackgroundTheme(
          topSkyBg: Color(0xFF103463),
          midLumenBg: Color(0xFF1B5294),
          vesselColor: Color(0xFF1D4ED8),
          cellColor: Color(0xFF60A5FA),
          wallColor: Color(0xFF2563EB),
          villiColor: Color(0xFFFBBF24),
          bubbleColor: Color(0xFF93C5FD),
          particleGlow: Color(0xFFFDE047),
        );
      case 7: // Stage 7: Sanctuaire Immunitaire — Golden Dawn & Radiant Cyan
      default:
        return const StageBackgroundTheme(
          topSkyBg: Color(0xFF0F4057),
          midLumenBg: Color(0xFF17637C),
          vesselColor: Color(0xFF0E7490),
          cellColor: Color(0xFF22D3EE),
          wallColor: Color(0xFF06B6D4),
          villiColor: Color(0xFFFBBF24),
          bubbleColor: Color(0xFF67E8F9),
          particleGlow: Color(0xFFFEF08A),
        );
    }
  }

  /// Dedicated Golden-Sapphire palette for the Special Revision Stage after Stage 7
  factory StageBackgroundTheme.forRevision() {
    return const StageBackgroundTheme(
      topSkyBg: Color(0xFF103766),
      midLumenBg: Color(0xFF1A5A96),
      vesselColor: Color(0xFFFBBF24),
      cellColor: Color(0xFF5EEAD4),
      wallColor: Color(0xFFD97706),
      villiColor: Color(0xFFFDE047),
      bubbleColor: Color(0xFFBAE6FD),
      particleGlow: Color(0xFFFBBF24),
    );
  }
}

/// Clean 3-Layer Biological Parallax Background System
class ParallaxBackgroundSystem {
  final int stageId;
  final bool isRevisionStage;
  late final StageBackgroundTheme theme;

  final Paint _vesselPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 22.0
    ..strokeCap = StrokeCap.round;
  final Paint _cellFill = Paint()..style = PaintingStyle.fill;
  final Paint _cellRim = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;
  final Paint _foldPaint = Paint()..style = PaintingStyle.fill;
  final Paint _bubbleFill = Paint()..style = PaintingStyle.fill;
  final Paint _bubbleStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  final Paint _shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.55);

  ParallaxBackgroundSystem({
    required this.stageId,
    this.isRevisionStage = false,
  }) {
    theme = isRevisionStage
        ? StageBackgroundTheme.forRevision()
        : StageBackgroundTheme.forStage(stageId);
  }

  void render(Canvas canvas, Size size, double scrollX, double time, {double bossMix = 0.0}) {
    // 0. Luminous Lumen Gradient (shifts warmly in Boss Arena)
    _renderLumenGradient(canvas, size, bossMix);

    // Layer 1 (speed x 0.2): Soft Translucent Blood Vessels & Distant Cells
    _renderLayer1DeepVesselsAndCells(canvas, size, scrollX * 0.2, time);

    // Optional celestial academic light shafts in the Special Revision Stage
    if (isRevisionStage) {
      _renderRevisionSanctuaryRays(canvas, size, scrollX * 0.35, time);
    }

    // Layer 2 (speed x 0.5): Mucosal Tissue Silhouette Ridges
    _renderLayer2MucosalFolds(canvas, size, scrollX * 0.5, time);

    // Layer 3 (speed x 0.9): Light Buoyant Bio-Bubbles (clean, sparse, non-cluttered)
    _renderLayer3BuoyantBubbles(canvas, size, scrollX * 0.9, time);
  }

  void _renderRevisionSanctuaryRays(Canvas canvas, Size size, double offset, double time) {
    const step = 340.0;
    final startIdx = (offset / step).floor() - 1;
    final endIdx = ((offset + size.width) / step).ceil() + 1;
    final sparkPaint = Paint()..style = PaintingStyle.fill;

    for (int i = startIdx; i <= endIdx; i++) {
      final bx = (i * step) - offset + 120.0;
      final rayRect = Rect.fromLTWH(bx - 36, 0, 72, size.height);
      final rayPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFBBF24).withValues(alpha: 0.14),
            const Color(0xFF22D3EE).withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ).createShader(rayRect);
      canvas.drawRect(rayRect, rayPaint);

      final sy = size.height * (0.22 + ((i.abs() * 37) % 55) / 100.0) +
          math.sin(time * 1.4 + i) * 14.0;
      sparkPaint.color = const Color(0xFFFDE047).withValues(alpha: 0.48);
      final d = Path()
        ..moveTo(bx, sy - 7)
        ..lineTo(bx + 6, sy)
        ..lineTo(bx, sy + 7)
        ..lineTo(bx - 6, sy)
        ..close();
      canvas.drawPath(d, sparkPaint);
    }
  }

  void _renderLumenGradient(Canvas canvas, Size size, double bossMix) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final topColor = Color.lerp(theme.topSkyBg, const Color(0xFF2B2259), bossMix * 0.52)!;
    final midColor = Color.lerp(theme.midLumenBg, const Color(0xFF422F7D), bossMix * 0.45)!;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, midColor, topColor],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _renderLayer1DeepVesselsAndCells(Canvas canvas, Size size, double offset, double time) {
    _vesselPaint.color = theme.vesselColor.withValues(alpha: 0.24);
    final vesselPaint = _vesselPaint;
    final cellFill = _cellFill;
    final cellRim = _cellRim;

    const step = 420.0;
    final startIdx = (offset / step).floor() - 1;
    final endIdx = ((offset + size.width) / step).ceil() + 1;

    for (int i = startIdx; i <= endIdx; i++) {
      final baseX = (i * step) - offset;

      final path = Path()
        ..moveTo(baseX - 40, -20)
        ..cubicTo(
          baseX + 120,
          size.height * 0.32 + math.sin(i * 1.4) * 35,
          baseX + 260,
          size.height * 0.68 + math.cos(i * 1.6) * 35,
          baseX + step + 40,
          size.height + 20,
        );
      canvas.drawPath(path, vesselPaint);

      // Soft biconcave background cells (low opacity so foreground stands out!)
      final cellX = baseX + 160.0 + math.sin(i * 2.7 + time * 0.4) * 18.0;
      final cellY = (size.height * 0.28) +
          ((i.abs() * 67) % math.max(1, (size.height * 0.44).toInt())) +
          math.cos(i * 2.1 + time * 0.5) * 14.0;
      final radius = 22.0 + ((i.abs() * 13) % 16);

      cellFill.color = theme.cellColor.withValues(alpha: 0.14);
      canvas.drawCircle(Offset(cellX, cellY), radius, cellFill);
      cellFill.color = theme.topSkyBg.withValues(alpha: 0.16);
      canvas.drawCircle(Offset(cellX, cellY), radius * 0.44, cellFill);
      cellRim.color = theme.cellColor.withValues(alpha: 0.25);
      canvas.drawCircle(Offset(cellX, cellY), radius, cellRim);
    }
  }

  void _renderLayer2MucosalFolds(Canvas canvas, Size size, double offset, double time) {
    _foldPaint.color = theme.wallColor.withValues(alpha: 0.20);
    final foldPaint = _foldPaint;

    const step = 280.0;
    final startIdx = (offset / step).floor() - 1;
    final endIdx = ((offset + size.width) / step).ceil() + 1;

    final topFold = Path()..moveTo(-60, 0);
    final bottomFold = Path()..moveTo(-60, size.height);

    for (int i = startIdx; i <= endIdx; i++) {
      final x = (i * step) - offset;
      final topWave = size.height * 0.12 + math.sin(i * 1.6 + time * 0.6) * 14.0;
      final bottomWave = size.height * 0.88 - math.cos(i * 1.6 + time * 0.6) * 14.0;

      topFold.lineTo(x, topWave);
      bottomFold.lineTo(x, bottomWave);
    }

    topFold.lineTo(size.width + 60, 0);
    topFold.close();
    bottomFold.lineTo(size.width + 60, size.height);
    bottomFold.close();

    canvas.drawPath(topFold, foldPaint);
    canvas.drawPath(bottomFold, foldPaint);
  }

  void _renderLayer3BuoyantBubbles(Canvas canvas, Size size, double offset, double time) {
    final bubbleFill = _bubbleFill;
    final bubbleStroke = _bubbleStroke;
    final shinePaint = _shinePaint;

    const step = 210.0;
    final startIdx = (offset / step).floor() - 1;
    final endIdx = ((offset + size.width) / step).ceil() + 1;

    for (int i = startIdx; i <= endIdx; i++) {
      final rawX = (i * step) + ((i.abs() * 41) % 100);
      final bx = rawX - offset;
      final phase = (time * 0.18 + (i.abs() * 0.37)) % 1.0;
      final by = size.height - (phase * (size.height + 50.0));
      final r = 5.0 + ((i.abs() * 7) % 8);

      bubbleFill.color = theme.bubbleColor.withValues(alpha: 0.16);
      canvas.drawCircle(Offset(bx, by), r, bubbleFill);

      bubbleStroke.color = theme.bubbleColor.withValues(alpha: 0.38);
      canvas.drawCircle(Offset(bx, by), r, bubbleStroke);

      canvas.drawCircle(Offset(bx - r * 0.35, by - r * 0.35), r * 0.22, shinePaint);
    }
  }
}
