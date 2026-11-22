import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/gastro_question.dart';
import '../models/gastro_world.dart';
import '../models/game_progress.dart';
import '../audio/audio_service.dart';
import 'arcade_models.dart';
import 'weapon_system.dart';
import 'enemy_system.dart';

enum GameState {
  ready,
  playing,
  paused,
  checkpoint,
  bossFight,
  victory,
  gameOver,
}

class ArcadeGameController extends ChangeNotifier {
  final int level;
  final GameProgress progress;
  final AudioService audio = AudioService();

  late final GastroWorld world;
  late final TunnelGeometry tunnel;
  late final CapsulePlayer player;
  late final ArcadeBoss boss;

  final List<ArcadeCollectible> collectibles = [];
  final List<ArcadeObstacle> obstacles = [];
  final List<ArcadeCheckpoint> checkpoints = [];
  final List<FloatingArcadeText> floatingTexts = [];
  final List<ArcadeParticle> particles = [];
  final List<BackgroundErythrocyte> backgroundCells = [];
  final List<CapsuleProjectile> playerProjectiles = [];
  final List<CapsuleProjectile> enemyProjectiles = [];
  final List<ArcadeEnemy> enemies = [];

  WeaponConfig get equippedWeaponConfig => WeaponConfig.getByName(progress.equippedWeapon);

  GameState state = GameState.ready;
  double cameraX = 0.0;
  double viewportWidth = 800.0;
  double viewportHeight = 500.0;

  double totalDistance = 5200.0;
  int score = 0;
  int combo = 0;
  int highestCombo = 0;
  int earnedXp = 0;
  int crystalsCollected = 0;
  double gameTime = 0.0;
  double screenShake = 0.0;

  ArcadeCheckpoint? activeCheckpoint;
  bool isBossDefeated = false;

  ArcadeGameController({
    required this.level,
    required this.progress,
  }) {
    world = GastroWorld.getWorldForLevel(level);
    _initLevel();
  }

  void _initLevel() {
    // Level length scales smoothly: 4200 to 5600
    totalDistance = 4500.0 + (level % 5) * 220.0;

    tunnel = TunnelGeometry(
      levelLength: totalDistance,
      world: world,
      baseCeiling: 85.0,
      baseFloor: 430.0,
    );

    player = CapsulePlayer(
      position: Offset(100.0, (tunnel.baseCeiling + tunnel.baseFloor) / 2),
      hearts: 3,
      maxHearts: 3,
      weaponType: equippedWeaponConfig.type,
    );

    playerProjectiles.clear();
    enemyProjectiles.clear();

    _generateBackgroundErythrocytes();
    _generateCheckpoints();
    _generateCollectibles();
    _generateObstacles();
    _generateEnemies();
    _generateBoss();
  }

  void _generateBackgroundErythrocytes() {
    final rand = math.Random(level * 777);
    backgroundCells.clear();
    for (int i = 0; i < 45; i++) {
      backgroundCells.add(
        BackgroundErythrocyte(
          position: Offset(rand.nextDouble() * totalDistance, rand.nextDouble() * 550),
          depth: 0.15 + rand.nextDouble() * 0.65,
          radius: 12.0 + rand.nextDouble() * 24.0,
          wobblePhase: rand.nextDouble() * math.pi * 2,
          rotation: rand.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  void _generateCheckpoints() {
    checkpoints.clear();

    // Primary question for this level
    final currentQ = allGastroQuestions[(level - 1).clamp(0, allGastroQuestions.length - 1)];

    // Check if there are questions in the revision queue to mix in!
    GastroQuestion? revisionQ;
    if (progress.revisionQueue.isNotEmpty) {
      final revId = progress.revisionQueue.firstWhere(
        (id) => id != currentQ.id,
        orElse: () => -1,
      );
      if (revId != -1) {
        revisionQ = allGastroQuestions.firstWhere((q) => q.id == revId);
      }
    }

    // Place checkpoint 1 at ~30%
    checkpoints.add(
      ArcadeCheckpoint(
        index: 1,
        worldX: totalDistance * 0.32,
        question: revisionQ ?? currentQ,
      ),
    );

    // Place checkpoint 2 at ~65%
    checkpoints.add(
      ArcadeCheckpoint(
        index: 2,
        worldX: totalDistance * 0.68,
        question: currentQ,
      ),
    );
  }

  void _generateCollectibles() {
    collectibles.clear();
    final rand = math.Random(level * 333);
    int colId = 1;

    // Distribute clusters along the tunnel
    for (double x = 300.0; x < totalDistance - 700.0; x += 110.0 + rand.nextDouble() * 90.0) {
      final ceilY = tunnel.getCeilingY(x, 0.0);
      final floorY = tunnel.getFloorY(x, 0.0);
      final midY = (ceilY + floorY) / 2;

      // Group in gentle arches of 3 to 4 items
      int count = 2 + rand.nextInt(3);
      for (int i = 0; i < count; i++) {
        final itemX = x + i * 32.0;
        final floatOffset = math.sin((i / count) * math.pi) * 35.0;
        final itemY = midY - floatOffset + (rand.nextDouble() - 0.5) * 30.0;

        CollectibleType type = CollectibleType.cellBubble;
        int xp = 20;
        int pts = 50;

        final roll = rand.nextDouble();
        if (roll < 0.40) {
          type = CollectibleType.cellBubble;
          xp = 20;
          pts = 40;
        } else if (roll < 0.70) {
          type = CollectibleType.atpCrystal;
          xp = 35;
          pts = 80;
        } else if (roll < 0.85) {
          type = CollectibleType.vitaminCapsule;
          xp = 50;
          pts = 120;
        } else if (roll < 0.92) {
          type = CollectibleType.shieldBoost;
          xp = 60;
          pts = 140;
        } else if (roll < 0.96) {
          type = CollectibleType.weaponUpgrade;
          xp = 75;
          pts = 180;
        } else {
          type = CollectibleType.heartBoost;
          xp = 60;
          pts = 150;
        }

        collectibles.add(
          ArcadeCollectible(
            id: colId++,
            position: Offset(itemX, itemY.clamp(ceilY + 30.0, floorY - 30.0)),
            type: type,
            xpValue: xp,
            scoreValue: pts,
            animPhase: rand.nextDouble() * math.pi * 2,
          ),
        );
      }
    }
  }

  void _generateObstacles() {
    obstacles.clear();
    final rand = math.Random(level * 555);
    int obsId = 1;

    for (double x = 500.0; x < totalDistance - 800.0; x += 220.0 + rand.nextDouble() * 160.0) {
      // Avoid placing right on checkpoints
      bool onCheckpoint = checkpoints.any((cp) => (cp.worldX - x).abs() < 120.0);
      if (onCheckpoint) continue;

      final ceilY = tunnel.getCeilingY(x, 0.0);
      final floorY = tunnel.getFloorY(x, 0.0);

      final roll = rand.nextDouble();
      if (roll < 0.45) {
        // Green toothy monster sitting on the floor (Reference Image 1)
        obstacles.add(
          ArcadeObstacle(
            id: obsId++,
            position: Offset(x, floorY - 32.0),
            initialY: floorY - 32.0,
            type: ObstacleType.toothyMicrobe,
            radius: 28.0,
            animPhase: rand.nextDouble() * math.pi * 2,
          ),
        );
      } else if (roll < 0.75) {
        // Spiky virus hovering mid-tunnel
        final midY = (ceilY + floorY) / 2 + (rand.nextDouble() - 0.5) * 60.0;
        obstacles.add(
          ArcadeObstacle(
            id: obsId++,
            position: Offset(x, midY),
            initialY: midY,
            type: ObstacleType.spikyVirus,
            radius: 22.0,
            animPhase: rand.nextDouble() * math.pi * 2,
          ),
        );
      } else {
        // Acid droplet dripping from ceiling
        obstacles.add(
          ArcadeObstacle(
            id: obsId++,
            position: Offset(x, ceilY + 18.0),
            initialY: ceilY + 18.0,
            type: ObstacleType.acidDroplet,
            radius: 18.0,
            velocityY: 80.0 + rand.nextDouble() * 60.0,
            animPhase: rand.nextDouble() * math.pi * 2,
          ),
        );
      }
    }
  }

  void _generateEnemies() {
    enemies.clear();
    final rand = math.Random(level * 888);
    int enemyId = 1;

    for (double x = 450.0; x < totalDistance - 850.0; x += 190.0 + rand.nextDouble() * 130.0) {
      // Avoid placing right on checkpoints
      bool onCheckpoint = checkpoints.any((cp) => (cp.worldX - x).abs() < 120.0);
      if (onCheckpoint) continue;

      final ceilY = tunnel.getCeilingY(x, 0.0);
      final floorY = tunnel.getFloorY(x, 0.0);
      final midY = (ceilY + floorY) / 2;

      final roll = rand.nextDouble();
      EnemyType eType;
      int hp;
      double radius;
      int score;
      int xp;

      if (roll < 0.28) {
        eType = EnemyType.helicoGrub;
        hp = 2 + (level / 7).floor();
        radius = 20.0;
        score = 120;
        xp = 25;
      } else if (roll < 0.52) {
        eType = EnemyType.spikeVirion;
        hp = 2 + (level / 8).floor();
        radius = 18.0;
        score = 140;
        xp = 30;
      } else if (roll < 0.74) {
        eType = EnemyType.cytokineBlob;
        hp = 3 + (level / 6).floor();
        radius = 22.0;
        score = 180;
        xp = 35;
      } else if (roll < 0.90) {
        eType = EnemyType.acidSentry;
        hp = 4 + (level / 5).floor();
        radius = 24.0;
        score = 220;
        xp = 45;
      } else {
        eType = EnemyType.toxicSpore;
        hp = 2;
        radius = 16.0;
        score = 100;
        xp = 20;
      }

      final enemyY = midY + (rand.nextDouble() - 0.5) * 80.0;
      enemies.add(
        ArcadeEnemy(
          id: enemyId++,
          position: Offset(x, enemyY.clamp(ceilY + 25.0, floorY - 25.0)),
          velocity: Offset(-45.0 - rand.nextDouble() * 30.0, 0),
          type: eType,
          maxHp: hp,
          radius: radius,
          scoreReward: score,
          xpReward: xp,
          shootInterval: 2.2 + rand.nextDouble() * 1.5,
        ),
      );
    }
  }

  void _generateBoss() {
    // Challenge questions from current world
    final worldQuestions = allGastroQuestions.where((q) => q.worldId == world.id).toList();

    boss = ArcadeBoss(
      name: world.boss.name,
      title: world.boss.title,
      auraColor: world.boss.auraColor,
      icon: world.boss.icon,
      position: Offset(totalDistance - 350.0, (tunnel.baseCeiling + tunnel.baseFloor) / 2),
      challengeQuestions: worldQuestions,
    );
  }

  void start() {
    state = GameState.playing;
    audio.playClick();
    notifyListeners();
  }

  void pause() {
    if (state == GameState.playing) {
      state = GameState.paused;
      notifyListeners();
    }
  }

  void resume() {
    if (state == GameState.paused) {
      state = GameState.playing;
      notifyListeners();
    }
  }

  void setViewport(double width, double height) {
    viewportWidth = width;
    viewportHeight = height;
  }

  // Input actions
  void setThrust(bool value) {
    player.isThrusting = value;
    if (value && state == GameState.playing) {
      audio.playThruster();
    }
  }

  void setMoveLeft(bool value) {
    player.isMovingLeft = value;
  }

  void setMoveRight(bool value) {
    player.isMovingRight = value;
  }

  void setMoveDown(bool value) {
    player.isMovingDown = value;
  }

  void shoot() {
    if (state != GameState.playing && state != GameState.bossFight) return;
    if (player.shootCooldownTimer > 0) return;

    final config = equippedWeaponConfig;
    player.shootCooldownTimer = config.cooldownSeconds;

    final baseSpeed = config.projectileSpeed;
    final bulletDamage = config.damage;
    final color = config.glowColor;

    if (config.type == WeaponType.doubleLaser || player.hasDoubleShot) {
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + const Offset(24, -8),
          velocity: Offset(baseSpeed, 0),
          damage: bulletDamage,
          color: color,
          radius: 5.5,
          weaponType: config.type,
        ),
      );
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + const Offset(24, 8),
          velocity: Offset(baseSpeed, 0),
          damage: bulletDamage,
          color: color,
          radius: 5.5,
          weaponType: config.type,
        ),
      );
    } else if (config.type == WeaponType.plasmaShot) {
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + const Offset(26, 0),
          velocity: Offset(baseSpeed, 0),
          damage: bulletDamage,
          color: color,
          radius: 9.0,
          weaponType: config.type,
        ),
      );
    } else if (config.type == WeaponType.electricWave) {
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + const Offset(24, 0),
          velocity: Offset(baseSpeed, 0),
          damage: bulletDamage,
          color: color,
          radius: 6.5,
          weaponType: config.type,
        ),
      );
    } else if (config.type == WeaponType.ultimatePulse) {
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + const Offset(26, 0),
          velocity: Offset(baseSpeed, -60),
          damage: bulletDamage,
          color: color,
          radius: 8.0,
          weaponType: config.type,
        ),
      );
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + const Offset(28, 0),
          velocity: Offset(baseSpeed + 40, 0),
          damage: bulletDamage,
          color: color,
          radius: 8.5,
          weaponType: config.type,
        ),
      );
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + const Offset(26, 0),
          velocity: Offset(baseSpeed, 60),
          damage: bulletDamage,
          color: color,
          radius: 8.0,
          weaponType: config.type,
        ),
      );
    } else {
      // medicalLaser
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + const Offset(24, 0),
          velocity: Offset(baseSpeed, 0),
          damage: bulletDamage,
          color: color,
          radius: 5.0,
          weaponType: config.type,
        ),
      );
    }

    audio.playBossLaser();
    _emitMuzzleParticles(player.position + const Offset(24, 0), color);
  }

  void activateShield() {
    if (state != GameState.playing && state != GameState.bossFight) return;
    player.activateShield(4.0);
    audio.playTargetLock();
    _addFloatingText('BOUCLIER ACTIF !', player.position + const Offset(0, -35), const Color(0xFF818CF8));
    notifyListeners();
  }

  /// 60 FPS Engine Tick
  void update(double dt) {
    if (state != GameState.playing && state != GameState.bossFight) {
      return;
    }

    gameTime += dt;
    if (screenShake > 0) {
      screenShake = math.max(0.0, screenShake - dt * 3.5);
    }

    _updatePlayerPhysics(dt);
    _updateCamera();
    _updateProjectiles(dt);
    _updateEnemies(dt);
    _updateCollectibles(dt);
    _updateObstacles(dt);
    _updateBoss(dt);
    _updateParticles(dt);
    _updateFloatingTexts(dt);
    _checkCollisions();

    notifyListeners();
  }

  void _updatePlayerPhysics(double dt) {
    // Decrement timers
    if (player.invulnerableTimer > 0) {
      player.invulnerableTimer = math.max(0.0, player.invulnerableTimer - dt);
    }
    if (player.boostTimer > 0) {
      player.boostTimer = math.max(0.0, player.boostTimer - dt);
    }
    if (player.shootCooldownTimer > 0) {
      player.shootCooldownTimer = math.max(0.0, player.shootCooldownTimer - dt);
    }
    if (player.shieldTimer > 0) {
      player.shieldTimer = math.max(0.0, player.shieldTimer - dt);
    }
    if (player.doubleShotTimer > 0) {
      player.doubleShotTimer = math.max(0.0, player.doubleShotTimer - dt);
    }

    player.animPhase += dt * 4.0;

    // Vertical physics: Thruster vs Gravity & Mucosal drag
    double vy = player.velocity.dy;
    const double gravity = 480.0;
    const double thrustPower = 1150.0;

    if (player.isThrusting) {
      vy -= thrustPower * dt;
      // Emit thruster bubble particles
      _emitThrusterParticles();
    } else {
      vy += gravity * dt;
    }

    if (player.isMovingDown) {
      vy += 650.0 * dt;
    }

    // Mucosal fluid damping
    vy *= 0.94;
    vy = vy.clamp(-400.0, 420.0);

    // Horizontal physics: Cruise auto-propulsion + directional control
    double vx = player.velocity.dx;
    double targetCruise = player.isBoosted ? 340.0 : 190.0;

    if (state == GameState.bossFight) {
      // In boss fight, hover in place with player freedom
      targetCruise = 0.0;
      if (player.isMovingRight) vx += 300.0 * dt;
      if (player.isMovingLeft) vx -= 300.0 * dt;
      vx *= 0.88;
    } else {
      if (player.isMovingRight) {
        vx += 280.0 * dt;
      } else if (player.isMovingLeft) {
        vx -= 280.0 * dt;
      } else {
        vx += (targetCruise - vx) * 3.5 * dt;
      }
      vx = vx.clamp(40.0, player.isBoosted ? 450.0 : 320.0);
    }

    player.velocity = Offset(vx, vy);
    player.position += player.velocity * dt;

    // Tilt angle reflects vertical climb/descent
    final targetAngle = (player.velocity.dy / 420.0).clamp(-0.45, 0.45);
    player.angle += (targetAngle - player.angle) * 7.0 * dt;

    // Boundaries collision: Ceiling and floor with soft deflection
    final ceilY = tunnel.getCeilingY(player.position.dx, gameTime) + player.radius + 6.0;
    final floorY = tunnel.getFloorY(player.position.dx, gameTime) - player.radius - 6.0;

    if (player.position.dy < ceilY) {
      player.position = Offset(player.position.dx, ceilY);
      player.velocity = Offset(player.velocity.dx * 0.8, 30.0);
    } else if (player.position.dy > floorY) {
      player.position = Offset(player.position.dx, floorY);
      player.velocity = Offset(player.velocity.dx * 0.8, -30.0);
    }
  }

  void _updateCamera() {
    if (state == GameState.bossFight) {
      // Keep boss and player centered
      final targetX = (totalDistance - 480.0).clamp(0.0, totalDistance);
      cameraX += (targetX - cameraX) * 0.06;
    } else {
      // Smooth horizontal camera tracking
      final targetCameraX = player.position.dx - viewportWidth * 0.28;
      cameraX = math.max(0.0, targetCameraX);
    }
  }

  void _updateProjectiles(double dt) {
    // Player projectiles
    for (int i = playerProjectiles.length - 1; i >= 0; i--) {
      final p = playerProjectiles[i];
      p.update(dt);
      if (p.isDead ||
          p.position.dx > cameraX + viewportWidth + 150.0 ||
          p.position.dx < cameraX - 100.0) {
        playerProjectiles.removeAt(i);
      }
    }

    // Enemy projectiles
    for (int i = enemyProjectiles.length - 1; i >= 0; i--) {
      final p = enemyProjectiles[i];
      p.update(dt);
      if (p.isDead ||
          p.position.dx > cameraX + viewportWidth + 150.0 ||
          p.position.dx < cameraX - 100.0) {
        enemyProjectiles.removeAt(i);
      }
    }
  }

  void _updateEnemies(double dt) {
    for (int i = enemies.length - 1; i >= 0; i--) {
      final enemy = enemies[i];
      enemy.update(dt, player.position, enemyProjectiles);
      if (enemy.isDead) {
        enemies.removeAt(i);
      }
    }
  }

  void _updateCollectibles(double dt) {
    for (final item in collectibles) {
      if (!item.isCollected) {
        item.animPhase += dt * 3.0;
      }
    }
  }

  void _updateObstacles(double dt) {
    for (final obs in obstacles) {
      obs.animPhase += dt * 2.5;

      if (obs.type == ObstacleType.acidDroplet) {
        // Acid drop falling from ceiling to floor
        double newY = obs.position.dy + obs.velocityY * dt;
        final floorY = tunnel.getFloorY(obs.position.dx, gameTime);
        if (newY >= floorY - 10.0) {
          // Splash and reset to ceiling
          _emitSplashParticles(obs.position, const Color(0xFF84CC16));
          newY = tunnel.getCeilingY(obs.position.dx, gameTime) + 12.0;
        }
        obs.position = Offset(obs.position.dx, newY);
      } else if (obs.type == ObstacleType.spikyVirus) {
        // Floating sinusoidal bob
        final floatY = obs.initialY + math.sin(obs.animPhase) * 22.0;
        obs.position = Offset(obs.position.dx, floatY);
      }
    }
  }

  void _updateBoss(double dt) {
    boss.animPhase += dt * 2.0;
    if (boss.hitTimer > 0) {
      boss.hitTimer = math.max(0.0, boss.hitTimer - dt);
      if (boss.hitTimer <= 0) {
        boss.isHit = false;
      }
    }

    // Gentle hovering sine motion in boss chamber
    final hoverY = (tunnel.baseCeiling + tunnel.baseFloor) / 2 + math.sin(boss.animPhase * 1.5) * 35.0;
    boss.position = Offset(boss.position.dx, hoverY);
  }

  void _updateParticles(double dt) {
    for (int i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      p.position += p.velocity * dt;
      p.life -= dt / p.maxLife;
      if (p.isDead) {
        particles.removeAt(i);
      }
    }
  }

  void _updateFloatingTexts(double dt) {
    for (int i = floatingTexts.length - 1; i >= 0; i--) {
      final txt = floatingTexts[i];
      txt.position += const Offset(0, -32.0) * dt;
      txt.life -= dt / txt.maxLife;
      if (txt.isDead) {
        floatingTexts.removeAt(i);
      }
    }
  }

  void _checkCollisions() {
    // 1. Collectibles
    for (final item in collectibles) {
      if (item.isCollected) continue;
      final dist = (player.position - item.position).distance;
      if (dist < player.radius + item.radius) {
        item.isCollected = true;
        crystalsCollected++;
        earnedXp += item.xpValue;
        score += item.scoreValue * (1 + (combo / 4).floor());
        combo++;
        if (combo > highestCombo) highestCombo = combo;

        audio.playCrystal();
        if (combo % 5 == 0) {
          audio.playCombo();
        }

        if (item.type == CollectibleType.heartBoost) {
          player.heal();
          _addFloatingText('+1 CŒUR !', item.position, const Color(0xFF34D399));
        } else if (item.type == CollectibleType.shieldBoost) {
          player.activateShield(5.0);
          _addFloatingText('BOUCLIER ACTIF (5s) !', item.position, const Color(0xFF818CF8));
        } else if (item.type == CollectibleType.weaponUpgrade) {
          player.activateDoubleShot(8.0);
          _addFloatingText('SUPER CADENCE (8s) !', item.position, const Color(0xFF38BDF8));
        } else {
          _addFloatingText('+${item.scoreValue} XP', item.position, const Color(0xFFFFD166));
        }

        _emitCollectParticles(item.position, item.type);
      }
    }

    // 2. Player Projectiles vs Enemies & Boss
    for (int pIdx = playerProjectiles.length - 1; pIdx >= 0; pIdx--) {
      final p = playerProjectiles[pIdx];
      bool bulletHit = false;

      // Against enemies
      for (final enemy in enemies) {
        if (enemy.isDead) continue;
        final dist = (p.position - enemy.position).distance;
        if (dist < p.radius + enemy.radius) {
          enemy.takeDamage(p.damage);
          bulletHit = true;
          _emitHitSparks(enemy.position);

          if (enemy.isDead) {
            score += enemy.scoreReward * (1 + (combo / 4).floor());
            earnedXp += enemy.xpReward;
            combo++;
            if (combo > highestCombo) highestCombo = combo;
            _addFloatingText('+${enemy.xpReward} XP', enemy.position, const Color(0xFF38BDF8));
            _emitExplosion(enemy.position, enemy.type);
            audio.playCombo();

            // 25% chance to drop a bonus
            if (math.Random().nextDouble() < 0.25) {
              collectibles.add(
                ArcadeCollectible(
                  id: 9000 + collectibles.length,
                  position: enemy.position,
                  type: math.Random().nextBool()
                      ? CollectibleType.heartBoost
                      : CollectibleType.shieldBoost,
                  xpValue: 50,
                  scoreValue: 120,
                ),
              );
            }
          }
          break;
        }
      }

      // Against Boss
      if (!bulletHit && state == GameState.bossFight && !boss.isDefeated) {
        final dist = (p.position - boss.position).distance;
        if (dist < p.radius + 60.0) {
          boss.takeDamage();
          bulletHit = true;
          _emitHitSparks(boss.position);
          score += 200;
          earnedXp += 50;
          if (boss.isDefeated) {
            _onBossDefeated();
          }
        }
      }

      if (bulletHit) {
        playerProjectiles.removeAt(pIdx);
      }
    }

    // 3. Enemy Projectiles vs Player
    for (int epIdx = enemyProjectiles.length - 1; epIdx >= 0; epIdx--) {
      final ep = enemyProjectiles[epIdx];
      final dist = (player.position - ep.position).distance;
      if (dist < player.radius + ep.radius) {
        if (player.isShieldActive) {
          _emitShieldDeflect(player.position);
          _addFloatingText('DÉVIÉ !', player.position + const Offset(0, -25), const Color(0xFF818CF8));
        } else if (!player.isInvulnerable) {
          player.takeDamage();
          combo = 0;
          screenShake = 1.0;
          audio.playHit();
          _addFloatingText('-1 CŒUR', player.position + const Offset(0, -25), const Color(0xFFEF4444));
          _emitHitSparks(player.position);
          if (player.hearts <= 0) {
            _onPlayerZeroHearts();
          }
        }
        enemyProjectiles.removeAt(epIdx);
      }
    }

    // 4. Enemies vs Player (Body contact)
    for (final enemy in enemies) {
      if (enemy.isDead) continue;
      final dist = (player.position - enemy.position).distance;
      if (dist < player.radius + enemy.radius) {
        if (player.isShieldActive) {
          _emitShieldDeflect(player.position);
          enemy.takeDamage(2);
          _addFloatingText('CHOC BOUCLIER !', enemy.position + const Offset(0, -20), const Color(0xFF818CF8));
        } else if (!player.isInvulnerable) {
          player.takeDamage();
          combo = 0;
          screenShake = 1.0;
          audio.playHit();
          _addFloatingText('-1 CŒUR', player.position + const Offset(0, -25), const Color(0xFFEF4444));
          _emitHitSparks(player.position);
          if (player.hearts <= 0) {
            _onPlayerZeroHearts();
          }
          break;
        }
      }
    }

    // 5. Obstacles
    if (!player.isInvulnerable) {
      for (final obs in obstacles) {
        final dist = (player.position - obs.position).distance;
        if (dist < player.radius + obs.radius) {
          player.takeDamage();
          combo = 0; // Combo break
          screenShake = 1.0;
          audio.playHit();

          _addFloatingText('-1 CŒUR', player.position + const Offset(0, -25), const Color(0xFFEF4444));
          _emitHitSparks(player.position);

          if (player.hearts <= 0) {
            // Emergency learning recovery
            _onPlayerZeroHearts();
          }
          break;
        }
      }
    }

    // 3. Checkpoints
    if (state == GameState.playing) {
      for (final cp in checkpoints) {
        if (!cp.isTriggered && player.position.dx >= cp.worldX - 20.0) {
          cp.isTriggered = true;
          activeCheckpoint = cp;
          state = GameState.checkpoint;
          audio.playTargetLock();
          break;
        }
      }
    }

    // 4. Boss Chamber Entrance
    if (state == GameState.playing && player.position.dx >= totalDistance - 750.0) {
      state = GameState.bossFight;
      audio.playPagerBeep();
      _addFloatingText('ALERTE BOSS : ${boss.name.toUpperCase()} !', player.position + const Offset(40, -40), Colors.amberAccent);
    }
  }

  void _onPlayerZeroHearts() {
    // Graceful revival: give 1 heart so student never gets locked out of educational learning!
    player.hearts = 1;
    player.invulnerableTimer = 3.0;
    _addFloatingText('RÉANIMATION D\'URGENCE !', player.position + const Offset(0, -35), const Color(0xFF38BDF8));
  }

  /// Called when student validates a checkpoint question
  void answerCheckpoint({required int selectedOptionIndex, required bool isCorrect}) {
    if (activeCheckpoint == null) return;

    final cp = activeCheckpoint!;
    cp.isCompleted = true;
    cp.isAnswerCorrect = isCorrect;

    // Track progression & spaced repetition queue
    progress.recordQuestionAnswer(
      questionId: cp.question.id,
      selectedOptionIndex: selectedOptionIndex,
      isCorrect: isCorrect,
      earnedXp: isCorrect ? 100 : 30,
    );

    if (isCorrect) {
      earnedXp += 100;
      score += 300;
      combo += 2;
      player.boostTimer = 3.5; // Boost thrusters!
      audio.playCorrect();
      _addFloatingText('EXCELLENT ! +100 XP', player.position + const Offset(0, -30), const Color(0xFF34D399));
    } else {
      player.takeDamage();
      combo = 0;
      audio.playWrong();
      _addFloatingText('RÉVISION ENREGISTRÉE', player.position + const Offset(0, -30), const Color(0xFFF87171));
    }

    // Resume play
    activeCheckpoint = null;
    state = GameState.playing;
    notifyListeners();
  }

  /// Called during the Boss challenge
  void answerBossQuestion({required int questionId, required int selectedOptionIndex, required bool isCorrect}) {
    progress.recordQuestionAnswer(
      questionId: questionId,
      selectedOptionIndex: selectedOptionIndex,
      isCorrect: isCorrect,
      earnedXp: isCorrect ? 120 : 30,
    );

    if (isCorrect) {
      boss.takeDamage();
      audio.playBossLaser();
      score += 450;
      earnedXp += 120;
      _emitBossLaser();

      if (boss.isDefeated) {
        _onBossDefeated();
      }
    } else {
      player.takeDamage();
      combo = 0;
      audio.playHit();
    }

    notifyListeners();
  }

  void _onBossDefeated() {
    isBossDefeated = true;
    state = GameState.victory;
    audio.playVictory();

    // Mark current level completed in GameProgress
    progress.completeLevel(level, 0, true);
    progress.updateArcadeStats(
      score: score,
      combo: highestCombo,
      crystals: crystalsCollected,
    );

    _emitVictoryConfetti();
  }

  void _addFloatingText(String text, Offset pos, Color color) {
    floatingTexts.add(
      FloatingArcadeText(
        text: text,
        position: pos,
        color: color,
        life: 1.1,
        maxLife: 1.1,
      ),
    );
  }

  void _emitThrusterParticles() {
    final rand = math.Random();
    particles.add(
      ArcadeParticle(
        position: player.position + Offset(-player.radius - 4.0, (rand.nextDouble() - 0.5) * 8.0),
        velocity: Offset(-180.0 - rand.nextDouble() * 60.0, (rand.nextDouble() - 0.5) * 45.0),
        color: rand.nextBool() ? const Color(0xFF00E5FF) : const Color(0xFF90E0EF),
        size: 3.5 + rand.nextDouble() * 3.5,
        maxLife: 0.35,
      ),
    );
  }

  void _emitCollectParticles(Offset pos, CollectibleType type) {
    final rand = math.Random();
    Color pCol = const Color(0xFFFFD166);
    if (type == CollectibleType.cellBubble) pCol = const Color(0xFFFB7185);
    if (type == CollectibleType.heartBoost) pCol = const Color(0xFF34D399);

    for (int i = 0; i < 12; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 60.0 + rand.nextDouble() * 120.0;
      particles.add(
        ArcadeParticle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: pCol,
          size: 3.0 + rand.nextDouble() * 3.0,
          maxLife: 0.5,
        ),
      );
    }
  }

  void _emitHitSparks(Offset pos) {
    final rand = math.Random();
    for (int i = 0; i < 16; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 80.0 + rand.nextDouble() * 160.0;
      particles.add(
        ArcadeParticle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: const Color(0xFFEF4444),
          size: 4.0 + rand.nextDouble() * 3.0,
          maxLife: 0.6,
        ),
      );
    }
  }

  void _emitSplashParticles(Offset pos, Color color) {
    final rand = math.Random();
    for (int i = 0; i < 8; i++) {
      final angle = -math.pi * rand.nextDouble();
      final speed = 40.0 + rand.nextDouble() * 70.0;
      particles.add(
        ArcadeParticle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: color,
          size: 3.0 + rand.nextDouble() * 3.0,
          maxLife: 0.4,
        ),
      );
    }
  }

  void _emitBossLaser() {
    // Generate beam particles from player to boss
    final start = player.position;
    final end = boss.position;
    final count = 25;
    for (int i = 0; i < count; i++) {
      final t = i / count;
      final pos = Offset.lerp(start, end, t)!;
      particles.add(
        ArcadeParticle(
          position: pos + Offset((math.Random().nextDouble() - 0.5) * 12.0, (math.Random().nextDouble() - 0.5) * 12.0),
          velocity: Offset((math.Random().nextDouble() - 0.5) * 40.0, (math.Random().nextDouble() - 0.5) * 40.0),
          color: const Color(0xFF00E5FF),
          size: 5.0,
          maxLife: 0.4,
        ),
      );
    }
  }

  void _emitMuzzleParticles(Offset pos, Color color) {
    final rand = math.Random();
    for (int i = 0; i < 6; i++) {
      final angle = (rand.nextDouble() - 0.5) * 0.8;
      final speed = 90.0 + rand.nextDouble() * 80.0;
      particles.add(
        ArcadeParticle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: color,
          size: 3.0 + rand.nextDouble() * 2.5,
          maxLife: 0.22,
        ),
      );
    }
  }

  void _emitShieldDeflect(Offset pos) {
    final rand = math.Random();
    for (int i = 0; i < 14; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 80.0 + rand.nextDouble() * 120.0;
      particles.add(
        ArcadeParticle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: const Color(0xFF818CF8),
          size: 3.5 + rand.nextDouble() * 3.0,
          maxLife: 0.35,
        ),
      );
    }
  }

  void _emitExplosion(Offset pos, EnemyType type) {
    final rand = math.Random();
    Color expColor = const Color(0xFF38BDF8);
    if (type == EnemyType.cytokineBlob || type == EnemyType.acidSentry) {
      expColor = const Color(0xFFF59E0B);
    } else if (type == EnemyType.toxicSpore) {
      expColor = const Color(0xFF10B981);
    }

    for (int i = 0; i < 24; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 90.0 + rand.nextDouble() * 190.0;
      particles.add(
        ArcadeParticle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: rand.nextBool() ? expColor : const Color(0xFFFFFFFF),
          size: 3.5 + rand.nextDouble() * 4.5,
          maxLife: 0.55,
        ),
      );
    }
  }

  void _emitVictoryConfetti() {
    final rand = math.Random();
    final colors = [
      const Color(0xFFFFD166),
      const Color(0xFF00E5FF),
      const Color(0xFF10B981),
      const Color(0xFFEC4899),
      const Color(0xFFFFFFFF),
    ];
    for (int i = 0; i < 80; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 120.0 + rand.nextDouble() * 260.0;
      particles.add(
        ArcadeParticle(
          position: boss.position,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: colors[rand.nextInt(colors.length)],
          size: 5.0 + rand.nextDouble() * 5.0,
          maxLife: 1.4,
        ),
      );
    }
  }

  double get progressFraction {
    return (player.position.dx / totalDistance).clamp(0.0, 1.0);
  }
}
