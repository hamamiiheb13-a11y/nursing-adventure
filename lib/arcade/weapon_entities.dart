import 'dart:math' as math;
import 'package:flutter/material.dart';

enum WeaponType {
  medicalLaser,
  doubleLaser,
  plasmaShot,
  electricWave,
  ultimatePulse,
  energyShield,
}

class WeaponConfig {
  final WeaponType type;
  final String name;
  final String description;
  final double cooldown; // seconds between shots
  final int damage;
  final double speed;
  final Color primaryColor;
  final Color glowColor;
  final IconData icon;

  const WeaponConfig({
    required this.type,
    required this.name,
    required this.description,
    required this.cooldown,
    required this.damage,
    required this.speed,
    required this.primaryColor,
    required this.glowColor,
    required this.icon,
  });

  static const List<WeaponConfig> allWeapons = [
    WeaponConfig(
      type: WeaponType.medicalLaser,
      name: 'Laser Médical MK-I',
      description: 'Faisceau photonique concentré précis pour désintégrer les toxines gastriques.',
      cooldown: 0.25,
      damage: 1,
      speed: 650.0,
      primaryColor: Color(0xFF00E5FF),
      glowColor: Color(0x6600E5FF),
      icon: Icons.bolt_rounded,
    ),
    WeaponConfig(
      type: WeaponType.doubleLaser,
      name: 'Double Laser Cyan',
      description: 'Deux faisceaux parallèles doublant la cadence et la surface de frappe.',
      cooldown: 0.22,
      damage: 2,
      speed: 700.0,
      primaryColor: Color(0xFF00B0FF),
      glowColor: Color(0x6600B0FF),
      icon: Icons.splitscreen_rounded,
    ),
    WeaponConfig(
      type: WeaponType.plasmaShot,
      name: 'Plasma Shot Bio-Émeraude',
      description: 'Orbe plasmique dense provoquant une décharge thermique concentrée.',
      cooldown: 0.38,
      damage: 4,
      speed: 480.0,
      primaryColor: Color(0xFFFF9100),
      glowColor: Color(0x66FF9100),
      icon: Icons.radio_button_checked_rounded,
    ),
    WeaponConfig(
      type: WeaponType.electricWave,
      name: 'Electric Wave Solaire',
      description: 'Arc électrique dentelé qui traverse et foudroie les grappes de micro-organismes.',
      cooldown: 0.32,
      damage: 3,
      speed: 550.0,
      primaryColor: Color(0xFF2979FF),
      glowColor: Color(0x662979FF),
      icon: Icons.electric_bolt_rounded,
    ),
    WeaponConfig(
      type: WeaponType.ultimatePulse,
      name: 'Ultimate Pulse Magenta',
      description: 'Onde de choc sphérique massive anéantissant toute impureté sur son passage.',
      cooldown: 0.70,
      damage: 8,
      speed: 380.0,
      primaryColor: Color(0xFFFFD700),
      glowColor: Color(0x88FFD700),
      icon: Icons.all_inclusive_rounded,
    ),
    WeaponConfig(
      type: WeaponType.energyShield,
      name: 'Energy Shield Pulsé',
      description: 'Générateur de barrière électromagnétique absorbant les chocs et projectiles ennemis.',
      cooldown: 5.0,
      damage: 0,
      speed: 0.0,
      primaryColor: Color(0xFF00E676),
      glowColor: Color(0x6600E676),
      icon: Icons.shield_rounded,
    ),
  ];

  static WeaponConfig getConfig(WeaponType type) {
    return allWeapons.firstWhere(
      (w) => w.type == type,
      orElse: () => allWeapons.first,
    );
  }

  static WeaponConfig getByName(String name) {
    return allWeapons.firstWhere(
      (w) => w.name.toLowerCase() == name.toLowerCase(),
      orElse: () => allWeapons.first,
    );
  }
}

class Projectile {
  Offset position; // World coordinate
  Offset velocity;
  final WeaponType type;
  final int damage;
  final bool isEnemy;
  double lifeTime;
  final double maxLifeTime;
  double radius;
  double animTimer = 0.0;
  bool isDead = false;

  Projectile({
    required this.position,
    required this.velocity,
    required this.type,
    required this.damage,
    this.isEnemy = false,
    this.lifeTime = 0.0,
    this.maxLifeTime = 3.0,
    this.radius = 6.0,
  });

  void update(double dt) {
    position += velocity * dt;
    lifeTime += dt;
    animTimer += dt;
    if (lifeTime >= maxLifeTime) {
      isDead = true;
    }
  }

  void draw(Canvas canvas, Offset screenPos) {
    final paint = Paint()..isAntiAlias = true;

    if (isEnemy) {
      // Enemy projectile: poisonous red/acid-green bead
      paint.color = const Color(0xFFFF1744);
      canvas.drawCircle(screenPos, radius + 2, Paint()..color = const Color(0x66FF1744));
      canvas.drawCircle(screenPos, radius, paint);
      paint.color = Colors.white;
      canvas.drawCircle(screenPos, radius * 0.4, paint);
      return;
    }

    switch (type) {
      case WeaponType.medicalLaser:
        // Thin cyan beam with glow
        final angle = math.atan2(velocity.dy, velocity.dx);
        canvas.save();
        canvas.translate(screenPos.dx, screenPos.dy);
        canvas.rotate(angle);

        // Glow
        paint.color = const Color(0x5500E5FF);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-16, -5, 32, 10),
            const Radius.circular(5),
          ),
          paint,
        );

        // Core cyan beam
        paint.color = const Color(0xFF00E5FF);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-14, -2.5, 28, 5),
            const Radius.circular(2.5),
          ),
          paint,
        );

        // Bright white center
        paint.color = Colors.white;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-10, -1, 20, 2),
            const Radius.circular(1),
          ),
          paint,
        );
        canvas.restore();
        break;

      case WeaponType.doubleLaser:
        // Two parallel cyan beams
        final angle = math.atan2(velocity.dy, velocity.dx);
        canvas.save();
        canvas.translate(screenPos.dx, screenPos.dy);
        canvas.rotate(angle);

        // Outer glow
        paint.color = const Color(0x4400B0FF);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-16, -10, 32, 20),
            const Radius.circular(6),
          ),
          paint,
        );

        // Dual beams
        for (final offset in [-5.0, 5.0]) {
          paint.color = const Color(0xFF00E5FF);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(-14, offset - 2, 28, 4),
              const Radius.circular(2),
            ),
            paint,
          );

          paint.color = Colors.white;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(-10, offset - 1, 20, 2),
              const Radius.circular(1),
            ),
            paint,
          );
        }
        canvas.restore();
        break;

      case WeaponType.plasmaShot:
        // Orange pulsing orb with corona
        final pulse = math.sin(animTimer * 14.0) * 2.0;
        final currentRadius = radius + pulse;

        // Outer heat aura
        paint.color = const Color(0x44FF6D00);
        canvas.drawCircle(screenPos, currentRadius + 6, paint);

        // Flame core gradient
        final plasmaGradient = RadialGradient(
          colors: const [
            Colors.white,
            Color(0xFFFFD600),
            Color(0xFFFF6D00),
            Color(0xFFDD2C00),
          ],
          stops: const [0.0, 0.35, 0.75, 1.0],
        );
        paint.shader = plasmaGradient.createShader(
          Rect.fromCircle(center: screenPos, radius: currentRadius),
        );
        canvas.drawCircle(screenPos, currentRadius, paint);
        paint.shader = null;
        break;

      case WeaponType.electricWave:
        // Jagged blue lightning arc
        final angle = math.atan2(velocity.dy, velocity.dx);
        canvas.save();
        canvas.translate(screenPos.dx, screenPos.dy);
        canvas.rotate(angle);

        final path = Path();
        path.moveTo(-18, 0);
        final r = math.Random((animTimer * 60).toInt());
        for (double x = -14; x <= 18; x += 6) {
          final dy = (r.nextDouble() - 0.5) * 12.0;
          path.lineTo(x, dy);
        }

        // Glow line
        paint.color = const Color(0x772979FF);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 6.0;
        canvas.drawPath(path, paint);

        // Sharp lightning arc
        paint.color = const Color(0xFF82B1FF);
        paint.strokeWidth = 3.0;
        canvas.drawPath(path, paint);

        // White core
        paint.color = Colors.white;
        paint.strokeWidth = 1.5;
        canvas.drawPath(path, paint);

        paint.style = PaintingStyle.fill;
        canvas.restore();
        break;

      case WeaponType.ultimatePulse:
        // Large white/gold expanding ring
        final ringRadius = (radius + animTimer * 28.0).clamp(12.0, 48.0);
        final alpha = ((1.0 - (lifeTime / maxLifeTime)) * 255).clamp(40, 255).toInt();

        // Pulsing glow aura
        paint.color = Color.fromARGB(alpha ~/ 3, 255, 215, 0);
        canvas.drawCircle(screenPos, ringRadius + 4, paint);

        // Golden expanding ring
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 4.0;
        paint.color = Color.fromARGB(alpha, 255, 215, 0);
        canvas.drawCircle(screenPos, ringRadius, paint);

        // Inner shockwave line
        paint.strokeWidth = 2.0;
        paint.color = Color.fromARGB(alpha, 255, 255, 255);
        canvas.drawCircle(screenPos, ringRadius * 0.75, paint);

        paint.style = PaintingStyle.fill;
        break;

      case WeaponType.energyShield:
        // EnergyShield is a player buff, but if a spark spawns:
        paint.color = const Color(0xFF00E676);
        canvas.drawCircle(screenPos, radius, paint);
        break;
    }
  }
}
