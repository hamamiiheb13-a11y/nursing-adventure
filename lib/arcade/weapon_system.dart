import 'dart:math' as math;
import 'package:flutter/material.dart';

enum WeaponType {
  medicalLaser,
  doubleLaser,
  plasmaShot,
  energyShield,
  electricWave,
  ultimatePulse,
}

class WeaponConfig {
  final WeaponType type;
  final String name;
  final String description;
  final double cooldownSeconds;
  final int damage;
  final double projectileSpeed;
  final Color glowColor;
  final IconData icon;

  const WeaponConfig({
    required this.type,
    required this.name,
    required this.description,
    required this.cooldownSeconds,
    required this.damage,
    required this.projectileSpeed,
    required this.glowColor,
    required this.icon,
  });

  static const List<WeaponConfig> allWeapons = [
    WeaponConfig(
      type: WeaponType.medicalLaser,
      name: 'Laser Médical MK-I',
      description: 'Faisceau photonique concentré précis pour désintégrer les toxines gastriques.',
      cooldownSeconds: 0.28,
      damage: 1,
      projectileSpeed: 620.0,
      glowColor: Color(0xFF00E5FF),
      icon: Icons.bolt_rounded,
    ),
    WeaponConfig(
      type: WeaponType.doubleLaser,
      name: 'Double Laser Cyan',
      description: 'Deux faisceaux parallèles doublant la cadence et la surface de frappe.',
      cooldownSeconds: 0.24,
      damage: 2,
      projectileSpeed: 680.0,
      glowColor: Color(0xFF38BDF8),
      icon: Icons.double_arrow_rounded,
    ),
    WeaponConfig(
      type: WeaponType.plasmaShot,
      name: 'Plasma Shot Bio-Émeraude',
      description: 'Orbes de plasma ionisé à impact explosif de zone.',
      cooldownSeconds: 0.32,
      damage: 3,
      projectileSpeed: 550.0,
      glowColor: Color(0xFF10B981),
      icon: Icons.bubble_chart_rounded,
    ),
    WeaponConfig(
      type: WeaponType.energyShield,
      name: 'Energy Shield Pulsé',
      description: 'Bouclier biomagnétique déflecteur absorbant les toxines et infligeant des chocs.',
      cooldownSeconds: 0.35,
      damage: 2,
      projectileSpeed: 480.0,
      glowColor: Color(0xFF818CF8),
      icon: Icons.shield_rounded,
    ),
    WeaponConfig(
      type: WeaponType.electricWave,
      name: 'Electric Wave Solaire',
      description: 'Ondes sinusoïdales à haute fréquence balayant la lumière de l\'estomac.',
      cooldownSeconds: 0.30,
      damage: 4,
      projectileSpeed: 640.0,
      glowColor: Color(0xFFF59E0B),
      icon: Icons.waves_rounded,
    ),
    WeaponConfig(
      type: WeaponType.ultimatePulse,
      name: 'Ultimate Pulse Magenta',
      description: 'Pulsation quantique nanothérapeutique éliminant instantanément les menaces.',
      cooldownSeconds: 0.40,
      damage: 6,
      projectileSpeed: 750.0,
      glowColor: Color(0xFFEC4899),
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  static WeaponConfig getConfig(WeaponType type) {
    return allWeapons.firstWhere((w) => w.type == type, orElse: () => allWeapons.first);
  }

  static WeaponConfig getByName(String name) {
    return allWeapons.firstWhere((w) => w.name == name, orElse: () => allWeapons.first);
  }
}

class CapsuleProjectile {
  Offset position;
  Offset velocity;
  final int damage;
  final Color color;
  final double radius;
  final bool isEnemy;
  final WeaponType weaponType;
  double lifeTime;
  double animPhase;

  CapsuleProjectile({
    required this.position,
    required this.velocity,
    required this.damage,
    required this.color,
    this.radius = 5.0,
    this.isEnemy = false,
    this.weaponType = WeaponType.medicalLaser,
    this.lifeTime = 2.0,
    this.animPhase = 0.0,
  });

  bool get isDead => lifeTime <= 0;

  void update(double dt) {
    position += velocity * dt;
    lifeTime -= dt;
    animPhase += dt * 8.0;

    // Wave pattern for electric wave
    if (weaponType == WeaponType.electricWave) {
      position = Offset(position.dx, position.dy + math.sin(animPhase) * 120.0 * dt);
    }
  }
}
