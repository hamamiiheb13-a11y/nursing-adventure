import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'weapon_entities.dart';

enum CapsuleAnimationState {
  idle,
  moving,
  shooting,
  damaged,
  shielded,
  victory,
}

class CapsuleEntity {
  Offset position; // World coordinates
  Offset velocity;
  int health;
  int maxHealth;
  double shieldTimer;
  int currentWeaponIndex;
  double weaponCooldown;
  CapsuleAnimationState animState;

  double aimAngle; // Rotation of weapon barrel in radians
  double radius;
  double invulnerableTimer;
  double animTime;
  double trailTimer;
  final List<Offset> propulsionTrails = [];

  CapsuleEntity({
    this.position = const Offset(120, 250),
    this.velocity = Offset.zero,
    this.health = 3,
    this.maxHealth = 3,
    this.shieldTimer = 0.0,
    this.currentWeaponIndex = 0,
    this.weaponCooldown = 0.0,
    this.animState = CapsuleAnimationState.idle,
    this.aimAngle = 0.0,
    this.radius = 20.0,
    this.invulnerableTimer = 0.0,
    this.animTime = 0.0,
    this.trailTimer = 0.0,
  });

  bool get isShieldActive => shieldTimer > 0;
  bool get isInvulnerable => invulnerableTimer > 0 || isShieldActive;
  bool get isDead => health <= 0;
  Rect get bounds => Rect.fromCircle(center: position, radius: radius);

  double get shield => shieldTimer;
  set shield(double val) => shieldTimer = val;

  WeaponType get currentWeapon => currentWeaponType;
  set currentWeapon(WeaponType w) {
    final idx = WeaponConfig.allWeapons.indexWhere((x) => x.type == w);
    if (idx != -1) currentWeaponIndex = idx;
  }

  WeaponType get currentWeaponType {
    final weapons = WeaponConfig.allWeapons;
    if (currentWeaponIndex >= 0 && currentWeaponIndex < weapons.length) {
      return weapons[currentWeaponIndex].type;
    }
    return WeaponType.medicalLaser;
  }

  void activateShield(double duration) {
    shieldTimer = math.max(shieldTimer, duration);
  }

  void takeDamage(int amount) {
    if (isInvulnerable) return;
    health = math.max(0, health - amount);
    invulnerableTimer = 1.8; // 1.8s invulnerability on hit
    velocity = Offset(velocity.dx * 0.2 - 120, -80); // Knockback
    animState = CapsuleAnimationState.damaged;
  }

  void heal(int amount) {
    health = math.min(maxHealth, health + amount);
  }

  void update(double dt) {
    animTime += dt;
    trailTimer += dt;

    if (shieldTimer > 0) {
      shieldTimer = math.max(0, shieldTimer - dt);
    }

    if (invulnerableTimer > 0) {
      invulnerableTimer = math.max(0, invulnerableTimer - dt);
    }

    if (weaponCooldown > 0) {
      weaponCooldown = math.max(0, weaponCooldown - dt);
    }

    // Update position with physics damping
    position += velocity * dt;
    velocity = Offset(velocity.dx * 0.94, velocity.dy * 0.94);

    // Determine animation state if not forced
    if (animState != CapsuleAnimationState.victory) {
      if (invulnerableTimer > 0 && health > 0) {
        animState = CapsuleAnimationState.damaged;
      } else if (isShieldActive) {
        animState = CapsuleAnimationState.shielded;
      } else if (velocity.distanceSquared > 400) {
        animState = CapsuleAnimationState.moving;
      } else {
        animState = CapsuleAnimationState.idle;
      }
    }
  }

  void draw(Canvas canvas, Offset screenPos) {
    // Flash transparency when damaged & invulnerable
    if (invulnerableTimer > 0 && (animTime * 18).toInt() % 2 == 0) {
      return; // blink frame
    }

    canvas.save();
    canvas.translate(screenPos.dx, screenPos.dy);

    // Subtle pitch tilt based on vertical velocity
    final tilt = (velocity.dy / 300.0).clamp(-0.25, 0.25);
    canvas.rotate(tilt);

    // 1. Propulsion Glow Effect (behind capsule)
    _drawPropulsion(canvas);

    // 2. Wing Details
    _drawWings(canvas);

    // 3. Capsule Body (Pill Shape with blue/cyan gradient)
    _drawCapsuleBody(canvas);

    // 4. Cockpit Window with highlight
    _drawCockpit(canvas);

    // 5. Weapon Barrel rotating toward mouse / aimAngle
    _drawWeaponBarrel(canvas);

    // 6. Shield Bubble (Cyan pulsing circle when active)
    if (isShieldActive) {
      _drawShield(canvas);
    }

    // 7. Victory sparkle
    if (animState == CapsuleAnimationState.victory) {
      _drawVictorySparkle(canvas);
    }

    canvas.restore();
  }

  void _drawPropulsion(Canvas canvas) {
    final flamePuff = math.sin(animTime * 25.0) * 4.0;
    final flameLength = 24.0 + (velocity.dx > 10 ? 12.0 : 0.0) + flamePuff;

    // Outer orange trail
    final outerFlame = Path()
      ..moveTo(-18, -7)
      ..lineTo(-18 - flameLength, 0)
      ..lineTo(-18, 7)
      ..close();

    final outerPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0xFFFF9100),
          Color(0xFFFF3D00),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(-18 - flameLength, -10, flameLength + 10, 20));

    canvas.drawPath(outerFlame, outerPaint);

    // Inner bright yellow flame
    final innerFlame = Path()
      ..moveTo(-18, -4)
      ..lineTo(-18 - flameLength * 0.6, 0)
      ..lineTo(-18, 4)
      ..close();

    final innerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFFFEA00)],
      ).createShader(Rect.fromLTWH(-18 - flameLength * 0.6, -4, flameLength * 0.6, 8));

    canvas.drawPath(innerFlame, innerPaint);
  }

  void _drawWings(Canvas canvas) {
    final wingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF00B0FF), Color(0xFF0077B6)],
      ).createShader(const Rect.fromLTWH(-16, -18, 20, 36));

    // Top Wing
    final topWing = Path()
      ..moveTo(-12, -10)
      ..lineTo(-4, -18)
      ..lineTo(6, -10)
      ..close();
    canvas.drawPath(topWing, wingPaint);

    // Bottom Wing
    final bottomWing = Path()
      ..moveTo(-12, 10)
      ..lineTo(-4, 18)
      ..lineTo(6, 10)
      ..close();
    canvas.drawPath(bottomWing, wingPaint);

    // Wing accent glow edges
    final edgePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawLine(const Offset(-12, -10), const Offset(-4, -18), edgePaint);
    canvas.drawLine(const Offset(-4, -18), const Offset(6, -10), edgePaint);
    canvas.drawLine(const Offset(-12, 10), const Offset(-4, 18), edgePaint);
    canvas.drawLine(const Offset(-4, 18), const Offset(6, 10), edgePaint);
  }

  void _drawCapsuleBody(Canvas canvas) {
    const pillRect = Rect.fromLTWH(-20, -11, 40, 22);
    final pillRRect = RRect.fromRectAndRadius(pillRect, const Radius.circular(11));

    // Pill gradient: Medical Pill with Left/Rear cyan-metallic and Right/Front pure medical white/cyan
    final bodyGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF00E5FF),
        Color(0xFF0091EA),
        Color(0xFF0D47A1),
      ],
      stops: [0.0, 0.45, 1.0],
    ).createShader(pillRect);

    final bodyPaint = Paint()..shader = bodyGradient;
    canvas.drawRRect(pillRRect, bodyPaint);

    // Forward medical capsule cap (front half in white/soft cyan)
    final frontClip = Path()
      ..addRect(const Rect.fromLTWH(0, -11, 20, 22));
    canvas.save();
    canvas.clipPath(frontClip);

    final frontPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
      ).createShader(const Rect.fromLTWH(0, -11, 20, 22));
    canvas.drawRRect(pillRRect, frontPaint);
    canvas.restore();

    // Metallic separation seam
    final seamPaint = Paint()
      ..color = const Color(0xFF004D40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(0, -11), const Offset(0, 11), seamPaint);

    // Outer rim highlight
    final rimPaint = Paint()
      ..color = const Color(0xAA00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(pillRRect, rimPaint);
  }

  void _drawCockpit(Canvas canvas) {
    // High-tech glass cockpit visor
    const cockpitRect = Rect.fromLTWH(4, -6, 12, 12);
    final cockpitRRect = RRect.fromRectAndRadius(cockpitRect, const Radius.circular(5));

    final glassPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF18FFFF),
          Color(0xFF00B0FF),
          Color(0xFF002171),
        ],
      ).createShader(cockpitRect);
    canvas.drawRRect(cockpitRRect, glassPaint);

    // Glass glint reflection
    final glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(6, -4), const Offset(12, -4), glintPaint);
  }

  void _drawWeaponBarrel(Canvas canvas) {
    canvas.save();
    // Barrel pivot near nose
    canvas.translate(18, 0);
    canvas.rotate(aimAngle.clamp(-0.7, 0.7));

    // Barrel
    final barrelPaint = Paint()..color = const Color(0xFF37474F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, -2.5, 9, 5), const Radius.circular(2)),
      barrelPaint,
    );

    // Muzzle tip glow
    final tipGlow = Paint()
      ..color = WeaponConfig.getConfig(currentWeaponType).primaryColor;
    canvas.drawCircle(const Offset(9, 0), 2.2, tipGlow);

    canvas.restore();
  }

  void _drawShield(Canvas canvas) {
    final pulse = math.sin(animTime * 8.0) * 3.0;
    final shieldRadius = radius + 10.0 + pulse;

    // Glowing cyan shield aura
    final shieldPaint = Paint()
      ..color = const Color(0x3300E5FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, shieldRadius, shieldPaint);

    // Ring with pulsing glow
    final ringPaint = Paint()
      ..color = const Color(0xBB00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset.zero, shieldRadius, ringPaint);

    // Hexagonal energy node markers
    final nodePaint = Paint()..color = Colors.white;
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + animTime * 1.5;
      final nodePos = Offset(math.cos(angle) * shieldRadius, math.sin(angle) * shieldRadius);
      canvas.drawCircle(nodePos, 2.0, nodePaint);
    }
  }

  void _drawVictorySparkle(Canvas canvas) {
    final sparklePaint = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 4; i++) {
      final angle = animTime * 3.0 + (i * math.pi / 2);
      final dist = 28.0 + math.sin(animTime * 5.0 + i) * 6.0;
      final center = Offset(math.cos(angle) * dist, math.sin(angle) * dist);
      canvas.drawLine(center + const Offset(-4, 0), center + const Offset(4, 0), sparklePaint);
      canvas.drawLine(center + const Offset(0, -4), center + const Offset(0, 4), sparklePaint);
    }
  }
}

typedef CapsuleState = CapsuleEntity;

