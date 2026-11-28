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
  bossIntro,
  bossFight,
  bossDefeatAnim,
  victory,
  gameOver,
}

class ArcadeGameController extends ChangeNotifier {
  final int level;
  final GameProgress progress;
  final int? revisionNumber;
  final bool isBonusRevisionChallenge;
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
  final List<DefeatedEnemyEffect> defeatedEnemies = [];
  final Map<int, bool> revisionAnswersInStage = {};

  WeaponConfig get equippedWeaponConfig => WeaponConfig.getByName(progress.equippedWeapon);

  bool get isRevisionStage => revisionNumber != null;

  /// Smooth progressive level pace from Stage 1 (1.0x) to Stage 7 (1.38x)
  double get stagePaceMultiplier {
    return (1.0 + (level.clamp(1, 7) - 1) * 0.063).clamp(1.0, 1.38);
  }

  double get _playerAgilityMultiplier => (1.0 + (level.clamp(1, 7) - 1) * 0.05).clamp(1.0, 1.35);
  double get _obstacleDifficulty => ((level.clamp(1, 7) - 1) / 6.0).clamp(0.0, 1.0);

  GameState state = GameState.ready;
  double cameraX = 0.0;
  double viewportWidth = 800.0;
  double viewportHeight = 500.0;

  double totalDistance = 7200.0;
  int score = 0;
  int combo = 0;
  int highestCombo = 0;
  int earnedXp = 0;
  int crystalsCollected = 0;
  double gameTime = 0.0;
  double screenShake = 0.0;

  // Educational & Boss Fight Progression Metrics
  int correctAnswersInStage = 0;
  int wrongAnswersInStage = 0;
  int revivesCount = 0;
  int lastStarsEarned = 3;
  String? newlyUnlockedWeapon;

  // Smooth Portal Entry Transition (prevents sudden combat interruption)
  ArcadeCheckpoint? _pendingCheckpoint;
  double checkpointWarpTimer = 0.0;
  bool get isEnteringCheckpoint => _pendingCheckpoint != null;

  // Boss Battle State Timers
  double bossIntroTimer = 0.0;
  double bossDefeatTimer = 0.0;
  double _bossDefeatBurstTick = 0.0;
  bool _bossPurifyWaveDone = false;
  double bossArenaMix = 0.0; // 0.0 exploration -> 1.0 boss chamber
  double arenaSupportTimer = 4.0;
  double specialWaveFlashTimer = 0.0;
  bool _midEvent1Triggered = false;
  bool _midEvent2Triggered = false;
  int _bossAttackIndex = 0;
  int _nextDynamicId = 5000;

  ArcadeCheckpoint? activeCheckpoint;
  bool isBossDefeated = false;

  ArcadeGameController({
    required this.level,
    required this.progress,
    this.revisionNumber,
    this.isBonusRevisionChallenge = false,
  }) {
    world = revisionNumber != null
        ? GastroWorld.revisionWorld
        : GastroWorld.getWorldForLevel(level);
    _initLevel();
  }

  void _initLevel() {
    _generateCheckpoints();

    // Generous corridor length so intervals between questions allow dynamic combat & breathing room
    final cpCount = math.max(3, checkpoints.length);
    totalDistance = math.max(5800.0, 2600.0 + cpCount * 1050.0);

    tunnel = TunnelGeometry(
      levelLength: totalDistance,
      world: world,
      baseCeiling: 70.0,
      baseFloor: 420.0,
      viewportHeight: viewportHeight,
    );

    final startWeapon = equippedWeaponConfig;
    player = CapsulePlayer(
      position: Offset(140.0, viewportHeight * 0.5),
      hearts: 3,
      maxHearts: 3,
      weaponType: startWeapon.type,
    );

    playerProjectiles.clear();
    enemyProjectiles.clear();

    // Recalculate checkpoint worldX positions against exact totalDistance
    _distributeCheckpointPositions();
    _generateBackgroundErythrocytes();
    _generateCollectibles();
    _generateObstacles();
    _generateEnemies();
    _generateBoss();
  }

  void _generateCheckpoints() {
    checkpoints.clear();

    if (revisionNumber != null) {
      if (!isBonusRevisionChallenge) {
        // One special Revision Stage after Stage 7: strictly contains ONLY
        // the questions missed across Stages 1-7 (never repeating already-right ones).
        final mistakeIds = progress.getMistakesForCycle(1);
        for (int i = 0; i < mistakeIds.length; i++) {
          final q = allGastroQuestions.firstWhere(
            (item) => item.id == mistakeIds[i],
            orElse: () => allGastroQuestions.first,
          );
          if (!checkpoints.any((cp) => cp.question.id == q.id)) {
            checkpoints.add(
              ArcadeCheckpoint(
                index: checkpoints.length + 1,
                worldX: 960.0 + checkpoints.length * 1050.0,
                question: q,
                isRevision: true,
              ),
            );
          }
        }
      } else {
        final bonusQuestions = <GastroQuestion>[
          allGastroQuestions[3],
          allGastroQuestions[11],
          allGastroQuestions[26],
        ];
        for (int i = 0; i < bonusQuestions.length; i++) {
          checkpoints.add(
            ArcadeCheckpoint(
              index: i + 1,
              worldX: 960.0 + i * 1100.0,
              question: bonusQuestions[i],
              isRevision: true,
            ),
          );
        }
      }
      return;
    }

    final int sectorId = level.clamp(1, 7);
    if (sectorId >= 1 && sectorId <= 6) {
      final stageQuestions =
          allGastroQuestions.where((q) => q.worldId == sectorId).toList();
      for (int i = 0; i < stageQuestions.length; i++) {
        checkpoints.add(
          ArcadeCheckpoint(
            index: i + 1,
            worldX: 960.0 + i * 1050.0,
            question: stageQuestions[i],
            isRevision: false,
          ),
        );
      }
    } else {
      // Stage 7: Final Sanctuary Synthesis (prioritizes unanswered/missed cases first before defaults)
      final unmastered = allGastroQuestions
          .where((q) => progress.questionsAnswered[q.id] != true)
          .take(3)
          .toList();
      final masterQuestions = unmastered.isNotEmpty
          ? unmastered
          : <GastroQuestion>[
              allGastroQuestions[3],
              allGastroQuestions[11],
              allGastroQuestions[26],
            ];
      for (int i = 0; i < masterQuestions.length; i++) {
        checkpoints.add(
          ArcadeCheckpoint(
            index: i + 1,
            worldX: 960.0 + i * 1100.0,
            question: masterQuestions[i],
            isRevision: false,
          ),
        );
      }
    }
  }

  void _distributeCheckpointPositions() {
    final count = checkpoints.length;
    if (count == 0) return;
    const double startX = 980.0;
    final double endX = math.max(startX + 600.0, totalDistance - 1550.0);
    final double span = math.max(600.0, endX - startX);
    for (int i = 0; i < count; i++) {
      final t = count == 1 ? 0.5 : (i / (count - 1));
      final updated = ArcadeCheckpoint(
        index: checkpoints[i].index,
        worldX: startX + span * t,
        question: checkpoints[i].question,
        isRevision: checkpoints[i].isRevision,
      );
      checkpoints[i] = updated;
    }
  }

  void _generateBackgroundErythrocytes() {
    final rand = math.Random(level * 777);
    backgroundCells.clear();
    for (int i = 0; i < 14; i++) {
      backgroundCells.add(
        BackgroundErythrocyte(
          position: Offset(rand.nextDouble() * totalDistance, 80.0 + rand.nextDouble() * 360.0),
          depth: 0.2 + rand.nextDouble() * 0.45,
          radius: 10.0 + rand.nextDouble() * 14.0,
          wobblePhase: rand.nextDouble() * math.pi * 2,
          rotation: rand.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  void _generateCollectibles() {
    collectibles.clear();
    final rand = math.Random(level * 333);
    int colId = 1;

    for (double x = 300.0; x < totalDistance - 1050.0; x += 210.0 + rand.nextDouble() * 95.0) {
      if (checkpoints.any((cp) => (cp.worldX - x).abs() < 130.0)) continue;

      final ceilY = tunnel.getCeilingY(x, 0.0);
      final floorY = tunnel.getFloorY(x, 0.0);
      final midY = (ceilY + floorY) / 2;

      final roll = rand.nextDouble();
      CollectibleType type;
      int xp = 25;
      int pts = 50;

      if (roll < 0.34) {
        type = CollectibleType.cellBubble;
        xp = 25;
        pts = 45;
      } else if (roll < 0.66) {
        type = CollectibleType.atpCrystal;
        xp = 40;
        pts = 80;
      } else if (roll < 0.82) {
        type = CollectibleType.vitaminCapsule;
        xp = 45;
        pts = 95;
      } else if (roll < 0.91) {
        type = CollectibleType.heartBoost;
        xp = 60;
        pts = 120;
      } else if (roll < 0.96) {
        type = CollectibleType.shieldBoost;
        xp = 80;
        pts = 150;
      } else {
        type = CollectibleType.weaponUpgrade;
        xp = 100;
        pts = 200;
      }

      final itemY = midY + (rand.nextDouble() - 0.5) * math.max(50.0, floorY - ceilY - 120.0);
      collectibles.add(
        ArcadeCollectible(
          id: colId++,
          position: Offset(x, itemY.clamp(ceilY + 34.0, floorY - 34.0)),
          type: type,
          xpValue: xp,
          scoreValue: pts,
          animPhase: rand.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  void _generateObstacles() {
    obstacles.clear();
    final rand = math.Random(level * 444 + (revisionNumber ?? 0) * 97);
    int obsId = 1;
    final double diff = _obstacleDifficulty;
    final double baseSpacing = (352.0 - math.min(level - 1, 10) * 8.0).clamp(260.0, 360.0);
    // Shuffled deck ensures every stage exhibits rich obstacle variety before repeating.
    final deck = <ObstacleType>[
      ObstacleType.toothyMicrobe,
      ObstacleType.spikyVirus,
      ObstacleType.acidDroplet,
      ObstacleType.inflammatoryZone,
      ObstacleType.bioFilament,
      ObstacleType.mucosalSpike,
    ]..shuffle(rand);
    int deckIndex = 0;

    for (double x = 450.0; x < totalDistance - 1100.0; x += baseSpacing + rand.nextDouble() * 115.0) {
      bool nearCheckpoint = checkpoints.any((cp) => (cp.worldX - x).abs() < 195.0);
      if (nearCheckpoint) continue;

      final ceilY = tunnel.getCeilingY(x, 0.0);
      final floorY = tunnel.getFloorY(x, 0.0);
      final lumenH = math.max(120.0, floorY - ceilY);
      final int obsVariant = obsId % 2;

      final chosenType = deck[deckIndex % deck.length];
      if (deckIndex % deck.length == deck.length - 1) {
        deck.shuffle(rand);
      }
      deckIndex++;

      switch (chosenType) {
        case ObstacleType.toothyMicrobe:
          obstacles.add(
            ArcadeObstacle(
              id: obsId++,
              position: Offset(x, floorY - 26.0),
              initialX: x,
              initialY: floorY - 26.0,
              type: ObstacleType.toothyMicrobe,
              radius: 22.0,
              velocityX: (obsVariant == 0 ? 1.0 : -1.0) * (36.0 + diff * 26.0),
              variant: obsVariant,
              animPhase: rand.nextDouble() * math.pi * 2,
            ),
          );
          break;
        case ObstacleType.spikyVirus:
          final midY = (ceilY + floorY) / 2 + (rand.nextDouble() - 0.5) * (lumenH * 0.30);
          obstacles.add(
            ArcadeObstacle(
              id: obsId++,
              position: Offset(x, midY),
              initialX: x,
              initialY: midY,
              type: ObstacleType.spikyVirus,
              radius: 18.0,
              variant: obsVariant,
              animPhase: rand.nextDouble() * math.pi * 2,
            ),
          );
          break;
        case ObstacleType.acidDroplet:
          obstacles.add(
            ArcadeObstacle(
              id: obsId++,
              position: Offset(x, ceilY + 18.0),
              initialX: x,
              initialY: ceilY + 18.0,
              type: ObstacleType.acidDroplet,
              radius: 14.0,
              velocityY: 78.0 + rand.nextDouble() * 38.0 + diff * 42.0,
              triggerTimer: 0.35 + rand.nextDouble() * 0.45,
              variant: obsVariant,
              animPhase: rand.nextDouble() * math.pi * 2,
            ),
          );
          break;
        case ObstacleType.inflammatoryZone:
          // Luminous Inflammatory Zone (drifts/pulses; calmed with Special / Electric Wave)
          final zoneY = floorY - 36.0 - rand.nextDouble() * math.max(24.0, lumenH * 0.36);
          obstacles.add(
            ArcadeObstacle(
              id: obsId++,
              position: Offset(x, zoneY),
              initialX: x,
              initialY: zoneY,
              type: ObstacleType.inflammatoryZone,
              radius: 25.0,
              variant: obsVariant,
              animPhase: rand.nextDouble() * math.pi * 2,
            ),
          );
          break;
        case ObstacleType.bioFilament:
          // Swaying biological mucus filament from ceiling
          final filHeight = math.min(84.0, lumenH * 0.32);
          obstacles.add(
            ArcadeObstacle(
              id: obsId++,
              position: Offset(x, ceilY + filHeight * 0.5),
              initialX: x,
              initialY: ceilY + filHeight * 0.5,
              type: ObstacleType.bioFilament,
              radius: 15.0,
              height: filHeight,
              variant: obsVariant,
              animPhase: rand.nextDouble() * math.pi * 2,
            ),
          );
          break;
        case ObstacleType.mucosalSpike:
          // Mucosal Polyp Spike emerging rhythmically from floor or ceiling (with fair clearance)
          final spikeH = math.min(72.0, lumenH * 0.28);
          final bool fromCeiling = obsVariant == 1;
          obstacles.add(
            ArcadeObstacle(
              id: obsId++,
              position: Offset(x, fromCeiling ? ceilY + spikeH * 0.5 : floorY - spikeH * 0.5),
              initialX: x,
              initialY: fromCeiling ? ceilY + spikeH * 0.5 : floorY - spikeH * 0.5,
              type: ObstacleType.mucosalSpike,
              radius: 16.0,
              height: spikeH,
              variant: obsVariant,
              animPhase: rand.nextDouble() * math.pi * 2,
            ),
          );
          break;
      }
    }
  }

  void _generateEnemies() {
    enemies.clear();
    defeatedEnemies.clear();
    final rand = math.Random(level * 555 + (revisionNumber ?? 0) * 113);
    int enemyId = 1;
    final pace = stagePaceMultiplier;
    final int stageTier = revisionNumber != null ? 6 : level.clamp(1, 7);

    // Weighted enemy squad archetype deck so encounters feel varied & strategic
    final enemyDeck = <EnemyType>[
      EnemyType.spikeVirion,
      EnemyType.helicoGrub,
      EnemyType.cytokineBlob,
      EnemyType.acidSentry,
      EnemyType.toxicSpore,
    ]..shuffle(rand);
    int deckPtr = 0;

    void addEnemyAt(double x, {double yOffset = 0.0, EnemyType? forcedType}) {
      final ceilY = tunnel.getCeilingY(x, 0.0);
      final floorY = tunnel.getFloorY(x, 0.0);
      final midY = (ceilY + floorY) / 2;

      final eType = forcedType ?? enemyDeck[deckPtr++ % enemyDeck.length];
      int hp;
      double radius;
      int scoreReward;
      int xpReward;

      switch (eType) {
        case EnemyType.helicoGrub:
          hp = 3 + (stageTier / 3).floor();
          radius = 20.0;
          scoreReward = 160;
          xpReward = 35;
          break;
        case EnemyType.spikeVirion:
          hp = 4 + (stageTier / 2).floor();
          radius = 20.0;
          scoreReward = 190;
          xpReward = 42;
          break;
        case EnemyType.cytokineBlob:
          hp = 4 + (stageTier / 3).floor();
          radius = 22.0;
          scoreReward = 200;
          xpReward = 45;
          break;
        case EnemyType.acidSentry:
          hp = 6 + (stageTier / 2).floor();
          radius = 24.0;
          scoreReward = 245;
          xpReward = 55;
          break;
        case EnemyType.toxicSpore:
          hp = 3 + (stageTier / 4).floor();
          radius = 19.0;
          scoreReward = 150;
          xpReward = 34;
          break;
      }

      final enemyY = (midY + yOffset + (rand.nextDouble() - 0.5) * math.max(40.0, (floorY - ceilY) * 0.28))
          .clamp(ceilY + 38.0, floorY - 38.0);
      final baseSpeed = (44.0 + rand.nextDouble() * 22.0) * (0.94 + pace * 0.08);
      enemies.add(
        ArcadeEnemy(
          id: enemyId++,
          position: Offset(x, enemyY),
          velocity: Offset(-baseSpeed, 0),
          type: eType,
          maxHp: hp,
          radius: radius,
          scoreReward: scoreReward,
          xpReward: xpReward,
          shootInterval: (2.35 - (stageTier - 1) * 0.11).clamp(1.45, 2.45) + rand.nextDouble() * 0.9,
        ),
      );
    }

    final double stepBase = math.max(290.0, 410.0 - (stageTier - 1) * 18.0);
    int waveCounter = 0;
    for (double x = 560.0; x < totalDistance - 1350.0; x += stepBase + rand.nextDouble() * 90.0) {
      bool nearCheckpoint = checkpoints.any((cp) => (cp.worldX - x).abs() < 165.0);
      bool nearObstacle = obstacles.any((o) => (o.position.dx - x).abs() < 90.0);
      if (nearCheckpoint || nearObstacle) continue;

      addEnemyAt(x);
      waveCounter++;

      // Starting Stage 2+, spawn dynamic flanking wingmen/chasers on alternating waves
      if (stageTier >= 2 && waveCounter % 2 == 0) {
        final wingOffset = waveCounter % 4 == 0 ? -52.0 : 52.0;
        addEnemyAt(
          x + 56.0,
          yOffset: wingOffset,
          forcedType: waveCounter % 3 == 0 ? EnemyType.acidSentry : EnemyType.spikeVirion,
        );
      }
      // Stage 5-7 adds a third pincer unit periodically
      if (stageTier >= 5 && waveCounter % 3 == 0) {
        addEnemyAt(x + 92.0, yOffset: -48.0, forcedType: EnemyType.cytokineBlob);
      }
    }

    // Guarantee dynamic enemies between checkpoints if sparse
    if (enemies.length < 4) {
      for (int i = 0; i < checkpoints.length - 1; i++) {
        final midX = (checkpoints[i].worldX + checkpoints[i + 1].worldX) * 0.5;
        if (!obstacles.any((o) => (o.position.dx - midX).abs() < 70.0)) {
          addEnemyAt(midX);
        }
      }
      if (enemies.isEmpty) {
        addEnemyAt((totalDistance - 1350.0).clamp(500.0, totalDistance - 1200.0));
      }
    }
  }

  void _generateBoss() {
    List<GastroQuestion> challengeQuestions;

    if (revisionNumber != null) {
      if (checkpoints.isNotEmpty) {
        challengeQuestions = [checkpoints.last.question];
      } else {
        challengeQuestions = [allGastroQuestions[3], allGastroQuestions[11], allGastroQuestions[26]];
      }
    } else {
      final int sectorId = level.clamp(1, 7);
      if (sectorId >= 1 && sectorId <= 6) {
        final stageQuestions =
            allGastroQuestions.where((q) => q.worldId == sectorId).toList();
        challengeQuestions =
            stageQuestions.isNotEmpty ? [stageQuestions.last] : [allGastroQuestions.first];
      } else {
        challengeQuestions = [
          allGastroQuestions[3],
          allGastroQuestions[11],
          allGastroQuestions[26],
        ];
      }
    }

    // Progressive Boss HP across Stages 1..7 (Stage 1 = 56 HP for clean test parity & ramp)
    final int clampedStage = revisionNumber != null ? 6 : level.clamp(1, 7);
    final int bossHp = 44 + clampedStage * 12;
    final bossStartPos = Offset(totalDistance - 240.0, viewportHeight * 0.5);

    boss = ArcadeBoss(
      name: revisionNumber != null
          ? 'Gardien du Savoir • Synthèse'
          : world.boss.name,
      title: revisionNumber != null
          ? 'Gardien des Connaissances Consolidées'
          : world.boss.title,
      dangerLevel: world.bossDangerLevel,
      auraColor: revisionNumber != null
          ? const Color(0xFFFBBF24)
          : world.boss.auraColor,
      icon: world.boss.icon,
      position: bossStartPos,
      homePosition: bossStartPos,
      maxHp: bossHp,
      currentHp: bossHp,
      challengeQuestions: challengeQuestions,
    );
  }

  void start() {
    state = GameState.playing;
    if (isRevisionStage) {
      audio.startRevisionBgm();
    } else {
      audio.startBgm(level);
    }
    audio.playGameStart();
    notifyListeners();
  }

  void cycleEquippedWeapon() {
    final unlocked = progress.unlockedWeapons;
    if (unlocked.length <= 1) return;
    final idx = unlocked.indexOf(progress.equippedWeapon);
    final nextName = unlocked[(idx + 1) % unlocked.length];
    progress.equipWeapon(nextName);
    player.weaponType = equippedWeaponConfig.type;
    audio.playClick();
    _addFloatingText(
      equippedWeaponConfig.shortName.toUpperCase(),
      player.position + const Offset(0, -34),
      equippedWeaponConfig.glowColor,
    );
    notifyListeners();
  }

  void pause() {
    if (state == GameState.playing || state == GameState.bossFight || state == GameState.bossIntro) {
      _stateBeforePause = state;
      state = GameState.paused;
      audio.stopBgm();
      notifyListeners();
    }
  }

  GameState _stateBeforePause = GameState.playing;

  void resume() {
    if (state == GameState.paused) {
      state = _stateBeforePause;
      if (state == GameState.bossFight || state == GameState.bossIntro) {
        audio.startBossBgm();
      } else if (isRevisionStage) {
        audio.startRevisionBgm();
      } else {
        audio.startBgm(level);
      }
      notifyListeners();
    }
  }

  /// Responsive Viewport Adapter: recalculates tunnel bounds dynamically to screen height
  void setViewport(double width, double height) {
    if ((viewportWidth - width).abs() > 1.0 || (viewportHeight - height).abs() > 1.0) {
      viewportWidth = width;
      viewportHeight = height;
      tunnel.updateViewport(width, height);

      final ceilY = tunnel.getCeilingY(player.position.dx, gameTime) + player.radius + 8.0;
      final floorY = tunnel.getFloorY(player.position.dx, gameTime) - player.radius - 8.0;
      if (player.position.dy < ceilY || player.position.dy > floorY) {
        player.position = Offset(player.position.dx, (ceilY + floorY) / 2);
      }

      boss.homePosition = Offset(totalDistance - 210.0, viewportHeight * 0.5);
      boss.chargeTargetY = viewportHeight * 0.5;
    }
  }

  // =========================================================================
  // TOUCH & KEYBOARD CONTROLS
  // =========================================================================

  void setMoveVector(Offset vector) {
    if (vector.distance < 0.08) {
      player.moveInput = Offset.zero;
      player.isThrusting = false;
      player.isMovingDown = false;
      player.isMovingLeft = false;
      player.isMovingRight = false;
    } else {
      player.moveInput = Offset(
        vector.dx.clamp(-1.0, 1.0),
        vector.dy.clamp(-1.0, 1.0),
      );
      player.isThrusting = vector.dy < -0.22;
      player.isMovingDown = vector.dy > 0.22;
      player.isMovingLeft = vector.dx < -0.22;
      player.isMovingRight = vector.dx > 0.22;
    }
  }

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

  void setShooting(bool isShooting, [Offset? targetPos]) {
    player.isShooting = isShooting;
    if (isShooting) {
      shoot(targetPos);
    }
  }

  /// Fires projectiles matching the active WeaponConfig AND Knowledge Synergie Multiplier
  void shoot([Offset? targetScreenPos]) {
    if (state != GameState.playing && state != GameState.bossFight) return;
    if (player.shootCooldownTimer > 0) return;

    final config = equippedWeaponConfig;
    // Correct answers boost fire rate slightly too!
    final fireRateBonus = (1.0 - (player.weaponPowerLevel - 1) * 0.07).clamp(0.75, 1.0);
    player.shootCooldownTimer = config.cooldownSeconds * fireRateBonus;
    player.shootRecoilTimer = 0.10;

    final double baseSpeed = config.projectileSpeed;
    final int scaledDamage = math.max(1, (config.damage * player.knowledgeDamageMultiplier).round());
    final Color color = player.isMaxSynergy ? const Color(0xFFFBBF24) : config.glowColor;
    final double radiusScale = player.weaponPowerLevel >= 3 ? 1.2 : 1.0;

    Offset shotDir = const Offset(1.0, 0.0);
    if (targetScreenPos != null) {
      final playerScreenPos = Offset(player.position.dx - cameraX, player.position.dy);
      final delta = targetScreenPos - playerScreenPos;
      if (delta.distance > 12.0) {
        shotDir = delta / delta.distance;
      }
    }

    final normalDir = Offset(-shotDir.dy, shotDir.dx);

    void spawnBolt({
      Offset offset = Offset.zero,
      Offset? velocityOverride,
      double radius = 5.5,
      bool homing = false,
      bool piercing = false,
      int? customDmg,
    }) {
      playerProjectiles.add(
        CapsuleProjectile(
          position: player.position + shotDir * 24.0 + offset,
          velocity: velocityOverride ?? (shotDir * baseSpeed),
          damage: customDmg ?? scaledDamage,
          color: color,
          radius: radius * radiusScale,
          isHoming: homing,
          isPiercing: piercing,
          weaponType: config.type,
        ),
      );
    }

    switch (config.type) {
      case WeaponType.doubleLaser:
        spawnBolt(offset: normalDir * -8.5, radius: 5.5);
        spawnBolt(offset: normalDir * 8.5, radius: 5.5);
        break;

      case WeaponType.antibacterialCannon:
        spawnBolt(velocityOverride: shotDir * baseSpeed, radius: 7.0);
        spawnBolt(velocityOverride: (shotDir * baseSpeed) + (normalDir * -105.0), radius: 5.5);
        spawnBolt(velocityOverride: (shotDir * baseSpeed) + (normalDir * 105.0), radius: 5.5);
        break;

      case WeaponType.therapeuticOrbs:
        spawnBolt(
          offset: normalDir * -6.0,
          velocityOverride: (shotDir * baseSpeed) + (normalDir * -45.0),
          radius: 7.5,
          homing: true,
        );
        spawnBolt(
          offset: normalDir * 6.0,
          velocityOverride: (shotDir * baseSpeed) + (normalDir * 45.0),
          radius: 7.5,
          homing: true,
        );
        break;

      case WeaponType.plasmaShot:
        spawnBolt(radius: 9.5, piercing: true);
        if (player.hasDoubleShot) {
          spawnBolt(offset: normalDir * 14.0, radius: 7.0);
        }
        break;

      case WeaponType.energyShield:
        spawnBolt(radius: 8.0, piercing: false);
        spawnBolt(offset: normalDir * -11.0, radius: 6.0);
        spawnBolt(offset: normalDir * 11.0, radius: 6.0);
        break;

      case WeaponType.electricWave:
        spawnBolt(radius: 8.5, piercing: true);
        break;

      case WeaponType.ultimatePulse:
        spawnBolt(velocityOverride: (shotDir * baseSpeed) + (normalDir * -75.0), radius: 7.5, homing: true);
        spawnBolt(velocityOverride: shotDir * (baseSpeed + 50.0), radius: 9.5, piercing: true);
        spawnBolt(velocityOverride: (shotDir * baseSpeed) + (normalDir * 75.0), radius: 7.5, homing: true);
        break;

      case WeaponType.medicalLaser:
        if (player.hasDoubleShot || player.weaponPowerLevel >= 3) {
          spawnBolt(offset: normalDir * -7.5, radius: 5.5);
          spawnBolt(offset: normalDir * 7.5, radius: 5.5);
        } else {
          spawnBolt(radius: 5.5);
        }
        break;
    }

    // Extra Knowledge Synergie side bolt at Max Synergie!
    if (player.isMaxSynergy && config.type != WeaponType.ultimatePulse) {
      spawnBolt(
        velocityOverride: (shotDir * baseSpeed * 0.95) + (normalDir * -55.0),
        radius: 5.0,
        homing: true,
        customDmg: math.max(1, (scaledDamage * 0.6).round()),
      );
    }

    audio.playWeaponShot(config.sfxIndex);
    _emitMuzzleParticles(player.position + shotDir * 24.0, color);
  }

  void activateShield() {
    if (state != GameState.playing && state != GameState.bossFight) return;
    player.activateShield(5.0);
    audio.playShieldActivate();
    _addFloatingText('BOUCLIER PROTECTEUR !', player.position + const Offset(0, -35), const Color(0xFF22D3EE));
    notifyListeners();
  }

  /// Special Anti-Inflammatory Weapon: clears enemy projectiles, soothes inflammation, damages enemies + boss!
  void triggerSpecialSkill() {
    if (state != GameState.playing && state != GameState.bossFight) return;
    if (!player.canUseSpecialSkill) return;

    player.triggerSpecialSkill();
    specialWaveFlashTimer = 0.65;
    audio.playSpecialSkill();

    // 1. Neutralize all enemy projectiles on screen
    for (final ep in enemyProjectiles) {
      _emitHitSparks(ep.position, color: const Color(0xFF34D399));
    }
    enemyProjectiles.clear();

    // 2. Soothe inflammatory hazards around the player
    for (final obs in obstacles) {
      if (obs.type == ObstacleType.inflammatoryZone && (obs.position - player.position).distance < 450.0) {
        obs.sootheTimer = 7.0;
        _emitCollectParticles(obs.position, CollectibleType.heartBoost);
      }
    }

    // 3. Deal Area-of-Effect therapeutic damage to nearby germs (stronger when Super Attack unlocked!)
    final double superMult = player.hasSuperAttack ? 1.65 : 1.0;
    final int specialDmg = math.max(6, (8 * player.knowledgeDamageMultiplier * superMult).round());
    for (final enemy in enemies) {
      if (enemy.isDead) continue;
      if ((enemy.position - player.position).distance < 420.0) {
        final dir = enemy.position - player.position;
        final normDir = dir.distance > 1.0 ? dir / dir.distance : const Offset(1, 0);
        enemy.takeDamage(specialDmg, hitDirection: normDir);
        _emitHitSparks(enemy.position, color: const Color(0xFF34D399));
        if (enemy.isDead) {
          _onEnemyDefeated(enemy, dropChance: 0.20);
        }
      }
    }

    // 4. Also strike the Boss if in Boss Chamber!
    if (state == GameState.bossFight && !boss.isDefeated) {
      if ((boss.position - player.position).distance < 720.0) {
        boss.takeDamage((specialDmg * 0.85).round());
        _emitHitSparks(boss.position, color: const Color(0xFFFBBF24));
        score += player.hasSuperAttack ? 400 : 250;
        if (boss.isDefeated) {
          _startBossDefeatSequence();
        }
      }
    }

    screenShake = 0.9;
    for (int i = 0; i < 28; i++) {
      final angle = (i / 28.0) * math.pi * 2;
      particles.add(
        ArcadeParticle(
          position: player.position,
          velocity: Offset(math.cos(angle) * 380.0, math.sin(angle) * 380.0),
          color: player.hasSuperAttack
              ? (i % 2 == 0 ? const Color(0xFFFBBF24) : const Color(0xFF34D399))
              : (i % 2 == 0 ? const Color(0xFF34D399) : const Color(0xFF22D3EE)),
          size: player.hasSuperAttack ? 6.5 : 5.5,
          life: 0.65,
          maxLife: 0.65,
        ),
      );
    }

    _addFloatingText(
      player.hasSuperAttack ? 'FRAPPE CLINIQUE MAX !' : 'ONDE ANTI-INFLAMMATOIRE !',
      player.position + const Offset(0, -45),
      player.hasSuperAttack ? const Color(0xFFFBBF24) : const Color(0xFF34D399),
    );
    notifyListeners();
  }

  /// Main 60 FPS Update Loop
  void update(double dt) {
    if (state == GameState.ready ||
        state == GameState.paused ||
        state == GameState.checkpoint ||
        state == GameState.victory ||
        state == GameState.gameOver) {
      return;
    }

    gameTime += dt;
    if (screenShake > 0) {
      screenShake = math.max(0.0, screenShake - dt * 3.5);
    }
    if (specialWaveFlashTimer > 0) {
      specialWaveFlashTimer = math.max(0.0, specialWaveFlashTimer - dt);
    }
    if (player.specialSkillCooldown > 0) {
      player.specialSkillCooldown = math.max(0.0, player.specialSkillCooldown - dt);
    }

    // State-specific orchestration
    if (state == GameState.bossIntro) {
      _updateBossIntro(dt);
      _updateDefeatedEnemies(dt);
      _updateParticles(dt);
      _updateFloatingTexts(dt);
      notifyListeners();
      return;
    }

    if (state == GameState.bossDefeatAnim) {
      _updateBossDefeatAnim(dt);
      _updateDefeatedEnemies(dt);
      _updateParticles(dt);
      _updateFloatingTexts(dt);
      notifyListeners();
      return;
    }

    if (player.isShooting && player.shootCooldownTimer <= 0 && !isEnteringCheckpoint) {
      shoot();
    }

    // Smooth Portal Entry Slowdown -> seamless Checkpoint Question Transition
    if (_pendingCheckpoint != null) {
      checkpointWarpTimer = math.max(0.0, checkpointWarpTimer - dt);
      final cp = _pendingCheckpoint!;
      final ceilY = tunnel.getCeilingY(cp.worldX, gameTime);
      final floorY = tunnel.getFloorY(cp.worldX, gameTime);
      final targetPos = Offset(cp.worldX, (ceilY + floorY) * 0.5);
      player.position = Offset.lerp(player.position, targetPos, math.min(1.0, dt * 8.5))!;
      player.angle *= 0.82;
      _updateCamera();
      _updateParticles(dt);
      _updateFloatingTexts(dt);
      if (checkpointWarpTimer <= 0) {
        _pendingCheckpoint = null;
        activeCheckpoint = cp;
        state = GameState.checkpoint;
      }
      notifyListeners();
      return;
    }

    _updatePlayerPhysics(dt);
    _updateCamera();
    _updateProjectiles(dt);
    _updateEnemies(dt);
    _updateDefeatedEnemies(dt);
    _updateCollectibles(dt);
    _updateObstacles(dt);
    _updateBoss(dt);
    _updateParticles(dt);
    _updateFloatingTexts(dt);
    _checkCollisions();

    notifyListeners();
  }

  void _updateBossIntro(double dt) {
    bossIntroTimer = math.max(0.0, bossIntroTimer - dt);
    bossArenaMix = (bossArenaMix + dt * 0.55).clamp(0.0, 1.0);
    boss.entranceProgress = (1.0 - (bossIntroTimer / 2.5)).clamp(0.0, 1.0);
    screenShake = math.max(screenShake, (1.0 - boss.entranceProgress) * 0.25);

    // Smoothly frame the Boss Arena
    final targetCam = math.max(0.0, totalDistance - viewportWidth);
    cameraX += (targetCam - cameraX) * (dt * 4.5).clamp(0.0, 1.0);

    // Move player nicely to the left side of arena
    final desiredPlayerX = (totalDistance - viewportWidth * 0.74).clamp(cameraX + 60.0, totalDistance - 420.0);
    final desiredPlayerY = viewportHeight * 0.5;
    player.position = Offset(
      player.position.dx + (desiredPlayerX - player.position.dx) * (dt * 3.5).clamp(0.0, 1.0),
      player.position.dy + (desiredPlayerY - player.position.dy) * (dt * 3.5).clamp(0.0, 1.0),
    );
    player.angle *= 0.85;

    // Boss glides dramatically in from the right edge with ambient swirl particles
    final targetBossX = totalDistance - math.max(165.0, viewportWidth * 0.23);
    final targetBossY = viewportHeight * 0.5;
    boss.homePosition = Offset(targetBossX, targetBossY);
    boss.position = Offset(
      (totalDistance + 160.0) * (1.0 - Curves.easeOutCubic.transform(boss.entranceProgress)) +
          targetBossX * Curves.easeOutCubic.transform(boss.entranceProgress),
      targetBossY + math.sin(boss.entranceProgress * math.pi * 2) * 14.0,
    );

    if (boss.entranceProgress < 0.85 && math.Random().nextDouble() < 0.35) {
      _emitHitSparks(boss.position + const Offset(-30, 0), color: boss.auraColor);
    }

    if (bossIntroTimer <= 1e-6) {
      bossIntroTimer = 0.0;
      state = GameState.bossFight;
      boss.attackCooldown = 1.35;
      _addFloatingText('COMBAT ENGAGÉ !', boss.position + const Offset(-80, -82), const Color(0xFFFBBF24));
    }
  }

  void _updateBossDefeatAnim(double dt) {
    bossDefeatTimer = math.max(0.0, bossDefeatTimer - dt);
    _bossDefeatBurstTick -= dt;
    screenShake = math.max(screenShake, bossDefeatTimer > 1.0 ? 0.55 : 0.25);

    // Sequential multi-point explosions across boss silhouette
    if (_bossDefeatBurstTick <= 0 && bossDefeatTimer > 0.75) {
      _bossDefeatBurstTick = 0.16;
      final rand = math.Random();
      final burstPos = boss.position +
          Offset((rand.nextDouble() - 0.5) * 90.0, (rand.nextDouble() - 0.5) * 80.0);
      _emitHitSparks(
        burstPos,
        color: rand.nextBool() ? const Color(0xFFFBBF24) : const Color(0xFF22D3EE),
      );
      _emitVictoryConfetti(burstCount: 10);
    }

    // Mid-sequence golden purification shockwave ring & hero capsule celebration flare
    if (!_bossPurifyWaveDone && bossDefeatTimer <= 1.15) {
      _bossPurifyWaveDone = true;
      specialWaveFlashTimer = 0.65;
      _emitVictoryConfetti(burstCount: 38);
      _addFloatingText('VICTOIRE !', boss.position + const Offset(-20, -60), const Color(0xFF34D399));
      audio.playRewardUnlock();
    }

    if (bossDefeatTimer <= 0) {
      _completeStageVictory();
    }
  }

  void _updatePlayerPhysics(double dt) {
    if (player.invulnerableTimer > 0) {
      player.invulnerableTimer = math.max(0.0, player.invulnerableTimer - dt);
    }
    if (player.boostTimer > 0) {
      player.boostTimer = math.max(0.0, player.boostTimer - dt);
    }
    if (player.shootCooldownTimer > 0) {
      player.shootCooldownTimer = math.max(0.0, player.shootCooldownTimer - dt);
    }
    if (player.shootRecoilTimer > 0) {
      player.shootRecoilTimer = math.max(0.0, player.shootRecoilTimer - dt);
    }
    if (player.shieldTimer > 0) {
      player.shieldTimer = math.max(0.0, player.shieldTimer - dt);
    }
    if (player.doubleShotTimer > 0) {
      player.doubleShotTimer = math.max(0.0, player.doubleShotTimer - dt);
    }
    if (player.collectFlashTimer > 0) {
      player.collectFlashTimer = math.max(0.0, player.collectFlashTimer - dt);
    }
    if (player.damageFlashTimer > 0) {
      player.damageFlashTimer = math.max(0.0, player.damageFlashTimer - dt);
    }
    if (player.shieldDeflectTimer > 0) {
      player.shieldDeflectTimer = math.max(0.0, player.shieldDeflectTimer - dt);
    }

    player.animPhase += dt * 4.5;

    // Progressive capsule speed upgrade based on arsenal + gentle progressive stage pace
    final double speedUpgradeMult = (1.0 + (progress.unlockedWeapons.length - 1) * 0.03).clamp(1.0, 1.18);
    final double paceMult = _playerAgilityMultiplier;
    final double maxSpeed = (player.isBoosted ? 285.0 : 220.0) *
        speedUpgradeMult *
        paceMult *
        player.joystickSensitivity;

    double targetVx = player.moveInput.dx * maxSpeed;
    double targetVy = player.moveInput.dy * maxSpeed;

    // Organ-specific subtle digestive physics cue: Stage 1 gentle esophageal peristaltic lift
    if (level == 1 && state == GameState.playing) {
      targetVy += math.sin(gameTime * 2.0) * 11.0;
    }

    if (state == GameState.bossFight) {
      // Arena mode: unrestricted 360° piloting without forced forward drift
    } else {
      if (player.moveInput.dx >= -0.12) {
        targetVx = math.max(
          targetVx,
          (player.isBoosted ? 195.0 : 118.0) * speedUpgradeMult * paceMult,
        );
      }
      _checkMidStageSurprises();
    }

    // Smooth fluid acceleration and organic inertial damping
    double currentVx = player.velocity.dx;
    double currentVy = player.velocity.dy;
    currentVx += (targetVx - currentVx) * math.min(1.0, 8.5 * dt);
    currentVy += (targetVy - currentVy) * math.min(1.0, 9.5 * dt);

    player.velocity = Offset(currentVx, currentVy);
    player.position += player.velocity * dt;

    // Gentle pitch banking proportional to vertical velocity
    final targetAngle = (player.velocity.dy / 300.0).clamp(-0.32, 0.32);
    player.angle += (targetAngle - player.angle) * math.min(1.0, 8.5 * dt);

    final currentSpeed = player.velocity.distance;
    final targetFlame = (currentSpeed / 240.0).clamp(0.25, 1.0);
    player.flameIntensity += (targetFlame - player.flameIntensity) * math.min(1.0, 8.0 * dt);

    player.trailPositions.insert(0, player.position);
    if (player.trailPositions.length > 9) {
      player.trailPositions.removeLast();
    }

    if (player.flameIntensity > 0.42 || player.isThrusting) {
      _emitThrusterParticles();
    }

    // Clamp to Arena horizontals during Boss Fight
    if (state == GameState.bossFight) {
      final minX = math.max(0.0, cameraX + player.radius + 16.0);
      final maxX = boss.homePosition.dx - 95.0;
      if (player.position.dx < minX) {
        player.position = Offset(minX, player.position.dy);
        player.velocity = Offset(math.max(0.0, player.velocity.dx), player.velocity.dy);
      } else if (player.position.dx > maxX) {
        player.position = Offset(maxX, player.position.dy);
        player.velocity = Offset(math.min(0.0, player.velocity.dx), player.velocity.dy);
      }
    }

    // Tunnel wall bounds
    final ceilY = tunnel.getCeilingY(player.position.dx, gameTime) + player.radius + 6.0;
    final floorY = tunnel.getFloorY(player.position.dx, gameTime) - player.radius - 6.0;

    if (player.position.dy < ceilY) {
      player.position = Offset(player.position.dx, ceilY);
      player.velocity = Offset(player.velocity.dx * 0.9, 15.0);
    } else if (player.position.dy > floorY) {
      player.position = Offset(player.position.dx, floorY);
      player.velocity = Offset(player.velocity.dx * 0.9, -15.0);
    }
  }

  /// Special in-stage surprises / events along progression to boost variety & excitement
  void _checkMidStageSurprises() {
    final double frac = progressFraction;
    if (!_midEvent1Triggered && frac >= 0.42 && frac < 0.70) {
      _midEvent1Triggered = true;
      final spawnX = player.position.dx + 280.0;
      if (spawnX < totalDistance - 1150.0) {
        final midY = (tunnel.getCeilingY(spawnX, gameTime) + tunnel.getFloorY(spawnX, gameTime)) * 0.5;
        collectibles.addAll([
          ArcadeCollectible(
            id: _nextDynamicId++,
            position: Offset(spawnX, midY - 36.0),
            type: CollectibleType.vitaminCapsule,
            xpValue: 50,
            scoreValue: 120,
          ),
          ArcadeCollectible(
            id: _nextDynamicId++,
            position: Offset(spawnX + 38.0, midY),
            type: CollectibleType.shieldBoost,
            xpValue: 80,
            scoreValue: 160,
          ),
          ArcadeCollectible(
            id: _nextDynamicId++,
            position: Offset(spawnX + 76.0, midY + 36.0),
            type: CollectibleType.vitaminCapsule,
            xpValue: 50,
            scoreValue: 120,
          ),
        ]);
        _addFloatingText(
          'RENFORT PROBIOTIQUE !',
          player.position + const Offset(80, -45),
          const Color(0xFF34D399),
        );
      }
    }

    if (!_midEvent2Triggered && frac >= 0.72) {
      _midEvent2Triggered = true;
      final spawnX = player.position.dx + 260.0;
      if (spawnX < totalDistance - 1080.0) {
        final midY = (tunnel.getCeilingY(spawnX, gameTime) + tunnel.getFloorY(spawnX, gameTime)) * 0.5;
        collectibles.add(
          ArcadeCollectible(
            id: _nextDynamicId++,
            position: Offset(spawnX, midY),
            type: CollectibleType.weaponUpgrade,
            xpValue: 100,
            scoreValue: 220,
          ),
        );
        enemies.add(
          ArcadeEnemy(
            id: _nextDynamicId++,
            position: Offset(spawnX + 95.0, midY - 40.0),
            velocity: const Offset(-55.0, 0.0),
            type: EnemyType.cytokineBlob,
            maxHp: 4,
            radius: 22.0,
            scoreReward: 220,
            xpReward: 50,
          ),
        );
        _addFloatingText(
          'SURCHARGE THÉRAPEUTIQUE !',
          player.position + const Offset(75, -45),
          const Color(0xFFFBBF24),
        );
      }
    }
  }

  void _updateCamera() {
    if (state == GameState.bossFight || state == GameState.bossDefeatAnim) {
      final targetX = math.max(0.0, totalDistance - viewportWidth);
      cameraX += (targetX - cameraX) * 0.08;
      bossArenaMix = (bossArenaMix + 0.02).clamp(0.0, 1.0);
    } else {
      // Keep capsule safely at 32% from left edge — always clear of joystick
      final targetCameraX = player.position.dx - viewportWidth * 0.32;
      cameraX = math.max(0.0, targetCameraX);
    }
  }

  Offset? _findNearestHomingTarget(Offset fromPos) {
    double bestDist = double.infinity;
    Offset? bestPos;

    if (state == GameState.bossFight && !boss.isDefeated) {
      bestDist = (boss.position - fromPos).distance;
      bestPos = boss.position;
    }

    for (final enemy in enemies) {
      if (enemy.isDead) continue;
      if (enemy.position.dx < cameraX - 20 || enemy.position.dx > cameraX + viewportWidth + 60) {
        continue;
      }
      final d = (enemy.position - fromPos).distance;
      if (d < bestDist) {
        bestDist = d;
        bestPos = enemy.position;
      }
    }
    return bestPos;
  }

  void _updateProjectiles(double dt) {
    for (int i = playerProjectiles.length - 1; i >= 0; i--) {
      final p = playerProjectiles[i];
      final target = p.isHoming ? _findNearestHomingTarget(p.position) : null;
      p.update(dt, homingTarget: target);

      // Energy Shield / Anti-inflammatory shots can intercept incoming enemy projectiles!
      if (p.weaponType == WeaponType.energyShield || p.weaponType == WeaponType.electricWave) {
        for (int epIdx = enemyProjectiles.length - 1; epIdx >= 0; epIdx--) {
          if ((p.position - enemyProjectiles[epIdx].position).distance < p.radius + enemyProjectiles[epIdx].radius + 6.0) {
            _emitHitSparks(enemyProjectiles[epIdx].position, color: p.color);
            enemyProjectiles.removeAt(epIdx);
          }
        }
      }

      if (p.isDead ||
          p.position.dx > cameraX + viewportWidth + 160.0 ||
          p.position.dx < cameraX - 100.0) {
        playerProjectiles.removeAt(i);
      }
    }

    for (int i = enemyProjectiles.length - 1; i >= 0; i--) {
      final ep = enemyProjectiles[i];
      ep.update(dt);
      if (ep.isDead ||
          ep.position.dx > cameraX + viewportWidth + 160.0 ||
          ep.position.dx < cameraX - 120.0 ||
          ep.position.dy < 0 ||
          ep.position.dy > viewportHeight) {
        enemyProjectiles.removeAt(i);
      }
    }
  }

  void _updateEnemies(double dt) {
    final pace = stagePaceMultiplier;
    for (int i = enemies.length - 1; i >= 0; i--) {
      final enemy = enemies[i];
      final ceilY = tunnel.getCeilingY(enemy.position.dx, gameTime);
      final floorY = tunnel.getFloorY(enemy.position.dx, gameTime);
      enemy.update(
        dt,
        player.position,
        enemyProjectiles,
        playerProjectiles: playerProjectiles,
        ceilY: ceilY,
        floorY: floorY,
        speedMultiplier: pace,
      );
      if (enemy.justAttacked) {
        audio.playEnemyAttack();
      }
      if (enemy.isDead) {
        enemies.removeAt(i);
      }
    }
  }

  void _updateDefeatedEnemies(double dt) {
    for (int i = defeatedEnemies.length - 1; i >= 0; i--) {
      defeatedEnemies[i].life -= dt;
      if (defeatedEnemies[i].isDead) {
        defeatedEnemies.removeAt(i);
      }
    }
  }

  void _onEnemyDefeated(ArcadeEnemy enemy, {double dropChance = 0.30}) {
    score += enemy.scoreReward * (1 + (combo / 4).floor());
    earnedXp += enemy.xpReward;
    combo++;
    if (combo > highestCombo) highestCombo = combo;

    Color burstCol = const Color(0xFF38BDF8);
    if (enemy.type == EnemyType.cytokineBlob || enemy.type == EnemyType.acidSentry) {
      burstCol = const Color(0xFFFB923C);
    } else if (enemy.type == EnemyType.toxicSpore || enemy.type == EnemyType.helicoGrub) {
      burstCol = const Color(0xFF34D399);
    } else if (enemy.type == EnemyType.spikeVirion) {
      burstCol = const Color(0xFFEC4899);
    }

    if (defeatedEnemies.length > 20) {
      defeatedEnemies.removeAt(0);
    }
    defeatedEnemies.add(
      DefeatedEnemyEffect(
        position: enemy.position,
        radius: enemy.radius,
        color: burstCol,
        spinDir: enemy.id.isEven ? 1.0 : -1.0,
        seed: enemy.id,
      ),
    );
    screenShake = math.max(screenShake, 0.18);
    _addFloatingText('+${enemy.xpReward} XP', enemy.position, const Color(0xFF38BDF8));
    _emitExplosion(enemy.position, enemy.type);
    audio.playEnemyDefeat();

    if (math.Random().nextDouble() < dropChance) {
      collectibles.add(
        ArcadeCollectible(
          id: 9000 + (_nextDynamicId++),
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

  void _updateCollectibles(double dt) {
    for (final item in collectibles) {
      if (!item.isCollected) {
        item.animPhase += dt * 3.0;
        // Drift arena support collectibles gently leftward so player can grab them
        if (state == GameState.bossFight && item.id >= 9500) {
          item.position += Offset(55.0 * dt, math.sin(item.animPhase) * 18.0 * dt);
        }
      }
    }
  }

  void _updateObstacles(double dt) {
    final double diff = _obstacleDifficulty;
    final double obsPace = 0.92 + stagePaceMultiplier * 0.16;

    for (final obs in obstacles) {
      if (obs.sootheTimer > 0) {
        obs.sootheTimer = math.max(0.0, obs.sootheTimer - dt);
      }
      if (obs.stunTimer > 0) {
        obs.stunTimer = math.max(0.0, obs.stunTimer - dt);
      }
      if (obs.triggerTimer > 0) {
        obs.triggerTimer = math.max(0.0, obs.triggerTimer - dt);
      }

      final double activeMult = obs.isStunned ? 0.32 : 1.0;
      obs.animPhase += dt * (2.3 + diff * 1.1) * obsPace * activeMult;

      final double ceilY = tunnel.getCeilingY(obs.baseX, gameTime);
      final double floorY = tunnel.getFloorY(obs.baseX, gameTime);
      final double safeTop = ceilY + obs.radius + 16.0;
      final double safeBottom = math.max(safeTop + 20.0, floorY - obs.radius - 16.0);
      final double distToPlayer = (player.position - obs.position).distance;

      switch (obs.type) {
        case ObstacleType.acidDroplet:
          // Swells at ceiling with telegraph, then plunges faster with gravity
          if (obs.triggerTimer > 0) {
            obs.pulseScale = 0.72 + (1.0 - (obs.triggerTimer / 0.8).clamp(0.0, 1.0)) * 0.42;
            obs.position = Offset(obs.baseX, ceilY + 14.0);
          } else {
            obs.pulseScale = 1.0;
            final double fallBoost = obs.velocityY * (1.0 + diff * 0.35) * obsPace * activeMult;
            double newY = obs.position.dy + fallBoost * dt;
            if (newY >= floorY - 10.0) {
              _emitSplashParticles(obs.position, const Color(0xFFA3E635));
              newY = ceilY + 14.0;
              obs.triggerTimer = (0.55 - diff * 0.22).clamp(0.22, 0.65);
            }
            obs.position = Offset(obs.baseX, newY);
          }
          break;

        case ObstacleType.spikyVirus:
          if (obs.variant % 2 == 0) {
            // Variant 0: Smooth elliptical orbital patrol inside tunnel
            final double orbitX = 24.0 + diff * 18.0;
            final double orbitY = 22.0 + diff * 18.0;
            final double nextX = obs.baseX + math.cos(obs.animPhase * 0.95) * orbitX;
            final double nextY = (obs.initialY + math.sin(obs.animPhase * 1.15) * orbitY)
                .clamp(safeTop, safeBottom);
            obs.position = Offset(nextX, nextY);
          } else {
            // Variant 1: Wave hover + subtle proximity reaction & danger aura
            if (distToPlayer < 225.0 && !obs.isStunned) {
              obs.triggerTimer = 0.35;
              final double reactDir = player.position.dy >= obs.position.dy ? 1.0 : -1.0;
              final double reactSpeed = (28.0 + diff * 26.0) * activeMult;
              final double nextY = (obs.position.dy + reactDir * reactSpeed * dt)
                  .clamp(safeTop, safeBottom);
              final double nextX = obs.baseX + math.sin(obs.animPhase * 1.4) * 16.0;
              obs.position = Offset(nextX, nextY);
            } else {
              final double waveY = (obs.initialY + math.sin(obs.animPhase) * (20.0 + diff * 10.0))
                  .clamp(safeTop, safeBottom);
              obs.position = Offset(obs.baseX, waveY);
            }
          }
          obs.pulseScale = 1.0 + math.sin(obs.animPhase * 1.8) * 0.08;
          break;

        case ObstacleType.toothyMicrobe:
          // Patrols floor contour back and forth + snaps/lunges when player closes in
          final double patrolRange = 36.0 + diff * 22.0;
          double nextX = obs.position.dx + obs.velocityX * obsPace * activeMult * dt;
          if (nextX > obs.baseX + patrolRange) {
            nextX = obs.baseX + patrolRange;
            obs.velocityX = -obs.velocityX.abs();
          } else if (nextX < obs.baseX - patrolRange) {
            nextX = obs.baseX - patrolRange;
            obs.velocityX = obs.velocityX.abs();
          }
          final double localFloor = tunnel.getFloorY(nextX, gameTime) - 24.0;
          double lungeLift = 0.0;
          if (distToPlayer < 190.0 && !obs.isStunned) {
            obs.triggerTimer = 0.40;
            lungeLift = (16.0 + diff * 14.0) *
                (0.5 + 0.5 * math.sin(obs.animPhase * 2.8).abs());
          }
          obs.position = Offset(nextX, (localFloor - lungeLift).clamp(safeTop, localFloor));
          obs.pulseScale = 1.0 + math.sin(obs.animPhase * 1.6) * 0.06;
          break;

        case ObstacleType.bioFilament:
          final double swayMax = 15.0 + diff * 10.0;
          obs.swayOffset = math.sin(obs.animPhase * 1.15) * swayMax * activeMult;
          obs.pulseScale = 0.96 + math.sin(obs.animPhase * 0.9) * (0.12 + diff * 0.08);
          final double cY = tunnel.getCeilingY(obs.baseX, gameTime);
          obs.position = Offset(
            obs.baseX + obs.swayOffset * 0.55,
            cY + obs.height * obs.pulseScale * 0.5,
          );
          break;

        case ObstacleType.inflammatoryZone:
          final double driftScale = obs.isSoothed ? 0.3 : 1.0;
          obs.pulseScale = 1.0 + math.sin(obs.animPhase * 1.9) * (0.11 + diff * 0.06);
          final double driftX = obs.baseX + math.cos(obs.animPhase * 0.65) * 16.0 * driftScale;
          final double driftY = (obs.initialY +
                  math.sin(obs.animPhase * 0.85) * (14.0 + diff * 10.0) * driftScale)
              .clamp(safeTop, safeBottom);
          obs.position = Offset(driftX, driftY);
          break;

        case ObstacleType.mucosalSpike:
          // Rhythmic extension & retraction polyp cycle (always leaves wide fair gap)
          final double rawCycle = (math.sin(obs.animPhase * 0.95) + 1.0) * 0.5;
          obs.pulseScale = (0.22 + rawCycle * 0.82).clamp(0.22, 1.04);
          if (rawCycle > 0.35 && rawCycle < 0.65) {
            obs.triggerTimer = 0.25;
          }
          final bool fromCeiling = obs.variant % 2 == 1;
          final double anchor = fromCeiling ? ceilY : floorY;
          final double halfReach = obs.height * obs.pulseScale * 0.5;
          obs.position = Offset(
            obs.baseX,
            fromCeiling ? anchor + halfReach : anchor - halfReach,
          );
          break;
      }
    }
  }

  void _updateBoss(double dt) {
    if (boss.isDefeated) return;

    // Smooth health bar ghost-damage trail interpolation
    boss.displayedHealthRatio +=
        (boss.healthRatio - boss.displayedHealthRatio) * math.min(1.0, 4.8 * dt);

    final double pace = stagePaceMultiplier;
    boss.animPhase += dt * (boss.isPhase3 ? 3.8 : (boss.isPhase2 ? 3.1 : 2.1)) * (0.9 + pace * 0.1);
    if (boss.hitTimer > 0) {
      boss.hitTimer = math.max(0.0, boss.hitTimer - dt);
      if (boss.hitTimer <= 0) {
        boss.isHit = false;
      }
    }
    if (boss.attackAnimTimer > 0) {
      boss.attackAnimTimer = math.max(0.0, boss.attackAnimTimer - dt);
    }
    if (boss.dodgeCooldown > 0) {
      boss.dodgeCooldown = math.max(0.0, boss.dodgeCooldown - dt);
    }
    if (boss.dodgeTimer > 0) {
      boss.dodgeTimer = math.max(0.0, boss.dodgeTimer - dt);
    }

    if (state != GameState.bossFight) {
      final hoverY = (tunnel.baseCeiling + tunnel.baseFloor) / 2 + math.sin(boss.animPhase) * 26.0;
      boss.position = Offset(boss.position.dx, hoverY);
      return;
    }

    // Dramatic Phase 2 Awakening shockwave when dropping below 50% HP
    if (!boss.phase2Announced && boss.isPhase2) {
      boss.phase2Announced = true;
      screenShake = 0.9;
      _emitHitSparks(boss.position, color: const Color(0xFFFB7185));
      _addFloatingText(
        'PHASE 2 • FURIE DU BOSS !',
        boss.position + const Offset(-45, -82),
        const Color(0xFFFB7185),
      );
      audio.playBossPhase2();
    }

    // Phase 3 overdrive warning at <= 25% HP (Stages 4-7 & Revision)
    if (!boss.phase3Announced && boss.isPhase3 && level >= 4) {
      boss.phase3Announced = true;
      screenShake = 0.85;
      _emitHitSparks(boss.position, color: const Color(0xFFFBBF24));
      _addFloatingText(
        'PHASE CRITIQUE !',
        boss.position + const Offset(-35, -82),
        const Color(0xFFFDE047),
      );
      audio.playBossPhase2();
    }

    // Periodic Support Pickups inside Boss Chamber so player never gets stuck!
    arenaSupportTimer -= dt;
    if (arenaSupportTimer <= 0) {
      arenaSupportTimer = player.hearts <= 1 ? 5.8 : 9.5;
      final dropType = player.hearts < player.maxHearts
          ? CollectibleType.heartBoost
          : (math.Random().nextBool() ? CollectibleType.shieldBoost : CollectibleType.weaponUpgrade);
      collectibles.add(
        ArcadeCollectible(
          id: 9500 + (_nextDynamicId++),
          position: Offset(
            cameraX + 40.0,
            viewportHeight * (0.28 + math.Random().nextDouble() * 0.44),
          ),
          type: dropType,
          xpValue: 50,
          scoreValue: 100,
        ),
      );
      _addFloatingText('SOUTIEN MÉDICAL !', Offset(cameraX + 120, viewportHeight * 0.35), const Color(0xFF34D399));
    }

    // Sweeping Boss Laser Beam active phase
    if (boss.currentPattern == BossAttackPattern.laserBeamFire) {
      boss.beamTimer -= dt;
      boss.beamTargetY += boss.beamSweepDelta * dt;
      boss.facingTilt = -0.06;
      if (boss.beamTimer <= 0) {
        boss.currentPattern = BossAttackPattern.hoverSpread;
        boss.beamTimer = 0.0;
        boss.attackCooldown = boss.isPhase2 ? 1.35 : 1.8;
      }
      return;
    }

    // Live Boss Attack State Machine (Charge Dash)
    if (boss.currentPattern == BossAttackPattern.chargeDash) {
      boss.position += boss.velocity * dt;
      boss.facingTilt = -0.18;
      if (boss.position.dx <= cameraX + viewportWidth * 0.34 || boss.attackCooldown <= 0) {
        boss.currentPattern = BossAttackPattern.hoverSpread;
        boss.velocity = Offset.zero;
        boss.attackCooldown = boss.isPhase2 ? 1.3 : 1.85;
      } else {
        boss.attackCooldown -= dt;
      }
      return;
    }

    // Reactive Boss dodge if player lands sustained hits in one lane
    if (boss.burstHitsTaken >= 4 && boss.dodgeCooldown <= 0 && !boss.isTelegraphing) {
      boss.burstHitsTaken = 0;
      boss.dodgeCooldown = boss.isPhase2 ? 2.4 : 3.2;
      boss.dodgeTimer = 0.65;
      boss.verticalDodgeOffset = (boss.position.dy >= player.position.dy ? 1.0 : -1.0) *
          (viewportHeight * 0.24);
    }

    // Reactive player-tracking hover + corridor safety clamping
    final double bossCeil = tunnel.getCeilingY(boss.position.dx, gameTime) + 78.0;
    final double bossFloor = tunnel.getFloorY(boss.position.dx, gameTime) - 78.0;
    final double dodgeOffset = boss.dodgeTimer > 0 ? boss.verticalDodgeOffset : 0.0;
    final double trackWeight = boss.isPhase2 ? 0.60 : 0.42;
    final double targetHoverY = (viewportHeight * 0.5 * (1.0 - trackWeight) +
            player.position.dy * trackWeight +
            math.sin(boss.animPhase * 0.95) * (viewportHeight * 0.16) +
            dodgeOffset)
        .clamp(math.min(bossCeil, bossFloor), math.max(bossCeil, bossFloor));

    final double stalkOffsetX = (player.position.dx - boss.homePosition.dx).abs() > 360
        ? -28.0
        : (boss.isHit ? 14.0 : 0.0);
    final double targetBossX = boss.homePosition.dx + stalkOffsetX;

    final double moveRateY = (boss.dodgeTimer > 0 ? 6.5 : (boss.isPhase2 ? 4.6 : 3.4)) * dt;
    final double prevY = boss.position.dy;
    final newBossX = boss.position.dx + (targetBossX - boss.position.dx) * math.min(1.0, 4.2 * dt);
    final newBossY = boss.position.dy + (targetHoverY - boss.position.dy) * math.min(1.0, moveRateY);
    boss.position = Offset(newBossX, newBossY);

    final double instVy = (newBossY - prevY) / math.max(0.001, dt);
    boss.facingTilt += ((instVy / 380.0).clamp(-0.22, 0.22) - boss.facingTilt) * math.min(1.0, 8.0 * dt);

    if (boss.telegraphTimer > 0) {
      boss.telegraphTimer -= dt;
      if (boss.telegraphTimer <= 0) {
        _executeBossPattern();
      }
      return;
    }

    boss.attackCooldown -= dt * (0.92 + pace * 0.08);
    if (boss.attackCooldown <= 0) {
      _chooseNextBossTelegraph();
    }
  }

  void _chooseNextBossTelegraph() {
    _bossAttackIndex++;
    final bool allowBeam = level >= 3 || isRevisionStage;
    final int cycleCount = boss.isPhase2 ? (allowBeam ? 6 : 5) : (allowBeam ? 5 : 4);
    final mod = _bossAttackIndex % cycleCount;
    if (mod == 0) {
      boss.currentPattern = BossAttackPattern.hoverSpread;
      boss.telegraphTimer = 0.62;
    } else if (mod == 1) {
      boss.currentPattern = BossAttackPattern.waveSweep;
      boss.telegraphTimer = 0.62;
    } else if (mod == 2) {
      boss.currentPattern = BossAttackPattern.chargeTelegraph;
      boss.chargeTargetY = player.position.dy.clamp(
        tunnel.getCeilingY(boss.position.dx, gameTime) + 64.0,
        tunnel.getFloorY(boss.position.dx, gameTime) - 64.0,
      );
      boss.telegraphTimer = 0.88; // Clear visual aim line before lunging!
    } else if (mod == 3) {
      boss.currentPattern = BossAttackPattern.radialBurst;
      boss.telegraphTimer = 0.70;
    } else if (mod == 4 && allowBeam) {
      boss.currentPattern = BossAttackPattern.laserBeamTelegraph;
      boss.beamTargetY = player.position.dy.clamp(
        tunnel.getCeilingY(boss.position.dx, gameTime) + 56.0,
        tunnel.getFloorY(boss.position.dx, gameTime) - 56.0,
      );
      boss.beamSweepDelta = boss.beamTargetY > viewportHeight * 0.5 ? -48.0 : 48.0;
      boss.telegraphTimer = 0.85;
    } else {
      boss.currentPattern = BossAttackPattern.spawnMinions;
      boss.telegraphTimer = 0.60;
    }
    audio.playTargetLock();
  }

  void _executeBossPattern() {
    final speedMul = (boss.isPhase3 ? 1.28 : (boss.isPhase2 ? 1.18 : 1.0)) *
        (0.92 + stagePaceMultiplier * 0.08);
    boss.attackAnimTimer = 0.34;

    switch (boss.currentPattern) {
      case BossAttackPattern.hoverSpread:
        final count = boss.isPhase3 ? 5 : (boss.isPhase2 ? 5 : 3);
        final baseDir = (player.position - boss.position);
        final baseAngle = baseDir.distance > 0 ? math.atan2(baseDir.dy, baseDir.dx) : math.pi;
        for (int i = 0; i < count; i++) {
          final spreadOffset = (i - (count - 1) / 2) * 0.24;
          final angle = baseAngle + spreadOffset;
          enemyProjectiles.add(
            CapsuleProjectile(
              position: boss.position + const Offset(-45, 0),
              velocity: Offset(math.cos(angle), math.sin(angle)) * (255.0 * speedMul),
              damage: 1,
              color: const Color(0xFFFB7185),
              radius: 7.8,
              isEnemy: true,
              lifeTime: 4.0,
            ),
          );
        }
        audio.playBossAttack();
        boss.attackCooldown = boss.isPhase2 ? 1.40 : 1.90;
        break;

      case BossAttackPattern.waveSweep:
        for (int i = -2; i <= 2; i++) {
          if (i == 0 && !boss.isPhase2) continue;
          if (i == 1 && boss.isPhase2) continue;
          enemyProjectiles.add(
            CapsuleProjectile(
              position: boss.position + Offset(-48, i * 26.0),
              velocity: Offset(-280.0 * speedMul, i * 32.0),
              damage: 1,
              color: const Color(0xFFFB923C),
              radius: 7.2,
              isEnemy: true,
              lifeTime: 4.0,
            ),
          );
        }
        audio.playBossAttack();
        boss.attackCooldown = boss.isPhase2 ? 1.38 : 1.85;
        break;

      case BossAttackPattern.chargeTelegraph:
        boss.position = Offset(boss.position.dx, boss.chargeTargetY);
        boss.currentPattern = BossAttackPattern.chargeDash;
        boss.velocity = Offset(-460.0 * speedMul, 0.0);
        boss.attackCooldown = 1.05;
        audio.playThruster();
        break;

      case BossAttackPattern.radialBurst:
        final int spokeCount = boss.isPhase2 ? 7 : 5;
        for (int s = 0; s < spokeCount; s++) {
          final double frac = s / math.max(1, spokeCount - 1);
          final double ang = math.pi + (frac - 0.5) * 1.45;
          enemyProjectiles.add(
            CapsuleProjectile(
              position: boss.position + Offset(math.cos(ang), math.sin(ang)) * 38.0,
              velocity: Offset(math.cos(ang), math.sin(ang)) * (235.0 * speedMul),
              damage: 1,
              color: const Color(0xFFA78BFA),
              radius: 7.2,
              isEnemy: true,
              lifeTime: 4.2,
            ),
          );
        }
        audio.playBossAttack();
        boss.attackCooldown = boss.isPhase2 ? 1.45 : 1.95;
        break;

      case BossAttackPattern.laserBeamTelegraph:
        boss.currentPattern = BossAttackPattern.laserBeamFire;
        boss.beamTimer = 0.65;
        audio.playBossLaser();
        screenShake = math.max(screenShake, 0.45);
        break;

      case BossAttackPattern.spawnMinions:
        final spawnCount = enemies.length < 2 ? 2 : 1;
        for (int s = 0; s < spawnCount; s++) {
          enemies.add(
            ArcadeEnemy(
              id: _nextDynamicId++,
              position: boss.position + Offset(-55.0, s == 0 ? -55.0 : 55.0),
              velocity: const Offset(-65.0, 0.0),
              type: s == 0 ? EnemyType.spikeVirion : EnemyType.helicoGrub,
              maxHp: 3 + (level.clamp(1, 7) / 4).floor(),
              radius: 18.0,
              scoreReward: 140,
              xpReward: 32,
            ),
          );
        }
        boss.attackCooldown = 1.7;
        break;

      case BossAttackPattern.chargeDash:
      case BossAttackPattern.laserBeamFire:
        break;
    }
  }

  void _updateParticles(double dt) {
    if (particles.length > 150) {
      particles.removeRange(0, particles.length - 150);
    }
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
      if (dist < player.radius + item.radius + 4.0) {
        item.isCollected = true;
        crystalsCollected++;
        earnedXp += item.xpValue;
        score += item.scoreValue * (1 + (combo / 4).floor());
        combo++;
        if (combo > highestCombo) highestCombo = combo;
        player.triggerCollectFlash();
        // Stage 3 Small Intestine villi absorption bonus: shaves Special cooldown slightly on pickup!
        if (level == 3 && player.specialSkillCooldown > 0) {
          player.specialSkillCooldown = math.max(0.0, player.specialSkillCooldown - 0.6);
        }

        audio.playCrystal();
        if (combo % 5 == 0) {
          audio.playCombo();
        }

        if (item.type == CollectibleType.heartBoost) {
          player.heal();
          _addFloatingText('+1 CŒUR !', item.position, const Color(0xFF34D399));
        } else if (item.type == CollectibleType.shieldBoost) {
          player.activateShield(5.0);
          _addFloatingText('BOUCLIER 5s !', item.position, const Color(0xFF22D3EE));
        } else if (item.type == CollectibleType.weaponUpgrade) {
          player.activateDoubleShot(8.0);
          _addFloatingText('SURVOLTAGE ARME !', item.position, const Color(0xFF38BDF8));
        } else {
          _addFloatingText('+${item.xpValue} XP', item.position, const Color(0xFFFBBF24));
        }

        _emitCollectParticles(item.position, item.type);
      }
    }

    // 2. Player Projectiles vs Enemies & Obstacles & Boss
    for (int pIdx = playerProjectiles.length - 1; pIdx >= 0; pIdx--) {
      final p = playerProjectiles[pIdx];
      bool removeBullet = false;

      // Player projectiles interact meaningfully with obstacles too:
      // - Soothe inflammatory zones with Electric Wave or Therapeutic Orbs
      // - Briefly stagger dynamic biological obstacles (toothyMicrobe, spikyVirus, bioFilament, mucosalSpike)
      for (final obs in obstacles) {
        if (obs.type == ObstacleType.inflammatoryZone &&
            !obs.isSoothed &&
            (p.weaponType == WeaponType.electricWave || p.weaponType == WeaponType.therapeuticOrbs)) {
          if ((p.position - obs.position).distance < p.radius + obs.radius + 8.0) {
            obs.sootheTimer = 5.0;
            _emitCollectParticles(obs.position, CollectibleType.heartBoost);
          }
        } else if ((obs.type == ObstacleType.toothyMicrobe ||
                obs.type == ObstacleType.spikyVirus ||
                obs.type == ObstacleType.mucosalSpike) &&
            !obs.isStunned &&
            (p.position - obs.position).distance < p.radius + obs.radius + 2.0) {
          obs.stunTimer = 1.25;
          _emitHitSparks(obs.position, color: p.color);
          score += 10;
          if (!p.isPiercing) {
            removeBullet = true;
            break;
          }
        }
      }

      for (final enemy in enemies) {
        if (enemy.isDead) continue;
        if (p.hitEnemyIds.contains(enemy.id)) continue;

        final dist = (p.position - enemy.position).distance;
        if (dist < p.radius + enemy.radius) {
          final dir = p.position - enemy.position;
          final normDir = dir.distance > 1.0 ? -dir / dir.distance : const Offset(1, 0);
          enemy.takeDamage(p.damage, hitDirection: normDir);
          p.hitEnemyIds.add(enemy.id);
          if (!p.isPiercing) removeBullet = true;

          audio.playEnemyHit();
          _emitHitSparks(p.position, color: p.color);

          if (enemy.isDead) {
            _onEnemyDefeated(enemy, dropChance: 0.30);
          }
          if (removeBullet) break;
        }
      }

      if (!removeBullet && state == GameState.bossFight && !boss.isDefeated) {
        final dist = (p.position - boss.position).distance;
        if (dist < p.radius + 68.0 && !p.hitEnemyIds.contains(-999)) {
          boss.takeDamage(p.damage);
          p.hitEnemyIds.add(-999);
          removeBullet = true;
          audio.playEnemyHit();
          _emitHitSparks(p.position, color: player.isMaxSynergy ? const Color(0xFFFBBF24) : p.color);
          score += 45 * p.damage;
          earnedXp += 4;
          if (player.isMaxSynergy) {
            _addFloatingText('CRITIQUE -${p.damage}', boss.position + const Offset(-30, -55), const Color(0xFFFBBF24));
          }
          if (boss.isDefeated) {
            _startBossDefeatSequence();
          }
        }
      }

      if (removeBullet) {
        playerProjectiles.removeAt(pIdx);
      }
    }

    // 3. Enemy Projectiles vs Player
    for (int epIdx = enemyProjectiles.length - 1; epIdx >= 0; epIdx--) {
      final ep = enemyProjectiles[epIdx];
      final dist = (player.position - ep.position).distance;
      if (dist < player.radius + ep.radius) {
        if (player.isShieldActive) {
          player.triggerShieldDeflect();
          _emitShieldDeflect(player.position);
          _addFloatingText('DÉVIÉ !', player.position + const Offset(0, -25), const Color(0xFF22D3EE));
        } else if (!player.isInvulnerable) {
          _damagePlayer();
        }
        enemyProjectiles.removeAt(epIdx);
      }
    }

    // 4. Physical Contact with Enemies
    for (final enemy in enemies) {
      if (enemy.isDead) continue;
      final dist = (player.position - enemy.position).distance;
      if (dist < player.radius + enemy.radius) {
        if (player.isShieldActive) {
          player.triggerShieldDeflect();
          _emitShieldDeflect(player.position);
          enemy.takeDamage(4, hitDirection: const Offset(1, 0));
          if (enemy.isDead) {
            _onEnemyDefeated(enemy, dropChance: 0.30);
          }
          _addFloatingText('CHOC BOUCLIER !', enemy.position + const Offset(0, -20), const Color(0xFF22D3EE));
        } else if (!player.isInvulnerable) {
          _damagePlayer();
          break;
        }
      }
    }

    // 5. Boss Physical Collision & Sweeping Laser Beam in Arena
    if (state == GameState.bossFight && !boss.isDefeated && !player.isInvulnerable) {
      if (boss.isFiringBeam &&
          player.position.dx < boss.position.dx - 30.0 &&
          (player.position.dy - boss.beamTargetY).abs() < player.radius + 16.0) {
        if (player.isShieldActive) {
          player.triggerShieldDeflect();
          _emitShieldDeflect(player.position);
        } else {
          _damagePlayer();
        }
      } else if ((player.position - boss.position).distance < player.radius + 58.0) {
        if (player.isShieldActive) {
          player.triggerShieldDeflect();
          _emitShieldDeflect(player.position);
          player.velocity = const Offset(-180.0, 0.0);
        } else {
          _damagePlayer();
          player.velocity = const Offset(-180.0, 0.0);
        }
      }
    }

    // 6. Obstacles (ignores soothed inflammatory zones & retracted mucosal spikes!)
    if (!player.isInvulnerable) {
      for (final obs in obstacles) {
        if (obs.isSoothed) continue;
        if (obs.type == ObstacleType.mucosalSpike && obs.pulseScale < 0.35) {
          continue;
        }
        bool hit = false;
        if (obs.type == ObstacleType.bioFilament) {
          final dx = (player.position.dx - obs.position.dx).abs();
          final dy = (player.position.dy - obs.position.dy).abs();
          hit = dx < (player.radius + 10.0) &&
              dy < (player.radius + obs.height * obs.pulseScale * 0.44);
        } else if (obs.type == ObstacleType.mucosalSpike) {
          final dx = (player.position.dx - obs.position.dx).abs();
          final dy = (player.position.dy - obs.position.dy).abs();
          hit = dx < (player.radius + obs.radius * 0.65) &&
              dy < (player.radius + obs.height * obs.pulseScale * 0.44);
        } else {
          hit = (player.position - obs.position).distance < (player.radius + obs.radius - 2.0);
        }
        if (hit) {
          _damagePlayer();
          break;
        }
      }
    }

    // 7. Educational Checkpoints (smooth portal deceleration + clear nearby projectiles)
    if (state == GameState.playing && _pendingCheckpoint == null) {
      for (final cp in checkpoints) {
        if (!cp.isTriggered && player.position.dx >= cp.worldX - 42.0) {
          cp.isTriggered = true;
          _pendingCheckpoint = cp;
          checkpointWarpTimer = 0.34;
          player.isShooting = false;
          enemyProjectiles.removeWhere((ep) => (ep.position - player.position).distance < 280.0);
          audio.playCheckpointOpen();
          break;
        }
      }
    }

    // 8. Entering Boss Chamber!
    if (state == GameState.playing && player.position.dx >= totalDistance - 950.0) {
      state = GameState.bossIntro;
      bossIntroTimer = 2.5;
      enemyProjectiles.clear();
      audio.playBossEntrance();
      audio.startBossBgm();
      notifyListeners();
    }
  }

  void _damagePlayer() {
    player.takeDamage();
    combo = 0;
    screenShake = 0.85;
    audio.playHit();
    _addFloatingText('-1 CŒUR', player.position + const Offset(0, -25), const Color(0xFFFB7185));
    _emitHitSparks(player.position, color: const Color(0xFFFB7185));
    if (player.hearts <= 0) {
      _onPlayerZeroHearts();
    }
  }

  void _onPlayerZeroHearts() {
    // Pedagogical safeguard: Student NEVER loses indefinitely or gets locked out!
    revivesCount++;
    player.hearts = 2;
    player.activateShield(3.0);
    audio.playRevive();
    _addFloatingText('SOUTIEN IMMUNITAIRE !', player.position + const Offset(0, -35), const Color(0xFF34D399));
  }

  /// Validates an educational checkpoint and upgrades capsule power!
  void answerCheckpoint({required int selectedOptionIndex, required bool isCorrect}) {
    if (activeCheckpoint == null) return;

    final cp = activeCheckpoint!;
    cp.isCompleted = true;
    cp.isAnswerCorrect = isCorrect;

    if (revisionNumber != null) {
      revisionAnswersInStage[cp.question.id] = isCorrect;
      progress.recordRevisionAnswer(
        revisionNumber: revisionNumber!,
        questionId: cp.question.id,
        selectedOptionIndex: selectedOptionIndex,
        isCorrect: isCorrect,
        earnedXp: isCorrect ? 100 : 35,
      );
    } else {
      progress.recordQuestionAnswer(
        questionId: cp.question.id,
        selectedOptionIndex: selectedOptionIndex,
        isCorrect: isCorrect,
        earnedXp: isCorrect ? 100 : 35,
        stageId: level,
      );
    }

    if (isCorrect) {
      correctAnswersInStage++;
      if (cp.isRevision) {
        progress.revisionQueue.remove(cp.question.id);
        progress.masteredQuestions.add(cp.question.id);
        _addFloatingText('NOTION MAÎTRISÉE !', player.position + const Offset(0, -45), const Color(0xFFFBBF24));
      }

      // Link knowledge directly to combat effectiveness & weaken the Boss while keeping a real fight!
      player.knowledgeDamageMultiplier = (1.0 + correctAnswersInStage * 0.30).clamp(1.0, 2.5);
      player.weaponPowerLevel = (1 + (correctAnswersInStage / 2).floor()).clamp(1, 4);
      final minBossFloor = (boss.maxHp * 0.55).round();
      if (boss.currentHp > minBossFloor) {
        boss.takeDamage(math.min(3, boss.currentHp - minBossFloor));
      }

      if (wrongAnswersInStage == 0 && correctAnswersInStage >= checkpoints.length && checkpoints.isNotEmpty) {
        player.knowledgeDamageMultiplier = 2.5;
        player.weaponPowerLevel = 4;
        player.hasSuperAttack = true;
        player.specialSkillCooldown = 0.0;
        player.activateDoubleShot(30.0);
        _addFloatingText('SYNERGIE MAXIMALE ! SUPER ATTAQUE PRÊTE !', player.position + const Offset(0, -48), const Color(0xFFFBBF24));
      }

      earnedXp += 100;
      score += 300;
      combo += 2;
      if (combo > highestCombo) highestCombo = combo;
      if (combo >= 2) {
        player.specialSkillCooldown = 0.0; // Combo streak charges Special!
      }
      player.boostTimer = 3.0;
      player.invulnerableTimer = math.max(player.invulnerableTimer, 2.0);
      player.heal();
      audio.playCorrect();
      _addFloatingText('+30% ARME • -3 PV BOSS', player.position + const Offset(55, -36), const Color(0xFF35D39A));
    } else {
      wrongAnswersInStage++;
      combo = 0;
      earnedXp += 35;
      audio.playWrong();
      // Generous grace invulnerability shield when resuming gameplay after reading
      player.invulnerableTimer = 2.5;
      _addFloatingText('EXPLICATION VALIDÉE', player.position + const Offset(55, -36), const Color(0xFFFFB547));
    }

    // Clear nearby enemy projectiles so student never takes an unfair hit right on resume
    enemyProjectiles.removeWhere((ep) => (ep.position - player.position).distance < 260.0);

    _pendingCheckpoint = null;
    checkpointWarpTimer = 0.0;
    activeCheckpoint = null;
    state = GameState.playing;
    notifyListeners();
  }

  /// Backward-compatible Boss tactical hit helper (if triggered directly in unit tests or finale)
  void answerBossQuestion({required int questionId, required int selectedOptionIndex, required bool isCorrect}) {
    if (revisionNumber != null) {
      revisionAnswersInStage[questionId] = isCorrect;
      progress.recordRevisionAnswer(
        revisionNumber: revisionNumber!,
        questionId: questionId,
        selectedOptionIndex: selectedOptionIndex,
        isCorrect: isCorrect,
        earnedXp: isCorrect ? 120 : 35,
      );
    } else {
      progress.recordQuestionAnswer(
        questionId: questionId,
        selectedOptionIndex: selectedOptionIndex,
        isCorrect: isCorrect,
        earnedXp: isCorrect ? 120 : 35,
        stageId: level,
      );
    }

    if (isCorrect) {
      if (revisionNumber != null || level % 7 == 0) {
        progress.revisionQueue.remove(questionId);
        progress.masteredQuestions.add(questionId);
      }
      boss.takeDamage(boss.currentHp);
      audio.playBossLaser();
      score += 400;
      earnedXp += 150;
      _emitBossLaser();
      if (boss.isDefeated) {
        _completeStageVictory();
      }
    } else {
      _damagePlayer();
      audio.playWrong();
    }

    notifyListeners();
  }

  void _startBossDefeatSequence() {
    isBossDefeated = true;
    state = GameState.bossDefeatAnim;
    bossDefeatTimer = 2.3;
    _bossDefeatBurstTick = 0.0;
    _bossPurifyWaveDone = false;
    enemyProjectiles.clear();
    audio.playBossDefeat();
    _emitVictoryConfetti(burstCount: 48);
    _addFloatingText('BOSS ÉRADIQUÉ !', boss.position, const Color(0xFFFFB547));
    notifyListeners();
  }

  void _completeStageVictory() {
    isBossDefeated = true;
    state = GameState.victory;
    audio.stopBgm();
    audio.playVictory();
    score += 1500;
    earnedXp += 400;

    // Coherent 1 / 2 / 3 star thresholds based on educational mastery (never punitive!)
    final double accuracyRatio = checkpoints.isEmpty
        ? 1.0
        : (correctAnswersInStage / checkpoints.length);
    if (wrongAnswersInStage == 0 && accuracyRatio >= 1.0) {
      lastStarsEarned = 3;
    } else if (accuracyRatio >= 0.5) {
      lastStarsEarned = 2;
    } else {
      lastStarsEarned = 1;
    }

    if (revisionNumber != null) {
      // Track revision stage results separately from the original stageResults
      progress.completeRevisionStage(
        revisionNumber: 1,
        score: score,
        stars: lastStarsEarned,
        correctCount: correctAnswersInStage,
        totalCount: checkpoints.length,
        isBonusChallenge: isBonusRevisionChallenge,
        questionIdsAsked: checkpoints.map((cp) => cp.question.id).toList(),
      );
      progress.updateArcadeStats(
        score: score,
        combo: highestCombo,
        crystals: crystalsCollected,
      );
    } else {
      final previousWeapons = List<String>.from(progress.unlockedWeapons);
      progress.completeLevel(level.clamp(1, 7), lastStarsEarned, score, crystalsCollected);
      progress.updateArcadeStats(
        score: score,
        combo: highestCombo,
        crystals: crystalsCollected,
      );

      if (!previousWeapons.contains(world.unlockedWeaponName)) {
        newlyUnlockedWeapon = world.unlockedWeaponName;
        audio.playRewardUnlock();
      }
    }

    _emitVictoryConfetti(burstCount: 45);
    notifyListeners();
  }

  void _addFloatingText(String text, Offset pos, Color color) {
    if (floatingTexts.length >= 2) {
      floatingTexts.removeAt(0);
    }
    floatingTexts.add(
      FloatingArcadeText(
        text: text,
        position: pos,
        color: color,
        fontSize: 12.0,
        life: 0.90,
        maxLife: 0.90,
      ),
    );
  }

  void _emitThrusterParticles() {
    final rand = math.Random();
    particles.add(
      ArcadeParticle(
        position: player.position + Offset(-player.radius - 6.0, (rand.nextDouble() - 0.5) * 8.0),
        velocity: Offset(-180.0 - rand.nextDouble() * 60.0, (rand.nextDouble() - 0.5) * 35.0),
        color: player.isMaxSynergy ? const Color(0xFFFBBF24) : const Color(0xFF22D3EE),
        size: 3.5 + rand.nextDouble() * 3.5,
        maxLife: 0.32,
      ),
    );
  }

  void _emitCollectParticles(Offset pos, CollectibleType type) {
    final rand = math.Random();
    Color pCol = const Color(0xFFFBBF24);
    if (type == CollectibleType.cellBubble) pCol = const Color(0xFFFB7185);
    if (type == CollectibleType.heartBoost) pCol = const Color(0xFF34D399);
    if (type == CollectibleType.shieldBoost) pCol = const Color(0xFF22D3EE);

    for (int i = 0; i < 10; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 55.0 + rand.nextDouble() * 110.0;
      particles.add(
        ArcadeParticle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: pCol,
          size: 3.0 + rand.nextDouble() * 2.5,
          maxLife: 0.45,
        ),
      );
    }
  }

  void _emitHitSparks(Offset pos, {Color color = const Color(0xFFFB923C)}) {
    final rand = math.Random();
    for (int i = 0; i < 12; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 70.0 + rand.nextDouble() * 140.0;
      particles.add(
        ArcadeParticle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: color,
          size: 3.5 + rand.nextDouble() * 2.5,
          maxLife: 0.48,
        ),
      );
    }
  }

  void _emitSplashParticles(Offset pos, Color color) {
    final rand = math.Random();
    for (int i = 0; i < 6; i++) {
      final angle = -math.pi * rand.nextDouble();
      final speed = 40.0 + rand.nextDouble() * 65.0;
      particles.add(
        ArcadeParticle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: color,
          size: 3.0 + rand.nextDouble() * 2.5,
          maxLife: 0.35,
        ),
      );
    }
  }

  void _emitBossLaser() {
    final start = player.position;
    final end = boss.position;
    const count = 20;
    for (int i = 0; i < count; i++) {
      final t = i / count;
      final pos = Offset.lerp(start, end, t)!;
      particles.add(
        ArcadeParticle(
          position: pos,
          velocity: Offset((math.Random().nextDouble() - 0.5) * 40.0, (math.Random().nextDouble() - 0.5) * 40.0),
          color: const Color(0xFF22D3EE),
          size: 4.5,
          maxLife: 0.35,
        ),
      );
    }
  }

  void _emitMuzzleParticles(Offset pos, Color color) {
    final rand = math.Random();
    for (int i = 0; i < 5; i++) {
      final angle = (rand.nextDouble() - 0.5) * 0.7;
      final speed = 80.0 + rand.nextDouble() * 70.0;
      particles.add(
        ArcadeParticle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: color,
          size: 2.8 + rand.nextDouble() * 2.2,
          maxLife: 0.20,
        ),
      );
    }
  }

  void _emitShieldDeflect(Offset pos) {
    final rand = math.Random();
    for (int i = 0; i < 10; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 75.0 + rand.nextDouble() * 110.0;
      particles.add(
        ArcadeParticle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: const Color(0xFF22D3EE),
          size: 3.5 + rand.nextDouble() * 2.5,
          maxLife: 0.32,
        ),
      );
    }
  }

  void _emitExplosion(Offset pos, EnemyType type) {
    final rand = math.Random();
    Color expColor = const Color(0xFF38BDF8);
    if (type == EnemyType.cytokineBlob || type == EnemyType.acidSentry) {
      expColor = const Color(0xFFFB923C);
    } else if (type == EnemyType.toxicSpore) {
      expColor = const Color(0xFF34D399);
    }

    for (int i = 0; i < 20; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 85.0 + rand.nextDouble() * 170.0;
      particles.add(
        ArcadeParticle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: rand.nextBool() ? expColor : const Color(0xFFFFFFFF),
          size: 3.5 + rand.nextDouble() * 4.0,
          maxLife: 0.50,
        ),
      );
    }
  }

  void _emitVictoryConfetti({int burstCount = 60}) {
    final rand = math.Random();
    final colors = [
      const Color(0xFFFBBF24),
      const Color(0xFF22D3EE),
      const Color(0xFF34D399),
      const Color(0xFFFB7185),
      const Color(0xFFFFFFFF),
    ];
    for (int i = 0; i < burstCount; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 110.0 + rand.nextDouble() * 250.0;
      particles.add(
        ArcadeParticle(
          position: boss.position + Offset((rand.nextDouble() - 0.5) * 40, (rand.nextDouble() - 0.5) * 40),
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: colors[rand.nextInt(colors.length)],
          size: 4.5 + rand.nextDouble() * 4.5,
          maxLife: 1.25,
        ),
      );
    }
  }

  double get progressFraction {
    return (player.position.dx / math.max(1.0, totalDistance - 900.0)).clamp(0.0, 1.0);
  }
}
