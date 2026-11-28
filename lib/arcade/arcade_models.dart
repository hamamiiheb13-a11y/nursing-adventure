import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/gastro_question.dart';
import '../models/gastro_world.dart';
import 'weapon_system.dart';

enum CollectibleType {
  cellBubble,     // Bulle cellulaire souriante
  atpCrystal,     // Cristal énergétique ATP doré
  vitaminCapsule, // Gélule médicale
  heartBoost,     // Nanobot de soin (+1 Cœur)
  shieldBoost,    // Bulle bouclier biomagnétique (5s)
  weaponUpgrade,  // Survoltage d'arme (8s tir double / boost)
}

enum ObstacleType {
  toothyMicrobe,    // Monstre vert cartoonesque à dents
  spikyVirus,       // Virus rotatif corail/violet
  acidDroplet,      // Gouttelette gastrique tombante
  mucosalSpike,     // Polype / épine muqueuse
  inflammatoryZone, // Zone inflammatoire pulsée (apaisable par onde anti-inflammatoire)
  bioFilament,      // Filament biologique suspendu oscillant
}

enum BossAttackPattern {
  hoverSpread,      // Salve en éventail télégraphiée
  waveSweep,        // Onde sinusoïdale rythmée
  chargeTelegraph,  // Ligne de visée prévenant d'une charge
  chargeDash,       // Charge rapide sur la voie télégraphiée
  radialBurst,      // Salve radiale tourbillonnante avec couloir d'esquive
  spawnMinions,     // Invocation d'escorte réactive (Phase 2)
}

class DefeatedEnemyEffect {
  Offset position;
  final double radius;
  final Color color;
  double life;
  final double maxLife;
  final double spinDir;

  DefeatedEnemyEffect({
    required this.position,
    required this.radius,
    required this.color,
    this.life = 0.40,
    this.maxLife = 0.40,
    this.spinDir = 1.0,
  });

  double get progress => (1.0 - (life / math.max(0.01, maxLife))).clamp(0.0, 1.0);
  bool get isDead => life <= 0.0;
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
  double shootRecoilTimer;
  double shieldTimer;
  double doubleShotTimer;
  double specialSkillCooldown;
  double specialSkillMaxCooldown;
  double joystickSensitivity;
  double flameIntensity; // 0.0 to 1.0
  double knowledgeDamageMultiplier; // Evolves from 1.0 up to 2.5x via right answers!
  int weaponPowerLevel; // 1 to 4
  double collectFlashTimer;
  double damageFlashTimer;
  double shieldDeflectTimer;
  bool hasSuperAttack;
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
    this.shootRecoilTimer = 0.0,
    this.shieldTimer = 0.0,
    this.doubleShotTimer = 0.0,
    this.specialSkillCooldown = 0.0,
    this.specialSkillMaxCooldown = 7.0,
    this.joystickSensitivity = 1.0,
    this.flameIntensity = 0.0,
    this.knowledgeDamageMultiplier = 1.0,
    this.weaponPowerLevel = 1,
    this.collectFlashTimer = 0.0,
    this.damageFlashTimer = 0.0,
    this.shieldDeflectTimer = 0.0,
    this.hasSuperAttack = false,
    List<Offset>? trailPositions,
    this.weaponType = WeaponType.medicalLaser,
  }) : trailPositions = trailPositions ?? <Offset>[];

  bool get isInvulnerable => invulnerableTimer > 0 || shieldTimer > 0;
  bool get isShieldActive => shieldTimer > 0;
  bool get isBoosted => boostTimer > 0;
  bool get hasDoubleShot => doubleShotTimer > 0;
  bool get canUseSpecialSkill => specialSkillCooldown <= 0;
  bool get isMaxSynergy => knowledgeDamageMultiplier >= 2.1 || hasSuperAttack;

  void activateShield(double durationSeconds) {
    shieldTimer = math.max(shieldTimer, durationSeconds);
  }

  void activateDoubleShot(double durationSeconds) {
    doubleShotTimer = math.max(doubleShotTimer, durationSeconds);
  }

  void triggerCollectFlash() {
    collectFlashTimer = 0.35;
  }

  void triggerShieldDeflect() {
    shieldDeflectTimer = 0.35;
  }

  void triggerSpecialSkill() {
    specialSkillCooldown = specialSkillMaxCooldown;
  }

  void takeDamage() {
    if (isInvulnerable) return;
    hearts = math.max(0, hearts - 1);
    invulnerableTimer = 1.8;
    damageFlashTimer = 0.45;
    velocity = Offset(velocity.dx * 0.35 - 55, -30);
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

  /// Adapts ceiling and floor positions dynamically to any screen height
  void updateViewport(double width, double height) {
    viewportHeight = height.clamp(280.0, 1600.0);
    baseCeiling = (viewportHeight * 0.14).clamp(40.0, 88.0);
    baseFloor = (viewportHeight * 0.86).clamp(viewportHeight - 88.0, viewportHeight - 40.0);
  }

  /// Gentle intestinal stricture zones in middle of level (always comfortably navigable)
  double _strictureOffset(double worldX, double scale) {
    if (worldX < 900.0 || worldX > levelLength - 1100.0) return 0.0;
    // Two predictable physiological narrowing pulses along the tract
    final center1 = levelLength * 0.38;
    final center2 = levelLength * 0.68;
    double pinch = 0.0;
    final d1 = (worldX - center1).abs();
    if (d1 < 220.0) {
      pinch += math.cos((d1 / 220.0) * math.pi * 0.5) * 28.0 * scale;
    }
    final d2 = (worldX - center2).abs();
    if (d2 < 240.0) {
      pinch += math.cos((d2 / 240.0) * math.pi * 0.5) * 30.0 * scale;
    }
    return pinch;
  }

  /// Calculates ceiling Y at a given world X
  double getCeilingY(double worldX, double timeSeconds) {
    final scale = (viewportHeight / 500.0).clamp(0.58, 1.3);

    if (worldX > levelLength - 950) {
      final progress = ((worldX - (levelLength - 950)) / 480).clamp(0.0, 1.0);
      return (baseCeiling - 28.0 * scale) * progress +
          (baseCeiling + 10 * scale * math.sin(worldX * 0.003)) * (1.0 - progress);
    }

    final wave1 = math.sin(worldX * 0.0028) * (18.0 * scale);
    final wave2 = math.cos(worldX * 0.0065 + 0.8) * (8.0 * scale);
    final peristalsis = math.sin(timeSeconds * 1.8 + worldX * 0.005) * (3.5 * scale);
    final pinch = _strictureOffset(worldX, scale);
    final rawY = baseCeiling + wave1 + wave2 + peristalsis + pinch;

    return rawY.clamp(22.0, viewportHeight * 0.30);
  }

  /// Calculates floor Y at a given world X
  double getFloorY(double worldX, double timeSeconds) {
    final scale = (viewportHeight / 500.0).clamp(0.58, 1.3);

    if (worldX > levelLength - 950) {
      final progress = ((worldX - (levelLength - 950)) / 480).clamp(0.0, 1.0);
      return (baseFloor + 30.0 * scale) * progress +
          (baseFloor + 12 * scale * math.sin(worldX * 0.0032 + 1.2)) * (1.0 - progress);
    }

    final wave1 = math.sin(worldX * 0.0031 + 1.4) * (18.0 * scale);
    final wave2 = math.sin(worldX * 0.006 - 0.5) * (9.0 * scale);
    final peristalsis = math.cos(timeSeconds * 1.8 + worldX * 0.005) * (3.5 * scale);
    final pinch = _strictureOffset(worldX, scale);
    final rawY = baseFloor + wave1 + wave2 + peristalsis - pinch;

    return rawY.clamp(viewportHeight * 0.70, viewportHeight - 16.0);
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
  final double height;
  double animPhase;
  double velocityY;
  double initialY;
  double baseX;
  double velocityX;
  double swayOffset;
  double triggerTimer;
  double pulseScale;
  double stunTimer;
  int variant;
  double sootheTimer; // > 0 means calmed by Anti-Inflammatory Special!
  bool hitPlayer;

  ArcadeObstacle({
    required this.id,
    required this.position,
    required this.type,
    this.radius = 22.0,
    this.height = 48.0,
    this.animPhase = 0.0,
    this.velocityY = 0.0,
    this.velocityX = 0.0,
    this.swayOffset = 0.0,
    this.triggerTimer = 0.0,
    this.pulseScale = 1.0,
    this.stunTimer = 0.0,
    this.variant = 0,
    this.sootheTimer = 0.0,
    double? initialX,
    required this.initialY,
    this.hitPlayer = false,
  }) : baseX = initialX ?? position.dx;

  bool get isSoothed => sootheTimer > 0;
  bool get isStunned => stunTimer > 0;
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
  final String dangerLevel;
  final Color auraColor;
  final IconData icon;
  Offset position;
  Offset homePosition;
  Offset velocity;
  final int maxHp;
  int currentHp;
  double animPhase;
  bool isHit;
  double hitTimer;
  bool isDefeated;
  BossAttackPattern currentPattern;
  double attackCooldown;
  double telegraphTimer;
  double chargeTargetY;
  double entranceProgress;
  final List<GastroQuestion> challengeQuestions;

  // Dynamic Boss combat animations & reactive AI fields
  double attackAnimTimer = 0.0;
  double dodgeTimer = 0.0;
  double dodgeCooldown = 0.0;
  double verticalDodgeOffset = 0.0;
  int burstHitsTaken = 0;
  double facingTilt = 0.0;
  bool phase2Announced = false;

  ArcadeBoss({
    required this.name,
    required this.title,
    this.dangerLevel = 'ÉLEVÉ',
    required this.auraColor,
    required this.icon,
    required this.position,
    Offset? homePosition,
    this.velocity = Offset.zero,
    this.maxHp = 24,
    this.currentHp = 24,
    this.animPhase = 0.0,
    this.isHit = false,
    this.hitTimer = 0.0,
    this.isDefeated = false,
    this.currentPattern = BossAttackPattern.hoverSpread,
    this.attackCooldown = 1.8,
    this.telegraphTimer = 0.0,
    this.chargeTargetY = 250.0,
    this.entranceProgress = 0.0,
    required this.challengeQuestions,
  }) : homePosition = homePosition ?? position;

  bool get isPhase2 => currentHp <= (maxHp * 0.5).ceil();
  bool get isTelegraphing => telegraphTimer > 0;
  bool get isAttackingAnim => attackAnimTimer > 0;
  double get healthRatio => (currentHp / math.max(1, maxHp)).clamp(0.0, 1.0);

  void takeDamage([int amount = 1]) {
    currentHp = math.max(0, currentHp - math.max(1, amount));
    isHit = true;
    hitTimer = 0.22;
    burstHitsTaken++;
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
    this.color = const Color(0xFFFBBF24),
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
