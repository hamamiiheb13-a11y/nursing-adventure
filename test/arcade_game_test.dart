import 'package:flutter_test/flutter_test.dart';
import 'package:nursing_adventure/models/gastro_question.dart';
import 'package:nursing_adventure/models/gastro_world.dart';
import 'package:nursing_adventure/models/game_progress.dart';
import 'package:nursing_adventure/arcade/arcade_models.dart';
import 'package:nursing_adventure/arcade/arcade_game_controller.dart';

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
    test('Level 1 initializes with World 1 and 3 checkpoints plus 1 boss question', () {
      final progress = GameProgress();
      final controller = ArcadeGameController(level: 1, progress: progress);

      expect(controller.world.id, 1);
      expect(controller.checkpoints.length, 3);
      expect(controller.collectibles.isNotEmpty, true);
      expect(controller.obstacles.isNotEmpty, true);
      expect(controller.boss.name, 'Helicobacter Rex');
      expect(controller.boss.challengeQuestions.length, 1);
      expect(controller.boss.currentHp, 1);

      // Checkpoint questions match official questions Q1..Q3
      for (final cp in controller.checkpoints) {
        expect(allGastroQuestions.contains(cp.question), true);
        expect(cp.question.originalNumber, inInclusiveRange(1, 27));
      }
    });

    test('Analog movement vector and EMP special skill work properly', () {
      final progress = GameProgress();
      final controller = ArcadeGameController(level: 1, progress: progress);
      controller.start();

      // Test analog movement vector
      const inputVec = Offset(0.6, -0.8);
      controller.setMoveVector(inputVec);
      expect(controller.player.moveInput, inputVec);

      // Test special skill (EMP Blast)
      expect(controller.player.specialSkillCooldown, 0.0);
      controller.triggerSpecialSkill();
      expect(controller.player.specialSkillCooldown, greaterThan(0.0));
      expect(controller.screenShake, greaterThan(0.0));
    });

    test('Correct checkpoint answer increases XP, combo, and awards speed boost', () {
      final progress = GameProgress();
      final controller = ArcadeGameController(level: 1, progress: progress);
      controller.start();

      final cp = controller.checkpoints.first;
      controller.activeCheckpoint = cp;

      controller.answerCheckpoint(
        selectedOptionIndex: cp.question.correctOptionIndex,
        isCorrect: true,
      );

      expect(controller.earnedXp, 100);
      expect(controller.combo, greaterThan(0));
      expect(controller.player.isBoosted, true);
      expect(progress.isLevelCompleted(1), false); // Level completed when defeating boss
      expect(progress.masteredQuestions.contains(cp.question.id), true);
    });

    test('Incorrect checkpoint answer loses heart and adds to Revision Queue', () {
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

      expect(controller.player.hearts, 2);
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

    test('Boss challenge reduces boss HP on correct answer and completes level on defeat', () {
      final progress = GameProgress();
      final controller = ArcadeGameController(level: 1, progress: progress);
      controller.start();

      final boss = controller.boss;
      expect(boss.currentHp, 1);
      expect(boss.isDefeated, false);

      // Hit 1 - Defeat!
      controller.answerBossQuestion(
        questionId: boss.challengeQuestions[0].id,
        selectedOptionIndex: boss.challengeQuestions[0].correctOptionIndex,
        isCorrect: true,
      );
      expect(boss.currentHp, 0);
      expect(boss.isDefeated, true);
      expect(controller.state, GameState.victory);
      expect(progress.isLevelCompleted(1), true);
      expect(progress.isLevelUnlocked(2), true);
    });

    test('Shooting spawns projectiles and respects cooldown', () {
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

      // Advance time past cooldown
      controller.update(0.35);
      controller.shoot();
      expect(controller.playerProjectiles.length, greaterThan(countAfterShoot));
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
    });
  });
}
