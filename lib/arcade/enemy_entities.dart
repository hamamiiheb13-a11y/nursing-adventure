import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'weapon_entities.dart';

abstract class Enemy {
  Offset position; // World coordinate
  Offset velocity;
  int health;
  int maxHealth;
  double speed;
  int damage;
  int scoreValue;
  double radius;
  double hitFlashTimer = 0.0;
  bool isDead = false;
  double animTimer = 0.0;

  Enemy({
    required this.position,
    required this.velocity,
    required this.health,
    required this.maxHealth,
    required this.speed,
    required this.damage,
    required this.scoreValue,
    required this.radius,
  });

  Rect get bounds => Rect.fromCircle(center: position, radius: radius);

  void onHit(int dmg) {
    health -= dmg;
    hitFlashTimer = 0.18; // White flash on damage
    if (health <= 0) {
      isDead = true;
    }
  }

  void update(double dt, {Offset? targetPos, List<Projectile>? enemyProjectiles}) {
    animTimer += dt;
    if (hitFlashTimer > 0) {
      hitFlashTimer = math.max(0, hitFlashTimer - dt);
    }
    position += velocity * dt;
  }

  void draw(Canvas canvas, Offset screenPos);
}

// 1. HelicoBacterium — Red spiral bacterium, wiggles left-right
class HelicoBacterium extends Enemy {
  final double initialY;
  final double wiggleFreq;
  final double wiggleAmp;

  HelicoBacterium({
    required super.position,
    super.speed = 120.0,
    super.health = 3,
    super.maxHealth = 3,
    super.damage = 1,
    super.scoreValue = 150,
    super.radius = 16.0,
    this.wiggleFreq = 5.0,
    this.wiggleAmp = 80.0,
  })  : initialY = position.dy,
        super(velocity: Offset(-speed, 0));

  @override
  void update(double dt, {Offset? targetPos, List<Projectile>? enemyProjectiles}) {
    animTimer += dt;
    if (hitFlashTimer > 0) {
      hitFlashTimer = math.max(0, hitFlashTimer - dt);
    }
    final vy = math.cos(animTimer * wiggleFreq) * wiggleAmp;
    velocity = Offset(-speed, vy);
    position += velocity * dt;
  }

  @override
  void draw(Canvas canvas, Offset screenPos) {
    canvas.save();
    canvas.translate(screenPos.dx, screenPos.dy);

    final isFlashing = hitFlashTimer > 0;

    // Segmented curved helical body
    for (int i = 0; i < 5; i++) {
      final segX = (i - 2) * 7.0;
      final segY = math.sin(animTimer * 8.0 + i * 0.8) * 4.0;
      final segRadius = (16.0 - (i - 2).abs() * 2.5).clamp(4.0, 16.0);

      final segGradient = RadialGradient(
        colors: isFlashing
            ? [Colors.white, Colors.white]
            : [const Color(0xFFFF8A80), const Color(0xFFC62828), const Color(0xFF530000)],
      ).createShader(Rect.fromCircle(center: Offset(segX, segY), radius: segRadius));

      canvas.drawCircle(Offset(segX, segY), segRadius, Paint()..shader = segGradient);
    }

    // Flagella tails at the rear (right side, since swimming left)
    final flagellaPaint = Paint()
      ..color = isFlashing ? Colors.white : const Color(0xFFFF5252)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int j = -1; j <= 1; j++) {
      final flagPath = Path()..moveTo(14, j * 3.0);
      final wave1 = math.sin(animTimer * 12.0 + j) * 8.0;
      final wave2 = math.cos(animTimer * 12.0 + j) * 10.0;
      flagPath.quadraticBezierTo(24, j * 5.0 + wave1, 34, j * 4.0 + wave2);
      canvas.drawPath(flagPath, flagellaPaint);
    }

    // Menacing glowing eyes at the front (left)
    final eyePaint = Paint()..color = isFlashing ? Colors.red : const Color(0xFFFFEB3B);
    canvas.drawCircle(const Offset(-10, -3), 2.5, eyePaint);
    canvas.drawCircle(const Offset(-10, 3), 2.5, eyePaint);

    canvas.restore();
  }
}

// 2. CytokineCloud — Orange blob, drifts down toward capsule
class CytokineCloud extends Enemy {
  CytokineCloud({
    required super.position,
    super.speed = 90.0,
    super.health = 4,
    super.maxHealth = 4,
    super.damage = 1,
    super.scoreValue = 200,
    super.radius = 20.0,
  }) : super(velocity: Offset(-speed, 20));

  @override
  void update(double dt, {Offset? targetPos, List<Projectile>? enemyProjectiles}) {
    animTimer += dt;
    if (hitFlashTimer > 0) {
      hitFlashTimer = math.max(0, hitFlashTimer - dt);
    }

    if (targetPos != null) {
      // Drift gently towards target player position
      final delta = targetPos - position;
      final angle = math.atan2(delta.dy, delta.dx);
      final desiredVx = math.cos(angle) * speed;
      final desiredVy = math.sin(angle) * speed;
      velocity = Offset(
        velocity.dx * 0.95 + desiredVx * 0.05,
        velocity.dy * 0.95 + desiredVy * 0.05,
      );
    } else {
      velocity = Offset(-speed, math.sin(animTimer * 2.0) * 30.0);
    }

    position += velocity * dt;
  }

  @override
  void draw(Canvas canvas, Offset screenPos) {
    canvas.save();
    canvas.translate(screenPos.dx, screenPos.dy);

    final isFlashing = hitFlashTimer > 0;

    // Organic pulsing blob lobes
    final path = Path();
    const numPoints = 8;
    for (int i = 0; i < numPoints; i++) {
      final angle = (i * 2 * math.pi) / numPoints;
      final pulse = math.sin(animTimer * 5.0 + i * 1.5) * 4.0;
      final r = radius + pulse;
      final px = math.cos(angle) * r;
      final py = math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();

    // Outer cloud glow
    canvas.drawCircle(
      Offset.zero,
      radius + 6,
      Paint()..color = isFlashing ? Colors.white70 : const Color(0x55FF6D00),
    );

    // Inner fiery gradient
    final gradient = RadialGradient(
      colors: isFlashing
          ? [Colors.white, Colors.white]
          : [
              const Color(0xFFFFD54F),
              const Color(0xFFFF6D00),
              const Color(0xFFDD2C00),
            ],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));

    canvas.drawPath(path, Paint()..shader = gradient);

    // Toxic nucleus bubbles inside
    final bubblePaint = Paint()
      ..color = isFlashing ? Colors.white : const Color(0x99FFEA00);
    for (int k = 0; k < 3; k++) {
      final bAngle = animTimer * 3.0 + k * 2.0;
      final bDist = 6.0;
      canvas.drawCircle(
        Offset(math.cos(bAngle) * bDist, math.sin(bAngle) * bDist),
        3.5,
        bubblePaint,
      );
    }

    canvas.restore();
  }
}

// 3. SpikeVirion — Purple spiky virus ball, bounces diagonally
class SpikeVirion extends Enemy {
  final double topLimit;
  final double bottomLimit;

  SpikeVirion({
    required super.position,
    super.speed = 160.0,
    super.health = 3,
    super.maxHealth = 3,
    super.damage = 1,
    super.scoreValue = 180,
    super.radius = 18.0,
    this.topLimit = 80.0,
    this.bottomLimit = 420.0,
  }) : super(velocity: Offset(-speed * 0.8, speed * 0.7));

  @override
  void update(double dt, {Offset? targetPos, List<Projectile>? enemyProjectiles}) {
    animTimer += dt;
    if (hitFlashTimer > 0) {
      hitFlashTimer = math.max(0, hitFlashTimer - dt);
    }

    // Bounce vertically at boundaries
    if (position.dy < topLimit && velocity.dy < 0) {
      velocity = Offset(velocity.dx, -velocity.dy);
    } else if (position.dy > bottomLimit && velocity.dy > 0) {
      velocity = Offset(velocity.dx, -velocity.dy);
    }

    position += velocity * dt;
  }

  @override
  void draw(Canvas canvas, Offset screenPos) {
    canvas.save();
    canvas.translate(screenPos.dx, screenPos.dy);
    canvas.rotate(animTimer * 2.5); // Continuous aggressive rotation

    final isFlashing = hitFlashTimer > 0;

    // 12 Sharp Radiating spikes with club heads
    final spikePaint = Paint()
      ..color = isFlashing ? Colors.white : const Color(0xFFBA68C8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final clubPaint = Paint()
      ..color = isFlashing ? Colors.white : const Color(0xFFE040FB)
      ..style = PaintingStyle.fill;

    const spikeCount = 10;
    for (int i = 0; i < spikeCount; i++) {
      final angle = (i * 2 * math.pi) / spikeCount;
      final inner = Offset(math.cos(angle) * (radius - 2), math.sin(angle) * (radius - 2));
      final outer = Offset(math.cos(angle) * (radius + 9), math.sin(angle) * (radius + 9));
      canvas.drawLine(inner, outer, spikePaint);
      canvas.drawCircle(outer, 3.2, clubPaint);
    }

    // Central viral capsid sphere
    final coreGradient = RadialGradient(
      colors: isFlashing
          ? [Colors.white, Colors.white]
          : [
              const Color(0xFFEA80FC),
              const Color(0xFF8E24AA),
              const Color(0xFF38006B),
            ],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));

    canvas.drawCircle(Offset.zero, radius, Paint()..shader = coreGradient);

    // Capsid surface facets / spikes
    final rimPaint = Paint()
      ..color = isFlashing ? Colors.white : const Color(0xFFD500F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset.zero, radius, rimPaint);

    canvas.restore();
  }
}

// 4. AcidDroplet — Green droplet, falls from ceiling
class AcidDroplet extends Enemy {
  final double floorY;
  bool isSplashing = false;
  double splashTimer = 0.0;

  AcidDroplet({
    required super.position,
    super.speed = 100.0,
    super.health = 2,
    super.maxHealth = 2,
    super.damage = 1,
    super.scoreValue = 120,
    super.radius = 14.0,
    this.floorY = 440.0,
  }) : super(velocity: const Offset(-40, 100));

  @override
  void update(double dt, {Offset? targetPos, List<Projectile>? enemyProjectiles}) {
    animTimer += dt;
    if (hitFlashTimer > 0) {
      hitFlashTimer = math.max(0, hitFlashTimer - dt);
    }

    if (isSplashing) {
      splashTimer += dt;
      if (splashTimer > 0.35) {
        isDead = true;
      }
      return;
    }

    // Accelerate downward with gravity
    velocity = Offset(velocity.dx, velocity.dy + 380.0 * dt);
    position += velocity * dt;

    if (position.dy >= floorY) {
      isSplashing = true;
    }
  }

  @override
  void draw(Canvas canvas, Offset screenPos) {
    canvas.save();
    canvas.translate(screenPos.dx, screenPos.dy);

    final isFlashing = hitFlashTimer > 0;

    if (isSplashing) {
      // Splash rings expanding on ground
      final splashProgress = splashTimer / 0.35;
      final splashPaint = Paint()
        ..color = (isFlashing ? Colors.white : const Color(0xFF76FF03))
            .withValues(alpha: 1.0 - splashProgress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: 36.0 * splashProgress,
          height: 12.0 * splashProgress,
        ),
        splashPaint,
      );
      canvas.restore();
      return;
    }

    // Aerodynamic falling droplet shape
    final dropPath = Path();
    dropPath.moveTo(0, -radius * 1.5); // Sharp top tail
    dropPath.quadraticBezierTo(radius, -radius * 0.2, radius, radius * 0.4);
    dropPath.arcToPoint(
      Offset(-radius, radius * 0.4),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    dropPath.quadraticBezierTo(-radius, -radius * 0.2, 0, -radius * 1.5);
    dropPath.close();

    // Fluorescent toxic acid green gradient
    final acidGradient = RadialGradient(
      colors: isFlashing
          ? [Colors.white, Colors.white]
          : [
              const Color(0xFFCCFF90),
              const Color(0xFF76FF03),
              const Color(0xFF1B5E20),
            ],
    ).createShader(Rect.fromCircle(center: Offset(0, radius * 0.4), radius: radius));

    canvas.drawPath(dropPath, Paint()..shader = acidGradient);

    // Caustic acid bubble highlight
    final glossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-radius * 0.3, radius * 0.2), 3.0, glossPaint);

    canvas.restore();
  }
}

// 5. ToxicSpore — Dark mushroom spore, slow but fires mini-spores
class ToxicSpore extends Enemy {
  double shootCooldown = 1.8;

  ToxicSpore({
    required super.position,
    super.speed = 60.0,
    super.health = 5,
    super.maxHealth = 5,
    super.damage = 2,
    super.scoreValue = 250,
    super.radius = 22.0,
  }) : super(velocity: Offset(-speed, 0));

  @override
  void update(double dt, {Offset? targetPos, List<Projectile>? enemyProjectiles}) {
    animTimer += dt;
    if (hitFlashTimer > 0) {
      hitFlashTimer = math.max(0, hitFlashTimer - dt);
    }

    // Slow drifting float with subtle bobbing
    position = Offset(position.dx - speed * dt, position.dy + math.sin(animTimer * 2.5) * 20.0 * dt);

    // Fire mini-spores periodically
    shootCooldown -= dt;
    if (shootCooldown <= 0 && enemyProjectiles != null) {
      shootCooldown = 2.2;
      // Spawn poisonous spore projectile towards player or straight left
      final dir = targetPos != null ? (targetPos - position) : const Offset(-1, 0);
      final angle = math.atan2(dir.dy, dir.dx);
      final projVel = Offset(math.cos(angle) * 200.0, math.sin(angle) * 200.0);

      enemyProjectiles.add(
        Projectile(
          position: position,
          velocity: projVel,
          type: WeaponType.medicalLaser,
          damage: 1,
          isEnemy: true,
          radius: 6.0,
          maxLifeTime: 4.0,
        ),
      );
    }
  }

  @override
  void draw(Canvas canvas, Offset screenPos) {
    canvas.save();
    canvas.translate(screenPos.dx, screenPos.dy);

    final isFlashing = hitFlashTimer > 0;

    // Dark spore body with glowing noxious pores
    final sporeGradient = RadialGradient(
      colors: isFlashing
          ? [Colors.white, Colors.white]
          : [
              const Color(0xFF616161),
              const Color(0xFF263238),
              const Color(0xFF000A12),
            ],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));

    canvas.drawCircle(Offset.zero, radius, Paint()..shader = sporeGradient);

    // Toxic glow pores (bioluminescent yellow-green)
    final porePaint = Paint()
      ..color = isFlashing ? Colors.white : const Color(0xFFC6FF00)
      ..style = PaintingStyle.fill;

    for (int p = 0; p < 5; p++) {
      final pAngle = (p * 2 * math.pi) / 5 + animTimer * 0.8;
      final dist = radius * 0.55;
      final porePos = Offset(math.cos(pAngle) * dist, math.sin(pAngle) * dist);
      canvas.drawCircle(porePos, 3.2, porePaint);
    }

    // Spore cap brim
    final brimPaint = Paint()
      ..color = isFlashing ? Colors.white : const Color(0xFF78909C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset.zero, radius, brimPaint);

    canvas.restore();
  }
}
