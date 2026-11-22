import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'weapon_entities.dart';

class BossExplosionParticle {
  Offset position;
  Offset velocity;
  Color color;
  double radius;
  double life;
  double maxLife;

  BossExplosionParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.radius,
    required this.maxLife,
  }) : life = maxLife;

  bool get isDead => life <= 0;

  void update(double dt) {
    position += velocity * dt;
    life -= dt;
  }

  void draw(Canvas canvas, Offset screenOffset) {
    if (isDead) return;
    final progress = (life / maxLife).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withValues(alpha: progress)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(screenOffset + position, radius * progress, paint);
  }
}

class BossEntity {
  final int stageId;
  final String name;
  final String title;
  Offset position; // World coordinates
  Offset velocity;
  int health;
  final int maxHealth;
  final double size; // ~260.0, 60-80% screen height

  int phase = 1; // 1 (100-66%), 2 (66-33%), 3 (<33% Enraged)
  double attackTimer = 0.0;
  double animTimer = 0.0;
  double hitFlashTimer = 0.0;
  bool isDefeated = false;
  double defeatTimer = 0.0;
  bool hasDroppedReward = false;
  final Color primaryColor;
  final Color auraColor;

  final List<BossExplosionParticle> particles = [];

  BossEntity({
    required this.stageId,
    required this.name,
    required this.title,
    required this.position,
    required this.maxHealth,
    required this.primaryColor,
    required this.auraColor,
    this.health = 50,
    this.size = 280.0,
    this.velocity = Offset.zero,
  });

  Rect get bounds => Rect.fromCenter(center: position, width: size * 0.85, height: size * 0.85);

  void onHit(int damage) {
    if (isDefeated) return;
    health = math.max(0, health - damage);
    hitFlashTimer = 0.15;

    // Check phase transitions
    final healthRatio = health / maxHealth;
    if (healthRatio <= 0.33) {
      phase = 3;
    } else if (healthRatio <= 0.66) {
      phase = 2;
    }

    if (health <= 0 && !isDefeated) {
      isDefeated = true;
      _spawnDefeatExplosions();
    }
  }

  void _spawnDefeatExplosions() {
    final rand = math.Random();
    for (int i = 0; i < 90; i++) {
      final angle = rand.nextDouble() * 2 * math.pi;
      final speed = 80.0 + rand.nextDouble() * 280.0;
      particles.add(
        BossExplosionParticle(
          position: Offset.zero,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: [
            primaryColor,
            auraColor,
            Colors.amber,
            Colors.white,
            const Color(0xFFFF1744),
          ][rand.nextInt(5)],
          radius: 3.0 + rand.nextDouble() * 7.0,
          maxLife: 0.8 + rand.nextDouble() * 1.4,
        ),
      );
    }
  }

  void update(
    double dt,
    Offset playerPos,
    List<Projectile> enemyProjectiles, {
    VoidCallback? onDropReward,
  }) {
    animTimer += dt;
    if (hitFlashTimer > 0) {
      hitFlashTimer = math.max(0, hitFlashTimer - dt);
    }

    // Update explosion particles
    for (final p in particles) {
      p.update(dt);
    }
    particles.removeWhere((p) => p.isDead);

    if (isDefeated) {
      defeatTimer += dt;
      if (defeatTimer > 0.6 && !hasDroppedReward) {
        hasDroppedReward = true;
        onDropReward?.call();
      }
      return;
    }

    // Hover & track player vertically
    final targetY = playerPos.dy.clamp(140.0, 380.0);
    final dy = targetY - position.dy;
    final speed = phase == 3 ? 120.0 : (phase == 2 ? 80.0 : 50.0);
    final vy = (dy * 1.5).clamp(-speed, speed);

    // Floating breathing oscillation
    final bob = math.sin(animTimer * 2.0) * 15.0;
    position = Offset(position.dx, position.dy + vy * dt + bob * dt);

    // Attack cadence based on phase
    attackTimer += dt;
    final interval = phase == 3 ? 1.1 : (phase == 2 ? 1.5 : 2.0);
    if (attackTimer >= interval) {
      attackTimer = 0.0;
      _executeAttack(playerPos, enemyProjectiles);
    }
  }

  void _executeAttack(Offset playerPos, List<Projectile> enemyProjectiles) {
    final dir = playerPos - position;
    final baseAngle = math.atan2(dir.dy, dir.dx);

    switch (phase) {
      case 1:
        // Single focused shot
        enemyProjectiles.add(
          Projectile(
            position: position + const Offset(-40, 0),
            velocity: Offset(math.cos(baseAngle) * 240, math.sin(baseAngle) * 240),
            type: WeaponType.medicalLaser,
            damage: 1,
            isEnemy: true,
            radius: 8.0,
          ),
        );
        break;

      case 2:
        // 3-way spread attack
        for (final spread in [-0.26, 0.0, 0.26]) {
          final angle = baseAngle + spread;
          enemyProjectiles.add(
            Projectile(
              position: position + const Offset(-40, 0),
              velocity: Offset(math.cos(angle) * 260, math.sin(angle) * 260),
              type: WeaponType.plasmaShot,
              damage: 1,
              isEnemy: true,
              radius: 9.0,
            ),
          );
        }
        break;

      case 3:
        // Enraged 5-way spread barrage
        for (final spread in [-0.48, -0.24, 0.0, 0.24, 0.48]) {
          final angle = baseAngle + spread;
          enemyProjectiles.add(
            Projectile(
              position: position + const Offset(-40, 0),
              velocity: Offset(math.cos(angle) * 290, math.sin(angle) * 290),
              type: WeaponType.ultimatePulse,
              damage: 1,
              isEnemy: true,
              radius: 10.0,
            ),
          );
        }
        break;
    }
  }

  void draw(Canvas canvas, Offset screenPos, Size screenSize) {
    // 1. Draw explosion particles
    for (final p in particles) {
      p.draw(canvas, screenPos);
    }

    if (isDefeated && defeatTimer > 1.2) {
      return; // Fully disintegrated
    }

    canvas.save();
    canvas.translate(screenPos.dx, screenPos.dy);

    // Roar/shake when taking hit
    if (hitFlashTimer > 0) {
      final shake = math.sin(animTimer * 40) * 4.0;
      canvas.translate(shake, 0);
    }

    // 2. Colossal Aura
    _drawBossAura(canvas);

    // 3. Stage-Specific Boss Body
    _drawBossBody(canvas);

    canvas.restore();

    // 4. Large Epic Health Bar on Screen Top
    _drawHealthBar(canvas, screenSize);
  }

  void _drawBossAura(Canvas canvas) {
    final auraPulse = math.sin(animTimer * 4.0) * 12.0;
    final r = (size * 0.42) + auraPulse;

    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (phase == 3 ? Colors.redAccent : auraColor).withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r * 1.3));

    canvas.drawCircle(Offset.zero, r * 1.3, auraPaint);
  }

  void _drawBossBody(Canvas canvas) {
    final isFlashing = hitFlashTimer > 0;
    final bodyRadius = size * 0.35;

    // Organic pulsating outer tentacles / fins
    final tentaclePaint = Paint()
      ..color = isFlashing ? Colors.white : primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + math.sin(animTimer * 3.0 + i) * 0.2;
      final start = Offset(math.cos(angle) * bodyRadius * 0.8, math.sin(angle) * bodyRadius * 0.8);
      final mid = Offset(math.cos(angle) * bodyRadius * 1.2, math.sin(angle) * bodyRadius * 1.2 + math.sin(animTimer * 5.0 + i) * 10);
      final end = Offset(math.cos(angle) * bodyRadius * 1.45, math.sin(angle) * bodyRadius * 1.45);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);
      canvas.drawPath(path, tentaclePaint);
    }

    // Massive Core Sphere
    final coreGradient = RadialGradient(
      colors: isFlashing
          ? [Colors.white, Colors.white]
          : [
              Colors.white.withValues(alpha: 0.8),
              primaryColor,
              auraColor,
              Colors.black,
            ],
      stops: const [0.0, 0.35, 0.8, 1.0],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: bodyRadius));

    canvas.drawCircle(Offset.zero, bodyRadius, Paint()..shader = coreGradient);

    // Menacing Central Eye
    final eyeRadius = bodyRadius * 0.4;
    final eyePaint = Paint()..color = (phase == 3 ? Colors.red : Colors.yellowAccent);
    canvas.drawCircle(const Offset(-15, 0), eyeRadius, eyePaint);

    // Pupil looking towards player (left)
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-24, 0), width: eyeRadius * 0.4, height: eyeRadius * 0.9),
      pupilPaint,
    );

    // Phase 3 Enraged Flaming Corona
    if (phase == 3) {
      final ragePaint = Paint()
        ..color = Colors.redAccent.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawCircle(Offset.zero, bodyRadius + 8.0 + math.sin(animTimer * 12.0) * 4.0, ragePaint);
    }
  }

  void _drawHealthBar(Canvas canvas, Size screenSize) {
    final barWidth = (screenSize.width * 0.65).clamp(280.0, 600.0);
    const barHeight = 18.0;
    final left = (screenSize.width - barWidth) / 2;
    const top = 22.0;

    // Background Container
    final bgRect = Rect.fromLTWH(left, top, barWidth, barHeight);
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.7);
    canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(9)), bgPaint);

    // Health Fill
    final healthRatio = (health / maxHealth).clamp(0.0, 1.0);
    if (healthRatio > 0) {
      final fillRect = Rect.fromLTWH(left + 2, top + 2, (barWidth - 4) * healthRatio, barHeight - 4);
      final fillGradient = LinearGradient(
        colors: phase == 3
            ? [Colors.orange, Colors.redAccent, Colors.red]
            : [Colors.cyanAccent, primaryColor, auraColor],
      ).createShader(fillRect);

      canvas.drawRRect(
        RRect.fromRectAndRadius(fillRect, const Radius.circular(7)),
        Paint()..shader = fillGradient,
      );
    }

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(9)), borderPaint);

    // Text: Boss Name & Phase
    final textPainter = TextPainter(
      text: TextSpan(
        text: '⚔️ $name - $title ${phase == 3 ? "[ENRAGÉ !]" : "[Phase $phase]"}',
        style: TextStyle(
          color: phase == 3 ? Colors.redAccent : Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset((screenSize.width - textPainter.width) / 2, top - 18),
    );
  }
}
