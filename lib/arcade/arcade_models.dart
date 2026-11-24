import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/gastro_question.dart';
import '../models/gastro_world.dart';
import 'weapon_system.dart';

enum CollectibleType {
  cellBubble,     // Translucent smiling red/pink cell bubble
  atpCrystal,     // Golden hexagonal energy crystal
  vitaminCapsule, // Red & white medical pill capsule
  heartBoost,     // Medical repair nanobot (+1 Heart)
  shieldBoost,    // Biomagnetic energy shield bubble (5s invulnerability)
  weaponUpgrade,  // Instant weapon power / double-shot boost
}

enum ObstacleType {
  toothyMicrobe,  // Green toothy monster with mouth, teeth & eye stalk
  spikyVirus,     // Violet rotating spike pathogen
  acidDroplet,    // Dripping yellow/green bile/acid from ceiling
  mucosalSpike,   // Inflammatory polyp / mucosal barb
}

class CapsulePlayer {
  Offset position;
  Offset velocity;
  Offset moveInput; // Analog vector (-1..1, -1..1)
  double angle;
  double radius;
  int hearts;
  int maxHearts;
  double invulnerableTimer;
  bool isThrusting;
  bool isMovingLeft;
  bool isMovingRight;
  bool isMovingDown;
  bool isShooting; // Continuous hold-to-fire
  double boostTimer;
  double animPhase;
  double shootCooldownTimer;
  double shieldTimer;
  double doubleShotTimer;
  double specialSkillCooldown;
  double specialSkillMaxCooldown;
  double joystickSensitivity;
  double flameIntensity; // 0.0 to 1.0
  List<Offset> trailPositions;
  WeaponType weaponType;

  CapsulePlayer({
    this.position = const Offset(120, 240),
    this.velocity = Offset.zero,
    this.moveInput = Offset.zero,
    this.angle = 0.0,
    this.radius = 18.0,
    this.hearts = 3,
    this.maxHearts = 3,
    this.invulnerableTimer = 0.0,
    this.isThrusting = false,
    this.isMovingLeft = false,
    this.isMovingRight = false,
    this.isMovingDown = false,
    this.isShooting = false,
    this.boostTimer = 0.0,
    this.animPhase = 0.0,
    this.shootCooldownTimer = 0.0,
    this.shieldTimer = 0.0,
    this.doubleShotTimer = 0.0,
    this.specialSkillCooldown = 0.0,
    this.specialSkillMaxCooldown = 8.0,
    this.joystickSensitivity = 1.0,
    this.flameIntensity = 0.0,
    List<Offset>? trailPositions,
    this.weaponType = WeaponType.medicalLaser,
  }) : trailPositions = trailPositions ?? <Offset>[];

  bool get isInvulnerable => invulnerableTimer > 0 || shieldTimer > 0;
  bool get isShieldActive => shieldTimer > 0;
  bool get isBoosted => boostTimer > 0;
  bool get hasDoubleShot => doubleShotTimer > 0;
  bool get canUseSpecialSkill => specialSkillCooldown <= 0;

  void activateShield(double durationSeconds) {
    shieldTimer = math.max(shieldTimer, durationSeconds);
  }

  void activateDoubleShot(double durationSeconds) {
    doubleShotTimer = math.max(doubleShotTimer, durationSeconds);
  }

  void triggerSpecialSkill() {
    specialSkillCooldown = specialSkillMaxCooldown;
  }

  void takeDamage() {
    if (isInvulnerable) return;
    hearts = math.max(0, hearts - 1);
    invulnerableTimer = 1.8; // 1.8s grace period
    velocity = Offset(velocity.dx * 0.3 - 60, -40); // Soft knockback
  }

  void heal() {
    hearts = math.min(maxHearts, hearts + 1);
  }
}

class TunnelGeometry {
  final double levelLength;
  double baseCeiling;
  double baseFloor;
  double viewportHeight;
  final GastroWorld world;

  TunnelGeometry({
    required this.levelLength,
    required this.world,
    this.baseCeiling = 70.0,
    this.baseFloor = 420.0,
    this.viewportHeight = 500.0,
  });

  /// Adapts ceiling and floor positions dynamically to any screen height!
  void updateViewport(double width, double height) {
    viewportHeight = height.clamp(280.0, 1600.0);
    // Ceiling occupies the top 13-16% of the screen
    baseCeiling = (viewportHeight * 0.14).clamp(42.0, 90.0);
    // Floor occupies the bottom 13-16% of the screen (leaving ~72% playable corridor)
    baseFloor = (viewportHeight * 0.86).clamp(viewportHeight - 90.0, viewportHeight - 42.0);
  }

  /// Calculates ceiling Y at a given world X
  double getCeilingY(double worldX, double timeSeconds) {
    final scale = (viewportHeight / 500.0).clamp(0.6, 1.3);

    if (worldX > levelLength - 900) {
      // Open up into the wide Boss Arena!
      final progress = ((worldX - (levelLength - 900)) / 500).clamp(0.0, 1.0);
      return (baseCeiling - 35.0 * scale) * progress +
          (baseCeiling + 12 * scale * math.sin(worldX * 0.003)) * (1.0 - progress);
    }

    final wave1 = math.sin(worldX * 0.0028) * (20.0 * scale);
    final wave2 = math.cos(worldX * 0.007 + 0.8) * (10.0 * scale);
    final peristalsis = math.sin(timeSeconds * 1.8 + worldX * 0.005) * (4.0 * scale);
    final rawY = baseCeiling + wave1 + wave2 + peristalsis;

    // Hard clamp to ensure ceiling never dips past 25% of screen height
    return rawY.clamp(20.0, viewportHeight * 0.24);
  }

  /// Calculates floor Y at a given world X
  double getFloorY(double worldX, double timeSeconds) {
    final scale = (viewportHeight / 500.0).clamp(0.6, 1.3);

    if (worldX > levelLength - 900) {
      // Open up into the wide Boss Arena!
      final progress = ((worldX - (levelLength - 900)) / 500).clamp(0.0, 1.0);
      return (baseFloor + 40.0 * scale) * progress +
          (baseFloor + 14 * scale * math.sin(worldX * 0.0032 + 1.2)) * (1.0 - progress);
    }

    final wave1 = math.sin(worldX * 0.0031 + 1.4) * (22.0 * scale);
    final wave2 = math.sin(worldX * 0.0065 - 0.5) * (12.0 * scale);
    final peristalsis = math.cos(timeSeconds * 1.8 + worldX * 0.005) * (4.0 * scale);
    final rawY = baseFloor + wave1 + wave2 + peristalsis;

    // Hard clamp to ensure floor never rises above 76% of screen height
    return rawY.clamp(viewportHeight * 0.76, viewportHeight - 15.0);
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
  final bool isRevision;
  bool isTriggered;
  bool isCompleted;
  bool isAnswerCorrect;

  ArcadeCheckpoint({
    required this.index,
    required this.worldX,
    required this.question,
    this.isRevision = false,
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
