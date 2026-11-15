import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/board_tile.dart';

class BoardPainter extends CustomPainter {
  final int? highlightTile;
  final bool isHighlightLadder;
  final double animationValue;

  BoardPainter({
    this.highlightTile,
    this.isHighlightLadder = false,
    this.animationValue = 0.0,
  });

  static Offset getTileCenter(int num, Size size) {
    final tileW = size.width / 10;
    final tileH = size.height / 10;
    final rowFromBottom = (num - 1) ~/ 10;
    final colInRow = (num - 1) % 10;
    final col = (rowFromBottom % 2 == 0) ? colInRow : (9 - colInRow);
    final row = 9 - rowFromBottom;
    return Offset((col + 0.5) * tileW, (row + 0.5) * tileH);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final tileW = size.width / 10;

    // 1. Draw all Ladders first (so snakes can cross cleanly)
    BoardDefinition.ladders.forEach((startTile, data) {
      final endTile = data['to'] as int;
      final startPos = getTileCenter(startTile, size);
      final endPos = getTileCenter(endTile, size);
      final isHighlighted = highlightTile == startTile && isHighlightLadder;

      _drawRescueLadder(canvas, startPos, endPos, tileW, isHighlighted);
    });

    // 2. Draw all Snakes
    BoardDefinition.snakes.forEach((startTile, data) {
      final endTile = data['to'] as int;
      final headPos = getTileCenter(startTile, size);
      final tailPos = getTileCenter(endTile, size);
      final isHighlighted = highlightTile == startTile && !isHighlightLadder;

      _drawScarySnake(canvas, headPos, tailPos, tileW, startTile, isHighlighted);
    });
  }

  // Draw gleaming golden rescue ladders with rungs and rescue light caps
  void _drawRescueLadder(Canvas canvas, Offset start, Offset end, double tileW, bool isHighlighted) {
    final diff = end - start;
    final len = diff.distance;
    if (len < 1) return;

    final dir = diff / len;
    final normal = Offset(-dir.dy, dir.dx);
    final halfWidth = tileW * 0.16;

    // Glowing aura if highlighted
    if (isHighlighted) {
      final auraPaint = Paint()
        ..color = const Color(0xFFFFD166).withOpacity(0.4 + 0.3 * math.sin(animationValue * math.pi * 2))
        ..strokeWidth = halfWidth * 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawLine(start, end, auraPaint);
    }

    // Dropshadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.45)
      ..strokeWidth = halfWidth * 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawLine(start + const Offset(2, 4), end + const Offset(2, 4), shadowPaint);

    final leftRailStart = start - normal * halfWidth;
    final leftRailEnd = end - normal * halfWidth;
    final rightRailStart = start + normal * halfWidth;
    final rightRailEnd = end + normal * halfWidth;

    // Golden Rail Paint
    final railPaint = Paint()
      ..shader = LinearGradient(
        colors: isHighlighted
            ? [const Color(0xFFFFF3B0), const Color(0xFFFFD166), const Color(0xFFE09F3E)]
            : [const Color(0xFFFFE6A7), const Color(0xFFE09F3E), const Color(0xFFBB3E03)],
      ).createShader(Rect.fromPoints(start, end))
      ..strokeWidth = math.max(3.5, tileW * 0.065)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw Side Rails
    canvas.drawLine(leftRailStart, leftRailEnd, railPaint);
    canvas.drawLine(rightRailStart, rightRailEnd, railPaint);

    // Draw Rungs
    final rungSpacing = math.max(14.0, tileW * 0.28);
    final rungCount = (len / rungSpacing).floor();

    final rungPaint = Paint()
      ..color = isHighlighted ? const Color(0xFFFFF3B0) : const Color(0xFFFFD166)
      ..strokeWidth = math.max(2.5, tileW * 0.045)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final boltPaint = Paint()
      ..color = const Color(0xFFFFF3B0)
      ..style = PaintingStyle.fill;

    for (int i = 1; i < rungCount; i++) {
      final t = (i * rungSpacing) / len;
      final rungCenter = Offset.lerp(start, end, t)!;
      final rLeft = rungCenter - normal * (halfWidth * 0.95);
      final rRight = rungCenter + normal * (halfWidth * 0.95);

      canvas.drawLine(rLeft, rRight, rungPaint);
      canvas.drawCircle(rLeft, tileW * 0.03, boltPaint);
      canvas.drawCircle(rRight, tileW * 0.03, boltPaint);
    }
  }

  // Draw scary anime red snake with slithering wavy body, cobra hood, fangs, glowing yellow eyes
  void _drawScarySnake(Canvas canvas, Offset head, Offset tail, double tileW, int seed, bool isHighlighted) {
    final diff = tail - head;
    final len = diff.distance;
    if (len < 1) return;

    final dir = diff / len;
    final normal = Offset(-dir.dy, dir.dx);

    // Wave parameters based on seed & animation
    final waves = math.max(2, (len / (tileW * 1.5)).round());
    final waveAmplitude = tileW * 0.35;

    // Glowing red hazard aura if active
    if (isHighlighted) {
      final auraPaint = Paint()
        ..color = const Color(0xFFFF0055).withOpacity(0.5 + 0.3 * math.sin(animationValue * math.pi * 2))
        ..strokeWidth = tileW * 0.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawLine(head, tail, auraPaint);
    }

    // Build serpentine spline path
    final path = Path()..moveTo(head.dx, head.dy);
    final segments = waves * 2;
    final points = <Offset>[head];

    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final base = Offset.lerp(head, tail, t)!;
      final side = (i % 2 == 1) ? 1.0 : -1.0;
      // Slight slither animation
      final slither = math.sin(animationValue * math.pi * 2 + i) * 0.15;
      final offset = normal * (waveAmplitude * (1.0 - t * 0.4) * (side + slither));
      points.add(base + offset);
    }
    points.add(tail);

    // Connect points with smooth Bézier curves
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = (p0 + p1) / 2;
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    path.lineTo(tail.dx, tail.dy);

    // Snake shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = tileW * 0.22
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.save();
    canvas.translate(2, 4);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Outer snake body (Crimson Red / Blood Serpent)
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: isHighlighted
            ? [const Color(0xFFFF0055), const Color(0xFFD00000), const Color(0xFF6A040F)]
            : [const Color(0xFFEF233C), const Color(0xFFD90429), const Color(0xFF370617)],
      ).createShader(Rect.fromPoints(head, tail))
      ..strokeWidth = math.max(6.0, tileW * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, bodyPaint);

    // Inner fiery underbelly scale line (Bright Neon Orange / Red)
    final bellyPaint = Paint()
      ..color = const Color(0xFFFF9E00).withOpacity(0.85)
      ..strokeWidth = math.max(2.0, tileW * 0.065)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, bellyPaint);

    // 3. Draw Menacing Cobra Snake Head at `head`
    _drawSnakeHead(canvas, head, dir, normal, tileW, isHighlighted);

    // 4. Draw Tail Rattle at `tail`
    _drawSnakeTail(canvas, tail, dir, normal, tileW);
  }

  void _drawSnakeHead(Canvas canvas, Offset head, Offset dir, Offset normal, double tileW, bool isHighlighted) {
    canvas.save();
    canvas.translate(head.dx, head.dy);
    final angle = math.atan2(dir.dy, dir.dx);
    canvas.rotate(angle);

    final headLength = tileW * 0.42;
    final headWidth = tileW * 0.36;

    // Cobra Flared Hood
    final hoodPath = Path()
      ..moveTo(headLength * 0.3, 0)
      ..quadraticBezierTo(0, headWidth * 0.6, -headLength * 0.6, headWidth * 0.4)
      ..lineTo(-headLength * 0.7, -headWidth * 0.4)
      ..quadraticBezierTo(0, -headWidth * 0.6, headLength * 0.3, 0)
      ..close();

    final hoodPaint = Paint()
      ..color = const Color(0xFF9D0208)
      ..style = PaintingStyle.fill;
    canvas.drawPath(hoodPath, hoodPaint);

    // Head Skull Plate (Vibrant Red)
    final skullPath = Path()
      ..moveTo(headLength * 0.5, 0)
      ..lineTo(headLength * 0.1, headWidth * 0.38)
      ..lineTo(-headLength * 0.4, headWidth * 0.25)
      ..lineTo(-headLength * 0.4, -headWidth * 0.25)
      ..lineTo(headLength * 0.1, -headWidth * 0.38)
      ..close();

    final skullPaint = Paint()
      ..color = isHighlighted ? const Color(0xFFFF0055) : const Color(0xFFD90429)
      ..style = PaintingStyle.fill;
    canvas.drawPath(skullPath, skullPaint);

    // Glowing Sinister Yellow/Green Snake Eyes
    final eyePaint = Paint()..color = const Color(0xFFCCFF00);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(headLength * 0.1, headWidth * 0.24), width: headLength * 0.22, height: headWidth * 0.16),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(headLength * 0.1, -headWidth * 0.24), width: headLength * 0.22, height: headWidth * 0.16),
      eyePaint,
    );

    // Slit Pupils (Black vertical slits)
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(headLength * 0.1, headWidth * 0.24), width: 1.5, height: headWidth * 0.14),
      pupilPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(headLength * 0.1, -headWidth * 0.24), width: 1.5, height: headWidth * 0.14),
      pupilPaint,
    );

    // White Sharp Fangs
    final fangPaint = Paint()..color = Colors.white;
    final leftFang = Path()
      ..moveTo(headLength * 0.38, headWidth * 0.14)
      ..lineTo(headLength * 0.62, headWidth * 0.18)
      ..lineTo(headLength * 0.42, headWidth * 0.08)
      ..close();
    final rightFang = Path()
      ..moveTo(headLength * 0.38, -headWidth * 0.14)
      ..lineTo(headLength * 0.62, -headWidth * 0.18)
      ..lineTo(headLength * 0.42, -headWidth * 0.08)
      ..close();
    canvas.drawPath(leftFang, fangPaint);
    canvas.drawPath(rightFang, fangPaint);

    // Flicking Forked Tongue
    final tonguePaint = Paint()
      ..color = const Color(0xFFFF0055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final tonguePath = Path()
      ..moveTo(headLength * 0.45, 0)
      ..lineTo(headLength * 0.75, 0)
      ..lineTo(headLength * 0.92, headWidth * 0.14)
      ..moveTo(headLength * 0.75, 0)
      ..lineTo(headLength * 0.92, -headWidth * 0.14);
    canvas.drawPath(tonguePath, tonguePaint);

    canvas.restore();
  }

  void _drawSnakeTail(Canvas canvas, Offset tail, Offset dir, Offset normal, double tileW) {
    canvas.save();
    canvas.translate(tail.dx, tail.dy);
    final angle = math.atan2(dir.dy, dir.dx);
    canvas.rotate(angle);

    final rattlePaint = Paint()..color = const Color(0xFFFFD166);
    final rSize = tileW * 0.06;
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(-i * rSize * 1.5, 0), rSize * (1.0 - i * 0.2), rattlePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.highlightTile != highlightTile ||
        oldDelegate.isHighlightLadder != isHighlightLadder ||
        oldDelegate.animationValue != animationValue;
  }
}
