import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/gastro_question.dart';
import '../models/gastro_world.dart';
import 'weapon_system.dart';

enum CollectibleType {
  cellBubble,     // Translucent smiling red/pink cell bubble (Reference Image 1)
  atpCrystal,     // Golden hexagonal energy crystal
  vitaminCapsule, // Red & white medical pill capsule
  heartBoost,     // Medical repair nanobot (+1 Heart)
  shieldBoost,    // Biomagnetic energy shield bubble (5s invulnerability)
  weaponUpgrade,  // Instant weapon power / double-shot boost
}

enum ObstacleType {
  toothyMicrobe,  // Green toothy monster with mouth, teeth & eye stalk (Reference Image 1)
  spikyVirus,     // Violet rotating spike pathogen
  acidDroplet,    // Dripping yellow/green bile/acid from ceiling
  mucosalSpike,   // Inflammatory polyp / mucosal barb
}

class CapsulePlayer {
  Offset position;
  Offset velocity;
  double angle;
  double radius;
  int hearts;
  int maxHearts;
  double invulnerableTimer;
  bool isThrusting;
  bool isMovingLeft;
  bool isMovingRight;
  bool isMovingDown;
  double boostTimer;
  double animPhase;
  double shootCooldownTimer;
  double shieldTimer;
  double doubleShotTimer;
  WeaponType weaponType;

  CapsulePlayer({
    this.position = const Offset(120, 240),
    this.velocity = Offset.zero,
    this.angle = 0.0,
    this.radius = 18.0,
    this.hearts = 3,
    this.maxHearts = 3,
    this.invulnerableTimer = 0.0,
    this.isThrusting = false,
    this.isMovingLeft = false,
    this.isMovingRight = false,
    this.isMovingDown = false,
    this.boostTimer = 0.0,
    this.animPhase = 0.0,
    this.shootCooldownTimer = 0.0,
    this.shieldTimer = 0.0,
    this.doubleShotTimer = 0.0,
    this.weaponType = WeaponType.medicalLaser,
  });

  bool get isInvulnerable => invulnerableTimer > 0 || shieldTimer > 0;
  bool get isShieldActive => shieldTimer > 0;
  bool get isBoosted => boostTimer > 0;
  bool get hasDoubleShot => doubleShotTimer > 0;

  void activateShield(double durationSeconds) {
    shieldTimer = math.max(shieldTimer, durationSeconds);
  }

  void activateDoubleShot(double durationSeconds) {
    doubleShotTimer = math.max(doubleShotTimer, durationSeconds);
  }

  void takeDamage() {
    if (isInvulnerable) return;
    hearts = math.max(0, hearts - 1);
    invulnerableTimer = 1.6; // 1.6s grace period
    velocity = Offset(velocity.dx * 0.3 - 80, -60); // knockback
  }

  void heal() {
    hearts = math.min(maxHearts, hearts + 1);
  }
}

class TunnelGeometry {
  final double levelLength;
  final double baseCeiling;
  final double baseFloor;
  final GastroWorld world;

  TunnelGeometry({
    required this.levelLength,
    required this.world,
    this.baseCeiling = 70.0,
    this.baseFloor = 420.0,
  });

  /// Calculates ceiling Y at a given world X
  double getCeilingY(double worldX, double timeSeconds) {
    if (worldX > levelLength - 900) {
      // Open up into the wide Boss Arena!
      final progress = ((worldX - (levelLength - 900)) / 500).clamp(0.0, 1.0);
      return (baseCeiling - 40.0) * progress + (baseCeiling + 15 * math.sin(worldX * 0.003)) * (1.0 - progress);
    }

    final wave1 = math.sin(worldX * 0.0028) * 32.0;
    final wave2 = math.cos(worldX * 0.007 + 0.8) * 16.0;
    final peristalsis = math.sin(timeSeconds * 1.8 + worldX * 0.005) * 6.0;
    return baseCeiling + wave1 + wave2 + peristalsis;
  }

  /// Calculates floor Y at a given world X
  double getFloorY(double worldX, double timeSeconds) {
    if (worldX > levelLength - 900) {
      // Open up into the wide Boss Arena!
      final progress = ((worldX - (levelLength - 900)) / 500).clamp(0.0, 1.0);
      return (baseFloor + 60.0) * progress + (baseFloor + 18 * math.sin(worldX * 0.0032 + 1.2)) * (1.0 - progress);
    }

    final wave1 = math.sin(worldX * 0.0031 + 1.4) * 36.0;
    final wave2 = math.sin(worldX * 0.0065 - 0.5) * 18.0;
    final peristalsis = math.cos(timeSeconds * 1.8 + worldX * 0.005) * 6.0;
    return baseFloor + wave1 + wave2 + peristalsis;
  }
}

class ArcadeCollectible {
  final int id;
  Offset position;
  final CollectibleType type;
  final int xpValue;
  final int scoreValue;
  bool isCollected;
  double animPhase;

  ArcadeCollectible({
    required this.id,
    required this.position,
    required this.type,
    this.xpValue = 25,
    this.scoreValue = 50,
    this.isCollected = false,
    this.animPhase = 0.0,
  });

  double get radius {
    switch (type) {
      case CollectibleType.cellBubble:
        return 16.0;
      case CollectibleType.atpCrystal:
        return 14.0;
      case CollectibleType.vitaminCapsule:
        return 15.0;
      case CollectibleType.heartBoost:
        return 16.0;
      case CollectibleType.shieldBoost:
        return 17.0;
      case CollectibleType.weaponUpgrade:
        return 16.0;
    }
  }
}

class ArcadeObstacle {
  final int id;
  Offset position;
  final ObstacleType type;
  final double radius;
  double animPhase;
  double velocityY;
  double initialY;
  bool hitPlayer;

  ArcadeObstacle({
    required this.id,
    required this.position,
    required this.type,
    this.radius = 22.0,
    this.animPhase = 0.0,
    this.velocityY = 0.0,
    required this.initialY,
    this.hitPlayer = false,
  });
}

class ArcadeCheckpoint {
  final int index; // 1, 2, 3...
  final double worldX;
  final GastroQuestion question;
  bool isTriggered;
  bool isCompleted;
  bool isAnswerCorrect;

  ArcadeCheckpoint({
    required this.index,
    required this.worldX,
    required this.question,
    this.isTriggered = false,
    this.isCompleted = false,
    this.isAnswerCorrect = false,
  });
}

class ArcadeBoss {
  final String name;
  final String title;
  final Color auraColor;
  final IconData icon;
  Offset position;
  final int maxHp;
  int currentHp;
  double animPhase;
  bool isHit;
  double hitTimer;
  bool isDefeated;
  final List<GastroQuestion> challengeQuestions;

  ArcadeBoss({
    required this.name,
    required this.title,
    required this.auraColor,
    required this.icon,
    required this.position,
    this.maxHp = 3,
    this.currentHp = 3,
    this.animPhase = 0.0,
    this.isHit = false,
    this.hitTimer = 0.0,
    this.isDefeated = false,
    required this.challengeQuestions,
  });

  void takeDamage() {
    currentHp = math.max(0, currentHp - 1);
    isHit = true;
    hitTimer = 0.6;
    if (currentHp <= 0) {
      isDefeated = true;
    }
  }
}

class FloatingArcadeText {
  final String text;
  Offset position;
  final Color color;
  double life; // 1.0 to 0.0
  final double maxLife;
  final double fontSize;

  FloatingArcadeText({
    required this.text,
    required this.position,
    this.color = const Color(0xFFFFD166),
    this.life = 1.0,
    this.maxLife = 1.0,
    this.fontSize = 15.0,
  });

  bool get isDead => life <= 0.0;
}

class ArcadeParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double life; // 1.0 -> 0.0
  final double maxLife;

  ArcadeParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    this.life = 1.0,
    this.maxLife = 1.0,
  });

  bool get isDead => life <= 0.0;
}

class BackgroundErythrocyte {
  Offset position;
  double depth; // 0.2 to 0.8
  double radius;
  double wobblePhase;
  double rotation;

  BackgroundErythrocyte({
    required this.position,
    required this.depth,
    required this.radius,
    required this.wobblePhase,
    required this.rotation,
  });
}
