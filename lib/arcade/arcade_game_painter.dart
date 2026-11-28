import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'arcade_models.dart';
import 'arcade_game_controller.dart';
import 'weapon_system.dart';
import 'enemy_system.dart';
import 'parallax_background_system.dart';

class ArcadeGamePainter extends CustomPainter {
  final ArcadeGameController controller;
  late final ParallaxBackgroundSystem _parallax;
  final Map<String, TextPainter> _labelCache = {};

  ArcadeGamePainter({required this.controller}) : super(repaint: controller) {
    _parallax = ParallaxBackgroundSystem(
      stageId: controller.level,
      isRevisionStage: controller.isRevisionStage,
    );
  }

  TextPainter _getCachedLabelPainter(
    String text, {
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w800,
    List<Shadow>? shadows,
  }) {
    final key = '$text|${fontSize.toStringAsFixed(1)}|${color.toARGB32()}|${fontWeight.value}';
    final cached = _labelCache[key];
    if (cached != null) return cached;
    if (_labelCache.length > 96) {
      _labelCache.clear();
    }
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: 0.7,
          shadows: shadows,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    _labelCache[key] = tp;
    return tp;
  }

  @override
  void paint(Canvas canvas, Size size) {
    controller.setViewport(size.width, size.height);

    // Save initial state
    canvas.save();

    // Screen Shake effect when hit
    if (controller.screenShake > 0) {
      final rand = math.Random();
      final shakeX = (rand.nextDouble() - 0.5) * controller.screenShake * 16.0;
      final shakeY = (rand.nextDouble() - 0.5) * controller.screenShake * 16.0;
      canvas.translate(shakeX, shakeY);
    }

    // 1. Draw Deep Biological Vascular Background with Parallax
    _drawParallaxBackground(canvas, size);

    // Camera Translation (World coordinates -> Screen coordinates)
    canvas.save();
    canvas.translate(-controller.cameraX, 0);

    // 2. Draw Distant Erythrocytes & Background Cells
    _drawBackgroundCells(canvas, size);

    // 3. Draw Organic Biological Tunnel Walls (Ceiling, Floor, Villi Fringe)
    _drawTunnelWalls(canvas, size);

    // 4. Draw Checkpoint Nanogates
    _drawCheckpoints(canvas, size);

    // 5. Draw Collectibles (Smiley Cell Bubbles, Crystals, Pills, Shields)
    _drawCollectibles(canvas, size);

    // 6. Draw Obstacles (Green Toothy Monster, Spiky Virus, Dripping Acid)
    _drawObstacles(canvas, size);

    // 7. Draw 2D Animated Enemies
    _drawEnemies(canvas, size);

    // 8. Draw Projectiles (Lasers, Plasma, Waves, Enemy Acid)
    _drawProjectiles(canvas, size);

    // 9. Draw Boss Monster (if approaching or in Boss Chamber)
    _drawBoss(canvas, size);

    // 10. Draw Player Capsule with Headlight Spotlight, Weapon Barrels & Shield
    _drawPlayerCapsule(canvas, size);

    // 11. Draw Particle Systems (Bubbles, Sparks, Lasers, Confetti)
    _drawParticles(canvas, size);

    // 12. Draw Floating Arcade Popups (+20, +50 XP, Combo)
    _drawFloatingTexts(canvas, size);

    canvas.restore(); // Restore world translation
    canvas.restore(); // Restore screen shake
  }

  // ==========================================================================
  // 1. 3-LAYER PARALLAX BIOLOGICAL BACKGROUND (SPEED x0.2, x0.5, x1.0)
  // ==========================================================================
  void _drawParallaxBackground(Canvas canvas, Size size) {
    _parallax.render(
      canvas,
      size,
      controller.cameraX,
      controller.gameTime,
      bossMix: controller.bossArenaMix,
    );
  }

  // ==========================================================================
  // 2. PARALLAX FLOATING BIO-CELLS (SOFT ORGANIC DEPTH)
  // ==========================================================================
  void _drawBackgroundCells(Canvas canvas, Size size) {
    final tint = controller.world.primaryColor;
    for (final cell in controller.backgroundCells) {
      final screenX = cell.position.dx - (controller.cameraX * (1.0 - cell.depth));
      if (screenX < controller.cameraX - 80 || screenX > controller.cameraX + size.width + 80) {
        continue;
      }

      final cellY = cell.position.dy + math.sin(controller.gameTime * 1.1 + cell.wobblePhase) * 10.0;

      canvas.save();
      canvas.translate(cell.position.dx, cellY);
      canvas.rotate(cell.rotation + controller.gameTime * 0.12);

      final r = cell.radius * (0.55 + cell.depth * 0.4);
      final alpha = (0.12 + cell.depth * 0.22).clamp(0.08, 0.34);

      final outerPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            tint.withValues(alpha: alpha),
            const Color(0xFF123B5A).withValues(alpha: alpha * 0.5),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));

      canvas.drawCircle(Offset.zero, r, outerPaint);
      canvas.drawCircle(
        Offset.zero,
        r * 0.44,
        Paint()..color = const Color(0xFF0E4170).withValues(alpha: alpha * 0.65),
      );

      canvas.restore();
    }
  }

  // ==========================================================================
  // 3. ORGANIC TUNNEL WALLS (SMOOTH BEZIER MUCOSAL FOLDS — ZERO SAWTOOTH)
  // ==========================================================================
  void _drawTunnelWalls(Canvas canvas, Size size) {
    final world = controller.world;
    final startX = (controller.cameraX - 100.0).clamp(0.0, controller.totalDistance);
    final endX = (controller.cameraX + size.width + 100.0).clamp(0.0, controller.totalDistance);
    const double step = 28.0;

    // --- CEILING PATH ---
    final ceilingPath = Path();
    ceilingPath.moveTo(startX, -50.0);
    ceilingPath.lineTo(startX, controller.tunnel.getCeilingY(startX, controller.gameTime));

    for (double x = startX; x <= endX; x += step) {
      final y = controller.tunnel.getCeilingY(x, controller.gameTime);
      final nextX = x + step;
      final nextY = controller.tunnel.getCeilingY(nextX, controller.gameTime);
      final midX = (x + nextX) * 0.5;
      final foldY = (y + nextY) * 0.5 + math.sin(x * 0.045 + controller.gameTime * 1.4) * 5.0;
      ceilingPath.quadraticBezierTo(midX, foldY, nextX, nextY);
    }
    ceilingPath.lineTo(endX, -50.0);
    ceilingPath.close();

    final ceilRect = Rect.fromLTRB(startX, -50, endX, 220);
    final ceilPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0E4170),
          world.tunnelDeepColor.withValues(alpha: 0.90),
          world.tunnelWallColor.withValues(alpha: 0.78),
        ],
      ).createShader(ceilRect);
    canvas.drawPath(ceilingPath, ceilPaint);

    // --- FLOOR PATH ---
    final floorPath = Path();
    floorPath.moveTo(startX, size.height + 50.0);
    floorPath.lineTo(startX, controller.tunnel.getFloorY(startX, controller.gameTime));

    for (double x = startX; x <= endX; x += step) {
      final y = controller.tunnel.getFloorY(x, controller.gameTime);
      final nextX = x + step;
      final nextY = controller.tunnel.getFloorY(nextX, controller.gameTime);
      final midX = (x + nextX) * 0.5;
      final foldY = (y + nextY) * 0.5 - math.cos(x * 0.045 + controller.gameTime * 1.4) * 5.0;
      floorPath.quadraticBezierTo(midX, foldY, nextX, nextY);
    }
    floorPath.lineTo(endX, size.height + 50.0);
    floorPath.close();

    final floorRect = Rect.fromLTRB(startX, 300, endX, size.height + 50);
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF0E4170),
          world.tunnelDeepColor.withValues(alpha: 0.90),
          world.tunnelWallColor.withValues(alpha: 0.78),
        ],
      ).createShader(floorRect);
    canvas.drawPath(floorPath, floorPaint);

    // --- SMOOTH MUCOSAL FRINGE & ORGAN-SPECIFIC DETAILS ---
    _drawVilliFringe(canvas, startX, endX);
  }

  void _drawVilliFringe(Canvas canvas, double startX, double endX) {
    final world = controller.world;
    final Color fringeTint = Color.lerp(world.tunnelWallColor, world.tunnelFringeColor, 0.55)!;

    final fringeFill = Paint()
      ..color = fringeTint.withValues(alpha: 0.42)
      ..style = PaintingStyle.fill;

    final rimPaint = Paint()
      ..color = const Color(0xFF20D5E8).withValues(alpha: 0.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Organ-dependent organic lobe spacing & amplitude (gentle, zero zigzag spikes!)
    final double lobeWidth = (controller.level == 3 || controller.level == 4) ? 26.0 : 38.0;
    final double lobeDepth = (controller.level == 3 || controller.level == 4) ? 10.5 : 7.5;
    final double alignedStart = (startX / lobeWidth).floor() * lobeWidth;

    final topMucosalPath = Path();
    final topRimPath = Path();
    bool firstTop = true;
    for (double x = alignedStart; x <= endX + lobeWidth; x += lobeWidth) {
      final y1 = controller.tunnel.getCeilingY(x, controller.gameTime);
      final y2 = controller.tunnel.getCeilingY(x + lobeWidth, controller.gameTime);
      final midX = x + lobeWidth * 0.5;
      final ctrlY = ((y1 + y2) * 0.5) + lobeDepth + math.sin(x * 0.08 + controller.gameTime * 1.8) * 2.2;

      if (firstTop) {
        topMucosalPath.moveTo(x, y1 - 10);
        topMucosalPath.lineTo(x, y1);
        topRimPath.moveTo(x, y1);
        firstTop = false;
      }
      topMucosalPath.quadraticBezierTo(midX, ctrlY, x + lobeWidth, y2);
      topRimPath.quadraticBezierTo(midX, ctrlY, x + lobeWidth, y2);
    }
    topMucosalPath.lineTo(endX + lobeWidth, -40.0);
    topMucosalPath.close();
    canvas.drawPath(topMucosalPath, fringeFill);
    canvas.drawPath(topRimPath, rimPaint);

    // Floor organic undulating mucosal cushion
    final botMucosalPath = Path();
    final botRimPath = Path();
    bool firstBot = true;
    for (double x = alignedStart; x <= endX + lobeWidth; x += lobeWidth) {
      final y1 = controller.tunnel.getFloorY(x, controller.gameTime);
      final y2 = controller.tunnel.getFloorY(x + lobeWidth, controller.gameTime);
      final midX = x + lobeWidth * 0.5;
      final ctrlY = ((y1 + y2) * 0.5) - lobeDepth - math.cos(x * 0.08 + controller.gameTime * 1.8) * 2.2;

      if (firstBot) {
        botMucosalPath.moveTo(x, y1 + 10);
        botMucosalPath.lineTo(x, y1);
        botRimPath.moveTo(x, y1);
        firstBot = false;
      }
      botMucosalPath.quadraticBezierTo(midX, ctrlY, x + lobeWidth, y2);
      botRimPath.quadraticBezierTo(midX, ctrlY, x + lobeWidth, y2);
    }
    botMucosalPath.lineTo(endX + lobeWidth, 1200.0);
    botMucosalPath.close();
    canvas.drawPath(botMucosalPath, fringeFill);
    canvas.drawPath(botRimPath, rimPaint);
  }

  // ==========================================================================
  // 4. CHECKPOINT QUESTION PORTALS (PROMINENT, INVITING & CLEARLY VISIBLE)
  // ==========================================================================
  void _drawCheckpoints(Canvas canvas, Size size) {
    for (final cp in controller.checkpoints) {
      if (cp.worldX < controller.cameraX - 120 || cp.worldX > controller.cameraX + size.width + 120) {
        continue;
      }

      final ceilY = controller.tunnel.getCeilingY(cp.worldX, controller.gameTime);
      final floorY = controller.tunnel.getFloorY(cp.worldX, controller.gameTime);
      final midY = (ceilY + floorY) / 2;

      final Color color = cp.isCompleted
          ? (cp.isAnswerCorrect ? const Color(0xFF10B981) : const Color(0xFFFBBF24))
          : (cp.isRevision ? const Color(0xFFFBBF24) : const Color(0xFF22D3EE));

      final double pulse = 1.0 + math.sin(controller.gameTime * 4.0 + cp.index) * 0.09;

      // Luminous light column portal
      final gatePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.42),
            color.withValues(alpha: 0.08),
          ],
        ).createShader(Rect.fromLTRB(cp.worldX - 24, ceilY, cp.worldX + 24, floorY));

      canvas.drawRect(Rect.fromLTRB(cp.worldX - 24, ceilY, cp.worldX + 24, floorY), gatePaint);

      final beamPaint = Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2;
      canvas.drawLine(Offset(cp.worldX, ceilY), Offset(cp.worldX, floorY), beamPaint);

      // Orbiting portal rings
      for (int i = 0; i < 3; i++) {
        final ringY = ceilY + (floorY - ceilY) * ((i + 1) / 4);
        final ringWidth = 30.0 + math.sin(controller.gameTime * 3.2 + i) * 9.0;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cp.worldX, ringY), width: ringWidth, height: 13.0),
          Paint()
            ..color = color.withValues(alpha: 0.72)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }

      // Larger, inviting Question Beacon Core
      final double badgeR = 23.0 * pulse;
      canvas.drawCircle(
        Offset(cp.worldX, midY),
        badgeR + 10.0,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: 0.50),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: Offset(cp.worldX, midY), radius: badgeR + 10.0)),
      );

      canvas.drawCircle(
        Offset(cp.worldX, midY),
        badgeR,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF165B94),
              const Color(0xFF0E4170),
            ],
          ).createShader(Rect.fromCircle(center: Offset(cp.worldX, midY), radius: badgeR)),
      );
      canvas.drawCircle(
        Offset(cp.worldX, midY),
        badgeR,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8,
      );

      // Question mark or checkmark emblem inside portal
      final String symbol = cp.isCompleted ? '✓' : '?';
      final tpSymbol = _getCachedLabelPainter(
        symbol,
        fontSize: 22.0,
        color: cp.isCompleted ? color : Colors.white,
        fontWeight: FontWeight.w900,
      );
      tpSymbol.paint(
        canvas,
        Offset(cp.worldX - tpSymbol.width / 2, midY - tpSymbol.height / 2),
      );

      // Floating "QUESTION #N" tag above beacon when active
      if (!cp.isCompleted) {
        final label = cp.isRevision ? 'RÉVISION #${cp.index}' : 'QUESTION #${cp.index}';
        final tpLabel = _getCachedLabelPainter(
          label,
          fontSize: 10.5,
          color: Colors.white,
          fontWeight: FontWeight.w900,
        );
        final pillRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cp.worldX, midY - badgeR - 18.0),
            width: tpLabel.width + 16.0,
            height: 20.0,
          ),
          const Radius.circular(10),
        );
        canvas.drawRRect(pillRect, Paint()..color = const Color(0xFF0E4170).withValues(alpha: 0.92));
        canvas.drawRRect(
          pillRect,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
        tpLabel.paint(
          canvas,
          Offset(cp.worldX - tpLabel.width / 2, midY - badgeR - 18.0 - tpLabel.height / 2),
        );
      }
    }
  }

  // ==========================================================================
  // 5. COLLECTIBLES
  // ==========================================================================
  void _drawCollectibles(Canvas canvas, Size size) {
    for (final item in controller.collectibles) {
      if (item.isCollected) continue;
      if (item.position.dx < controller.cameraX - 60 || item.position.dx > controller.cameraX + size.width + 60) {
        continue;
      }

      final floatY = item.position.dy + math.sin(controller.gameTime * 2.8 + item.animPhase) * 6.0;
      final pos = Offset(item.position.dx, floatY);

      switch (item.type) {
        case CollectibleType.cellBubble:
          _drawCellBubble(canvas, pos, item.radius);
          break;
        case CollectibleType.atpCrystal:
          _drawAtpCrystal(canvas, pos, item.radius);
          break;
        case CollectibleType.vitaminCapsule:
          _drawVitaminCapsule(canvas, pos, item.radius);
          break;
        case CollectibleType.heartBoost:
          _drawHeartBoost(canvas, pos, item.radius);
          break;
        case CollectibleType.shieldBoost:
          _drawShieldBoost(canvas, pos, item.radius);
          break;
        case CollectibleType.weaponUpgrade:
          _drawWeaponUpgrade(canvas, pos, item.radius);
          break;
      }
    }
  }

  // Smiling Cell Bubble (Direct homage to Reference Image 1)
  void _drawCellBubble(Canvas canvas, Offset pos, double r) {
    // Soft luminous radial glow (fast on all devices)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFB7185).withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pos, radius: r + 7));
    canvas.drawCircle(pos, r + 7, glowPaint);

    final membranePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF1F2), Color(0xFFFDA4AF), Color(0xFFE11D48)],
      ).createShader(Rect.fromCircle(center: pos, radius: r));
    canvas.drawCircle(pos, r, membranePaint);

    // Cute cartoon smiley face inside the cell!
    final eyePaint = Paint()..color = const Color(0xFF881337);
    canvas.drawCircle(pos + const Offset(-4, -2), 2.2, eyePaint);
    canvas.drawCircle(pos + const Offset(4, -2), 2.2, eyePaint);

    final smilePaint = Paint()
      ..color = const Color(0xFF881337)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(
      Rect.fromCenter(center: pos + const Offset(0, 1), width: 8, height: 6),
      0,
      math.pi,
      false,
      smilePaint,
    );

    // Glass shine highlight
    final shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(pos + const Offset(-5, -6), 2.5, shinePaint);
  }

  // Golden ATP Crystal
  void _drawAtpCrystal(Canvas canvas, Offset pos, double r) {
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFBBF24).withValues(alpha: 0.42),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pos, radius: r + 8));
    canvas.drawCircle(pos, r + 8, glowPaint);

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(controller.gameTime * 1.5);

    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi) / 3;
      final pt = Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();

    final crystalPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFBEB), Color(0xFFFBBF24), Color(0xFFB45309)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    canvas.drawPath(path, crystalPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);

    canvas.restore();
  }

  // Medical Vitamin Capsule
  void _drawVitaminCapsule(Canvas canvas, Offset pos, double r) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(0.4 + math.sin(controller.gameTime * 2.0) * 0.15);

    final rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: r * 2.2, height: r * 1.2),
      Radius.circular(r * 0.6),
    );

    // Left half red, right half white
    final redPaint = Paint()..color = const Color(0xFFEF4444);
    final whitePaint = Paint()..color = Colors.white;

    canvas.save();
    canvas.clipRRect(rRect);
    canvas.drawRect(Rect.fromLTRB(-r * 1.5, -r, 0, r), redPaint);
    canvas.drawRect(Rect.fromLTRB(0, -r, r * 1.5, r), whitePaint);
    canvas.restore();

    final borderPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rRect, borderPaint);

    canvas.restore();
  }

  // Health Nanobot Heart
  void _drawHeartBoost(Canvas canvas, Offset pos, double r) {
    final scale = 1.0 + math.sin(controller.gameTime * 4.0) * 0.12;
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF10B981).withValues(alpha: 0.45),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r + 8));
    canvas.drawCircle(Offset.zero, r + 8, glowPaint);

    final heartPath = Path()
      ..moveTo(0, r * 0.35)
      ..cubicTo(-r * 1.1, -r * 0.6, -r * 0.55, -r * 1.1, 0, -r * 0.4)
      ..cubicTo(r * 0.55, -r * 1.1, r * 1.1, -r * 0.6, 0, r * 0.35);

    final heartPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawPath(heartPath, heartPaint);

    canvas.restore();
  }

  // Biomagnetic Energy Shield Boost
  void _drawShieldBoost(Canvas canvas, Offset pos, double r) {
    final scale = 1.0 + math.sin(controller.gameTime * 3.5) * 0.08;
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF818CF8).withValues(alpha: 0.45),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r + 9));
    canvas.drawCircle(Offset.zero, r + 9, glowPaint);

    final shieldPath = Path()
      ..moveTo(0, -r)
      ..lineTo(r * 0.9, -r * 0.4)
      ..lineTo(r * 0.8, r * 0.5)
      ..lineTo(0, r)
      ..lineTo(-r * 0.8, r * 0.5)
      ..lineTo(-r * 0.9, -r * 0.4)
      ..close();

    final shieldPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFC7D2FE), Color(0xFF818CF8), Color(0xFF4338CA)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    canvas.drawPath(shieldPath, shieldPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawPath(shieldPath, borderPaint);

    canvas.restore();
  }

  // Weapon Upgrade Orb
  void _drawWeaponUpgrade(Canvas canvas, Offset pos, double r) {
    final scale = 1.0 + math.sin(controller.gameTime * 4.5) * 0.1;
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.50),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r + 9));
    canvas.drawCircle(Offset.zero, r + 9, glowPaint);

    final orbPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFE0F2FE), Color(0xFF38BDF8), Color(0xFF0369A1)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    canvas.drawCircle(Offset.zero, r, orbPaint);

    // Lightning bolt icon inside
    final bolt = Path()
      ..moveTo(1, -r * 0.6)
      ..lineTo(-r * 0.35, 1)
      ..lineTo(0, 1)
      ..lineTo(-1, r * 0.6)
      ..lineTo(r * 0.35, -1)
      ..lineTo(0, -1)
      ..close();
    final boltPaint = Paint()..color = Colors.white;
    canvas.drawPath(bolt, boltPaint);

    canvas.restore();
  }

  // ==========================================================================
  // 6. OBSTACLES (GREEN TOOTHY MONSTER, SPIKY VIRUS, ACID DROPLET)
  // ==========================================================================
  void _drawObstacles(Canvas canvas, Size size) {
    for (final obs in controller.obstacles) {
      if (obs.position.dx < controller.cameraX - 80 || obs.position.dx > controller.cameraX + size.width + 80) {
        continue;
      }

      switch (obs.type) {
        case ObstacleType.toothyMicrobe:
          _drawToothyMicrobe(canvas, obs);
          break;
        case ObstacleType.spikyVirus:
          _drawSpikyVirus(canvas, obs);
          break;
        case ObstacleType.acidDroplet:
          _drawAcidDroplet(canvas, obs);
          break;
        case ObstacleType.mucosalSpike:
          _drawMucosalSpike(canvas, obs);
          break;
        case ObstacleType.inflammatoryZone:
          _drawInflammatoryZone(canvas, obs);
          break;
        case ObstacleType.bioFilament:
          _drawBioFilament(canvas, obs);
          break;
      }
    }
  }

  void _drawMucosalSpike(Canvas canvas, ArcadeObstacle obs) {
    final bool fromCeiling = obs.variant % 2 == 1;
    final double anchorY = fromCeiling
        ? controller.tunnel.getCeilingY(obs.baseX, controller.gameTime) - 4.0
        : controller.tunnel.getFloorY(obs.baseX, controller.gameTime) + 4.0;
    final double extendFactor = obs.pulseScale.clamp(0.18, 1.08);
    final double dirY = fromCeiling ? 1.0 : -1.0;
    final double tipY = anchorY + dirY * obs.height * extendFactor;
    final double halfBase = obs.radius * (0.72 + (1.0 - extendFactor) * 0.15);

    if (obs.triggerTimer > 0 && !obs.isStunned) {
      canvas.drawCircle(
        Offset(obs.position.dx, tipY),
        obs.radius * 0.65,
        Paint()
          ..color = const Color(0xFFFB7185).withValues(alpha: 0.42)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    final spikePath = Path()
      ..moveTo(obs.position.dx - halfBase, anchorY)
      ..quadraticBezierTo(
        obs.position.dx - halfBase * 0.35,
        anchorY + dirY * obs.height * extendFactor * 0.65,
        obs.position.dx,
        tipY,
      )
      ..quadraticBezierTo(
        obs.position.dx + halfBase * 0.35,
        anchorY + dirY * obs.height * extendFactor * 0.65,
        obs.position.dx + halfBase,
        anchorY,
      )
      ..close();

    final bodyColor = obs.isStunned
        ? const Color(0xFF64748B)
        : const Color(0xFFF43F5E);
    final coreColor = obs.isStunned
        ? const Color(0xFF94A3B8)
        : const Color(0xFFFDA4AF);

    canvas.drawPath(
      spikePath,
      Paint()
        ..shader = LinearGradient(
          begin: fromCeiling ? Alignment.topCenter : Alignment.bottomCenter,
          end: fromCeiling ? Alignment.bottomCenter : Alignment.topCenter,
          colors: [const Color(0xFF881337), bodyColor, coreColor],
        ).createShader(Rect.fromPoints(
          Offset(obs.position.dx - halfBase, anchorY),
          Offset(obs.position.dx + halfBase, tipY),
        )),
    );

    canvas.drawCircle(
      Offset(obs.position.dx, tipY - dirY * 4.0),
      4.2,
      Paint()..color = const Color(0xFFFDE047),
    );
  }

  void _drawInflammatoryZone(Canvas canvas, ArcadeObstacle obs) {
    final pos = obs.position;
    final r = obs.radius;
    final bool soothed = obs.isSoothed;
    final pulse = obs.pulseScale.clamp(0.85, 1.24);

    final Color outer = soothed ? const Color(0xFF34D399) : const Color(0xFFFB7185);
    final Color inner = soothed ? const Color(0xFFA7F3D0) : const Color(0xFFFBBF24);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          inner.withValues(alpha: soothed ? 0.35 : 0.68),
          outer.withValues(alpha: soothed ? 0.15 : 0.32),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pos, radius: r * pulse * 1.28));
    canvas.drawCircle(pos, r * pulse * 1.28, glowPaint);

    final ringPaint = Paint()
      ..color = outer.withValues(alpha: soothed ? 0.45 : 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = soothed ? 1.8 : 2.8;
    canvas.drawCircle(pos, r * pulse, ringPaint);

    if (!soothed) {
      for (int i = 0; i < 3; i++) {
        final a = obs.animPhase + i * 2.1 + controller.gameTime * 2.2;
        final off = Offset(math.cos(a) * r * 0.44, math.sin(a) * r * 0.44);
        canvas.drawCircle(pos + off, 4.2, Paint()..color = const Color(0xFFFDE047));
      }
    }
  }

  void _drawBioFilament(Canvas canvas, ArcadeObstacle obs) {
    final ceilY = controller.tunnel.getCeilingY(obs.baseX, controller.gameTime);
    final sway = obs.swayOffset;
    final reachedH = obs.height * obs.pulseScale.clamp(0.75, 1.22);
    final endPt = Offset(obs.baseX + sway, ceilY + reachedH);

    final strandPaint = Paint()
      ..color = (obs.isStunned ? const Color(0xFF94A3B8) : const Color(0xFFFDBA74))
          .withValues(alpha: 0.80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(obs.baseX, ceilY - 4.0)
      ..quadraticBezierTo(
        obs.baseX - sway * 0.45,
        ceilY + reachedH * 0.5,
        endPt.dx,
        endPt.dy,
      );
    canvas.drawPath(path, strandPaint);

    // Bulbous mucous node at tip
    canvas.drawCircle(
      endPt,
      10.5,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFEF3C7), Color(0xFFFB923C)],
        ).createShader(Rect.fromCircle(center: endPt, radius: 10.5)),
    );
  }

  // The Green Monster from Reference Image 1 (mouth chomping, tracking eye stalk, alert lunge!)
  void _drawToothyMicrobe(Canvas canvas, ArcadeObstacle obs) {
    final pos = obs.position;
    final r = obs.radius;
    final bool lunging = obs.triggerTimer > 0 && !obs.isStunned;

    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    final pulse = (obs.pulseScale + (lunging ? 0.08 : 0.0)).clamp(0.85, 1.22);
    final dirSign = obs.velocityX >= 0 ? 1.0 : -1.0;
    canvas.scale(pulse, pulse * (1.0 - (pulse - 1.0) * 0.4));

    if (lunging) {
      canvas.drawCircle(
        Offset.zero,
        r * 1.35,
        Paint()
          ..color = const Color(0xFFA3E635).withValues(alpha: 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    // Green slime body
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF84CC16), Color(0xFF4D7C0F), Color(0xFF14532D)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));

    final bodyPath = Path()
      ..moveTo(-r * 1.1, r * 0.6)
      ..quadraticBezierTo(-r * 0.9, -r * 0.3, -r * 0.2, -r * 0.7)
      ..quadraticBezierTo(r * 0.6, -r * 0.8, r * 1.1, -r * 0.1)
      ..quadraticBezierTo(r * 1.2, r * 0.7, 0, r * 0.75)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Animated Chomping Mouth
    final chompOpen = 0.25 +
        (lunging ? 0.30 : 0.0) +
        math.sin(obs.animPhase * 2.2).abs() * 0.25;
    final mouthPath = Path()
      ..moveTo(-r * 0.7, r * 0.18)
      ..quadraticBezierTo(0, -r * (0.25 + chompOpen), r * 0.7, r * 0.18)
      ..quadraticBezierTo(0, r * (0.45 + chompOpen * 0.6), -r * 0.7, r * 0.18);

    canvas.drawPath(mouthPath, Paint()..color = const Color(0xFF7F1D1D));

    // Sharp White Teeth
    final toothPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 4; i++) {
      final toothX = -r * 0.5 + i * (r * 0.33);
      final toothPath = Path()
        ..moveTo(toothX - 3, -r * 0.06)
        ..lineTo(toothX, r * (0.14 + chompOpen * 0.25))
        ..lineTo(toothX + 3, -r * 0.06)
        ..close();
      canvas.drawPath(toothPath, toothPaint);
    }

    // Curved Pink Tongue
    canvas.drawArc(
      Rect.fromCenter(center: Offset(r * 0.1, r * 0.22), width: r * 0.5, height: r * 0.35),
      0,
      math.pi,
      true,
      Paint()..color = const Color(0xFFFB7185),
    );

    // Big Eyeball on Stalk tracking the player
    final stalkOffset = Offset(-r * 0.38 + dirSign * 2.0, -r * 1.05);
    canvas.drawLine(
      Offset(-r * 0.3, -r * 0.5),
      stalkOffset,
      Paint()
        ..color = const Color(0xFF4D7C0F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(stalkOffset, 9.0, Paint()..color = const Color(0xFFFEF08A));

    final toPlayer = controller.player.position - (pos + stalkOffset);
    final pupilDir = toPlayer.distance > 1.0
        ? (toPlayer / toPlayer.distance) * 3.4
        : const Offset(-3.2, 0.0);
    canvas.drawCircle(stalkOffset + pupilDir, 4.2, Paint()..color = Colors.black);
    canvas.drawCircle(stalkOffset + pupilDir + const Offset(-1.0, -1.6), 1.5, Paint()..color = Colors.white);

    canvas.restore();
  }

  // Spiky Pathogen Sphere (orbital or proximity-reactive with danger halo)
  void _drawSpikyVirus(Canvas canvas, ArcadeObstacle obs) {
    final pos = obs.position;
    final r = obs.radius;
    final bool alerted = obs.triggerTimer > 0 && !obs.isStunned;

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(obs.pulseScale.clamp(0.85, 1.22));
    canvas.rotate(obs.animPhase * (alerted ? 1.5 : 0.9));

    if (alerted) {
      canvas.drawCircle(
        Offset.zero,
        r + 12,
        Paint()
          ..color = const Color(0xFFE879F9).withValues(alpha: 0.36)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
    }

    // Spikes radiating
    final spikePaint = Paint()
      ..color = obs.isStunned ? const Color(0xFF94A3B8) : const Color(0xFF9333EA);
    final stemPaint = Paint()
      ..color = obs.isStunned ? const Color(0xFF64748B) : const Color(0xFF7E22CE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi) / 4;
      final tip = Offset(math.cos(angle) * (r + 8), math.sin(angle) * (r + 8));
      canvas.drawLine(Offset.zero, tip, stemPaint);
      canvas.drawCircle(tip, 3.6, spikePaint);
    }

    // Core body
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFA855F7), Color(0xFF6B21A8), Color(0xFF3B0764)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    canvas.drawCircle(Offset.zero, r, bodyPaint);

    // Menacing eyes
    final eyeColor = alerted ? const Color(0xFFFB7185) : const Color(0xFFFDE047);
    final eyePaint = Paint()..color = eyeColor;
    canvas.drawCircle(const Offset(-6, -2), 3.5, eyePaint);
    canvas.drawCircle(const Offset(6, -2), 3.5, eyePaint);
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(const Offset(-7, -2), 1.8, pupilPaint);
    canvas.drawCircle(const Offset(5, -2), 1.8, pupilPaint);

    canvas.restore();
  }

  // Dripping Acid Droplet (ceiling swell telegraph -> corrosive streak & floor target ring!)
  void _drawAcidDroplet(Canvas canvas, ArcadeObstacle obs) {
    final pos = obs.position;
    final r = obs.radius * obs.pulseScale.clamp(0.75, 1.28);
    final floorY = controller.tunnel.getFloorY(obs.baseX, controller.gameTime);

    // Subtle warning ripple on tunnel floor showing drop trajectory
    if (obs.triggerTimer <= 0.15) {
      final dropFrac = ((pos.dy / math.max(1.0, floorY)).clamp(0.0, 1.0));
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(obs.baseX, floorY - 3.0),
          width: r * (1.2 + dropFrac * 1.1),
          height: 6.0,
        ),
        Paint()
          ..color = const Color(0xFFA3E635).withValues(alpha: 0.28 + dropFrac * 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF84CC16).withValues(alpha: obs.triggerTimer > 0 ? 0.68 : 0.48),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pos, radius: r + 11));
    canvas.drawCircle(pos, r + 11, glowPaint);

    final double tailStretch = obs.triggerTimer > 0 ? 1.15 : 1.75;
    final dropPath = Path()
      ..moveTo(pos.dx, pos.dy - r * tailStretch)
      ..cubicTo(pos.dx - r, pos.dy, pos.dx - r * 0.85, pos.dy + r, pos.dx, pos.dy + r)
      ..cubicTo(pos.dx + r * 0.85, pos.dy + r, pos.dx + r, pos.dy, pos.dx, pos.dy - r * tailStretch);

    final dropPaint = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFFECFCCB), Color(0xFFA3E635), Color(0xFF3F6212)],
      ).createShader(Rect.fromCircle(center: pos, radius: r));
    canvas.drawPath(dropPath, dropPaint);
    canvas.drawCircle(
      pos + Offset(-r * 0.25, r * 0.22),
      r * 0.24,
      Paint()..color = Colors.white.withValues(alpha: 0.72),
    );
  }

  // ==========================================================================
  // 6B. 2D ANIMATED ENEMIES (5 FIERCE REACTIVE ARCHETYPES + DEFEAT FX)
  // ==========================================================================
  void _drawEnemies(Canvas canvas, Size size) {
    // Draw Multi-Layer Defeat Shockwaves & Fragment Burst Animations
    for (final eff in controller.defeatedEnemies) {
      if (eff.position.dx < controller.cameraX - 90 ||
          eff.position.dx > controller.cameraX + size.width + 90) {
        continue;
      }
      final t = eff.progress;
      final fade = (1.0 - t).clamp(0.0, 1.0);
      final ringR = eff.radius * (0.85 + t * 2.4);

      canvas.save();
      canvas.translate(eff.position.dx, eff.position.dy);
      // Outer shockwave ring
      canvas.drawCircle(
        Offset.zero,
        ringR,
        Paint()
          ..color = eff.color.withValues(alpha: fade * 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (4.8 * fade).clamp(1.0, 4.8),
      );
      // Secondary white sonic ring
      canvas.drawCircle(
        Offset.zero,
        ringR * 0.65,
        Paint()
          ..color = Colors.white.withValues(alpha: fade * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (2.4 * fade).clamp(0.6, 2.4),
      );
      // Dissolving radial bio-shards
      final shardPaint = Paint()..color = eff.color.withValues(alpha: fade);
      for (int s = 0; s < 6; s++) {
        final a = s * (math.pi / 3.0) + t * 2.2 * eff.spinDir + (eff.seed % 5) * 0.3;
        final d = eff.radius * (0.4 + t * 1.9);
        final sr = (4.5 * (1.0 - t * 0.75)).clamp(1.0, 5.0);
        canvas.drawCircle(Offset(math.cos(a) * d, math.sin(a) * d), sr, shardPaint);
      }
      canvas.restore();
    }

    for (final enemy in controller.enemies) {
      if (enemy.isDead) continue;
      if (enemy.position.dx < controller.cameraX - 80 ||
          enemy.position.dx > controller.cameraX + size.width + 80) {
        continue;
      }

      canvas.save();
      canvas.translate(enemy.position.dx, enemy.position.dy);
      canvas.rotate(enemy.facingTilt);

      double scaleX = 1.0;
      double scaleY = 1.0;
      if (enemy.damageWobbleTimer > 0) {
        final wob = math.sin(enemy.damageWobbleTimer * 48.0) * (enemy.damageWobbleTimer / 0.34) * 0.22;
        scaleX = 1.0 - wob;
        scaleY = 1.0 + wob;
      } else if (enemy.isWindingUpAttack) {
        final swell = 1.0 + math.sin(controller.gameTime * 22.0) * 0.11 + 0.08;
        scaleX = swell;
        scaleY = swell;
      } else if (enemy.attackRecoilTimer > 0) {
        final rec = (enemy.attackRecoilTimer / 0.24) * 0.20;
        scaleX = 1.0 + rec;
        scaleY = 1.0 - rec * 0.65;
      }
      canvas.scale(scaleX, scaleY);

      final isFlashing = enemy.isFlashing;

      if (enemy.isWindingUpAttack) {
        canvas.drawCircle(
          Offset.zero,
          enemy.radius + 10.0,
          Paint()
            ..color = const Color(0xFFFBBF24).withValues(alpha: 0.45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      } else if (enemy.isChasing) {
        canvas.drawCircle(
          Offset.zero,
          enemy.radius + 9.0,
          Paint()
            ..shader = RadialGradient(
              colors: [
                const Color(0xFFFB7185).withValues(alpha: 0.38),
                Colors.transparent,
              ],
            ).createShader(Rect.fromCircle(center: Offset.zero, radius: enemy.radius + 9.0)),
        );
      } else if (enemy.isDodging || enemy.isFleeing) {
        final wakePaint = Paint()
          ..color = const Color(0xFF5EEAD4).withValues(alpha: 0.50)
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(-enemy.radius * 1.1, -6), Offset(-enemy.radius * 1.7, -9), wakePaint);
        canvas.drawLine(Offset(-enemy.radius * 1.1, 6), Offset(-enemy.radius * 1.7, 9), wakePaint);
      }

      switch (enemy.type) {
        case EnemyType.helicoGrub:
          _drawHelicoGrub(canvas, enemy, isFlashing);
          break;
        case EnemyType.spikeVirion:
          _drawSpikeVirion(canvas, enemy, isFlashing);
          break;
        case EnemyType.cytokineBlob:
          _drawCytokineBlob(canvas, enemy, isFlashing);
          break;
        case EnemyType.acidSentry:
          _drawAcidSentry(canvas, enemy, isFlashing);
          break;
        case EnemyType.toxicSpore:
          _drawToxicSpore(canvas, enemy, isFlashing);
          break;
      }

      // Battle damage scar cracks when injured (<=50% HP)
      if (enemy.isInjured && !isFlashing) {
        final crackPaint = Paint()
          ..color = const Color(0xFFFEF08A).withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(
          Path()
            ..moveTo(-enemy.radius * 0.4, -enemy.radius * 0.35)
            ..lineTo(-enemy.radius * 0.05, 0)
            ..lineTo(-enemy.radius * 0.25, enemy.radius * 0.32),
          crackPaint,
        );
      }

      canvas.scale(1.0 / scaleX, 1.0 / scaleY);
      canvas.rotate(-enemy.facingTilt);

      if (enemy.currentHp < enemy.maxHp) {
        final barWidth = enemy.radius * 2.2;
        const barHeight = 4.8;
        final barY = -enemy.radius - 14.0;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-barWidth / 2, barY, barWidth, barHeight),
            const Radius.circular(2.5),
          ),
          Paint()..color = const Color(0xD90B253C),
        );

        final hpRatio = (enemy.currentHp / enemy.maxHp).clamp(0.0, 1.0);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-barWidth / 2, barY, barWidth * hpRatio, barHeight),
            const Radius.circular(2.5),
          ),
          Paint()..color = hpRatio > 0.45 ? const Color(0xFF34D399) : const Color(0xFFFB7185),
        );
      }

      canvas.restore();
    }
  }

  // 1. Helico-Grub (Chitinous armored spiral bacterium with mandibles & whipping flagella)
  void _drawHelicoGrub(Canvas canvas, ArcadeEnemy enemy, bool isFlashing) {
    final r = enemy.radius;
    // Whipping flagella tails behind (facing left toward player -> tails trail right)
    final flagellaPaint = Paint()
      ..color = const Color(0xFF34D399).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final offY = (i - 1.5) * 4.5;
      final wave = math.sin(enemy.animPhase * 3.4 + i * 1.1) * 9.0;
      final flagPath = Path()
        ..moveTo(r * 0.75, offY)
        ..quadraticBezierTo(r * 1.4, offY + wave, r * 2.05, offY - wave * 0.8);
      canvas.drawPath(flagPath, flagellaPaint);
    }

    // Segmented armored spiral body
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isFlashing
            ? const [Colors.white, Color(0xFFA7F3D0)]
            : const [Color(0xFF34D399), Color(0xFF059669), Color(0xFF064E3B)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));

    final bodyPath = Path()
      ..moveTo(-r * 1.05, 0)
      ..cubicTo(-r * 0.75, -r * 0.92, r * 0.35, -r * 0.85, r * 0.92, -r * 0.20)
      ..cubicTo(r * 1.10, r * 0.55, r * 0.25, r * 0.95, -r * 0.65, r * 0.65)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Dorsal ridge armor plates
    for (int p = -1; p <= 1; p++) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(p * r * 0.28, -r * 0.12), width: r * 0.48, height: r * 0.95),
        -math.pi * 0.4,
        math.pi * 0.8,
        false,
        Paint()
          ..color = const Color(0xFF065F46)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    // Fierce angry glowing amber eye + chitin mandibles facing left
    canvas.drawPath(
      Path()
        ..moveTo(-r * 0.85, r * 0.15)
        ..lineTo(-r * 1.32, r * 0.05)
        ..lineTo(-r * 0.92, r * 0.42)
        ..close(),
      Paint()..color = const Color(0xFFFEF08A),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-r * 0.52, -r * 0.26), width: 9.0, height: 6.5),
      Paint()..color = const Color(0xFFFDE047),
    );
    canvas.drawCircle(Offset(-r * 0.60, -r * 0.26), 2.3, Paint()..color = const Color(0xFF7F1D1D));
  }

  // 2. Spike-Virion (Menacing hunter capsid with barbed spikes, angry optic & RNA core)
  void _drawSpikeVirion(Canvas canvas, ArcadeEnemy enemy, bool isFlashing) {
    final r = enemy.radius;
    canvas.save();
    canvas.rotate(enemy.animPhase * 0.85);

    // 10 barbed glycoprotein spikes
    final spikePaint = Paint()..color = isFlashing ? Colors.white : const Color(0xFFF43F5E);
    final stemPaint = Paint()
      ..color = isFlashing ? Colors.white : const Color(0xFFBE185D)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi * 2) / 10;
      final spikeLen = r * 1.42 + math.sin(enemy.animPhase * 2.5 + i) * 3.5;
      final pt = Offset(math.cos(angle) * spikeLen, math.sin(angle) * spikeLen);
      canvas.drawLine(Offset.zero, pt, stemPaint);
      canvas.drawCircle(pt, 3.6, spikePaint);
      canvas.drawCircle(pt, 1.5, Paint()..color = const Color(0xFFFDE047));
    }
    canvas.restore();

    // Central armored viral capsid
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: isFlashing
            ? const [Colors.white, Color(0xFFFDA4AF)]
            : const [Color(0xFFFB7185), Color(0xFFBE123C), Color(0xFF4C0519)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    canvas.drawCircle(Offset.zero, r, corePaint);
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..color = const Color(0xFFFDA4AF).withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Slanted predatory eye & serrated fangs (does not spin awkwardly upside down)
    canvas.drawPath(
      Path()
        ..moveTo(-r * 0.58, -r * 0.25)
        ..lineTo(-r * 0.10, -r * 0.08)
        ..lineTo(-r * 0.50, r * 0.04)
        ..close(),
      Paint()..color = const Color(0xFFFEF08A),
    );
    canvas.drawCircle(Offset(-r * 0.36, -r * 0.12), 2.3, Paint()..color = Colors.black);
    canvas.drawPath(
      Path()
        ..moveTo(-r * 0.62, r * 0.35)
        ..lineTo(-r * 0.40, r * 0.22)
        ..lineTo(-r * 0.20, r * 0.38)
        ..lineTo(0, r * 0.22),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  // 3. Cytokine-Blob (Translucent toxic ameboid artillery with pulsing firing siphon)
  void _drawCytokineBlob(Canvas canvas, ArcadeEnemy enemy, bool isFlashing) {
    final r = enemy.radius;
    final blobPaint = Paint()
      ..shader = RadialGradient(
        colors: isFlashing
            ? const [Colors.white, Color(0xFFFDE68A)]
            : const [Color(0xFFFDE047), Color(0xFFEA580C), Color(0xFF7C2D12)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));

    final path = Path();
    const count = 12;
    for (int i = 0; i < count; i++) {
      final angle = (i * math.pi * 2) / count;
      final rad = r + math.sin(enemy.animPhase * 2.8 + i * 1.4) * 4.2;
      final pt = Offset(math.cos(angle) * rad, math.sin(angle) * rad);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, blobPaint);

    // Floating internal toxic nuclei
    canvas.drawCircle(Offset(r * 0.22, -r * 0.25), r * 0.22, Paint()..color = const Color(0x99FFFFFF));
    canvas.drawCircle(Offset(r * 0.28, r * 0.28), r * 0.16, Paint()..color = const Color(0x88FB7185));

    // Angry slanted eyes + glowing siphon mouth pointing left
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-r * 0.32, -r * 0.26), width: 7.5, height: 5.5),
      Paint()..color = const Color(0xFF450A0A),
    );
    canvas.drawCircle(Offset(-r * 0.35, -r * 0.26), 2.2, Paint()..color = const Color(0xFFFEF08A));
    canvas.drawCircle(
      Offset(-r * 0.62, r * 0.16),
      enemy.isWindingUpAttack ? 7.0 : 5.0,
      Paint()..color = enemy.isWindingUpAttack ? const Color(0xFFFB7185) : const Color(0xFF451A03),
    );
  }

  // 4. Acid Sentry (Biomechanical armored dreadnought drone with dual artillery barrels)
  void _drawAcidSentry(Canvas canvas, ArcadeEnemy enemy, bool isFlashing) {
    final r = enemy.radius;
    // Left-pointing twin acid cannon barrels
    final gunPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-r * 1.25, -r * 0.56, r * 0.65, 5.5), const Radius.circular(2)),
      gunPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-r * 1.25, r * 0.36, r * 0.65, 5.5), const Radius.circular(2)),
      gunPaint,
    );

    // Multi-layered metallic hexagonal chassis
    final armorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isFlashing
            ? const [Colors.white, Color(0xFFE2E8F0)]
            : const [Color(0xFF64748B), Color(0xFF334155), Color(0xFF0F172A)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));

    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi) / 3;
      final pt = Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        hexPath.moveTo(pt.dx, pt.dy);
      } else {
        hexPath.lineTo(pt.dx, pt.dy);
      }
    }
    hexPath.close();
    canvas.drawPath(hexPath, armorPaint);
    canvas.drawPath(
      hexPath,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Spinning reactor core + crimson ocular scanner
    canvas.drawCircle(
      Offset(-r * 0.10, 0),
      r * 0.52,
      Paint()
        ..shader = RadialGradient(
          colors: enemy.isWindingUpAttack
              ? const [Colors.white, Color(0xFFFB7185), Color(0xFFBE123C)]
              : const [Color(0xFFFEF08A), Color(0xFFF59E0B), Color(0xFF9A3412)],
        ).createShader(Rect.fromCircle(center: Offset(-r * 0.10, 0), radius: r * 0.52)),
    );
    canvas.drawCircle(Offset(-r * 0.18, 0), r * 0.20, Paint()..color = Colors.white);
  }

  // 5. Toxic Spore (Volatile crystalline bio-mine with pulsing fissure gas rings)
  void _drawToxicSpore(Canvas canvas, ArcadeEnemy enemy, bool isFlashing) {
    final r = enemy.radius;
    // Outer warning reticle ring when chasing or winding up burst
    if (enemy.isChasing || enemy.isWindingUpAttack) {
      canvas.drawCircle(
        Offset.zero,
        r + 6.0 + math.sin(enemy.animPhase * 5.0) * 2.5,
        Paint()
          ..color = const Color(0xFF34D399).withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }

    final sporePaint = Paint()
      ..shader = RadialGradient(
        colors: isFlashing
            ? const [Colors.white, Color(0xFFA7F3D0)]
            : const [Color(0xFF6EE7B7), Color(0xFF059669), Color(0xFF064E3B)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    canvas.drawCircle(Offset.zero, r, sporePaint);

    // Glowing diagonal bio-fissure cracks + protruding spikes
    final nodulePaint = Paint()..color = const Color(0xFFFDE047);
    for (int i = 0; i < 6; i++) {
      final a = (i * math.pi) / 3 + enemy.animPhase * 0.6;
      canvas.drawCircle(Offset(math.cos(a) * r, math.sin(a) * r), 3.4, nodulePaint);
    }
    canvas.drawCircle(Offset(-r * 0.22, -r * 0.10), 4.0, Paint()..color = const Color(0xFF064E3B));
    canvas.drawCircle(Offset(-r * 0.24, -r * 0.10), 2.0, Paint()..color = const Color(0xFFFB7185));
  }

  // ==========================================================================
  // 6C. PROJECTILES (DIRECTIONAL ROTATION, SPEED TRAILS & 8 WEAPON SILHOUETTES)
  // ==========================================================================
  void _drawProjectiles(Canvas canvas, Size size) {
    for (final p in controller.playerProjectiles) {
      if (p.isDead ||
          p.position.dx < controller.cameraX - 60 ||
          p.position.dx > controller.cameraX + size.width + 60) {
        continue;
      }

      final double velAngle = p.velocity.distance > 1.0
          ? math.atan2(p.velocity.dy, p.velocity.dx)
          : 0.0;

      // Soft radial glow halo
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            p.color.withValues(alpha: 0.58),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: p.position, radius: p.radius * 2.4));
      canvas.drawCircle(p.position, p.radius * 2.4, glowPaint);

      canvas.save();
      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(velAngle);

      // Sleek tapering energy tail streak behind every shot
      final tailLen = p.radius * 3.8;
      canvas.drawLine(
        Offset(-tailLen, 0),
        Offset.zero,
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.transparent, p.color.withValues(alpha: 0.72)],
          ).createShader(Rect.fromLTWH(-tailLen, -3, tailLen, 6))
          ..strokeWidth = (p.radius * 0.85).clamp(2.2, 7.0)
          ..strokeCap = StrokeCap.round,
      );

      switch (p.weaponType) {
        case WeaponType.antibacterialCannon:
          // Heavy golden-orange burst shell with glowing core star
          canvas.drawOval(
            Rect.fromCenter(center: Offset.zero, width: p.radius * 2.5, height: p.radius * 1.75),
            Paint()..color = p.color,
          );
          canvas.drawCircle(Offset.zero, p.radius * 0.62, Paint()..color = const Color(0xFFFEF08A));
          canvas.drawCircle(
            Offset.zero,
            p.radius * 1.15,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.75)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
          break;

        case WeaponType.therapeuticOrbs:
          // Rotating homing capsule orb with orbiting emerald spark ring
          canvas.drawCircle(
            Offset.zero,
            p.radius * 1.05,
            Paint()
              ..shader = RadialGradient(
                colors: [Colors.white, p.color, const Color(0xFF059669)],
              ).createShader(Rect.fromCircle(center: Offset.zero, radius: p.radius * 1.05)),
          );
          canvas.drawCircle(
            Offset(math.cos(p.animPhase) * (p.radius + 4), math.sin(p.animPhase) * (p.radius + 4)),
            2.4,
            Paint()..color = const Color(0xFFA7F3D0),
          );
          break;

        case WeaponType.plasmaShot:
          // Ionized plasma core with electric corona ring
          canvas.drawCircle(
            Offset.zero,
            p.radius * 1.1,
            Paint()
              ..shader = RadialGradient(
                colors: [Colors.white, p.color, const Color(0xFF0F766E)],
              ).createShader(Rect.fromCircle(center: Offset.zero, radius: p.radius * 1.1)),
          );
          canvas.drawCircle(
            Offset.zero,
            p.radius * 1.4,
            Paint()
              ..color = const Color(0xFF99F6E4).withValues(alpha: 0.65)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6,
          );
          break;

        case WeaponType.energyShield:
          // Biomagnetic violet deflector crescent
          final arcRect = Rect.fromCircle(center: Offset.zero, radius: p.radius * 1.35);
          canvas.drawArc(
            arcRect,
            -math.pi * 0.42,
            math.pi * 0.84,
            false,
            Paint()
              ..color = p.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.8
              ..strokeCap = StrokeCap.round,
          );
          canvas.drawCircle(Offset.zero, p.radius * 0.45, Paint()..color = Colors.white);
          break;

        case WeaponType.electricWave:
          final wavePaint = Paint()
            ..color = p.color
            ..strokeWidth = 3.8
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;
          final wavePath = Path()
            ..moveTo(-18, 0)
            ..quadraticBezierTo(-9, -10, 0, 0)
            ..quadraticBezierTo(9, 10, 18, 0);
          canvas.drawPath(wavePath, wavePaint);
          canvas.drawCircle(const Offset(14, 0), 3.2, Paint()..color = Colors.white);
          break;

        case WeaponType.ultimatePulse:
          final pulseRect = Rect.fromCenter(center: Offset.zero, width: p.radius * 3.8, height: p.radius * 1.65);
          final pulsePaint = Paint()
            ..shader = LinearGradient(
              colors: [const Color(0xFFFBBF24), p.color, Colors.white],
            ).createShader(pulseRect);
          canvas.drawOval(pulseRect, pulsePaint);
          break;

        case WeaponType.doubleLaser:
        case WeaponType.medicalLaser:
          final beamRect = Rect.fromCenter(center: Offset.zero, width: p.radius * 4.2, height: p.radius * 1.25);
          final beamPaint = Paint()
            ..shader = LinearGradient(
              colors: [p.color, Colors.white],
            ).createShader(beamRect);
          canvas.drawRRect(RRect.fromRectAndRadius(beamRect, const Radius.circular(3.5)), beamPaint);
          break;
      }
      canvas.restore();
    }

    // 2. Enemy Projectiles (glowing corrosive globules with pulsing danger halo)
    for (final ep in controller.enemyProjectiles) {
      if (ep.isDead ||
          ep.position.dx < controller.cameraX - 60 ||
          ep.position.dx > controller.cameraX + size.width + 60) {
        continue;
      }

      final acidPaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, ep.color, const Color(0xFFBE123C)],
        ).createShader(Rect.fromCircle(center: ep.position, radius: ep.radius));
      canvas.drawCircle(ep.position, ep.radius, acidPaint);

      canvas.drawCircle(
        ep.position,
        ep.radius + 2.5,
        Paint()
          ..color = const Color(0xFFFDA4AF).withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
  }

  // ==========================================================================
  // 7. BOSS MONSTER (OVERHAULED 8 ANATOMICAL LEVIATHANS + LASER BEAM + PHASE 2/3)
  // ==========================================================================
  void _drawBoss(Canvas canvas, Size size) {
    final boss = controller.boss;
    if (boss.isDefeated && controller.state == GameState.victory) return;
    if (boss.position.dx < controller.cameraX - 240 ||
        boss.position.dx > controller.cameraX + size.width + 260) {
      return;
    }

    final t = controller.gameTime;

    // 1. Charge Aiming Lane Telegraph BEFORE boss lunges!
    if (controller.state == GameState.bossFight &&
        boss.currentPattern == BossAttackPattern.chargeTelegraph &&
        boss.isTelegraphing) {
      final flashAlpha = (0.35 + 0.35 * math.sin(t * 22.0)).clamp(0.15, 0.7);
      final laneRect = Rect.fromLTRB(
        controller.cameraX,
        boss.chargeTargetY - 40.0,
        boss.position.dx,
        boss.chargeTargetY + 40.0,
      );
      canvas.drawRect(
        laneRect,
        Paint()..color = const Color(0xFFFB7185).withValues(alpha: flashAlpha * 0.48),
      );
      canvas.drawLine(
        Offset(controller.cameraX, boss.chargeTargetY),
        Offset(boss.position.dx, boss.chargeTargetY),
        Paint()
          ..color = const Color(0xFFFDE047).withValues(alpha: flashAlpha)
          ..strokeWidth = 3.4,
      );
    }

    // 2. Diagnostic Plasma Laser Telegraph Sightline & Active Sweeping Beam
    if (controller.state == GameState.bossFight &&
        boss.currentPattern == BossAttackPattern.laserBeamTelegraph &&
        boss.isTelegraphing) {
      final flashAlpha = (0.4 + 0.4 * math.sin(t * 28.0)).clamp(0.2, 0.85);
      canvas.drawLine(
        Offset(controller.cameraX, boss.beamTargetY),
        Offset(boss.position.dx - 44.0, boss.position.dy),
        Paint()
          ..color = const Color(0xFFFDE047).withValues(alpha: flashAlpha)
          ..strokeWidth = 3.0,
      );
      canvas.drawCircle(
        Offset(boss.position.dx - 46.0, boss.position.dy),
        16.0 + 6.0 * math.sin(t * 20.0),
        Paint()
          ..shader = RadialGradient(
            colors: const [Colors.white, Color(0xFFFDE047), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(boss.position.dx - 46.0, boss.position.dy),
              radius: 24.0,
            ),
          ),
      );
    } else if (controller.state == GameState.bossFight && boss.isFiringBeam) {
      final beamPath = Path()
        ..moveTo(boss.position.dx - 46.0, boss.position.dy)
        ..lineTo(controller.cameraX, boss.beamTargetY);
      canvas.drawPath(
        beamPath,
        Paint()
          ..color = const Color(0xFFFB7185).withValues(alpha: 0.48)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 32.0
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        beamPath,
        Paint()
          ..color = const Color(0xFFFDE047).withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14.0
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        beamPath,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeCap = StrokeCap.round,
      );
    }

    final pos = boss.position;
    final bool isDying = controller.state == GameState.bossDefeatAnim;
    final double defeatFrac = isDying
        ? (1.0 - (controller.bossDefeatTimer / 2.3)).clamp(0.0, 1.0)
        : 0.0;
    final double defeatScale = isDying ? (1.0 - defeatFrac * 0.45).clamp(0.42, 1.0) : 1.0;

    canvas.save();
    final double hitShakeX = boss.isHit ? math.sin(t * 68.0) * 6.0 : 0.0;
    final double defeatJitterX = isDying ? math.sin(t * 72.0) * 5.0 * (1.0 - defeatFrac * 0.3) : 0.0;
    final double attackLungeX = boss.isAttackingAnim
        ? -math.sin((boss.attackAnimTimer / 0.34) * math.pi) * 16.0
        : 0.0;
    canvas.translate(pos.dx + hitShakeX + defeatJitterX + attackLungeX, pos.dy);
    canvas.rotate(boss.facingTilt);
    canvas.scale(defeatScale * 1.12, defeatScale * 1.12);

    final Color auraCol = boss.isHit
        ? Colors.white
        : (boss.isPhase3
            ? const Color(0xFFF43F5E)
            : (boss.isPhase2 ? const Color(0xFFFB7185) : boss.auraColor));

    // Dramatic Multi-Ringed Boss Presence Aura
    final double pulseSize = 98.0 +
        (boss.isTelegraphing
            ? 14.0 + math.sin(t * 18.0) * 10.0
            : (boss.isPhase2 ? math.sin(t * 7.0) * 7.0 : 0.0));
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          auraCol.withValues(alpha: boss.isTelegraphing ? 0.65 : 0.42),
          auraCol.withValues(alpha: 0.14),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: pulseSize));
    canvas.drawCircle(Offset.zero, pulseSize, auraPaint);

    // Rotating Boss Fury Ring in Phase 2+
    if (boss.isPhase2 && !isDying) {
      canvas.save();
      canvas.rotate(-t * (boss.isPhase3 ? 2.6 : 1.6));
      for (int k = 0; k < 6; k++) {
        final a = k * (math.pi / 3.0);
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: 78.0),
          a,
          0.38,
          false,
          Paint()
            ..color = const Color(0xFFFDE047).withValues(alpha: 0.65)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.2
            ..strokeCap = StrokeCap.round,
        );
      }
      canvas.restore();
    }

    // Clear pre-attack energy charge orb when telegraphing
    if (controller.state == GameState.bossFight && boss.isTelegraphing) {
      final double chargePulse = 0.5 + 0.5 * math.sin(t * 22.0);
      const Offset corePos = Offset(-56, 0);
      final Color chargeCol = boss.currentPattern == BossAttackPattern.radialBurst
          ? const Color(0xFFA78BFA)
          : const Color(0xFFFBBF24);
      canvas.drawCircle(
        corePos,
        15.0 + chargePulse * 9.0,
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white, chargeCol, Colors.transparent],
          ).createShader(Rect.fromCircle(center: corePos, radius: 26.0)),
      );
    }

    final Color coreTop = boss.isHit ? Colors.white : Color.lerp(auraCol, Colors.white, 0.34)!;
    final Color coreMid = boss.isHit ? const Color(0xFFFDA4AF) : auraCol;
    final Color coreDark = Color.lerp(auraCol, const Color(0xFF0A2444), 0.58)!;
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.25),
        colors: [coreTop, coreMid, coreDark],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 70));

    final outlinePaint = Paint()
      ..color = boss.isPhase2 ? const Color(0xFFFDE047).withValues(alpha: 0.78) : Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;

    final int bossKey = controller.isRevisionStage ? 8 : controller.level.clamp(1, 7);
    final double jawSnap = math.sin(t * (boss.isPhase2 ? 12.0 : 6.0)).abs() * 8.0 +
        (boss.isAttackingAnim ? 10.0 : 0.0);

    switch (bossKey) {
      case 1: // Helicobacter Rex: Segmented spiral leviathan with 5 toxic flagella & serrated beak
        final tailPaint = Paint()
          ..color = const Color(0xFF34D399).withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.6
          ..strokeCap = StrokeCap.round;
        for (int f = -2; f <= 2; f++) {
          final p = Path()..moveTo(46, f * 9.0);
          p.quadraticBezierTo(82, f * 15.0 + math.sin(t * 7.5 + f) * 18, 118, f * 11.0 + math.cos(t * 6.5 + f) * 20);
          canvas.drawPath(p, tailPaint);
        }
        final helixRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-68, -44, 128, 88), const Radius.circular(42));
        canvas.drawRRect(helixRect, bodyPaint);
        canvas.drawRRect(helixRect, outlinePaint);
        // Armor dorsal bands + sharp mandibles facing left
        for (int s = -1; s <= 1; s++) {
          canvas.drawLine(Offset(s * 24.0, -40), Offset(s * 24.0 + 10, 40), Paint()..color = const Color(0x55064E3B)..strokeWidth = 4.0);
        }
        canvas.drawPath(Path()..moveTo(-58, -14)..lineTo(-82, -6 + jawSnap * 0.4)..lineTo(-56, 2)..close(), Paint()..color = const Color(0xFFFEF08A));
        canvas.drawPath(Path()..moveTo(-58, 16)..lineTo(-82, 8 - jawSnap * 0.4)..lineTo(-56, 2)..close(), Paint()..color = const Color(0xFFFEF08A));
        break;

      case 2: // Colossus Inflammatio: Magma-cracked gastric titan with serrated horns & orbiting acid orbs
        final hornPaint = Paint()..shader = const LinearGradient(colors: [Color(0xFFFDE047), Color(0xFFEA580C)]).createShader(const Rect.fromLTWH(-50, -90, 100, 50));
        canvas.drawPath(Path()..moveTo(-26, -50)..lineTo(-48, -92)..lineTo(-4, -56)..close(), hornPaint);
        canvas.drawPath(Path()..moveTo(16, -50)..lineTo(42, -92)..lineTo(42, -46)..close(), hornPaint);
        canvas.drawCircle(Offset.zero, 65.0, bodyPaint);
        canvas.drawCircle(Offset.zero, 65.0, outlinePaint);
        for (int m = 0; m < 3; m++) {
          final a = t * 2.4 + m * (math.pi * 2 / 3);
          canvas.drawCircle(Offset(math.cos(a) * 82, math.sin(a) * 82), 8.5, Paint()..color = const Color(0xFFFB923C));
        }
        break;

      case 3: // Auto-Immuno Titan: Hexagonal cyber-golem with rotating Y-antibody shield blades
        final armPaint = Paint()..color = const Color(0xFF5EEAD4)..style = PaintingStyle.stroke..strokeWidth = 5.0..strokeCap = StrokeCap.round;
        for (int i = 0; i < 6; i++) {
          final a = i * (math.pi / 3) + t * 1.5;
          final s = Offset(math.cos(a) * 60, math.sin(a) * 60);
          final m = Offset(math.cos(a) * 88, math.sin(a) * 88);
          canvas.drawLine(s, m, armPaint);
          canvas.drawLine(m, m + Offset(math.cos(a + 0.45) * 16, math.sin(a + 0.45) * 16), armPaint);
          canvas.drawLine(m, m + Offset(math.cos(a - 0.45) * 16, math.sin(a - 0.45) * 16), armPaint);
        }
        final hex = Path();
        for (int i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          final pt = Offset(math.cos(a) * 66, math.sin(a) * 66);
          if (i == 0) {
            hex.moveTo(pt.dx, pt.dy);
          } else {
            hex.lineTo(pt.dx, pt.dy);
          }
        }
        hex.close();
        canvas.drawPath(hex, bodyPaint);
        canvas.drawPath(hex, outlinePaint);
        break;

      case 4: // Calprotectin Behemoth: Hydraulic enzymatic pincer predator with crystalline carapace
        final clawPaint = Paint()..shader = const LinearGradient(colors: [Color(0xFF6EE7B7), Color(0xFF047857)]).createShader(const Rect.fromLTWH(-90, -50, 50, 100));
        final cWave = math.sin(t * 5.2) * 10.0;
        canvas.drawPath(Path()..moveTo(-46, -24)..lineTo(-86, -42 + cWave)..lineTo(-76, -12)..close(), clawPaint);
        canvas.drawPath(Path()..moveTo(-46, 24)..lineTo(-86, 42 - cWave)..lineTo(-76, 12)..close(), clawPaint);
        final shellRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-58, -56, 118, 112), const Radius.circular(30));
        canvas.drawRRect(shellRect, bodyPaint);
        canvas.drawRRect(shellRect, outlinePaint);
        break;

      case 5: // Chromosoma Prime: Floating cosmic archon with interlocking DNA energy rings
        final ringPaint = Paint()..color = const Color(0xFFFBCFE8).withValues(alpha: 0.78)..style = PaintingStyle.stroke..strokeWidth = 3.5;
        canvas.save();
        canvas.rotate(t * 1.1);
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 168, height: 54), ringPaint);
        canvas.rotate(math.pi / 3);
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 168, height: 54), ringPaint);
        canvas.rotate(math.pi / 3);
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 168, height: 54), ringPaint);
        canvas.restore();
        canvas.drawCircle(Offset.zero, 60.0, bodyPaint);
        canvas.drawCircle(Offset.zero, 60.0, outlinePaint);
        break;

      case 6: // Thrombosis Hydra: Terrifying 3-headed coagulation hydra with independently snapping lateral heads
        final headBob = math.sin(t * 5.5) * 9.0;
        for (final off in [Offset(-34, -52 + headBob), Offset(-38, 52 - headBob)]) {
          canvas.drawCircle(off, 27, bodyPaint);
          canvas.drawCircle(off, 27, outlinePaint);
          canvas.drawCircle(off + const Offset(-10, -6), 4.5, Paint()..color = const Color(0xFFFDE047));
          canvas.drawCircle(off + const Offset(-11, -6), 2.0, Paint()..color = Colors.black);
        }
        canvas.drawCircle(Offset.zero, 60.0, bodyPaint);
        canvas.drawCircle(Offset.zero, 60.0, outlinePaint);
        break;

      case 8: // Special Revision Guardian: Regal Sapphire-Gold Knowledge Sentinel with holographic crown runes
        final haloPaint = Paint()..color = const Color(0xFFFBBF24).withValues(alpha: 0.85)..style = PaintingStyle.stroke..strokeWidth = 3.4;
        for (int i = 0; i < 8; i++) {
          final a = i * (math.pi / 4) - t * 1.1;
          canvas.drawCircle(Offset(math.cos(a) * 80, math.sin(a) * 80), 6.0, Paint()..color = const Color(0xFF22D3EE));
        }
        canvas.drawCircle(Offset.zero, 76, haloPaint);
        canvas.drawCircle(Offset.zero, 62, bodyPaint);
        canvas.drawCircle(Offset.zero, 62, outlinePaint);
        break;

      case 7: // Alpha-Cure Prime: Omega-class crowned final guardian with blazing wing-blades & golden core
      default:
        final wingPaint = Paint()..color = const Color(0xFFFBBF24).withValues(alpha: 0.82)..strokeWidth = 5.5..strokeCap = StrokeCap.round;
        for (int i = 0; i < 10; i++) {
          final a = i * (math.pi / 5) + t * 1.4;
          canvas.drawLine(Offset(math.cos(a) * 58, math.sin(a) * 58), Offset(math.cos(a) * 98, math.sin(a) * 98), wingPaint);
        }
        // Crown crest spikes
        canvas.drawPath(Path()..moveTo(-26, -54)..lineTo(-34, -84)..lineTo(-10, -58)..lineTo(0, -90)..lineTo(12, -58)..lineTo(34, -84)..lineTo(26, -54)..close(), Paint()..color = const Color(0xFFFDE047));
        canvas.drawCircle(Offset.zero, 64.0, bodyPaint);
        canvas.drawCircle(Offset.zero, 64.0, outlinePaint);
        break;
    }

    // Glowing Throbbing Weakpoint Reactor Core + Fierce Slanted Eyes & Fanged Maw
    canvas.drawCircle(
      const Offset(-16, 4),
      15.0 + math.sin(t * 7.0) * 2.5,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            const Color(0xFFFBBF24).withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: const Offset(-16, 4), radius: 18)),
    );

    // Fierce Slanted Predator Eyes
    final eyeColor = boss.isHit ? Colors.white : (boss.isPhase2 ? const Color(0xFFF43F5E) : const Color(0xFFFEF08A));
    canvas.drawPath(
      Path()..moveTo(-40, -24)..lineTo(-14, -12)..lineTo(-36, -6)..close(),
      Paint()..color = eyeColor,
    );
    canvas.drawPath(
      Path()..moveTo(4, -12)..lineTo(26, -24)..lineTo(22, -6)..close(),
      Paint()..color = eyeColor,
    );
    canvas.drawCircle(const Offset(-28, -14), 3.2, Paint()..color = Colors.black);
    canvas.drawCircle(const Offset(16, -14), 3.2, Paint()..color = Colors.black);

    // Snapping Fanged Predator Jaw
    final jawPath = Path()
      ..moveTo(-34, 16)
      ..quadraticBezierTo(-4, 42 + jawSnap, 26, 16)
      ..quadraticBezierTo(-4, 24 - jawSnap * 0.3, -34, 16);
    canvas.drawPath(jawPath, Paint()..color = const Color(0xFF450A0A));
    final fangPaint = Paint()..color = Colors.white;
    for (int f = -2; f <= 2; f++) {
      final fx = f * 10.0 - 4.0;
      canvas.drawPath(
        Path()..moveTo(fx - 3.5, 19)..lineTo(fx, 29 + jawSnap * 0.35)..lineTo(fx + 3.5, 19)..close(),
        fangPaint,
      );
    }

    // Damage fractures when Phase 2 (< 50% HP)
    if (boss.isPhase2 && !boss.isHit) {
      final fissurePaint = Paint()
        ..color = const Color(0xFFFEF08A).withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(Path()..moveTo(18, -36)..lineTo(8, -8)..lineTo(24, 14), fissurePaint);
      canvas.drawPath(Path()..moveTo(-38, -2)..lineTo(-22, 14)..lineTo(-34, 34), fissurePaint);
    }

    canvas.restore();
  }

  // ==========================================================================
  // 8. PLAYER CAPSULE (EXPLORATION POD WITH HEADLIGHT, RECOIL & SYNERGY AURA)
  // ==========================================================================
  void _drawPlayerCapsule(Canvas canvas, Size size) {
    final p = controller.player;

    // --- SPECIAL ANTI-INFLAMMATORY EXPANDING SHOCKWAVE RING ---
    if (controller.specialWaveFlashTimer > 0) {
      final t = (1.0 - (controller.specialWaveFlashTimer / 0.65)).clamp(0.0, 1.0);
      final ringRadius = 35.0 + t * 380.0;
      final alpha = ((1.0 - t) * 0.75).clamp(0.0, 0.75);
      canvas.drawCircle(
        p.position,
        ringRadius,
        Paint()
          ..color = const Color(0xFF34D399).withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (10.0 * (1.0 - t * 0.6)).clamp(2.0, 10.0),
      );
    }

    // --- SMOOTH ION PROPULSION TRAIL RIBBON (Tapering cyan/gold energy flow) ---
    if (p.trailPositions.length >= 2) {
      final Color trailCol = p.isMaxSynergy
          ? const Color(0xFFFFB547)
          : (p.collectFlashTimer > 0 ? const Color(0xFF35D39A) : const Color(0xFF20D5E8));
      for (int i = 0; i < p.trailPositions.length - 1; i++) {
        final fraction = ((p.trailPositions.length - i) / p.trailPositions.length).clamp(0.0, 1.0);
        final a = p.trailPositions[i];
        final b = p.trailPositions[i + 1];
        canvas.drawLine(
          a,
          b,
          Paint()
            ..color = trailCol.withValues(alpha: fraction * 0.34)
            ..strokeWidth = (9.0 * fraction).clamp(1.5, 9.0)
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          a,
          b,
          Paint()
            ..color = Colors.white.withValues(alpha: fraction * 0.45)
            ..strokeWidth = (3.2 * fraction).clamp(0.8, 3.2)
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // --- COLLECT, DAMAGE & SHIELD DEFLECTION FEEDBACK RINGS ---
    if (p.collectFlashTimer > 0) {
      final frac = 1.0 - (p.collectFlashTimer / 0.35);
      canvas.drawCircle(
        p.position,
        p.radius + 10.0 + frac * 22.0,
        Paint()
          ..color = const Color(0xFFFFB547).withValues(alpha: ((1.0 - frac) * 0.85).clamp(0.0, 0.85))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );
    }
    if (p.damageFlashTimer > 0) {
      final frac = 1.0 - (p.damageFlashTimer / 0.35).clamp(0.0, 1.0);
      canvas.drawCircle(
        p.position,
        p.radius + 8.0 + frac * 20.0,
        Paint()
          ..color = const Color(0xFFF16D78).withValues(alpha: ((1.0 - frac) * 0.78).clamp(0.0, 0.78))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );
    }
    if (p.shieldDeflectTimer > 0) {
      final frac = 1.0 - (p.shieldDeflectTimer / 0.35);
      canvas.drawCircle(
        p.position,
        p.radius + 14.0 + frac * 28.0,
        Paint()
          ..color = const Color(0xFF20D5E8).withValues(alpha: ((1.0 - frac) * 0.85).clamp(0.0, 0.85))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );
    }

    // Gentle hover bobbing + smooth shot recoil
    final floatY = math.sin(controller.gameTime * 3.2 + p.animPhase * 0.3) * 2.2;
    final recoilOffset = p.shootRecoilTimer > 0 ? -(p.shootRecoilTimer / 0.10) * 3.2 : 0.0;
    final int arsenalTier = controller.progress.unlockedWeapons.length;

    canvas.save();
    canvas.translate(p.position.dx + recoilOffset, p.position.dy + floatY);
    canvas.rotate(p.angle);

    // --- CRISP SHIP VISIBILITY CONTRAST HALO (Always keeps hero ship clear in intense battles) ---
    canvas.drawCircle(
      Offset.zero,
      p.radius * 1.48,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF22D3EE).withValues(alpha: 0.24),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: p.radius * 1.48)),
    );

    // --- MAX SYNERGIE GOLDEN AURA ---
    if (p.isMaxSynergy) {
      final auraPulse = 1.0 + math.sin(controller.gameTime * 6.5) * 0.07;
      canvas.drawCircle(
        Offset.zero,
        (p.radius + 13.0) * auraPulse,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFB547).withValues(alpha: 0.36),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: p.radius + 15.0)),
      );
    }

    // --- A. SOFT BIO-SCAN HEADLIGHT CONE ---
    final conePath = Path()
      ..moveTo(p.radius * 0.85, -3.5)
      ..lineTo(p.radius * 0.85 + 220.0, -70.0)
      ..lineTo(p.radius * 0.85 + 220.0, 70.0)
      ..lineTo(p.radius * 0.85, 3.5)
      ..close();

    final lightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF20D5E8).withValues(alpha: 0.25),
          const Color(0xFF20D5E8).withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(p.radius * 0.85, -70, 220, 140));
    canvas.drawPath(conePath, lightPaint);

    // --- B. INVULNERABILITY PROTECTIVE PULSE ---
    if (p.isInvulnerable && !p.isShieldActive) {
      final shieldAlpha = (math.sin(controller.gameTime * 14.0) * 0.30 + 0.45).clamp(0.15, 0.75);
      canvas.drawCircle(
        Offset.zero,
        p.radius + 7.5,
        Paint()
          ..color = const Color(0xFF35D39A).withValues(alpha: shieldAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }

    // --- C. MULTI-LAYERED PLASMA PROPULSION THRUSTER FLAME ---
    final isFiringThruster = p.isThrusting || p.isBoosted || p.flameIntensity > 0.15 || p.moveInput.dx > 0.1;
    if (isFiringThruster) {
      final intensity = math.max(p.flameIntensity, p.isBoosted ? 1.4 : (p.isThrusting ? 1.05 : 0.7));
      final flameLength = (22.0 + math.sin(controller.gameTime * 26.0) * 4.5) * intensity;
      final flamePath = Path()
        ..moveTo(-p.radius * 1.15, -5.8)
        ..quadraticBezierTo(-p.radius * 1.15 - flameLength * 0.6, -2.8, -p.radius * 1.15 - flameLength, 0)
        ..quadraticBezierTo(-p.radius * 1.15 - flameLength * 0.6, 2.8, -p.radius * 1.15, 5.8)
        ..close();

      final flamePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            p.isMaxSynergy ? const Color(0xFFFFB547) : const Color(0xFF20D5E8),
            const Color(0xFF20C9B0),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(-p.radius * 1.15 - flameLength, -6, flameLength, 12));
      canvas.drawPath(flamePath, flamePaint);
      // Inner white-hot core jet
      canvas.drawPath(
        Path()
          ..moveTo(-p.radius * 1.15, -2.5)
          ..lineTo(-p.radius * 1.15 - flameLength * 0.55, 0)
          ..lineTo(-p.radius * 1.15, 2.5)
          ..close(),
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }

    // --- D. FUTURISTIC MEDICAL MINI-SUBMARINE CAPSULE ---
    // Swept dorsal & ventral stabilizer fins with cyan wingtip lights
    final finWave = math.sin(p.animPhase * 1.6) * 2.0;
    final topFin = Path()
      ..moveTo(-p.radius * 0.35, -p.radius * 0.72)
      ..quadraticBezierTo(-p.radius * 0.68, -p.radius * 1.44 + finWave, -p.radius * 0.96, -p.radius * 1.22 + finWave)
      ..lineTo(-p.radius * 0.04, -p.radius * 0.80)
      ..close();
    final botFin = Path()
      ..moveTo(-p.radius * 0.35, p.radius * 0.72)
      ..quadraticBezierTo(-p.radius * 0.68, p.radius * 1.44 - finWave, -p.radius * 0.96, p.radius * 1.22 - finWave)
      ..lineTo(-p.radius * 0.04, p.radius * 0.80)
      ..close();

    final finPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF22D3EE), Color(0xFF0E4170)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: p.radius * 1.45));
    canvas.drawPath(topFin, finPaint);
    canvas.drawPath(botFin, finPaint);
    canvas.drawCircle(Offset(-p.radius * 0.92, -p.radius * 1.20 + finWave), 2.4, Paint()..color = const Color(0xFFA5F3FC));
    canvas.drawCircle(Offset(-p.radius * 0.92, p.radius * 1.20 - finWave), 2.4, Paint()..color = const Color(0xFFA5F3FC));

    // Metallic titanium-pearl capsule hull
    final hullRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: p.radius * 2.52, height: p.radius * 1.76),
      Radius.circular(p.radius * 0.88),
    );
    final hullRect = hullRRect.outerRect;
    final hullPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: p.damageFlashTimer > 0
            ? const [Color(0xFFFDE2E4), Color(0xFFF16D78), Color(0xFFB91C1C)]
            : arsenalTier >= 4
                ? const [Color(0xFFFFFFFF), Color(0xFFE0F7FA), Color(0xFF67E8F9)]
                : const [Color(0xFFFFFFFF), Color(0xFFE2E8F0), Color(0xFF94A3B8)],
      ).createShader(hullRect);
    canvas.drawRRect(hullRRect, hullPaint);

    // Subtle panel seam line
    canvas.drawLine(
      Offset(-p.radius * 0.45, -p.radius * 0.80),
      Offset(-p.radius * 0.45, p.radius * 0.80),
      Paint()
        ..color = const Color(0xFF0E4170).withValues(alpha: 0.25)
        ..strokeWidth = 1.4,
    );

    // Sleek glossy top specular highlight on shell
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(-p.radius * 0.12, -p.radius * 0.46), width: p.radius * 1.48, height: p.radius * 0.34),
        Radius.circular(p.radius * 0.2),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.78),
    );

    // Central luminous medical collar band & subtle cross emblem
    final collarColor = arsenalTier >= 3 ? const Color(0xFFFFB547) : const Color(0xFF20C9B0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(-p.radius * 0.20, 0), width: 6.5, height: p.radius * 1.70),
        const Radius.circular(3.2),
      ),
      Paint()..color = collarColor,
    );

    // Bio-core energy reactor window on aft compartment
    final corePulse = 0.65 + 0.35 * math.sin(controller.gameTime * 5.0);
    final coreCenter = Offset(-p.radius * 0.64, 0);
    canvas.drawCircle(
      coreCenter,
      p.radius * 0.36,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            const Color(0xFF20D5E8).withValues(alpha: corePulse),
            const Color(0xFF165B94),
          ],
        ).createShader(Rect.fromCircle(center: coreCenter, radius: p.radius * 0.36)),
    );

    // Translucent cyan cockpit canopy dome with pilot visor reflection
    final visorRect = Rect.fromCenter(
      center: Offset(p.radius * 0.50, 0),
      width: p.radius * 1.08,
      height: p.radius * 1.12,
    );
    canvas.drawOval(
      visorRect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.25, -0.35),
          colors: [
            Color(0xFFE0F7FA),
            Color(0xFF20D5E8),
            Color(0xFF0E7490),
          ],
        ).createShader(visorRect),
    );
    canvas.drawCircle(
      Offset(p.radius * 0.60, -p.radius * 0.22),
      2.8,
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );

    // Crisp rim outline
    canvas.drawRRect(
      hullRRect,
      Paint()
        ..color = p.damageFlashTimer > 0
            ? const Color(0xFFF16D78)
            : Colors.white.withValues(alpha: 0.82)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // --- E. WEAPON CANNONS & MUZZLE FLARE EMITTERS ---
    final weaponConfig = controller.equippedWeaponConfig;
    final cannonPaint = Paint()..color = const Color(0xFF123B5A);
    final muzzlePos = Offset(p.radius * 0.45 + 12, -p.radius * 0.58 + 1.75);
    final muzzleGlow = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, weaponConfig.glowColor, Colors.transparent],
      ).createShader(Rect.fromCircle(center: muzzlePos, radius: p.shootRecoilTimer > 0 ? 12.0 : 5.5));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(p.radius * 0.45, -p.radius * 0.60, 12, 3.8),
        const Radius.circular(1.8),
      ),
      cannonPaint,
    );
    canvas.drawCircle(muzzlePos, p.shootRecoilTimer > 0 ? 9.0 : 3.4, muzzleGlow);

    if (p.hasDoubleShot || weaponConfig.type == WeaponType.doubleLaser || arsenalTier >= 2) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(p.radius * 0.45, p.radius * 0.38, 12, 3.8),
          const Radius.circular(1.8),
        ),
        cannonPaint,
      );
      canvas.drawCircle(
        Offset(p.radius * 0.45 + 12, p.radius * 0.38 + 1.75),
        p.shootRecoilTimer > 0 ? 7.5 : 3.0,
        Paint()..color = weaponConfig.glowColor,
      );
    }

    // --- F. TRANSLUCENT BIOMAGNETIC HEX-ARC SHIELD ---
    if (p.isShieldActive) {
      final shieldRadius = p.radius + 15.0;
      final shieldPulse = math.sin(controller.gameTime * 6.5) * 1.8;

      final shieldGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF20D5E8).withValues(alpha: 0.08),
            const Color(0xFF20C9B0).withValues(alpha: 0.32),
            Colors.transparent,
          ],
          stops: const [0.45, 0.80, 1.0],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: shieldRadius + shieldPulse + 7));
      canvas.drawCircle(Offset.zero, shieldRadius + shieldPulse + 7, shieldGlow);

      canvas.drawCircle(
        Offset.zero,
        shieldRadius + shieldPulse,
        Paint()
          ..color = const Color(0xFF20D5E8).withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }

    canvas.restore();
  }

  // ==========================================================================
  // 9. PARTICLES (BUBBLES, SPARKS, LASER BEAM, CONFETTI)
  // ==========================================================================
  void _drawParticles(Canvas canvas, Size size) {
    for (final p in controller.particles) {
      if (p.position.dx < controller.cameraX - 40 || p.position.dx > controller.cameraX + size.width + 40) {
        continue;
      }

      final paint = Paint()
        ..color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.position, p.size * p.life, paint);
    }
  }

  // ==========================================================================
  // 10. FLOATING ARCADE TEXTS (+20, +50 XP, COMBO)
  // ==========================================================================
  void _drawFloatingTexts(Canvas canvas, Size size) {
    for (final txt in controller.floatingTexts) {
      if (txt.position.dx < controller.cameraX - 100 || txt.position.dx > controller.cameraX + size.width + 100) {
        continue;
      }

      // Quantize alpha into 8 steps so TextPainter stays cached instead of re-laying out at 60 FPS
      final double qAlpha = ((txt.life.clamp(0.0, 1.0) * 8).round() / 8.0).clamp(0.125, 1.0);
      final textPainter = _getCachedLabelPainter(
        txt.text,
        fontSize: txt.fontSize,
        color: txt.color.withValues(alpha: qAlpha),
        fontWeight: FontWeight.w900,
        shadows: [
          Shadow(
            color: const Color(0xFF062542).withValues(alpha: 0.75 * qAlpha),
            offset: const Offset(1.5, 1.5),
            blurRadius: 3.0,
          ),
        ],
      );

      textPainter.paint(
        canvas,
        txt.position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ArcadeGamePainter oldDelegate) =>
      oldDelegate.controller != controller;
}
