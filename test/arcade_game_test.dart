import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nursing_adventure/models/gastro_question.dart';
import 'package:nursing_adventure/models/gastro_world.dart';
import 'package:nursing_adventure/models/game_progress.dart';
import 'package:nursing_adventure/arcade/arcade_models.dart';
import 'package:nursing_adventure/arcade/arcade_game_controller.dart';
import 'package:nursing_adventure/arcade/enemy_system.dart';
import 'package:nursing_adventure/arcade/weapon_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CapsulePlayer & Physics Unit Tests', () {
    test('CapsulePlayer starts with 3 hearts and standard radius', () {
      final player = CapsulePlayer();
      expect(player.hearts, 3);
      expect(player.maxHearts, 3);
      expect(player.isInvulnerable, false);
      expect(player.isShieldActive, false);
      expect(player.isBoosted, false);
      expect(player.radius, 18.0);
    });

    test('Activating shield gives invulnerability without heart loss', () {
      final player = CapsulePlayer();
      player.activateShield(4.0);
      expect(player.isShieldActive, true);
      expect(player.isInvulnerable, true);

      // Taking damage with shield active does not reduce hearts
      player.takeDamage();
      expect(player.hearts, 3);
    });

    test('Taking damage reduces heart and triggers invulnerability period', () {
      final player = CapsulePlayer();
      player.takeDamage();
      expect(player.hearts, 2);
      expect(player.isInvulnerable, true);
      expect(player.invulnerableTimer, greaterThan(0.0));

      // Damage during invulnerability is ignored
      player.takeDamage();
      expect(player.hearts, 2);
    });

    test('Healing restores hearts up to maxHearts', () {
      final player = CapsulePlayer(hearts: 1, maxHearts: 3);
      player.heal();
      expect(player.hearts, 2);
      player.heal();
      expect(player.hearts, 3);
      player.heal(); // Already at max
      expect(player.hearts, 3);
    });
  });

  group('TunnelGeometry & Peristalsis Tests', () {
    test('Tunnel calculates undulating ceiling and floor', () {
      final world = GastroWorld.worlds.first;
      final tunnel = TunnelGeometry(levelLength: 5000.0, world: world);

      final ceil1 = tunnel.getCeilingY(100.0, 0.0);
      final floor1 = tunnel.getFloorY(100.0, 0.0);

      expect(ceil1, greaterThan(30.0));
      expect(floor1, greaterThan(ceil1 + 150.0)); // Plentiful lumen height

      // Boss arena expands at the end of the level
      final bossCeil = tunnel.getCeilingY(4800.0, 0.0);
      final bossFloor = tunnel.getFloorY(4800.0, 0.0);
      expect(bossFloor - bossCeil, greaterThan(floor1 - ceil1));
    });
  });

  group('ArcadeGameController & Educational Checkpoints Integration', () {
    test('Level 1 initializes with World 1, all 4 stage checkpoints, and live 2D boss', () {
      final progress = GameProgress();
      final controller = ArcadeGameController(level: 1, progress: progress);

      expect(controller.world.id, 1);
      expect(controller.checkpoints.length, 4);
      expect(controller.collectibles.isNotEmpty, true);
      expect(controller.obstacles.isNotEmpty, true);
      expect(controller.boss.name, 'Helicobacter Rex');
      expect(controller.boss.maxHp, 56);
      expect(controller.boss.currentHp, 56);

      // Checkpoint questions match official PDF questions for Stage 1
      for (final cp in controller.checkpoints) {
        expect(allGastroQuestions.contains(cp.question), true);
        expect(cp.question.worldId, 1);
        expect(cp.question.originalNumber, inInclusiveRange(1, 27));
      }
    });

    test('Analog movement vector and Anti-Inflammatory Special Skill work properly', () {
      final progress = GameProgress();
      final controller = ArcadeGameController(level: 1, progress: progress);
      controller.start();

      // Test analog movement vector
      const inputVec = Offset(0.6, -0.8);
      controller.setMoveVector(inputVec);
      expect(controller.player.moveInput.dx, closeTo(0.6, 0.01));
      expect(controller.player.moveInput.dy, closeTo(-0.8, 0.01));

      // Place a nearby inflammatory zone hazard to verify Special Skill soothing
      final hazard = ArcadeObstacle(
        id: 7777,
        position: controller.player.position + const Offset(80.0, 0.0),
        type: ObstacleType.inflammatoryZone,
        initialY: controller.player.position.dy,
      );
      controller.obstacles.add(hazard);
      expect(hazard.isSoothed, false);

      // Test special skill (Anti-Inflammatory Wave)
      expect(controller.player.specialSkillCooldown, 0.0);
      controller.triggerSpecialSkill();
      expect(controller.player.specialSkillCooldown, greaterThan(0.0));
      expect(controller.screenShake, greaterThan(0.0));
      expect(hazard.isSoothed, true);
    });

    test('Correct checkpoint answers boost knowledge damage multiplier and trigger Max Synergy', () {
      final progress = GameProgress();
      final controller = ArcadeGameController(level: 1, progress: progress);
      controller.start();

      expect(controller.player.knowledgeDamageMultiplier, 1.0);

      for (final cp in controller.checkpoints) {
        controller.activeCheckpoint = cp;
        controller.answerCheckpoint(
          selectedOptionIndex: cp.question.correctOptionIndex,
          isCorrect: true,
        );
      }

      expect(controller.earnedXp, 400);
      expect(controller.combo, greaterThanOrEqualTo(4));
      expect(controller.player.isBoosted, true);
      expect(controller.player.knowledgeDamageMultiplier, 2.5);
      expect(controller.player.isMaxSynergy, true);
      expect(progress.isLevelCompleted(1), false); // Level completed when defeating boss
      for (final cp in controller.checkpoints) {
        expect(progress.masteredQuestions.contains(cp.question.id), true);
      }
    });

    test('Incorrect checkpoint answer records mistake to Revision Queue without soft-locking', () {
      final progress = GameProgress();
      final controller = ArcadeGameController(level: 1, progress: progress);
      controller.start();

      final cp = controller.checkpoints.first;
      controller.activeCheckpoint = cp;

      final wrongIndex = (cp.question.correctOptionIndex + 1) % cp.question.options.length;

      controller.answerCheckpoint(
        selectedOptionIndex: wrongIndex,
        isCorrect: false,
      );

      expect(controller.player.hearts, 3); // Positive educational flow, generous grace shield
      expect(controller.player.invulnerableTimer, greaterThanOrEqualTo(2.0));
      expect(controller.wrongAnswersInStage, 1);
      expect(progress.revisionQueue.contains(cp.question.id), true);
      expect(progress.masteredQuestions.contains(cp.question.id), false);
      expect(progress.questionsInRevisionCount, 1);
    });

    test('Answering a revision question correctly removes it from queue and marks as Mastered', () {
      final progress = GameProgress();
      progress.revisionQueue.add(4); // Q4 in revision

      expect(progress.revisionQueue.contains(4), true);
      expect(progress.masteredQuestions.contains(4), false);

      // Answer correctly
      progress.recordQuestionAnswer(
        questionId: 4,
        selectedOptionIndex: allGastroQuestions[3].correctOptionIndex,
        isCorrect: true,
      );

      expect(progress.revisionQueue.contains(4), false);
      expect(progress.masteredQuestions.contains(4), true);
      expect(progress.questionsInRevisionCount, 0);
      expect(progress.questionsMasteredCount, 1);
    });

    test('Live Boss enters Phase 2 at half HP and awards 1/2/3 stars coherently', () {
      final progress = GameProgress();
      final controller = ArcadeGameController(level: 1, progress: progress);
      controller.start();

      // Answer all 4 checkpoints right first (+3 direct Boss HP chip each & Super Attack unlocked)
      for (final cp in controller.checkpoints) {
        controller.activeCheckpoint = cp;
        controller.answerCheckpoint(
          selectedOptionIndex: cp.question.correctOptionIndex,
          isCorrect: true,
        );
      }

      final boss = controller.boss;
      expect(boss.currentHp, 44); // 56 - 4 * 3 direct pedagogical damage
      expect(controller.player.hasSuperAttack, true);
      expect(boss.isPhase2, false);
      expect(boss.isDefeated, false);

      // Deal 16 damage -> drops to 28 (<= half of 56) -> Phase 2
      boss.takeDamage(16);
      expect(boss.currentHp, 28);
      expect(boss.isPhase2, true);
      expect(boss.isDefeated, false);

      // Final tactical blow -> Defeat + 3 Stars (0 errors) + Stage 2 & Weapon unlocked
      controller.answerBossQuestion(
        questionId: allGastroQuestions.first.id,
        selectedOptionIndex: allGastroQuestions.first.correctOptionIndex,
        isCorrect: true,
      );
      expect(boss.currentHp, 0);
      expect(boss.isDefeated, true);
      expect(controller.state, GameState.victory);
      expect(controller.lastStarsEarned, 3);
      expect(progress.isLevelCompleted(1), true);
      expect(progress.isLevelUnlocked(2), true);
      expect(progress.unlockedWeapons.contains('Double Laser Océan'), true);

      // Controller with 1 mistake & < 50% right (0/4) -> 1 star
      final progressLow = GameProgress();
      final c2 = ArcadeGameController(level: 1, progress: progressLow);
      c2.start();
      c2.activeCheckpoint = c2.checkpoints.first;
      c2.answerCheckpoint(
        selectedOptionIndex: (c2.checkpoints.first.question.correctOptionIndex + 1) % 2,
        isCorrect: false,
      );
      c2.answerBossQuestion(
        questionId: allGastroQuestions.first.id,
        selectedOptionIndex: allGastroQuestions.first.correctOptionIndex,
        isCorrect: true,
      );
      expect(c2.state, GameState.victory);
      expect(c2.lastStarsEarned, 1);

      // Controller with 3/4 right (>= 50%) and 1 mistake -> 2 stars
      final progressMid = GameProgress();
      final c3 = ArcadeGameController(level: 1, progress: progressMid);
      c3.start();
      for (int i = 0; i < c3.checkpoints.length; i++) {
        final cp = c3.checkpoints[i];
        c3.activeCheckpoint = cp;
        final isRight = i > 0;
        c3.answerCheckpoint(
          selectedOptionIndex: isRight
              ? cp.question.correctOptionIndex
              : (cp.question.correctOptionIndex + 1) % cp.question.options.length,
          isCorrect: isRight,
        );
      }
      c3.answerBossQuestion(
        questionId: allGastroQuestions.first.id,
        selectedOptionIndex: allGastroQuestions.first.correctOptionIndex,
        isCorrect: true,
      );
      expect(c3.state, GameState.victory);
      expect(c3.lastStarsEarned, 2);
    });

    test('Evolved weapons spawn distinct projectile patterns and respect cooldown', () {
      final progress = GameProgress();
      final controller = ArcadeGameController(level: 1, progress: progress);
      controller.start();

      expect(controller.playerProjectiles.isEmpty, true);

      controller.shoot();
      expect(controller.playerProjectiles.length, greaterThanOrEqualTo(1));
      final countAfterShoot = controller.playerProjectiles.length;

      // Immediate second shot is blocked by cooldown
      controller.shoot();
      expect(controller.playerProjectiles.length, countAfterShoot);

      // Advance time past cooldown & equip 3-way Canon Antibactérien
      controller.update(0.35);
      progress.unlockedWeapons.add('Canon Antibactérien');
      progress.equipWeapon('Canon Antibactérien');
      controller.player.shootCooldownTimer = 0.0;
      controller.playerProjectiles.clear();
      controller.shoot();
      expect(controller.playerProjectiles.length, 3);

      // Equip Orbes Thérapeutiques -> spawns 2 homing orbs
      progress.unlockedWeapons.add('Orbes Thérapeutiques');
      progress.equipWeapon('Orbes Thérapeutiques');
      controller.player.shootCooldownTimer = 0.0;
      controller.playerProjectiles.clear();
      controller.shoot();
      expect(controller.playerProjectiles.length, 2);
      expect(controller.playerProjectiles.every((p) => p.isHoming), true);
    });

    test('Enemies spawn in level and can take damage from player', () {
      final progress = GameProgress();
      final controller = ArcadeGameController(level: 1, progress: progress);
      controller.start();

      expect(controller.enemies.isNotEmpty, true);
      final firstEnemy = controller.enemies.first;
      final initialHp = firstEnemy.currentHp;

      firstEnemy.takeDamage(1);
      expect(firstEnemy.currentHp, initialHp - 1);
      expect(firstEnemy.isFlashing, true);
      expect(firstEnemy.damageWobbleTimer, greaterThan(0.0));
    });

    test('Enemies exhibit distinct dodge, flee, chase, and ranged attack behaviors', () {
      final enemyProjectiles = <CapsuleProjectile>[];
      const playerPos = Offset(200.0, 240.0);

      // 1. HelicoGrub dodges incoming projectile then flees close player
      final evasive = ArcadeEnemy(
        id: 101,
        position: const Offset(300.0, 240.0),
        velocity: const Offset(-45.0, 0.0),
        type: EnemyType.helicoGrub,
        maxHp: 3,
        radius: 18.0,
      );
      final incomingShot = CapsuleProjectile(
        position: const Offset(220.0, 238.0),
        velocity: const Offset(600.0, 0.0),
        damage: 2,
        color: const Color(0xFF22D3EE),
      );
      evasive.update(
        0.05,
        playerPos,
        enemyProjectiles,
        playerProjectiles: [incomingShot],
        ceilY: 60.0,
        floorY: 440.0,
      );
      expect(evasive.isDodging, true);
      expect(evasive.velocity.dy.abs(), greaterThan(5.0));

      // When dodge ends and player is close (<225px), HelicoGrub flees away
      evasive.dodgeTimer = 0.0;
      evasive.dodgeCooldown = 1.0;
      evasive.position = const Offset(320.0, 250.0);
      for (int i = 0; i < 8; i++) {
        evasive.update(0.05, playerPos, enemyProjectiles);
      }
      expect(evasive.isFleeing, true);
      expect(evasive.velocity.dx, greaterThan(0.0));

      // 2. SpikeVirion actively chases player within range
      final chaser = ArcadeEnemy(
        id: 102,
        position: const Offset(480.0, 340.0),
        velocity: const Offset(-40.0, 0.0),
        type: EnemyType.spikeVirion,
        maxHp: 4,
        radius: 19.0,
      );
      for (int i = 0; i < 10; i++) {
        chaser.update(0.05, playerPos, enemyProjectiles);
      }
      expect(chaser.isChasing, true);
      expect(chaser.velocity.dx, lessThan(-60.0));
      expect(chaser.velocity.dy, lessThan(-20.0)); // Steering upward toward y=240

      // 3. CytokineBlob winds up attack and fires aimed projectile
      final shooter = ArcadeEnemy(
        id: 103,
        position: const Offset(460.0, 280.0),
        velocity: const Offset(-30.0, 0.0),
        type: EnemyType.cytokineBlob,
        maxHp: 4,
        radius: 22.0,
        shootCooldown: 0.05,
      );
      for (int i = 0; i < 15; i++) {
        shooter.update(0.05, playerPos, enemyProjectiles);
      }
      expect(enemyProjectiles.isNotEmpty, true);
    });

    test('Game pace increases smoothly and progressively across levels 1..7', () {
      final paces = <double>[];
      for (int lvl = 1; lvl <= 7; lvl++) {
        final ctrl = ArcadeGameController(level: lvl, progress: GameProgress());
        paces.add(ctrl.stagePaceMultiplier);
      }
      expect(paces.first, 1.0);
      for (int i = 1; i < paces.length; i++) {
        expect(paces[i], greaterThan(paces[i - 1]));
        expect(paces[i] - paces[i - 1], lessThanOrEqualTo(0.10));
      }
      expect(paces.last, greaterThan(1.30));
    });

    test('Boss reacts with dodge, diverse attack patterns, and celebratory defeat animation', () {
      final progress = GameProgress();
      final controller = ArcadeGameController(level: 2, progress: progress);
      controller.start();

      // Mark stage checkpoints complete, then enter Boss Fight chamber
      for (final cp in controller.checkpoints) {
        cp.isTriggered = true;
      }
      controller.player.position = Offset(controller.totalDistance - 940.0, 250.0);
      controller.update(0.016);
      expect(controller.state, GameState.bossIntro);

      for (int i = 0; i < 50; i++) {
        controller.update(0.05);
      }
      expect(controller.state, GameState.bossFight);

      // Sustained hits trigger reactive boss dodge
      controller.boss.takeDamage(2);
      controller.boss.takeDamage(2);
      controller.boss.takeDamage(2);
      controller.boss.takeDamage(2);
      controller.update(0.05);
      expect(controller.boss.dodgeTimer, greaterThan(0.0));

      // Boss cycles patterns & fires projectiles across multiple ticks
      bool sawBossProjectiles = false;
      final patternsSeen = <BossAttackPattern>{};
      for (int i = 0; i < 110; i++) {
        controller.update(0.05);
        if (controller.enemyProjectiles.isNotEmpty) {
          sawBossProjectiles = true;
        }
        patternsSeen.add(controller.boss.currentPattern);
      }
      expect(sawBossProjectiles, true);
      expect(patternsSeen.length, greaterThanOrEqualTo(2));

      // Defeat boss via player projectile hit -> triggers bossDefeatAnim -> victory
      controller.boss.takeDamage(controller.boss.currentHp - 1);
      controller.playerProjectiles.add(
        CapsuleProjectile(
          position: controller.boss.position,
          velocity: const Offset(500, 0),
          damage: 2,
          color: const Color(0xFF22D3EE),
        ),
      );
      controller.update(0.02);
      expect(controller.state, GameState.bossDefeatAnim);
      expect(controller.bossDefeatTimer, closeTo(2.3, 0.05));

      for (int i = 0; i < 60; i++) {
        controller.update(0.05);
      }
      expect(controller.state, GameState.victory);
      expect(controller.crystalsCollected >= 0, true);
    });
  });
}
