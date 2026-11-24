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

  double totalDistance = 5000.0;
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
    // Distance scales cleanly with stage
    totalDistance = 4400.0 + (level % 6) * 200.0;

    tunnel = TunnelGeometry(
      levelLength: totalDistance,
      world: world,
      baseCeiling: 70.0,
      baseFloor: 420.0,
      viewportHeight: viewportHeight,
    );

    player = CapsulePlayer(
      position: Offset(120.0, viewportHeight * 0.5),
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
    for (int i = 0; i < 40; i++) {
      backgroundCells.add(
        BackgroundErythrocyte(
          position: Offset(rand.nextDouble() * totalDistance, rand.nextDouble() * 600),
          depth: 0.15 + rand.nextDouble() * 0.65,
          radius: 12.0 + rand.nextDouble() * 22.0,
          wobblePhase: rand.nextDouble() * math.pi * 2,
          rotation: rand.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  void _generateCheckpoints() {
    checkpoints.clear();

    if (level >= 1 && level <= 6) {
      // Questions officielles du nouveau PDF pour ce stage
      final stageQuestions = allGastroQuestions.where((q) => q.worldId == level).toList();
      if (stageQuestions.isEmpty) return;

      // La dernière question sera le duel final du Boss !
      // Toutes les questions précédentes sont réparties le long du parcours.
      final checkpointQuestions = stageQuestions.length > 1
          ? stageQuestions.sublist(0, stageQuestions.length - 1)
          : stageQuestions;

      final count = checkpointQuestions.length;
      for (int i = 0; i < count; i++) {
        final fraction = 0.22 + (0.54 / math.max(1, count)) * i;
        checkpoints.add(
          ArcadeCheckpoint(
            index: i + 1,
            worldX: totalDistance * fraction,
            question: checkpointQuestions[i],
            isRevision: false,
          ),
        );
      }
    } else {
      // =====================================================================
      // STAGE 7 : MODE DE RÉVISION INTELLIGENT
      // Reprend EXCLUSIVEMENT les questions que l'étudiant a ratées !
      // =====================================================================
      final failedIds = progress.revisionQueue.toList();
      final List<GastroQuestion> revQuestions = [];

      for (final id in failedIds) {
        final q = allGastroQuestions.firstWhere(
          (item) => item.id == id,
          orElse: () => allGastroQuestions.first,
        );
        if (!revQuestions.contains(q)) {
          revQuestions.add(q);
        }
      }

      if (revQuestions.isNotEmpty) {
        final count = revQuestions.length;
        for (int i = 0; i < count; i++) {
          final fraction = 0.18 + (0.60 / math.max(1, count)) * i;
          checkpoints.add(
            ArcadeCheckpoint(
              index: i + 1,
              worldX: totalDistance * fraction,
              question: revQuestions[i],
              isRevision: true,
            ),
          );
        }
      } else {
        // MAÎTRISE PARFAITE : L'étudiant n'a commis AUCUNE erreur pendant les 6 premiers stages !
        // 3 Checkpoints de consécration et Boss suprême
        final masterQuestions = [allGastroQuestions[3], allGastroQuestions[11], allGastroQuestions[26]];
        for (int i = 0; i < masterQuestions.length; i++) {
          checkpoints.add(
            ArcadeCheckpoint(
              index: i + 1,
              worldX: totalDistance * (0.28 + i * 0.24),
              question: masterQuestions[i],
              isRevision: false,
            ),
          );
        }
      }
    }
  }

  void _generateCollectibles() {
    collectibles.clear();
    final rand = math.Random(level * 333);
    int colId = 1;

    for (double x = 280.0; x < totalDistance - 700.0; x += 120.0 + rand.nextDouble() * 80.0) {
      final ceilY = tunnel.getCeilingY(x, 0.0);
      final floorY = tunnel.getFloorY(x, 0.0);
      final midY = (ceilY + floorY) / 2;

      // Group in clusters of 2-3
      final clusterSize = 1 + rand.nextInt(3);
      for (int c = 0; c < clusterSize; c++) {
        final roll = rand.nextDouble();
        CollectibleType type;
        int xp = 25;
        int pts = 50;

        if (roll < 0.40) {
          type = CollectibleType.cellBubble;
          xp = 20;
          pts = 40;
        } else if (roll < 0.72) {
          type = CollectibleType.atpCrystal;
          xp = 35;
          pts = 75;
        } else if (roll < 0.88) {
          type = CollectibleType.vitaminCapsule;
          xp = 40;
          pts = 90;
        } else if (roll < 0.94) {
          type = CollectibleType.heartBoost;
          xp = 60;
          pts = 120;
        } else if (roll < 0.98) {
          type = CollectibleType.shieldBoost;
          xp = 80;
          pts = 150;
        } else {
          type = CollectibleType.weaponUpgrade;
          xp = 100;
          pts = 200;
        }

        final itemY = midY + (rand.nextDouble() - 0.5) * (floorY - ceilY - 80.0);
        collectibles.add(
          ArcadeCollectible(
            id: colId++,
            position: Offset(x + c * 28.0, itemY.clamp(ceilY + 20.0, floorY - 20.0)),
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
    final rand = math.Random(level * 444);
    int obsId = 1;

    for (double x = 450.0; x < totalDistance - 750.0; x += 190.0 + rand.nextDouble() * 120.0) {
      bool onCheckpoint = checkpoints.any((cp) => (cp.worldX - x).abs() < 140.0);
      if (onCheckpoint) continue;

      final ceilY = tunnel.getCeilingY(x, 0.0);
      final floorY = tunnel.getFloorY(x, 0.0);

      final roll = rand.nextDouble();
      if (roll < 0.45) {
        // Monstre vert à dents sur le sol
        obstacles.add(
          ArcadeObstacle(
            id: obsId++,
            position: Offset(x, floorY - 28.0),
            initialY: floorY - 28.0,
            type: ObstacleType.toothyMicrobe,
            radius: 26.0,
            animPhase: rand.nextDouble() * math.pi * 2,
          ),
        );
      } else if (roll < 0.75) {
        // Virus spirochète flottant au milieu
        final midY = (ceilY + floorY) / 2 + (rand.nextDouble() - 0.5) * 50.0;
        obstacles.add(
          ArcadeObstacle(
            id: obsId++,
            position: Offset(x, midY),
            initialY: midY,
            type: ObstacleType.spikyVirus,
            radius: 20.0,
            animPhase: rand.nextDouble() * math.pi * 2,
          ),
        );
      } else {
        // Gouttelette de suc gastrique acide tombant du plafond
        obstacles.add(
          ArcadeObstacle(
            id: obsId++,
            position: Offset(x, ceilY + 16.0),
            initialY: ceilY + 16.0,
            type: ObstacleType.acidDroplet,
            radius: 16.0,
            velocityY: 85.0 + rand.nextDouble() * 55.0,
            animPhase: rand.nextDouble() * math.pi * 2,
          ),
        );
      }
    }
  }

  void _generateEnemies() {
    enemies.clear();
    final rand = math.Random(level * 555);
    int enemyId = 1;

    for (double x = 500.0; x < totalDistance - 800.0; x += 220.0 + rand.nextDouble() * 140.0) {
      bool onCheckpoint = checkpoints.any((cp) => (cp.worldX - x).abs() < 150.0);
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

      if (roll < 0.40) {
        eType = EnemyType.helicoGrub;
        hp = 2 + (level / 4).floor();
        radius = 20.0;
        score = 140;
        xp = 30;
      } else if (roll < 0.72) {
        eType = EnemyType.cytokineBlob;
        hp = 3 + (level / 5).floor();
        radius = 22.0;
        score = 180;
        xp = 35;
      } else if (roll < 0.88) {
        eType = EnemyType.acidSentry;
        hp = 4 + (level / 4).floor();
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

      final enemyY = midY + (rand.nextDouble() - 0.5) * 60.0;
      enemies.add(
        ArcadeEnemy(
          id: enemyId++,
          position: Offset(x, enemyY.clamp(ceilY + 28.0, floorY - 28.0)),
          velocity: Offset(-45.0 - rand.nextDouble() * 25.0, 0),
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
    List<GastroQuestion> challengeQuestions;

    if (level >= 1 && level <= 6) {
      final stageQuestions = allGastroQuestions.where((q) => q.worldId == level).toList();
      // Le boss teste la question d'apogée du stage
      challengeQuestions = stageQuestions.isNotEmpty ? [stageQuestions.last] : [allGastroQuestions.first];
    } else {
      // Stage 7 : Le boss teste les révisions ou la synthèse finale
      if (progress.revisionQueue.isNotEmpty) {
        challengeQuestions = progress.revisionQueue
            .map((id) => allGastroQuestions.firstWhere((q) => q.id == id, orElse: () => allGastroQuestions.first))
            .take(3)
            .toList();
      } else {
        challengeQuestions = [allGastroQuestions[3], allGastroQuestions[11], allGastroQuestions[26]];
      }
    }

    boss = ArcadeBoss(
      name: world.boss.name,
      title: world.boss.title,
      auraColor: world.boss.auraColor,
      icon: world.boss.icon,
      position: Offset(totalDistance - 350.0, (tunnel.baseCeiling + tunnel.baseFloor) / 2),
      challengeQuestions: challengeQuestions,
      maxHp: challengeQuestions.length,
      currentHp: challengeQuestions.length,
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

  /// Responsive Viewport Adapter : Recalcule dynamiquement les parois du tunnel et positions
  void setViewport(double width, double height) {
    if ((viewportWidth - width).abs() > 1.0 || (viewportHeight - height).abs() > 1.0) {
      viewportWidth = width;
      viewportHeight = height;
      tunnel.updateViewport(width, height);

      // Re-centrage doux du joueur pour qu'il soit toujours parfaitement visible
      final ceilY = tunnel.getCeilingY(player.position.dx, gameTime) + player.radius + 8.0;
      final floorY = tunnel.getFloorY(player.position.dx, gameTime) - player.radius - 8.0;
      if (player.position.dy < ceilY || player.position.dy > floorY) {
        player.position = Offset(player.position.dx, (ceilY + floorY) / 2);
      }
    }
  }

  // =========================================================================
  // COMMANDES & SYSTÈME D'INPUT PROFESSIONNEL (JOYSTICK + WASD / SOURIS)
  // =========================================================================

  /// Déplacement analogique fluide continu via Joystick ou Clavier
  void setMoveVector(Offset vector) {
    // Zone morte de 0.12 pour éliminer tout tremblement
    if (vector.distance < 0.12) {
      player.moveInput = Offset.zero;
      player.isThrusting = false;
      player.isMovingDown = false;
      player.isMovingLeft = false;
      player.isMovingRight = false;
    } else {
      player.moveInput = vector;
      player.isThrusting = vector.dy < -0.25;
      player.isMovingDown = vector.dy > 0.25;
      player.isMovingLeft = vector.dx < -0.25;
      player.isMovingRight = vector.dx > 0.25;
    }
  }

  /// Déplacement au clavier : met à jour le vecteur omnidirectionnel
  void updateKeyboardDirection([
    bool up = false,
    bool down = false,
    bool left = false,
    bool right = false,
  ]) {
    double dx = 0.0;
    double dy = 0.0;
    if (up) dy -= 1.0;
    if (down) dy += 1.0;
    if (left) dx -= 1.0;
    if (right) dx += 1.0;

    final vec = Offset(dx, dy);
    if (vec.distance > 0.01) {
      setMoveVector(vec / vec.distance);
    } else {
      setMoveVector(Offset.zero);
    }
  }

  void setThrust(bool value) {
    player.isThrusting = value;
    _recalculateDirectionalBooleans();
  }

  void setMoveLeft(bool value) {
    player.isMovingLeft = value;
    _recalculateDirectionalBooleans();
  }

  void setMoveRight(bool value) {
    player.isMovingRight = value;
    _recalculateDirectionalBooleans();
  }

  void setMoveDown(bool value) {
    player.isMovingDown = value;
    _recalculateDirectionalBooleans();
  }

  void _recalculateDirectionalBooleans() {
    double dx = 0.0;
    double dy = 0.0;
    if (player.isThrusting) dy -= 1.0;
    if (player.isMovingDown) dy += 1.0;
    if (player.isMovingLeft) dx -= 1.0;
    if (player.isMovingRight) dx += 1.0;

    final vec = Offset(dx, dy);
    player.moveInput = vec.distance > 0.01 ? (vec / vec.distance) : Offset.zero;
  }

  /// Tir continu (hold to shoot)
  void setShooting(bool isShooting, [Offset? targetPos]) {
    player.isShooting = isShooting;
    if (isShooting) {
      shoot(targetPos);
    }
  }

  void shoot([Offset? targetScreenPos]) {
    if (state != GameState.playing && state != GameState.bossFight) return;
    if (player.shootCooldownTimer > 0) return;

    final config = equippedWeaponConfig;
    player.shootCooldownTimer = config.cooldownSeconds;

    final baseSpeed = config.projectileSpeed;
    final bulletDamage = config.damage;
    final color = config.glowColor;

    Offset shotDir = const Offset(1.0, 0.0);
    if (targetScreenPos != null) {
      final playerScreenPos = Offset(player.position.dx - cameraX, player.position.dy);
      final delta = targetScreenPos - playerScreenPos;
      if (delta.distance > 10.0) {
        shotDir = delta / delta.distance;
      }
    }

    final normalDir = Offset(-shotDir.dy, shotDir.dx);

    if (config.type == WeaponType.doubleLaser || player.hasDoubleShot) {
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + normalDir * -8.0 + shotDir * 24.0,
          velocity: shotDir * baseSpeed,
          damage: bulletDamage,
          color: color,
          radius: 5.5,
          weaponType: config.type,
        ),
      );
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + normalDir * 8.0 + shotDir * 24.0,
          velocity: shotDir * baseSpeed,
          damage: bulletDamage,
          color: color,
          radius: 5.5,
          weaponType: config.type,
        ),
      );
    } else if (config.type == WeaponType.plasmaShot) {
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + shotDir * 26.0,
          velocity: shotDir * baseSpeed,
          damage: bulletDamage,
          color: color,
          radius: 9.0,
          weaponType: config.type,
        ),
      );
    } else if (config.type == WeaponType.electricWave) {
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + shotDir * 24.0,
          velocity: shotDir * baseSpeed,
          damage: bulletDamage,
          color: color,
          radius: 6.5,
          weaponType: config.type,
        ),
      );
    } else if (config.type == WeaponType.ultimatePulse) {
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + shotDir * 26.0,
          velocity: (shotDir * baseSpeed) + (normalDir * -55.0),
          damage: bulletDamage,
          color: color,
          radius: 8.0,
          weaponType: config.type,
        ),
      );
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + shotDir * 28.0,
          velocity: shotDir * (baseSpeed + 40.0),
          damage: bulletDamage,
          color: color,
          radius: 8.5,
          weaponType: config.type,
        ),
      );
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + shotDir * 26.0,
          velocity: (shotDir * baseSpeed) + (normalDir * 55.0),
          damage: bulletDamage,
          color: color,
          radius: 8.0,
          weaponType: config.type,
        ),
      );
    } else {
      // Laser Médical standard
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + shotDir * 24.0,
          velocity: shotDir * baseSpeed,
          damage: bulletDamage,
          color: color,
          radius: 5.0,
          weaponType: config.type,
        ),
      );
    }

    audio.playBossLaser();
    _emitMuzzleParticles(player.position + shotDir * 24.0, color);
  }

  void activateShield() {
    if (state != GameState.playing && state != GameState.bossFight) return;
    player.activateShield(5.0);
    audio.playTargetLock();
    _addFloatingText('BOUCLIER ACTIF (5s) !', player.position + const Offset(0, -35), const Color(0xFF00E5FF));
    notifyListeners();
  }

  /// Compétence Spéciale : Impulsion Électromagnétique Médicale (EMP)
  void triggerSpecialSkill() {
    if (state != GameState.playing && state != GameState.bossFight) return;
    if (!player.canUseSpecialSkill) return;

    player.triggerSpecialSkill();
    audio.playBossLaser();

    // 1. Désintégration immédiate de tous les projectiles ennemis
    for (final ep in enemyProjectiles) {
      _emitHitSparks(ep.position);
    }
    enemyProjectiles.clear();

    // 2. Dégâts de zone majeurs aux germes et bactéries environnants
    for (final enemy in enemies) {
      if (enemy.isDead) continue;
      final dist = (enemy.position - player.position).distance;
      if (dist < 340.0) {
        enemy.takeDamage(6);
        _emitHitSparks(enemy.position);
        score += 150;
        earnedXp += 30;
      }
    }

    // 3. Onde de choc visuelle et particules d'énergie
    screenShake = 1.2;
    for (int i = 0; i < 32; i++) {
      final angle = (i / 32.0) * math.pi * 2;
      particles.add(
        ArcadeParticle(
          position: player.position,
          velocity: Offset(math.cos(angle) * 350.0, math.sin(angle) * 350.0),
          color: const Color(0xFF00E5FF),
          size: 5.5,
          life: 0.65,
          maxLife: 0.65,
        ),
      );
    }

    _addFloatingText('ONDE EMP DE NETTOYAGE !', player.position + const Offset(0, -45), const Color(0xFF00E5FF));
    notifyListeners();
  }

  /// 60 FPS Game Loop
  void update(double dt) {
    if (state != GameState.playing && state != GameState.bossFight) {
      return;
    }

    gameTime += dt;
    if (screenShake > 0) {
      screenShake = math.max(0.0, screenShake - dt * 3.5);
    }

    // Décompte de la compétence spéciale
    if (player.specialSkillCooldown > 0) {
      player.specialSkillCooldown = math.max(0.0, player.specialSkillCooldown - dt);
    }

    // Tir continu si la commande est maintenue
    if (player.isShooting && player.shootCooldownTimer <= 0) {
      shoot();
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
    // Décrémentation des timers
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

    // Vitesse maximale selon le mode (boosté ou standard) et la sensibilité
    final double maxSpeed = (player.isBoosted ? 360.0 : 250.0) * player.joystickSensitivity;

    // Vitesse cible déduite du vecteur d'entrée
    double targetVx = player.moveInput.dx * maxSpeed;
    double targetVy = player.moveInput.dy * maxSpeed;

    if (state == GameState.bossFight) {
      // Arène du boss : liberté totale 360°
    } else {
      // En exploration : propulsion vers l'avant par défaut si le joueur ne tire pas vers l'arrière
      if (player.moveInput.dx >= -0.15) {
        targetVx = math.max(targetVx, player.isBoosted ? 260.0 : 140.0);
      }
    }

    // Accélération et décélération douces (frottement biologique sans plongeon brusque)
    double currentVx = player.velocity.dx;
    double currentVy = player.velocity.dy;

    currentVx += (targetVx - currentVx) * 8.5 * dt;
    currentVy += (targetVy - currentVy) * 9.5 * dt;

    player.velocity = Offset(currentVx, currentVy);
    player.position += player.velocity * dt;

    // Calcul de l'inclinaison de la capsule selon le déplacement vertical
    final targetAngle = (player.velocity.dy / 300.0).clamp(-0.40, 0.40);
    player.angle += (targetAngle - player.angle) * 8.0 * dt;

    // Intensité de la flamme du réacteur
    final currentSpeed = player.velocity.distance;
    final targetFlame = (currentSpeed / 240.0).clamp(0.2, 1.0);
    player.flameIntensity += (targetFlame - player.flameIntensity) * 7.0 * dt;

    // Enregistrement de la traînée ionique (garder les 10 dernières positions)
    player.trailPositions.insert(0, player.position);
    if (player.trailPositions.length > 10) {
      player.trailPositions.removeLast();
    }

    // Particules de propulsion
    if (player.flameIntensity > 0.4 || player.isThrusting) {
      _emitThrusterParticles();
    }

    // Collisions avec les parois du tunnel avec déflexion douce
    final ceilY = tunnel.getCeilingY(player.position.dx, gameTime) + player.radius + 6.0;
    final floorY = tunnel.getFloorY(player.position.dx, gameTime) - player.radius - 6.0;

    if (player.position.dy < ceilY) {
      player.position = Offset(player.position.dx, ceilY);
      player.velocity = Offset(player.velocity.dx * 0.85, 20.0);
    } else if (player.position.dy > floorY) {
      player.position = Offset(player.position.dx, floorY);
      player.velocity = Offset(player.velocity.dx * 0.85, -20.0);
    }
  }

  void _updateCamera() {
    if (state == GameState.bossFight) {
      // Arène de boss : caméra stabilisée
      final targetX = (totalDistance - viewportWidth * 0.70).clamp(0.0, totalDistance);
      cameraX += (targetX - cameraX) * 0.06;
    } else {
      // La capsule est maintenue à environ 33 % de l'écran depuis la gauche
      // Cela dégage 67 % du champ de vision devant elle et évite que le joystick ne la cache !
      final targetCameraX = player.position.dx - viewportWidth * 0.33;
      cameraX = math.max(0.0, targetCameraX);
    }
  }

  void _updateProjectiles(double dt) {
    for (int i = playerProjectiles.length - 1; i >= 0; i--) {
      final p = playerProjectiles[i];
      p.update(dt);
      if (p.isDead ||
          p.position.dx > cameraX + viewportWidth + 150.0 ||
          p.position.dx < cameraX - 100.0) {
        playerProjectiles.removeAt(i);
      }
    }

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
        double newY = obs.position.dy + obs.velocityY * dt;
        final floorY = tunnel.getFloorY(obs.position.dx, gameTime);
        if (newY >= floorY - 10.0) {
          _emitSplashParticles(obs.position, const Color(0xFF84CC16));
          newY = tunnel.getCeilingY(obs.position.dx, gameTime) + 14.0;
        }
        obs.position = Offset(obs.position.dx, newY);
      } else if (obs.type == ObstacleType.spikyVirus) {
        final floatY = obs.initialY + math.sin(obs.animPhase) * 20.0;
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

    final hoverY = (tunnel.baseCeiling + tunnel.baseFloor) / 2 + math.sin(boss.animPhase * 1.5) * 32.0;
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
          _addFloatingText('BOUCLIER ACTIF (5s) !', item.position, const Color(0xFF00E5FF));
        } else if (item.type == CollectibleType.weaponUpgrade) {
          player.activateDoubleShot(8.0);
          _addFloatingText('SUPER CADENCE (8s) !', item.position, const Color(0xFF38BDF8));
        } else {
          _addFloatingText('+${item.scoreValue} XP', item.position, const Color(0xFFFFD166));
        }

        _emitCollectParticles(item.position, item.type);
      }
    }

    // 2. Projectiles du joueur contre ennemis et Boss
    for (int pIdx = playerProjectiles.length - 1; pIdx >= 0; pIdx--) {
      final p = playerProjectiles[pIdx];
      bool bulletHit = false;

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

            if (math.Random().nextDouble() < 0.28) {
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

    // 3. Projectiles ennemis contre le joueur
    for (int epIdx = enemyProjectiles.length - 1; epIdx >= 0; epIdx--) {
      final ep = enemyProjectiles[epIdx];
      final dist = (player.position - ep.position).distance;
      if (dist < player.radius + ep.radius) {
        if (player.isShieldActive) {
          _emitShieldDeflect(player.position);
          _addFloatingText('DÉVIÉ !', player.position + const Offset(0, -25), const Color(0xFF00E5FF));
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

    // 4. Contact physique direct ennemis
    for (final enemy in enemies) {
      if (enemy.isDead) continue;
      final dist = (player.position - enemy.position).distance;
      if (dist < player.radius + enemy.radius) {
        if (player.isShieldActive) {
          _emitShieldDeflect(player.position);
          enemy.takeDamage(2);
          _addFloatingText('CHOC BOUCLIER !', enemy.position + const Offset(0, -20), const Color(0xFF00E5FF));
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

    // 6. Déclenchement des Checkpoints pédagogiques
    if (state == GameState.playing) {
      for (final cp in checkpoints) {
        if (!cp.isTriggered && player.position.dx >= cp.worldX - 25.0) {
          cp.isTriggered = true;
          activeCheckpoint = cp;
          state = GameState.checkpoint;
          audio.playTargetLock();
          break;
        }
      }
    }

    // 7. Entrée dans l'arène du Boss
    if (state == GameState.playing && player.position.dx >= totalDistance - 750.0) {
      state = GameState.bossFight;
      audio.playPagerBeep();
      _addFloatingText('ALERTE BOSS : ${boss.name.toUpperCase()} !', player.position + const Offset(40, -40), Colors.amberAccent);
    }
  }

  void _onPlayerZeroHearts() {
    // Récupération pédagogique : confère 1 cœur et 3s d'invulnérabilité pour ne jamais bloquer l'étudiant
    player.hearts = 1;
    player.invulnerableTimer = 3.0;
    _addFloatingText('RÉANIMATION D\'URGENCE !', player.position + const Offset(0, -35), const Color(0xFF38BDF8));
  }

  /// Validation d'un Checkpoint pédagogique
  void answerCheckpoint({required int selectedOptionIndex, required bool isCorrect}) {
    if (activeCheckpoint == null) return;

    final cp = activeCheckpoint!;
    cp.isCompleted = true;
    cp.isAnswerCorrect = isCorrect;

    // Enregistrement officiel de la réponse
    progress.recordQuestionAnswer(
      questionId: cp.question.id,
      selectedOptionIndex: selectedOptionIndex,
      isCorrect: isCorrect,
      earnedXp: isCorrect ? 100 : 30,
    );

    if (isCorrect) {
      // Si c'était une question de révision, elle est validée et retirée de la file d'attente !
      if (cp.isRevision) {
        progress.revisionQueue.remove(cp.question.id);
        progress.masteredQuestions.add(cp.question.id);
        _addFloatingText('NOTION MAÎTRISÉE ! +150 XP', player.position + const Offset(0, -45), const Color(0xFFFFD700));
      }
      earnedXp += 100;
      score += 300;
      combo += 2;
      player.boostTimer = 3.5;
      audio.playCorrect();
      _addFloatingText('EXCELLENT ! +100 XP', player.position + const Offset(0, -30), const Color(0xFF34D399));
    } else {
      player.takeDamage();
      combo = 0;
      audio.playWrong();
      _addFloatingText('RÉVISION ENREGISTRÉE', player.position + const Offset(0, -30), const Color(0xFFF87171));
    }

    activeCheckpoint = null;
    state = GameState.playing;
    notifyListeners();
  }

  /// Défi final du Boss
  void answerBossQuestion({required int questionId, required int selectedOptionIndex, required bool isCorrect}) {
    progress.recordQuestionAnswer(
      questionId: questionId,
      selectedOptionIndex: selectedOptionIndex,
      isCorrect: isCorrect,
      earnedXp: isCorrect ? 120 : 30,
    );

    if (isCorrect) {
      if (level == 7) {
        progress.revisionQueue.remove(questionId);
        progress.masteredQuestions.add(questionId);
      }
      boss.takeDamage();
      audio.playBossLaser();
      score += 400;
      earnedXp += 150;
      _emitBossLaser();
      _addFloatingText('CRITIQUE SUR LE BOSS ! -1 HP', player.position + const Offset(0, -30), const Color(0xFF38BDF8));
      if (boss.isDefeated) {
        _onBossDefeated();
      }
    } else {
      player.takeDamage();
      audio.playWrong();
      _addFloatingText('RIPOSTE DU BOSS !', player.position + const Offset(0, -30), const Color(0xFFEF4444));
    }

    notifyListeners();
  }

  void _onBossDefeated() {
    isBossDefeated = true;
    state = GameState.victory;
    score += 1500;
    earnedXp += 400;
    audio.playVictory();

    progress.completeLevel(level, 3, score, crystalsCollected);
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
        position: player.position + Offset(-player.radius - 6.0, (rand.nextDouble() - 0.5) * 8.0),
        velocity: Offset(-190.0 - rand.nextDouble() * 70.0, (rand.nextDouble() - 0.5) * 40.0),
        color: rand.nextBool() ? const Color(0xFF00E5FF) : const Color(0xFFFF9100),
        size: 3.5 + rand.nextDouble() * 4.0,
        maxLife: 0.35,
      ),
    );
  }

  void _emitCollectParticles(Offset pos, CollectibleType type) {
    final rand = math.Random();
    Color pCol = const Color(0xFFFFD166);
    if (type == CollectibleType.cellBubble) pCol = const Color(0xFFFB7185);
    if (type == CollectibleType.heartBoost) pCol = const Color(0xFF34D399);
    if (type == CollectibleType.shieldBoost) pCol = const Color(0xFF00E5FF);

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
    final start = player.position;
    final end = boss.position;
    const count = 25;
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
          color: const Color(0xFF00E5FF),
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
