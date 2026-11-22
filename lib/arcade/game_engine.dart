import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/gastro_world.dart';
import '../models/game_progress.dart';
import 'capsule_entity.dart';
import 'enemy_entities.dart';
import 'weapon_entities.dart';
import 'boss_entity.dart';
import 'environment_painter.dart';

enum GameState {
  playing,
  paused,
  checkpoint,
  boss,
  victory,
  gameover,
}

enum CollectibleType {
  heartBoost,
  energyCrystal,
  shieldBoost,
  weaponUpgrade,
}

class Collectible {
  Offset position;
  final CollectibleType type;
  final double radius;
  bool isCollected;
  double animTimer = 0.0;

  Collectible({
    required this.position,
    required this.type,
    this.radius = 14.0,
    this.isCollected = false,
  });

  Rect get bounds => Rect.fromCircle(center: position, radius: radius);

  void update(double dt) {
    animTimer += dt;
  }

  void draw(Canvas canvas, Offset screenPos) {
    if (isCollected) return;
    canvas.save();
    canvas.translate(screenPos.dx, screenPos.dy);

    final floatY = math.sin(animTimer * 4.0) * 4.0;
    canvas.translate(0, floatY);

    final paint = Paint()..isAntiAlias = true;

    switch (type) {
      case CollectibleType.heartBoost:
        // Glowing red heart
        final heartPath = Path();
        heartPath.moveTo(0, 4);
        heartPath.cubicTo(-10, -6, -12, 6, 0, 14);
        heartPath.cubicTo(12, 6, 10, -6, 0, 4);

        paint.color = const Color(0x66FF1744);
        canvas.drawCircle(const Offset(0, 5), radius + 4, paint);

        paint.color = const Color(0xFFFF1744);
        canvas.drawPath(heartPath, paint);
        break;

      case CollectibleType.energyCrystal:
        // Golden glowing diamond crystal
        final diamond = Path()
          ..moveTo(0, -radius)
          ..lineTo(radius * 0.8, 0)
          ..lineTo(0, radius)
          ..lineTo(-radius * 0.8, 0)
          ..close();

        paint.color = const Color(0x66FFD700);
        canvas.drawCircle(Offset.zero, radius + 3, paint);

        paint.shader = const LinearGradient(
          colors: [Colors.white, Color(0xFFFFD700), Color(0xFFFF8F00)],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));
        canvas.drawPath(diamond, paint);
        paint.shader = null;
        break;

      case CollectibleType.shieldBoost:
        // Cyan shield orb
        paint.color = const Color(0x5500E5FF);
        canvas.drawCircle(Offset.zero, radius + 4, paint);

        paint.color = const Color(0xFF00E5FF);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2.5;
        canvas.drawCircle(Offset.zero, radius, paint);

        paint.style = PaintingStyle.fill;
        paint.color = Colors.white;
        canvas.drawCircle(Offset.zero, radius * 0.45, paint);
        break;

      case CollectibleType.weaponUpgrade:
        // Rainbow glowing orb with weapon bolt
        paint.color = const Color(0x66E040FB);
        canvas.drawCircle(Offset.zero, radius + 5, paint);

        paint.shader = const SweepGradient(
          colors: [Color(0xFF00E5FF), Color(0xFFFF4081), Color(0xFFFFD700), Color(0xFF00E5FF)],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));
        canvas.drawCircle(Offset.zero, radius, paint);
        paint.shader = null;

        paint.color = Colors.white;
        canvas.drawCircle(Offset.zero, radius * 0.4, paint);
        break;
    }

    canvas.restore();
  }
}

enum ObstacleType {
  mucosalSpike,
  acidPool,
  polypGrowth,
}

class Obstacle {
  Offset position;
  final ObstacleType type;
  final double radius;
  final int damage;
  double animTimer = 0.0;

  Obstacle({
    required this.position,
    required this.type,
    this.radius = 18.0,
    this.damage = 1,
  });

  Rect get bounds => Rect.fromCircle(center: position, radius: radius);

  void update(double dt) {
    animTimer += dt;
  }

  void draw(Canvas canvas, Offset screenPos) {
    canvas.save();
    canvas.translate(screenPos.dx, screenPos.dy);

    final paint = Paint()..isAntiAlias = true;

    switch (type) {
      case ObstacleType.mucosalSpike:
        // Jagged reddish-purple thorn
        final spike = Path()
          ..moveTo(0, -radius * 1.3)
          ..lineTo(radius * 0.9, radius)
          ..lineTo(-radius * 0.9, radius)
          ..close();

        paint.color = const Color(0xFF880E4F);
        canvas.drawPath(spike, paint);

        paint.color = const Color(0xFFFF4081);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2.0;
        canvas.drawPath(spike, paint);
        break;

      case ObstacleType.acidPool:
        // Caustic bubbling slime pool
        paint.color = const Color(0x8876FF03);
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: radius * 2.4, height: radius * 1.1), paint);

        paint.color = const Color(0xFF64DD17);
        final bubblePulse = math.sin(animTimer * 5.0) * 3.0;
        canvas.drawCircle(Offset(0, bubblePulse - 2), radius * 0.45, paint);
        break;

      case ObstacleType.polypGrowth:
        // Bulbous inflammatory mass
        paint.color = const Color(0xFFC2185B);
        canvas.drawCircle(Offset.zero, radius, paint);

        paint.color = const Color(0xFFE91E63);
        canvas.drawCircle(const Offset(-4, -4), radius * 0.65, paint);
        break;
    }

    canvas.restore();
  }
}

class Checkpoint {
  final double worldX;
  final int questionId;
  bool isTriggered;
  bool isCompleted;
  double animTimer = 0.0;

  Checkpoint({
    required this.worldX,
    required this.questionId,
    this.isTriggered = false,
    this.isCompleted = false,
  });

  void update(double dt) {
    animTimer += dt;
  }

  void draw(Canvas canvas, Offset screenPos, double screenHeight) {
    canvas.save();
    canvas.translate(screenPos.dx, screenHeight / 2);

    final ringRadius = 45.0 + math.sin(animTimer * 4.0) * 4.0;
    final color = isCompleted
        ? const Color(0xFF00E676)
        : (isTriggered ? const Color(0xFFFF9100) : const Color(0xFF00E5FF));

    // Futuristic glowing gate column
    final gatePaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0;
    canvas.drawLine(Offset(0, -screenHeight * 0.4), Offset(0, screenHeight * 0.4), gatePaint);

    final coreLine = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawLine(Offset(0, -screenHeight * 0.4), Offset(0, screenHeight * 0.4), coreLine);

    // Question Portal Orb
    final orbPaint = Paint()..color = Colors.black.withValues(alpha: 0.85);
    canvas.drawCircle(Offset.zero, ringRadius, orbPaint);

    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(Offset.zero, ringRadius, ringPaint);

    // Q text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Q$questionId',
        style: TextStyle(
          color: color,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(blurRadius: 6, color: color)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }
}

class CapsuleGameEngine {
  // State
  GameState state;

  // Capsule
  CapsuleState capsule;

  // World scrolling
  double scrollX;
  double levelLength;

  // Entities
  List<Enemy> enemies;
  List<Projectile> playerProjectiles;
  List<Projectile> enemyProjectiles;
  List<Collectible> collectibles;
  List<Obstacle> obstacles;

  // Checkpoints
  List<Checkpoint> checkpoints;
  int nextCheckpointIndex;

  // Boss
  BossEntity? boss;

  // Stage metadata
  final GastroWorld world;
  final GameProgress progress;
  final int stageId;

  // Viewport
  double viewportWidth;
  double viewportHeight;
  double gameTime = 0.0;
  int score = 0;
  int xpGained = 0;

  // Input states
  bool _moveLeft = false;
  bool _moveRight = false;
  bool _moveUp = false;
  bool _moveDown = false;
  Offset? _mousePosition;

  // Events (callbacks)
  Function(int questionId)? onCheckpointReached;
  Function()? onBossDefeated;
  Function()? onPlayerDied;
  Function()? onLevelComplete;

  CapsuleGameEngine({
    required this.world,
    required this.progress,
    this.stageId = 1,
    this.viewportWidth = 800.0,
    this.viewportHeight = 500.0,
    this.levelLength = 5200.0,
  })  : state = GameState.playing,
        capsule = CapsuleState(
          position: const Offset(120, 250),
          currentWeaponIndex: WeaponConfig.allWeapons.indexWhere(
            (w) => w.name == progress.equippedWeapon,
          ).clamp(0, 5),
        ),
        scrollX = 0.0,
        enemies = [],
        playerProjectiles = [],
        enemyProjectiles = [],
        collectibles = [],
        obstacles = [],
        checkpoints = [],
        nextCheckpointIndex = 0 {
    _initializeStage();
  }

  void _initializeStage() {
    // 1. Create checkpoints from world questions
    final qIds = world.questionIds;
    final double step = (levelLength - 1200.0) / (qIds.length + 1);
    for (int i = 0; i < qIds.length; i++) {
      checkpoints.add(
        Checkpoint(
          worldX: 800.0 + (i + 1) * step,
          questionId: qIds[i],
        ),
      );
    }

    // 2. Populate enemies across the level
    final rand = math.Random(stageId * 31);
    for (double x = 600.0; x < levelLength - 900.0; x += 320.0 + rand.nextDouble() * 180.0) {
      final y = 100.0 + rand.nextDouble() * 300.0;
      final typeIndex = rand.nextInt(5);

      switch (typeIndex) {
        case 0:
          enemies.add(HelicoBacterium(position: Offset(x, y)));
          break;
        case 1:
          enemies.add(CytokineCloud(position: Offset(x, y)));
          break;
        case 2:
          enemies.add(SpikeVirion(position: Offset(x, y), topLimit: 70, bottomLimit: 430));
          break;
        case 3:
          enemies.add(AcidDroplet(position: Offset(x, 60), floorY: 440));
          break;
        case 4:
          enemies.add(ToxicSpore(position: Offset(x, y)));
          break;
      }
    }

    // 3. Populate collectibles
    for (double x = 450.0; x < levelLength - 1000.0; x += 400.0 + rand.nextDouble() * 250.0) {
      final y = 120.0 + rand.nextDouble() * 260.0;
      final roll = rand.nextDouble();
      final CollectibleType type;
      if (roll < 0.55) {
        type = CollectibleType.energyCrystal;
      } else if (roll < 0.78) {
        type = CollectibleType.heartBoost;
      } else if (roll < 0.92) {
        type = CollectibleType.shieldBoost;
      } else {
        type = CollectibleType.weaponUpgrade;
      }
      collectibles.add(Collectible(position: Offset(x, y), type: type));
    }

    // 4. Populate obstacles
    for (double x = 700.0; x < levelLength - 1100.0; x += 480.0 + rand.nextDouble() * 200.0) {
      final isTop = rand.nextBool();
      final y = isTop ? 75.0 : 425.0;
      obstacles.add(
        Obstacle(
          position: Offset(x, y),
          type: ObstacleType.values[rand.nextInt(ObstacleType.values.length)],
        ),
      );
    }

    // 5. Boss entity at the finale
    boss = BossEntity(
      stageId: world.id,
      name: world.bossName,
      title: world.bossDescription.split('.').first,
      position: Offset(levelLength - 400.0, 250.0),
      maxHealth: 45 + stageId * 15,
      health: 45 + stageId * 15,
      primaryColor: world.primaryColor,
      auraColor: world.secondaryColor,
    );
  }

  // Input Handlers

  void onMoveLeft(bool pressed) => _moveLeft = pressed;
  void onMoveRight(bool pressed) => _moveRight = pressed;
  void onMoveUp(bool pressed) => _moveUp = pressed;
  void onMoveDown(bool pressed) => _moveDown = pressed;

  void onShoot(Offset? mousePosition) {
    _mousePosition = mousePosition;
    if (state != GameState.playing && state != GameState.boss) return;
    if (capsule.weaponCooldown > 0) return;

    final config = WeaponConfig.allWeapons[capsule.currentWeaponIndex];
    capsule.weaponCooldown = config.cooldown;

    // Calculate projectile angle toward mouse if provided, otherwise forward right
    double angle = 0.0;
    if (_mousePosition != null) {
      final screenPlayerX = capsule.position.dx - scrollX;
      final screenPlayerY = capsule.position.dy;
      final delta = _mousePosition! - Offset(screenPlayerX, screenPlayerY);
      angle = math.atan2(delta.dy, delta.dx).clamp(-0.6, 0.6);
    }
    capsule.aimAngle = angle;

    final muzzlePos = capsule.position + Offset(22 * math.cos(angle), 22 * math.sin(angle));
    final velocity = Offset(math.cos(angle) * config.speed, math.sin(angle) * config.speed);

    if (config.type == WeaponType.energyShield) {
      capsule.activateShield(6.0);
      return;
    }

    playerProjectiles.add(
      Projectile(
        position: muzzlePos,
        velocity: velocity,
        type: config.type,
        damage: config.damage,
        radius: config.type == WeaponType.ultimatePulse ? 14.0 : 6.0,
      ),
    );
  }

  void onShield(bool active) {
    if (active) {
      capsule.activateShield(4.0);
    }
  }

  // Resume after answering question dialog
  void resumeFromCheckpoint(bool isAnswerCorrect) {
    if (nextCheckpointIndex < checkpoints.length) {
      checkpoints[nextCheckpointIndex].isCompleted = true;
      nextCheckpointIndex++;
    }

    if (isAnswerCorrect) {
      score += 500;
      xpGained += 50;
      capsule.heal(1);
    } else {
      capsule.takeDamage(1);
    }

    state = GameState.playing;
  }

  // Main Game Loop Update
  void update(double dt) {
    if (state == GameState.paused || state == GameState.checkpoint) return;

    gameTime += dt;

    // 1. Process Player Movement
    const moveSpeed = 280.0;
    double vx = 0.0;
    double vy = 0.0;

    if (_moveLeft) vx -= moveSpeed;
    if (_moveRight) vx += moveSpeed;
    if (_moveUp) vy -= moveSpeed;
    if (_moveDown) vy += moveSpeed;

    capsule.velocity = Offset(
      capsule.velocity.dx * 0.88 + vx * 0.12,
      capsule.velocity.dy * 0.88 + vy * 0.12,
    );
    capsule.update(dt);

    // Clamp player within world & viewport vertical limits
    final minY = 75.0;
    final maxY = viewportHeight - 75.0;
    final clampedY = capsule.position.dy.clamp(minY, maxY);

    // Keep player in bounds relative to camera
    final minX = scrollX + 30.0;
    final maxX = scrollX + viewportWidth - 40.0;
    final clampedX = capsule.position.dx.clamp(minX, maxX);
    capsule.position = Offset(clampedX, clampedY);

    // 2. Camera Scrolling
    if (state == GameState.playing) {
      final desiredScroll = capsule.position.dx - 180.0;
      if (desiredScroll > scrollX) {
        scrollX = desiredScroll;
      }

      // Check if reached boss chamber
      if (scrollX >= levelLength - viewportWidth - 200.0) {
        state = GameState.boss;
        scrollX = levelLength - viewportWidth;
      }
    }

    // 3. Update Checkpoints
    for (int i = 0; i < checkpoints.length; i++) {
      final cp = checkpoints[i];
      cp.update(dt);
      if (!cp.isTriggered && capsule.position.dx >= cp.worldX - 30.0) {
        cp.isTriggered = true;
        nextCheckpointIndex = i;
        state = GameState.checkpoint;
        onCheckpointReached?.call(cp.questionId);
        return;
      }
    }

    // 4. Update Projectiles
    for (final p in playerProjectiles) {
      p.update(dt);
    }
    playerProjectiles.removeWhere(
      (p) => p.isDead || p.position.dx > scrollX + viewportWidth + 100 || p.position.dx < scrollX - 100,
    );

    for (final p in enemyProjectiles) {
      p.update(dt);
    }
    enemyProjectiles.removeWhere(
      (p) => p.isDead || p.position.dx > scrollX + viewportWidth + 100 || p.position.dx < scrollX - 100,
    );

    // 5. Update Enemies
    for (final enemy in enemies) {
      // Only update enemies active near the screen
      if (enemy.position.dx > scrollX - 80 && enemy.position.dx < scrollX + viewportWidth + 200) {
        enemy.update(dt, targetPos: capsule.position, enemyProjectiles: enemyProjectiles);
      }
    }
    enemies.removeWhere((e) => e.isDead);

    // 6. Update Collectibles & Obstacles
    for (final c in collectibles) {
      c.update(dt);
    }
    for (final o in obstacles) {
      o.update(dt);
    }

    // 7. Update Boss
    if (boss != null && (state == GameState.boss || state == GameState.victory)) {
      boss!.update(
        dt,
        capsule.position,
        enemyProjectiles,
        onDropReward: () {
          collectibles.add(
            Collectible(
              position: boss!.position + const Offset(-60, 0),
              type: CollectibleType.weaponUpgrade,
            ),
          );
        },
      );

      if (boss!.isDefeated && state == GameState.boss) {
        onBossDefeated?.call();
        score += 2000;
        xpGained += 250;
        state = GameState.victory;
        capsule.animState = CapsuleAnimationState.victory;
        onLevelComplete?.call();
      }
    }

    // 8. Collisions
    _processCollisions();

    // 9. Check Game Over
    if (capsule.isDead && state != GameState.gameover) {
      state = GameState.gameover;
      onPlayerDied?.call();
    }
  }

  void _processCollisions() {
    final playerBounds = capsule.bounds;

    // Player Projectiles vs Enemies
    for (final proj in playerProjectiles) {
      if (proj.isDead) continue;
      final projCircle = Rect.fromCircle(center: proj.position, radius: proj.radius);

      for (final enemy in enemies) {
        if (enemy.isDead) continue;
        if (projCircle.overlaps(enemy.bounds)) {
          proj.isDead = true;
          enemy.onHit(proj.damage);
          score += 50;
          if (enemy.isDead) {
            score += enemy.scoreValue;
            xpGained += 20;
          }
          break;
        }
      }

      // Player Projectiles vs Boss
      if (boss != null && !boss!.isDefeated && state == GameState.boss) {
        if (projCircle.overlaps(boss!.bounds)) {
          proj.isDead = true;
          boss!.onHit(proj.damage);
          score += 40;
        }
      }
    }

    // Enemy Projectiles vs Player
    for (final proj in enemyProjectiles) {
      if (proj.isDead) continue;
      if (Rect.fromCircle(center: proj.position, radius: proj.radius).overlaps(playerBounds)) {
        proj.isDead = true;
        capsule.takeDamage(proj.damage);
      }
    }

    // Player vs Enemies (Body collision)
    for (final enemy in enemies) {
      if (enemy.isDead) continue;
      if (enemy.bounds.overlaps(playerBounds)) {
        capsule.takeDamage(enemy.damage);
        enemy.onHit(1);
      }
    }

    // Player vs Collectibles
    for (final col in collectibles) {
      if (col.isCollected) continue;
      if (col.bounds.overlaps(playerBounds)) {
        col.isCollected = true;
        _applyCollectible(col.type);
      }
    }
    collectibles.removeWhere((c) => c.isCollected);

    // Player vs Obstacles
    for (final obs in obstacles) {
      if (obs.bounds.overlaps(playerBounds)) {
        capsule.takeDamage(obs.damage);
      }
    }
  }

  void _applyCollectible(CollectibleType type) {
    switch (type) {
      case CollectibleType.heartBoost:
        capsule.heal(1);
        score += 100;
        break;
      case CollectibleType.energyCrystal:
        score += 250;
        xpGained += 15;
        break;
      case CollectibleType.shieldBoost:
        capsule.activateShield(6.0);
        score += 150;
        break;
      case CollectibleType.weaponUpgrade:
        // Cycle / advance weapon
        capsule.currentWeaponIndex = (capsule.currentWeaponIndex + 1) % WeaponConfig.allWeapons.length;
        score += 500;
        xpGained += 50;
        break;
    }
  }

  // Draw complete scene
  void draw(Canvas canvas, Size size) {
    viewportWidth = size.width;
    viewportHeight = size.height;

    // 1. Draw Parallax Background Environment
    final envPainter = EnvironmentPainter(
      scrollX: scrollX,
      stageId: world.id,
      animTime: gameTime,
    );
    envPainter.paint(canvas, size);

    // 2. Draw Obstacles
    for (final obs in obstacles) {
      final screenX = obs.position.dx - scrollX;
      if (screenX > -50 && screenX < size.width + 50) {
        obs.draw(canvas, Offset(screenX, obs.position.dy));
      }
    }

    // 3. Draw Checkpoints
    for (final cp in checkpoints) {
      final screenX = cp.worldX - scrollX;
      if (screenX > -100 && screenX < size.width + 100) {
        cp.draw(canvas, Offset(screenX, 0), size.height);
      }
    }

    // 4. Draw Collectibles
    for (final col in collectibles) {
      final screenX = col.position.dx - scrollX;
      if (screenX > -50 && screenX < size.width + 50) {
        col.draw(canvas, Offset(screenX, col.position.dy));
      }
    }

    // 5. Draw Enemies
    for (final enemy in enemies) {
      final screenX = enemy.position.dx - scrollX;
      if (screenX > -60 && screenX < size.width + 60) {
        enemy.draw(canvas, Offset(screenX, enemy.position.dy));
      }
    }

    // 6. Draw Boss (if in range)
    if (boss != null) {
      final screenX = boss!.position.dx - scrollX;
      if (screenX > -boss!.size && screenX < size.width + boss!.size) {
        boss!.draw(canvas, Offset(screenX, boss!.position.dy), size);
      }
    }

    // 7. Draw Projectiles
    for (final p in playerProjectiles) {
      final screenX = p.position.dx - scrollX;
      p.draw(canvas, Offset(screenX, p.position.dy));
    }
    for (final p in enemyProjectiles) {
      final screenX = p.position.dx - scrollX;
      p.draw(canvas, Offset(screenX, p.position.dy));
    }

    // 8. Draw Player Capsule
    final screenPlayerX = capsule.position.dx - scrollX;
    capsule.draw(canvas, Offset(screenPlayerX, capsule.position.dy));
  }
}
