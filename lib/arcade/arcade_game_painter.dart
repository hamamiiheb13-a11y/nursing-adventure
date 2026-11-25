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

  ArcadeGamePainter({required this.controller}) : super(repaint: controller) {
    _parallax = ParallaxBackgroundSystem(stageId: controller.level);
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
  // 2. PARALLAX FLOATING ERYTHROCYTES (RED BLOOD CELLS)
  // ==========================================================================
  void _drawBackgroundCells(Canvas canvas, Size size) {
    for (final cell in controller.backgroundCells) {
      // Parallax position
      final screenX = cell.position.dx - (controller.cameraX * (1.0 - cell.depth));
      if (screenX < controller.cameraX - 80 || screenX > controller.cameraX + size.width + 80) {
        continue;
      }

      final cellY = cell.position.dy + math.sin(controller.gameTime * 1.2 + cell.wobblePhase) * 12.0;

      canvas.save();
      canvas.translate(cell.position.dx, cellY);
      canvas.rotate(cell.rotation + controller.gameTime * 0.15);

      final r = cell.radius * (0.6 + cell.depth * 0.5);
      final alpha = (0.2 + cell.depth * 0.35).clamp(0.1, 0.7);

      // Erythrocyte biconcave disc shape
      final outerPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFE11D48).withValues(alpha: alpha),
            const Color(0xFF881337).withValues(alpha: alpha * 0.7),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));

      canvas.drawCircle(Offset.zero, r, outerPaint);

      // Center indentation shadow
      final centerPaint = Paint()
        ..color = const Color(0xFF4C0519).withValues(alpha: alpha * 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, r * 0.42, centerPaint);

      canvas.restore();
    }
  }

  // ==========================================================================
  // 3. ORGANIC TUNNEL WALLS (CEILING, FLOOR & VILLI FRINGE)
  // ==========================================================================
  void _drawTunnelWalls(Canvas canvas, Size size) {
    final world = controller.world;
    final startX = (controller.cameraX - 100.0).clamp(0.0, controller.totalDistance);
    final endX = (controller.cameraX + size.width + 100.0).clamp(0.0, controller.totalDistance);
    const double step = 20.0;

    // --- CEILING PATH ---
    final ceilingPath = Path();
    ceilingPath.moveTo(startX, -50.0);
    ceilingPath.lineTo(startX, controller.tunnel.getCeilingY(startX, controller.gameTime));

    for (double x = startX; x <= endX; x += step) {
      final y = controller.tunnel.getCeilingY(x, controller.gameTime);
      ceilingPath.lineTo(x, y);
    }
    ceilingPath.lineTo(endX, -50.0);
    ceilingPath.close();

    // Ceiling gradient fill
    final ceilRect = Rect.fromLTRB(startX, -50, endX, 220);
    final ceilPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          world.tunnelDeepColor,
          world.tunnelWallColor,
        ],
      ).createShader(ceilRect);
    canvas.drawPath(ceilingPath, ceilPaint);

    // --- FLOOR PATH ---
    final floorPath = Path();
    floorPath.moveTo(startX, size.height + 50.0);
    floorPath.lineTo(startX, controller.tunnel.getFloorY(startX, controller.gameTime));

    for (double x = startX; x <= endX; x += step) {
      final y = controller.tunnel.getFloorY(x, controller.gameTime);
      floorPath.lineTo(x, y);
    }
    floorPath.lineTo(endX, size.height + 50.0);
    floorPath.close();

    // Floor gradient fill
    final floorRect = Rect.fromLTRB(startX, 300, endX, size.height + 50);
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          world.tunnelDeepColor,
          world.tunnelWallColor,
        ],
      ).createShader(floorRect);
    canvas.drawPath(floorPath, floorPaint);

    // --- CARTOON VILLI FRINGE (Undulating teeth/villosités from Reference Image 1) ---
    _drawVilliFringe(canvas, startX, endX);
  }

  void _drawVilliFringe(Canvas canvas, double startX, double endX) {
    final world = controller.world;

    final fringePaint = Paint()
      ..color = world.tunnelFringeColor
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Ceiling villi (pointing downward)
    final topVilliPath = Path();
    bool firstTop = true;
    for (double x = startX; x <= endX; x += 14.0) {
      final baseY = controller.tunnel.getCeilingY(x, controller.gameTime);
      final tipY = baseY + 9.0 + math.sin(x * 0.12 + controller.gameTime * 2.5) * 4.0;
      if (firstTop) {
        topVilliPath.moveTo(x, baseY);
        firstTop = false;
      }
      topVilliPath.lineTo(x + 7.0, tipY);
      topVilliPath.lineTo(x + 14.0, controller.tunnel.getCeilingY(x + 14.0, controller.gameTime));
    }
    canvas.drawPath(topVilliPath, fringePaint);
    canvas.drawPath(topVilliPath, outlinePaint);

    // Floor villi (pointing upward)
    final bottomVilliPath = Path();
    bool firstBottom = true;
    for (double x = startX; x <= endX; x += 14.0) {
      final baseY = controller.tunnel.getFloorY(x, controller.gameTime);
      final tipY = baseY - 9.0 - math.sin(x * 0.12 + controller.gameTime * 2.5) * 4.0;
      if (firstBottom) {
        bottomVilliPath.moveTo(x, baseY);
        firstBottom = false;
      }
      bottomVilliPath.lineTo(x + 7.0, tipY);
      bottomVilliPath.lineTo(x + 14.0, controller.tunnel.getFloorY(x + 14.0, controller.gameTime));
    }
    canvas.drawPath(bottomVilliPath, fringePaint);
    canvas.drawPath(bottomVilliPath, outlinePaint);
  }

  // ==========================================================================
  // 4. CHECKPOINT NANOGATES
  // ==========================================================================
  void _drawCheckpoints(Canvas canvas, Size size) {
    for (final cp in controller.checkpoints) {
      if (cp.worldX < controller.cameraX - 100 || cp.worldX > controller.cameraX + size.width + 100) {
        continue;
      }

      final ceilY = controller.tunnel.getCeilingY(cp.worldX, controller.gameTime);
      final floorY = controller.tunnel.getFloorY(cp.worldX, controller.gameTime);

      final color = cp.isCompleted
          ? (cp.isAnswerCorrect ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
          : const Color(0xFF00E5FF);

      // Light column
      final gatePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.45),
            color.withValues(alpha: 0.1),
          ],
        ).createShader(Rect.fromLTRB(cp.worldX - 16, ceilY, cp.worldX + 16, floorY));

      canvas.drawRect(Rect.fromLTRB(cp.worldX - 16, ceilY, cp.worldX + 16, floorY), gatePaint);

      // Border arches
      final beamPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      canvas.drawLine(Offset(cp.worldX, ceilY), Offset(cp.worldX, floorY), beamPaint);

      // Rotating beacon rings
      final midY = (ceilY + floorY) / 2;
      for (int i = 0; i < 3; i++) {
        final ringY = ceilY + (floorY - ceilY) * ((i + 1) / 4);
        final ringWidth = 24.0 + math.sin(controller.gameTime * 3.0 + i) * 8.0;
        final ringPaint = Paint()
          ..color = color.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cp.worldX, ringY), width: ringWidth, height: 12.0),
          ringPaint,
        );
      }

      // Checkpoint Emblem
      final emblemPaint = Paint()..color = color;
      canvas.drawCircle(Offset(cp.worldX, midY), 16.0, emblemPaint);
      final iconPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      // Medical cross
      canvas.drawLine(Offset(cp.worldX - 7, midY), Offset(cp.worldX + 7, midY), iconPaint);
      canvas.drawLine(Offset(cp.worldX, midY - 7), Offset(cp.worldX, midY + 7), iconPaint);
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
    // Outer glowing membrane
    final glowPaint = Paint()
      ..color = const Color(0xFFF43F5E).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawCircle(pos, r + 4, glowPaint);

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
      ..color = const Color(0xFFFFD166).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawCircle(pos, r + 5, glowPaint);

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(controller.gameTime * 1.5);

    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi) / 3;
      final pt = Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) path.moveTo(pt.dx, pt.dy); else path.lineTo(pt.dx, pt.dy);
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
      ..color = const Color(0xFF10B981).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawCircle(Offset.zero, r + 4, glowPaint);

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
      ..color = const Color(0xFF818CF8).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawCircle(Offset.zero, r + 5, glowPaint);

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
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9.0);
    canvas.drawCircle(Offset.zero, r + 5, glowPaint);

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
          _drawSpikyVirus(canvas, obs);
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

  void _drawInflammatoryZone(Canvas canvas, ArcadeObstacle obs) {
    final pos = obs.position;
    final r = obs.radius;
    final bool soothed = obs.isSoothed;
    final pulse = 1.0 + math.sin(controller.gameTime * 4.5 + obs.animPhase) * 0.10;

    final Color outer = soothed ? const Color(0xFF34D399) : const Color(0xFFFB7185);
    final Color inner = soothed ? const Color(0xFFA7F3D0) : const Color(0xFFFBBF24);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          inner.withValues(alpha: soothed ? 0.35 : 0.65),
          outer.withValues(alpha: soothed ? 0.15 : 0.30),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pos, radius: r * pulse * 1.25));
    canvas.drawCircle(pos, r * pulse * 1.25, glowPaint);

    final ringPaint = Paint()
      ..color = outer.withValues(alpha: soothed ? 0.45 : 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = soothed ? 1.8 : 2.6;
    canvas.drawCircle(pos, r * pulse, ringPaint);

    if (!soothed) {
      // Micro inflammatory vesicles inside patch
      for (int i = 0; i < 3; i++) {
        final a = obs.animPhase + i * 2.1 + controller.gameTime * 2.0;
        final off = Offset(math.cos(a) * r * 0.4, math.sin(a) * r * 0.4);
        canvas.drawCircle(pos + off, 4.0, Paint()..color = const Color(0xFFFDE047));
      }
    }
  }

  void _drawBioFilament(Canvas canvas, ArcadeObstacle obs) {
    final ceilY = controller.tunnel.getCeilingY(obs.position.dx, controller.gameTime);
    final sway = math.sin(controller.gameTime * 2.8 + obs.animPhase) * 14.0;
    final endPt = Offset(obs.position.dx + sway, ceilY + obs.height);

    final strandPaint = Paint()
      ..color = const Color(0xFFFDBA74).withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(obs.position.dx, ceilY - 4.0)
      ..quadraticBezierTo(
        obs.position.dx - sway * 0.5,
        ceilY + obs.height * 0.5,
        endPt.dx,
        endPt.dy,
      );
    canvas.drawPath(path, strandPaint);

    // Bulbous mucous node at tip
    canvas.drawCircle(
      endPt,
      10.0,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFEF3C7), Color(0xFFFB923C)],
        ).createShader(Rect.fromCircle(center: endPt, radius: 10.0)),
    );
  }

  // The Green Monster from Reference Image 1 (mouth wide open, teeth, eye stalk!)
  void _drawToothyMicrobe(Canvas canvas, ArcadeObstacle obs) {
    final pos = obs.position;
    final r = obs.radius;

    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    // Subtle breath pulse
    final pulse = 1.0 + math.sin(controller.gameTime * 3.5 + obs.animPhase) * 0.05;
    canvas.scale(pulse, pulse);

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

    // Wide Open Mouth (Crimson Throat)
    final mouthPath = Path()
      ..moveTo(-r * 0.7, r * 0.2)
      ..quadraticBezierTo(0, -r * 0.4, r * 0.7, r * 0.2)
      ..quadraticBezierTo(0, r * 0.55, -r * 0.7, r * 0.2);

    final mouthPaint = Paint()..color = const Color(0xFF7F1D1D);
    canvas.drawPath(mouthPath, mouthPaint);

    // Sharp White Teeth (Upper and lower jaws)
    final toothPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 4; i++) {
      final toothX = -r * 0.5 + i * (r * 0.33);
      final toothPath = Path()
        ..moveTo(toothX - 3, -r * 0.05)
        ..lineTo(toothX, r * 0.16)
        ..lineTo(toothX + 3, -r * 0.05)
        ..close();
      canvas.drawPath(toothPath, toothPaint);
    }

    // Curved Pink Tongue
    final tonguePaint = Paint()..color = const Color(0xFFFB7185);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(r * 0.1, r * 0.22), width: r * 0.5, height: r * 0.35),
      0,
      math.pi,
      true,
      tonguePaint,
    );

    // Big Eyeball on Stalk (Looking left towards incoming player!)
    final stalkPaint = Paint()
      ..color = const Color(0xFF4D7C0F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-r * 0.3, -r * 0.5), Offset(-r * 0.4, -r * 1.05), stalkPaint);

    // Eye globe
    final eyeCenter = Offset(-r * 0.4, -r * 1.05);
    final eyePaint = Paint()..color = const Color(0xFFFEF08A);
    canvas.drawCircle(eyeCenter, 9.0, eyePaint);

    // Pupil watching the player
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(eyeCenter + const Offset(-3.5, 0), 4.2, pupilPaint);
    final eyeShine = Paint()..color = Colors.white;
    canvas.drawCircle(eyeCenter + const Offset(-4.5, -2), 1.5, eyeShine);

    canvas.restore();
  }

  // Spiky Pathogen Sphere
  void _drawSpikyVirus(Canvas canvas, ArcadeObstacle obs) {
    final pos = obs.position;
    final r = obs.radius;

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(controller.gameTime * 2.0 + obs.animPhase);

    // Spikes radiating
    final spikePaint = Paint()..color = const Color(0xFF9333EA);
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi) / 4;
      final tip = Offset(math.cos(angle) * (r + 8), math.sin(angle) * (r + 8));
      canvas.drawCircle(tip, 3.5, spikePaint);
      final stemPaint = Paint()
        ..color = const Color(0xFF7E22CE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawLine(Offset.zero, tip, stemPaint);
    }

    // Core body
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFA855F7), Color(0xFF6B21A8), Color(0xFF3B0764)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    canvas.drawCircle(Offset.zero, r, bodyPaint);

    // Menacing eyes
    final eyePaint = Paint()..color = const Color(0xFFFDE047);
    canvas.drawCircle(const Offset(-6, -2), 3.5, eyePaint);
    canvas.drawCircle(const Offset(6, -2), 3.5, eyePaint);
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(const Offset(-7, -2), 1.8, pupilPaint);
    canvas.drawCircle(const Offset(5, -2), 1.8, pupilPaint);

    canvas.restore();
  }

  // Dripping Neon Acid Droplet
  void _drawAcidDroplet(Canvas canvas, ArcadeObstacle obs) {
    final pos = obs.position;
    final r = obs.radius;

    final glowPaint = Paint()
      ..color = const Color(0xFF84CC16).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawCircle(pos, r + 4, glowPaint);

    final dropPath = Path()
      ..moveTo(pos.dx, pos.dy - r * 1.3)
      ..cubicTo(pos.dx - r, pos.dy, pos.dx - r * 0.8, pos.dy + r, pos.dx, pos.dy + r)
      ..cubicTo(pos.dx + r * 0.8, pos.dy + r, pos.dx + r, pos.dy, pos.dx, pos.dy - r * 1.3);

    final dropPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFECFCCB), const Color(0xFFA3E635), const Color(0xFF4D7C0F)],
      ).createShader(Rect.fromCircle(center: pos, radius: r));
    canvas.drawPath(dropPath, dropPaint);
  }

  // ==========================================================================
  // 6B. 2D ANIMATED ENEMIES (5 DISTINCT GASTRIC THREATS)
  // ==========================================================================
  void _drawEnemies(Canvas canvas, Size size) {
    for (final enemy in controller.enemies) {
      if (enemy.isDead) continue;
      if (enemy.position.dx < controller.cameraX - 80 ||
          enemy.position.dx > controller.cameraX + size.width + 80) {
        continue;
      }

      canvas.save();
      canvas.translate(enemy.position.dx, enemy.position.dy);

      final isFlashing = enemy.isFlashing;

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

      // HP Bar overhead
      if (enemy.currentHp < enemy.maxHp) {
        final barWidth = enemy.radius * 2.2;
        const barHeight = 4.0;
        final barY = -enemy.radius - 12.0;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-barWidth / 2, barY, barWidth, barHeight),
            const Radius.circular(2),
          ),
          Paint()..color = Colors.black54,
        );

        final hpRatio = (enemy.currentHp / enemy.maxHp).clamp(0.0, 1.0);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-barWidth / 2, barY, barWidth * hpRatio, barHeight),
            const Radius.circular(2),
          ),
          Paint()..color = hpRatio > 0.4 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        );
      }

      canvas.restore();
    }
  }

  // 1. Helico-Grub (Spiral bacterium with eye & flagella)
  void _drawHelicoGrub(Canvas canvas, ArcadeEnemy enemy, bool isFlashing) {
    final r = enemy.radius;
    final bodyPaint = Paint()
      ..color = isFlashing
          ? Colors.white
          : const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    // Curved bean/spiral body
    final bodyPath = Path()
      ..moveTo(-r * 0.9, 0)
      ..cubicTo(-r * 0.8, -r * 0.9, r * 0.3, -r * 0.8, r * 0.9, -r * 0.2)
      ..cubicTo(r * 1.1, r * 0.5, r * 0.2, r * 0.9, -r * 0.5, r * 0.6)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Trailing flagella tails
    final flagellaPaint = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    for (int i = 0; i < 3; i++) {
      final flagPath = Path();
      flagPath.moveTo(-r * 0.8, (i - 1) * 5.0);
      final wave = math.sin(enemy.animPhase * 3.0 + i) * 8.0;
      flagPath.quadraticBezierTo(-r * 1.4, (i - 1) * 7.0 + wave, -r * 2.0, (i - 1) * 5.0 - wave);
      canvas.drawPath(flagPath, flagellaPaint);
    }

    // Eye stalk & pupil
    canvas.drawCircle(Offset(r * 0.4, -r * 0.4), 4.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(r * 0.45, -r * 0.4), 2.2, Paint()..color = const Color(0xFF0F172A));
  }

  // 2. Spike-Virion (Rotating spiky virus core)
  void _drawSpikeVirion(Canvas canvas, ArcadeEnemy enemy, bool isFlashing) {
    final r = enemy.radius;
    canvas.rotate(enemy.animPhase);

    // Radiating spikes
    final spikePaint = Paint()..color = isFlashing ? Colors.white : const Color(0xFFEC4899);
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi) / 4;
      final spikeLen = r * 1.35 + math.sin(enemy.animPhase * 2.0 + i) * 3.0;
      final pt = Offset(math.cos(angle) * spikeLen, math.sin(angle) * spikeLen);
      canvas.drawLine(Offset.zero, pt, spikePaint..strokeWidth = 2.5);
      canvas.drawCircle(pt, 3.2, Paint()..color = const Color(0xFFF43F5E));
    }

    // Central viral capsid
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: isFlashing
            ? [Colors.white, const Color(0xFFFDA4AF)]
            : [const Color(0xFFF472B6), const Color(0xFFBE185D)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    canvas.drawCircle(Offset.zero, r, corePaint);

    // Core biohazard-style ring
    canvas.drawCircle(
      Offset.zero,
      r * 0.45,
      Paint()
        ..color = const Color(0xFF831843)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  // 3. Cytokine-Blob (Acidic ameboid slime)
  void _drawCytokineBlob(Canvas canvas, ArcadeEnemy enemy, bool isFlashing) {
    final r = enemy.radius;
    final blobPaint = Paint()
      ..shader = RadialGradient(
        colors: isFlashing
            ? [Colors.white, const Color(0xFFFDE68A)]
            : [const Color(0xFFFBBF24), const Color(0xFFD97706), const Color(0xFF78350F)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));

    final path = Path();
    const count = 10;
    for (int i = 0; i < count; i++) {
      final angle = (i * math.pi * 2) / count;
      final rad = r + math.sin(enemy.animPhase * 2.5 + i * 1.2) * 4.0;
      final pt = Offset(math.cos(angle) * rad, math.sin(angle) * rad);
      if (i == 0) path.moveTo(pt.dx, pt.dy); else path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, blobPaint);

    // Mouth / Acid vent
    final mouthPaint = Paint()..color = const Color(0xFF451A03);
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(-2, 2), width: r * 0.8, height: r * 0.6),
      0,
      math.pi,
      true,
      mouthPaint,
    );
  }

  // 4. Acid Sentry (Biomechanical armored guardian)
  void _drawAcidSentry(Canvas canvas, ArcadeEnemy enemy, bool isFlashing) {
    final r = enemy.radius;
    final armorPaint = Paint()..color = isFlashing ? Colors.white : const Color(0xFF334155);
    final corePaint = Paint()..color = const Color(0xFFF59E0B);

    // Hexagonal shell
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi) / 3;
      final pt = Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) hexPath.moveTo(pt.dx, pt.dy); else hexPath.lineTo(pt.dx, pt.dy);
    }
    hexPath.close();
    canvas.drawPath(hexPath, armorPaint);

    // Central glowing red/orange ocular eye
    canvas.drawCircle(Offset.zero, r * 0.45, corePaint);
    canvas.drawCircle(Offset.zero, r * 0.2, Paint()..color = Colors.white);
  }

  // 5. Toxic Spore (Floating explosive mine)
  void _drawToxicSpore(Canvas canvas, ArcadeEnemy enemy, bool isFlashing) {
    final r = enemy.radius;
    final sporePaint = Paint()
      ..shader = RadialGradient(
        colors: isFlashing
            ? [Colors.white, const Color(0xFFA7F3D0)]
            : [const Color(0xFF34D399), const Color(0xFF047857)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    canvas.drawCircle(Offset.zero, r, sporePaint);

    // 4 Cross nodules
    final nodulePaint = Paint()..color = const Color(0xFF064E3B);
    canvas.drawCircle(Offset(0, -r), 3.5, nodulePaint);
    canvas.drawCircle(Offset(0, r), 3.5, nodulePaint);
    canvas.drawCircle(Offset(-r, 0), 3.5, nodulePaint);
    canvas.drawCircle(Offset(r, 0), 3.5, nodulePaint);
  }

  // ==========================================================================
  // 6C. PROJECTILES (8 DISTINCT WEAPON STYLES & ENEMY GLOBULES)
  // ==========================================================================
  void _drawProjectiles(Canvas canvas, Size size) {
    // 1. Player Projectiles
    for (final p in controller.playerProjectiles) {
      if (p.isDead ||
          p.position.dx < controller.cameraX - 60 ||
          p.position.dx > controller.cameraX + size.width + 60) {
        continue;
      }

      // Soft radial glow halo (lightweight, high FPS)
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            p.color.withValues(alpha: 0.55),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: p.position, radius: p.radius * 2.2));
      canvas.drawCircle(p.position, p.radius * 2.2, glowPaint);

      switch (p.weaponType) {
        case WeaponType.antibacterialCannon:
          // Heavy golden-orange burst pellet with antibacterial star core
          canvas.drawCircle(p.position, p.radius, Paint()..color = p.color);
          canvas.drawCircle(p.position, p.radius * 0.55, Paint()..color = const Color(0xFFFEF08A));
          canvas.drawCircle(
            p.position,
            p.radius * 1.25,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.7)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4,
          );
          break;

        case WeaponType.therapeuticOrbs:
          // Mint emerald homing capsule orb with trailing medical cross glow
          canvas.drawCircle(
            p.position,
            p.radius,
            Paint()
              ..shader = RadialGradient(
                colors: [Colors.white, p.color, const Color(0xFF059669)],
              ).createShader(Rect.fromCircle(center: p.position, radius: p.radius)),
          );
          canvas.drawCircle(p.position - const Offset(6, 0), p.radius * 0.5, Paint()..color = p.color.withValues(alpha: 0.45));
          break;

        case WeaponType.plasmaShot:
          final orbPaint = Paint()
            ..shader = RadialGradient(
              colors: [Colors.white, p.color, const Color(0xFF0F766E)],
            ).createShader(Rect.fromCircle(center: p.position, radius: p.radius));
          canvas.drawCircle(p.position, p.radius, orbPaint);
          break;

        case WeaponType.energyShield:
          // Biomagnetic violet deflector crescent
          final arcRect = Rect.fromCircle(center: p.position, radius: p.radius * 1.25);
          canvas.drawArc(
            arcRect,
            -math.pi * 0.4,
            math.pi * 0.8,
            false,
            Paint()
              ..color = p.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5
              ..strokeCap = StrokeCap.round,
          );
          canvas.drawCircle(p.position, p.radius * 0.4, Paint()..color = Colors.white);
          break;

        case WeaponType.electricWave:
          final wavePaint = Paint()
            ..color = p.color
            ..strokeWidth = 3.6
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;
          final wavePath = Path()
            ..moveTo(p.position.dx - 16, p.position.dy)
            ..quadraticBezierTo(p.position.dx - 8, p.position.dy - 9, p.position.dx, p.position.dy)
            ..quadraticBezierTo(p.position.dx + 8, p.position.dy + 9, p.position.dx + 16, p.position.dy);
          canvas.drawPath(wavePath, wavePaint);
          break;

        case WeaponType.ultimatePulse:
          final pulseRect = Rect.fromCenter(center: p.position, width: p.radius * 3.4, height: p.radius * 1.6);
          final pulsePaint = Paint()
            ..shader = LinearGradient(
              colors: [Colors.white, p.color, const Color(0xFFFBBF24)],
            ).createShader(pulseRect);
          canvas.drawOval(pulseRect, pulsePaint);
          break;

        case WeaponType.doubleLaser:
        case WeaponType.medicalLaser:
          final beamRect = Rect.fromCenter(center: p.position, width: p.radius * 3.8, height: p.radius * 1.25);
          final beamPaint = Paint()
            ..shader = LinearGradient(
              colors: [Colors.white, p.color],
            ).createShader(beamRect);
          canvas.drawRRect(RRect.fromRectAndRadius(beamRect, const Radius.circular(3.5)), beamPaint);
          break;
      }
    }

    // 2. Enemy Projectiles (crisp coral-orange spheres)
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
        ep.radius + 2.0,
        Paint()
          ..color = const Color(0xFFFDA4AF).withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  // ==========================================================================
  // 7. BOSS MONSTER (LIVE 2D BOSS CHAMBER WITH TELEGRAPHS & PHASE 2 AURA)
  // ==========================================================================
  void _drawBoss(Canvas canvas, Size size) {
    final boss = controller.boss;
    if (boss.isDefeated && controller.state == GameState.victory) return;
    if (boss.position.dx < controller.cameraX - 200 || boss.position.dx > controller.cameraX + size.width + 240) {
      return;
    }

    // Draw Charge Aiming Lane Telegraph BEFORE boss lunges!
    if (controller.state == GameState.bossFight &&
        boss.currentPattern == BossAttackPattern.chargeTelegraph &&
        boss.isTelegraphing) {
      final flashAlpha = (0.35 + 0.35 * math.sin(controller.gameTime * 22.0)).clamp(0.15, 0.7);
      final laneRect = Rect.fromLTRB(
        controller.cameraX,
        boss.chargeTargetY - 38.0,
        boss.position.dx,
        boss.chargeTargetY + 38.0,
      );
      canvas.drawRect(
        laneRect,
        Paint()..color = const Color(0xFFFB7185).withValues(alpha: flashAlpha * 0.45),
      );
      canvas.drawLine(
        Offset(controller.cameraX, boss.chargeTargetY),
        Offset(boss.position.dx, boss.chargeTargetY),
        Paint()
          ..color = const Color(0xFFFDE047).withValues(alpha: flashAlpha)
          ..strokeWidth = 3.0,
      );
    }

    final pos = boss.position;
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    final Color auraCol = boss.isHit
        ? Colors.white
        : (boss.isPhase2 ? const Color(0xFFFB7185) : boss.auraColor);

    // Boss Aura (pulses when telegraphing or in Phase 2)
    final double pulseSize = 86.0 + (boss.isTelegraphing ? math.sin(controller.gameTime * 18.0) * 10.0 : 0.0);
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          auraCol.withValues(alpha: boss.isTelegraphing ? 0.55 : 0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: pulseSize));
    canvas.drawCircle(Offset.zero, pulseSize, auraPaint);

    // Boss Body (Luminous 2D cartoon pathogen boss)
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: boss.isHit
            ? [Colors.white, const Color(0xFFFDA4AF), const Color(0xFFE11D48)]
            : [
                Color.lerp(auraCol, Colors.white, 0.35)!,
                auraCol,
                const Color(0xFF1E293B),
              ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 66));
    canvas.drawCircle(Offset.zero, 62.0, bodyPaint);

    // Boss Outline
    canvas.drawCircle(
      Offset.zero,
      62.0,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Animated Boss Flagella / Appendages
    final tentaclePaint = Paint()
      ..color = auraCol
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi) / 3 + math.sin(controller.gameTime * 2.0 + i) * 0.12;
      final wave = math.sin(controller.gameTime * 4.5 + i) * 14.0;
      final start = Offset(math.cos(angle) * 52, math.sin(angle) * 52);
      final end = Offset(math.cos(angle) * 96 + wave, math.sin(angle) * 96 + wave);
      canvas.drawLine(start, end, tentaclePaint);
    }

    // Glowing Expressive Eyes
    final eyePaint = Paint()..color = boss.isHit ? Colors.white : const Color(0xFFFEF08A);
    canvas.drawOval(Rect.fromCenter(center: const Offset(-22, -14), width: 20, height: 24), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(18, -14), width: 20, height: 24), eyePaint);

    final pupilPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(const Offset(-25, -14), 6.0, pupilPaint);
    canvas.drawCircle(const Offset(15, -14), 6.0, pupilPaint);

    // Tooth-filled Cartoon Jaw
    final jawPath = Path()
      ..moveTo(-32, 16)
      ..quadraticBezierTo(-2, 46, 28, 16)
      ..quadraticBezierTo(-2, 22, -32, 16);
    final jawPaint = Paint()..color = const Color(0xFF881337);
    canvas.drawPath(jawPath, jawPaint);

    // Overhead Smooth Continuous Boss Health Bar
    const barW = 136.0;
    final barBgRect = Rect.fromCenter(center: const Offset(0, -84), width: barW, height: 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barBgRect, const Radius.circular(6)),
      Paint()..color = const Color(0xCC0F172A),
    );
    final fillW = (barW - 4.0) * boss.healthRatio;
    if (fillW > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-barW / 2 + 2.0, -88.0, fillW, 8.0),
          const Radius.circular(4),
        ),
        Paint()
          ..color = boss.isPhase2 ? const Color(0xFFFB7185) : const Color(0xFFFBBF24),
      );
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

    // --- ION PROPULSION JET TRAIL (NEWEST AT INDEX 0 -> FADES BACKWARD) ---
    if (p.trailPositions.isNotEmpty) {
      final int len = p.trailPositions.length;
      for (int i = 0; i < len; i++) {
        final pos = p.trailPositions[i];
        final fraction = ((len - i) / len).clamp(0.0, 1.0);
        final radius = (p.radius * 0.42 * fraction).clamp(2.0, 8.5);
        final alpha = (fraction * 0.42).clamp(0.05, 0.45);

        final Color trailCol = p.isMaxSynergy ? const Color(0xFFFBBF24) : const Color(0xFF22D3EE);
        canvas.drawCircle(pos, radius * 1.3, Paint()..color = trailCol.withValues(alpha: alpha));
        canvas.drawCircle(pos, radius * 0.5, Paint()..color = Colors.white.withValues(alpha: alpha * 0.85));
      }
    }

    // Recoil nudge backward on shot
    final recoilOffset = p.shootRecoilTimer > 0 ? -(p.shootRecoilTimer / 0.10) * 3.5 : 0.0;

    canvas.save();
    canvas.translate(p.position.dx + recoilOffset, p.position.dy);
    canvas.rotate(p.angle);

    // --- MAX SYNERGIE GOLDEN AURA ---
    if (p.isMaxSynergy) {
      final auraPulse = 1.0 + math.sin(controller.gameTime * 8.0) * 0.08;
      canvas.drawCircle(
        Offset.zero,
        (p.radius + 10.0) * auraPulse,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFBBF24).withValues(alpha: 0.35),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: p.radius + 12.0)),
      );
    }

    // --- A. SOFT HEADLIGHT CONE ---
    final conePath = Path()
      ..moveTo(p.radius * 0.8, -4.0)
      ..lineTo(p.radius * 0.8 + 220.0, -76.0)
      ..lineTo(p.radius * 0.8 + 220.0, 76.0)
      ..lineTo(p.radius * 0.8, 4.0)
      ..close();

    final lightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF22D3EE).withValues(alpha: 0.32),
          const Color(0xFF22D3EE).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(p.radius * 0.8, -76, 220, 152));
    canvas.drawPath(conePath, lightPaint);

    // --- B. INVULNERABILITY FLASH ---
    if (p.isInvulnerable && !p.isShieldActive) {
      final shieldAlpha = (math.sin(controller.gameTime * 18.0) * 0.35 + 0.45).clamp(0.1, 0.75);
      final shieldPaint = Paint()
        ..color = const Color(0xFF34D399).withValues(alpha: shieldAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(Offset.zero, p.radius + 7.0, shieldPaint);
    }

    // --- C. THRUSTER FLAME NOZZLE ---
    final isFiringThruster = p.isThrusting || p.isBoosted || p.flameIntensity > 0.15 || p.moveInput.dx > 0.1;
    if (isFiringThruster) {
      final intensity = math.max(p.flameIntensity, p.isBoosted ? 1.4 : (p.isThrusting ? 1.0 : 0.65));
      final flameLength = (22.0 + math.sin(controller.gameTime * 28.0) * 5.0) * intensity;
      final flamePath = Path()
        ..moveTo(-p.radius * 0.9, -6.0)
        ..lineTo(-p.radius * 0.9 - flameLength, 0)
        ..lineTo(-p.radius * 0.9, 6.0)
        ..close();

      final flamePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            p.isMaxSynergy ? const Color(0xFFFBBF24) : const Color(0xFF22D3EE),
            const Color(0xFF38BDF8),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(-p.radius - flameLength, -8, flameLength, 16));
      canvas.drawPath(flamePath, flamePaint);
    }

    // --- D. CAPSULE BODY (PEARL WHITE + METALLIC SHADING) ---
    // Stabilizer mini-wings (top and bottom fins from Reference Image 1)
    final finWingY = math.sin(p.animPhase * 2.0) * 2.5;
    final topFin = Path()
      ..moveTo(-p.radius * 0.4, -p.radius * 0.8)
      ..lineTo(-p.radius * 0.7, -p.radius * 1.5 + finWingY)
      ..lineTo(0, -p.radius * 0.9)
      ..close();
    final bottomFin = Path()
      ..moveTo(-p.radius * 0.4, p.radius * 0.8)
      ..lineTo(-p.radius * 0.7, p.radius * 1.5 - finWingY)
      ..lineTo(0, p.radius * 0.9)
      ..close();

    final finPaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawPath(topFin, finPaint);
    canvas.drawPath(bottomFin, finPaint);

    // Oval Capsule Pod Body
    final podRect = Rect.fromCenter(center: Offset.zero, width: p.radius * 2.3, height: p.radius * 1.8);
    final podPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFE2E8F0),
          Color(0xFF94A3B8),
        ],
      ).createShader(podRect);
    canvas.drawOval(podRect, podPaint);

    // Medical Stripe
    final stripePaint = Paint()
      ..color = const Color(0xFF0D9488)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawArc(podRect, -math.pi * 0.35, math.pi * 0.7, false, stripePaint);

    // Cockpit Visor / Headlamp Dome (Glowing Cyan Glass)
    final visorRect = Rect.fromCenter(center: Offset(p.radius * 0.5, 0), width: p.radius * 0.95, height: p.radius * 1.1);
    final visorPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFE0F2FE),
          Color(0xFF38BDF8),
          Color(0xFF0284C7),
        ],
      ).createShader(visorRect);
    canvas.drawOval(visorRect, visorPaint);

    // Visor glass reflection gleam
    final gleamPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(Offset(p.radius * 0.6, -3), 2.5, gleamPaint);

    // Outer outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawOval(podRect, outlinePaint);

    // --- E. WEAPON CANNONS & MUZZLE EMITTERS ---
    final weaponConfig = controller.equippedWeaponConfig;
    final cannonPaint = Paint()..color = const Color(0xFF1E293B);
    final muzzleGlow = Paint()
      ..color = weaponConfig.glowColor.withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5);

    // Primary Top Cannon
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(p.radius * 0.4, -p.radius * 0.55, 11, 3.5),
        const Radius.circular(1.5),
      ),
      cannonPaint,
    );
    canvas.drawCircle(Offset(p.radius * 0.4 + 11, -p.radius * 0.55 + 1.75), 2.5, muzzleGlow);

    // Secondary Bottom Cannon (Double shot or upgraded)
    if (p.hasDoubleShot || weaponConfig.type == WeaponType.doubleLaser) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(p.radius * 0.4, p.radius * 0.35, 11, 3.5),
          const Radius.circular(1.5),
        ),
        cannonPaint,
      );
      canvas.drawCircle(Offset(p.radius * 0.4 + 11, p.radius * 0.35 + 1.75), 2.5, muzzleGlow);
    }

    // --- F. ACTIVE BIOMAGNETIC ENERGY SHIELD ---
    if (p.isShieldActive) {
      final shieldRadius = p.radius + 14.0;
      final shieldPulse = math.sin(controller.gameTime * 8.0) * 2.0;

      // Outer glow
      final shieldGlow = Paint()
        ..color = const Color(0xFF818CF8).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
      canvas.drawCircle(Offset.zero, shieldRadius + shieldPulse + 4, shieldGlow);

      // Translucent hex barrier
      final barrierPaint = Paint()
        ..color = const Color(0xFF818CF8).withValues(alpha: 0.22)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, shieldRadius + shieldPulse, barrierPaint);

      // Pulsing hex border
      final hexPath = Path();
      for (int i = 0; i < 6; i++) {
        final angle = (i * math.pi) / 3 + controller.gameTime * 2.0;
        final pt = Offset(
          math.cos(angle) * (shieldRadius + shieldPulse),
          math.sin(angle) * (shieldRadius + shieldPulse),
        );
        if (i == 0) hexPath.moveTo(pt.dx, pt.dy); else hexPath.lineTo(pt.dx, pt.dy);
      }
      hexPath.close();

      final hexPaint = Paint()
        ..color = const Color(0xFFC7D2FE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(hexPath, hexPaint);
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

      final textSpan = TextSpan(
        text: txt.text,
        style: TextStyle(
          color: txt.color.withValues(alpha: txt.life.clamp(0.0, 1.0)),
          fontSize: txt.fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.8 * txt.life),
              offset: const Offset(1.5, 1.5),
              blurRadius: 3.0,
            ),
          ],
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

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
