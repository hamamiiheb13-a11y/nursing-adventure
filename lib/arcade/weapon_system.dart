import 'dart:math' as math;
import 'package:flutter/material.dart';

enum WeaponType {
  medicalLaser,
  doubleLaser,
  antibacterialCannon,
  therapeuticOrbs,
  plasmaShot,
  energyShield,
  electricWave,
  ultimatePulse,
}

class WeaponConfig {
  final WeaponType type;
  final String name;
  final String shortName;
  final String description;
  final double cooldownSeconds;
  final int damage;
  final double projectileSpeed;
  final Color glowColor;
  final Color coreColor;
  final IconData icon;
  final int sfxIndex;

  const WeaponConfig({
    required this.type,
    required this.name,
    required this.shortName,
    required this.description,
    required this.cooldownSeconds,
    required this.damage,
    required this.projectileSpeed,
    required this.glowColor,
    required this.coreColor,
    required this.icon,
    required this.sfxIndex,
  });

  static const List<WeaponConfig> allWeapons = [
    WeaponConfig(
      type: WeaponType.medicalLaser,
      name: 'Laser Médical MK-I',
      shortName: 'Laser MK-I',
      description: 'Faisceau photonique précis à cadence rapide pour cibler les germes digestifs.',
      cooldownSeconds: 0.23,
      damage: 2,
      projectileSpeed: 660.0,
      glowColor: Color(0xFF22D3EE),
      coreColor: Color(0xFFE0F2FE),
      icon: Icons.bolt_rounded,
      sfxIndex: 0,
    ),
    WeaponConfig(
      type: WeaponType.doubleLaser,
      name: 'Double Laser Océan',
      shortName: 'Double Laser',
      description: 'Doubles faisceaux parallèles multipliant la couverture de tir.',
      cooldownSeconds: 0.22,
      damage: 2,
      projectileSpeed: 700.0,
      glowColor: Color(0xFF0EA5E9),
      coreColor: Color(0xFFBAE6FD),
      icon: Icons.double_arrow_rounded,
      sfxIndex: 1,
    ),
    WeaponConfig(
      type: WeaponType.antibacterialCannon,
      name: 'Canon Antibactérien',
      shortName: 'Antibactérien',
      description: 'Salve triple en éventail à fort impact contre les bactéries et rétrécissements.',
      cooldownSeconds: 0.28,
      damage: 3,
      projectileSpeed: 590.0,
      glowColor: Color(0xFFFB923C),
      coreColor: Color(0xFFFEF08A),
      icon: Icons.scatter_plot_rounded,
      sfxIndex: 2,
    ),
    WeaponConfig(
      type: WeaponType.therapeuticOrbs,
      name: 'Projectiles Thérapeutiques',
      shortName: 'Orbes Thérap.',
      description: 'Capsules bio-guidées qui s\'orientent automatiquement vers les pathogènes.',
      cooldownSeconds: 0.26,
      damage: 4,
      projectileSpeed: 550.0,
      glowColor: Color(0xFF34D399),
      coreColor: Color(0xFFD1FAE5),
      icon: Icons.track_changes_rounded,
      sfxIndex: 3,
    ),
    WeaponConfig(
      type: WeaponType.plasmaShot,
      name: 'Plasma Bio-Émeraude',
      shortName: 'Plasma Émer.',
      description: 'Orbes ionisés à onde de choc détruisant amas et projectiles acides.',
      cooldownSeconds: 0.28,
      damage: 4,
      projectileSpeed: 580.0,
      glowColor: Color(0xFF14B8A6),
      coreColor: Color(0xFFCCFBF1),
      icon: Icons.bubble_chart_rounded,
      sfxIndex: 4,
    ),
    WeaponConfig(
      type: WeaponType.energyShield,
      name: 'Bouclier Déflecteur Pulsé',
      shortName: 'Déflecteur',
      description: 'Arcs biomagnétiques neutralisant les tirs ennemis sur leur trajectoire.',
      cooldownSeconds: 0.30,
      damage: 3,
      projectileSpeed: 520.0,
      glowColor: Color(0xFFA78BFA),
      coreColor: Color(0xFFEDE9FE),
      icon: Icons.shield_rounded,
      sfxIndex: 5,
    ),
    WeaponConfig(
      type: WeaponType.electricWave,
      name: 'Onde Anti-Inflammatoire',
      shortName: 'Anti-Inflam.',
      description: 'Ondes thérapeutiques perforantes apaisant les foyers inflammatoires.',
      cooldownSeconds: 0.28,
      damage: 5,
      projectileSpeed: 640.0,
      glowColor: Color(0xFFFBBF24),
      coreColor: Color(0xFFFEF3C7),
      icon: Icons.waves_rounded,
      sfxIndex: 6,
    ),
    WeaponConfig(
      type: WeaponType.ultimatePulse,
      name: 'Rayon Thérapeutique Ultime',
      shortName: 'Ultime',
      description: 'Triple faisceau quantique à dégâts massifs pour l\'éradication finale.',
      cooldownSeconds: 0.32,
      damage: 6,
      projectileSpeed: 760.0,
      glowColor: Color(0xFFFB7185),
      coreColor: Color(0xFFFFE4E6),
      icon: Icons.auto_awesome_rounded,
      sfxIndex: 7,
    ),
  ];

  static WeaponConfig getConfig(WeaponType type) {
    return allWeapons.firstWhere((w) => w.type == type, orElse: () => allWeapons.first);
  }

  static WeaponConfig getByName(String name) {
    final normalized = name.toLowerCase();
    for (final w in allWeapons) {
      if (w.name.toLowerCase() == normalized || w.shortName.toLowerCase() == normalized) {
        return w;
      }
    }
    // Backward compatibility mapping for legacy save files
    if (normalized.contains('double')) return getConfig(WeaponType.doubleLaser);
    if (normalized.contains('antibact')) return getConfig(WeaponType.antibacterialCannon);
    if (normalized.contains('thérapeutique') || normalized.contains('orbe')) {
      return getConfig(WeaponType.therapeuticOrbs);
    }
    if (normalized.contains('plasma')) return getConfig(WeaponType.plasmaShot);
    if (normalized.contains('shield') || normalized.contains('bouclier')) {
      return getConfig(WeaponType.energyShield);
    }
    if (normalized.contains('wave') || normalized.contains('inflammatoire')) {
      return getConfig(WeaponType.electricWave);
    }
    if (normalized.contains('ultimate') || normalized.contains('quantum') || normalized.contains('ultime')) {
      return getConfig(WeaponType.ultimatePulse);
    }
    return allWeapons.first;
  }
}

class CapsuleProjectile {
  Offset position;
  Offset velocity;
  final int damage;
  final Color color;
  final double radius;
  final bool isEnemy;
  final bool isHoming;
  final bool isPiercing;
  final WeaponType weaponType;
  double lifeTime;
  double animPhase;
  final Set<int> hitEnemyIds;

  CapsuleProjectile({
    required this.position,
    required this.velocity,
    required this.damage,
    required this.color,
    this.radius = 5.0,
    this.isEnemy = false,
    this.isHoming = false,
    this.isPiercing = false,
    this.weaponType = WeaponType.medicalLaser,
    this.lifeTime = 2.0,
    this.animPhase = 0.0,
    Set<int>? hitEnemyIds,
  }) : hitEnemyIds = hitEnemyIds ?? <int>{};

  bool get isDead => lifeTime <= 0;

  void update(double dt, {Offset? homingTarget}) {
    // Soft homing steering for therapeutic orbs
    if (isHoming && !isEnemy && homingTarget != null) {
      final toTarget = homingTarget - position;
      final dist = toTarget.distance;
      if (dist > 8.0 && dist < 520.0) {
        final desiredDir = toTarget / dist;
        final currentSpeed = velocity.distance;
        final currentDir = currentSpeed > 0 ? velocity / currentSpeed : const Offset(1, 0);
        final blendedDir = Offset.lerp(currentDir, desiredDir, (dt * 4.5).clamp(0.0, 1.0))!;
        final norm = blendedDir.distance > 0 ? blendedDir / blendedDir.distance : currentDir;
        velocity = norm * currentSpeed;
      }
    }

    position += velocity * dt;
    lifeTime -= dt;
    animPhase += dt * 8.0;

    // Sinusoidal pulse sweep for anti-inflammatory wave
    if (weaponType == WeaponType.electricWave && !isEnemy) {
      position = Offset(position.dx, position.dy + math.sin(animPhase) * 115.0 * dt);
    }
  }
}
