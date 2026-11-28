import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nursing_adventure/arcade/arcade_game_controller.dart';
import 'package:nursing_adventure/arcade/arcade_models.dart';
import 'package:nursing_adventure/arcade/weapon_system.dart';
import 'package:nursing_adventure/main.dart';
import 'package:nursing_adventure/models/game_progress.dart';
import 'package:nursing_adventure/models/gastro_question.dart';
import 'package:nursing_adventure/screens/capsule_warriors_revision_stage_screen.dart';
import 'package:nursing_adventure/screens/capsule_warriors_world_select_screen.dart';
import 'package:nursing_adventure/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Per-Player Isolation, Session Refresh & New Game Reset Tests', () {
    test('New visitor starts fresh at Stage 1 without inheriting previous player progress', () async {
      SharedPreferences.setMockInitialValues({});
      String? tabSessionA;
      String? tabSessionB;

      final storage = StorageService();

      // Player A plays in Tab/Session A up to Stage 4 with score & mistakes
      storage.configureForTest(
        readSessionId: () => tabSessionA,
        writeSessionId: (id) => tabSessionA = id,
        eraseSessionId: () => tabSessionA = null,
      );
      final playerA = await storage.loadProgress();
      playerA.playerName = 'Alice';
      playerA.recordQuestionAnswer(
        questionId: 2,
        selectedOptionIndex: 0,
        isCorrect: false,
        stageId: 1,
      );
      playerA.completeStage(1, 3, 1800);
      playerA.completeStage(2, 2, 2100);
      playerA.completeStage(3, 3, 2400);
      await storage.saveProgress(playerA);
      expect(playerA.currentStage, 4);
      expect(playerA.totalScore, 6300);

      // Brand-new Player B opens the link in a fresh browser/tab (tabSessionB == null)
      storage.configureForTest(
        readSessionId: () => tabSessionB,
        writeSessionId: (id) => tabSessionB = id,
        eraseSessionId: () => tabSessionB = null,
      );
      final playerB = await storage.loadProgress();
      expect(playerB.playerId, isNot(equals(playerA.playerId)));
      expect(playerB.currentStage, 1);
      expect(playerB.totalScore, 0);
      expect(playerB.totalXP, 0);
      expect(playerB.completedCount, 0);
      expect(playerB.revisionQueue, isEmpty);
      expect(playerB.getMistakesForCycle(1), isEmpty);
      expect(playerB.isWorldUnlocked(2), false);

      // Simulate refreshing Tab A -> preserves Alice without mixing with Player B
      storage.configureForTest(
        readSessionId: () => tabSessionA,
        writeSessionId: (id) => tabSessionA = id,
        eraseSessionId: () => tabSessionA = null,
      );
      final refreshedAlice = await storage.loadProgress();
      expect(refreshedAlice.playerId, playerA.playerId);
      expect(refreshedAlice.playerName, 'Alice');
      expect(refreshedAlice.currentStage, 4);
      expect(refreshedAlice.totalScore, 6300);
      expect(refreshedAlice.getMistakesForCycle(1), [2]);

      // Simulate Player B playing Stage 1 cleanly & refreshing Tab B -> keeps ONLY Bob
      playerB.playerName = 'Bob';
      playerB.recordQuestionAnswer(
        questionId: 4,
        selectedOptionIndex: 0,
        isCorrect: false,
        stageId: 1,
      );
      playerB.completeStage(1, 2, 950);
      await storage.saveProgress(playerB);

      storage.configureForTest(
        readSessionId: () => tabSessionB,
        writeSessionId: (id) => tabSessionB = id,
        eraseSessionId: () => tabSessionB = null,
      );
      final refreshedBob = await storage.loadProgress();
      expect(refreshedBob.playerId, playerB.playerId);
      expect(refreshedBob.currentStage, 2);
      expect(refreshedBob.totalScore, 950);
      expect(refreshedBob.getMistakesForCycle(1), [4]); // Never sees Alice's [2]!

      // Returning player recovery via switchPlayer
      final recoveredAlice = await storage.switchPlayer(playerA.playerId);
      expect(recoveredAlice.playerName, 'Alice');
      expect(recoveredAlice.currentStage, 4);

      // New Game / reset affects ONLY current player (Alice), preserving Bob intact
      await storage.clearProgress();
      final resetAlice = await storage.loadProgress();
      expect(resetAlice.currentStage, 1);
      expect(resetAlice.totalScore, 0);
      expect(resetAlice.completedCount, 0);
      expect(resetAlice.getMistakesForCycle(1), isEmpty);

      final stillIntactBob = await storage.switchPlayer(playerB.playerId);
      expect(stillIntactBob.currentStage, 2);
      expect(stillIntactBob.totalScore, 950);
      expect(stillIntactBob.getMistakesForCycle(1), [4]);

      storage.configureForTest();
    });

    testWidgets('Home UI allows returning player selection & New Game confirmation reset', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({});
      String? sessionId;
      final storage = StorageService();
      storage.configureForTest(
        readSessionId: () => sessionId,
        writeSessionId: (id) => sessionId = id,
        eraseSessionId: () => sessionId = null,
      );

      // Pre-populate returning player Sara cleanly
      final sara = await storage.startNewPlayerSession(customName: 'Sara');
      sara.completeStage(1, 3, 1500);
      await storage.saveProgress(sara);

      // Open Home Screen in active session as Sara
      await tester.pumpWidget(const CapsuleWarriorsApp());
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('Sara'), findsOneWidget);
      expect(find.text('NOUVELLE PARTIE'), findsOneWidget);

      // Tap NOUVELLE PARTIE -> shows confirmation modal
      await tester.tap(find.text('NOUVELLE PARTIE'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('CONFIRMER'), findsOneWidget);
      expect(find.text('ANNULER'), findsOneWidget);

      // Cancel preserves Sara's progress
      await tester.tap(find.text('ANNULER'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(storage.currentProgress.totalScore, 1500);

      // Confirm resets ONLY Sara back to Stage 1
      await tester.tap(find.text('NOUVELLE PARTIE'));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.tap(find.text('CONFIRMER'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(storage.currentProgress.currentStage, 1);
      expect(storage.currentProgress.totalScore, 0);
      expect(find.text('Aucune mission en cours'), findsOneWidget);

      storage.configureForTest();
    });
  });

  group('Obstacle Behavior, Variety, Stagger Interaction & Scaling Tests', () {
    test('Obstacles show lively motion, mucosalSpike cycle, stagger reaction & higher stage challenge', () {
      final p1 = GameProgress();
      final c1 = ArcadeGameController(level: 1, progress: p1);
      c1.start();

      final typesPresent = c1.obstacles.map((o) => o.type).toSet();
      expect(typesPresent.length, greaterThanOrEqualTo(4));

      // Explicitly place key obstacle types to verify deterministic behavior & interaction
      final microbe = ArcadeObstacle(
        id: 801,
        position: const Offset(500, 400),
        initialX: 500,
        initialY: 400,
        velocityX: 40.0,
        type: ObstacleType.toothyMicrobe,
      );
      final virus = ArcadeObstacle(
        id: 802,
        position: const Offset(620, 240),
        initialX: 620,
        initialY: 240,
        type: ObstacleType.spikyVirus,
        variant: 0,
      );
      final droplet = ArcadeObstacle(
        id: 803,
        position: const Offset(720, 90),
        initialX: 720,
        initialY: 90,
        velocityY: 95.0,
        triggerTimer: 0.1,
        type: ObstacleType.acidDroplet,
      );
      final spike = ArcadeObstacle(
        id: 804,
        position: const Offset(820, 410),
        initialX: 820,
        initialY: 410,
        type: ObstacleType.mucosalSpike,
        height: 68.0,
        variant: 0,
      );
      c1.obstacles.addAll([microbe, virus, droplet, spike]);

      final initMicrobePos = microbe.position;
      final initVirusPos = virus.position;

      for (int i = 0; i < 12; i++) {
        c1.update(0.05);
      }

      expect(microbe.position.dx, isNot(closeTo(initMicrobePos.dx, 0.5)));
      expect(virus.position, isNot(equals(initVirusPos)));
      expect(droplet.position.dy, greaterThan(95.0)); // Finished telegraph & started falling
      expect(spike.pulseScale, greaterThan(0.2));

      // Verify player projectile briefly staggers obstacle when hitting it
      c1.playerProjectiles.add(
        CapsuleProjectile(
          position: virus.position,
          velocity: const Offset(400, 0),
          damage: 2,
          color: const Color(0xFF22D3EE),
          weaponType: WeaponType.medicalLaser,
        ),
      );
      c1.update(0.02);
      expect(virus.isStunned, true);

      // Verify generous spacing between questions & higher stage pace across 1..7
      expect(c1.totalDistance, greaterThanOrEqualTo(5800.0));
      for (int i = 1; i < c1.checkpoints.length; i++) {
        final gap = c1.checkpoints[i].worldX - c1.checkpoints[i - 1].worldX;
        expect(gap, greaterThanOrEqualTo(900.0));
      }

      final c7 = ArcadeGameController(level: 7, progress: GameProgress());
      expect(c7.stagePaceMultiplier, greaterThan(c1.stagePaceMultiplier));
      expect(c7.boss.maxHp, greaterThan(c1.boss.maxHp));
    });
  });

  group('7 Original Stages + Single Special Revision Stage Verification', () {
    test('Stages 1-7 track only mistakes for ONE special Revision Stage & never unlock Stage 8', () {
      final p = GameProgress(playerId: 'cycle_tester', playerName: 'Nadia');

      // Ensure another player's mistake cannot enter Nadia's revision stage
      final otherPlayer = GameProgress(playerId: 'other', playerName: 'Other');
      otherPlayer.recordQuestionAnswer(
        questionId: 17,
        selectedOptionIndex: 0,
        isCorrect: false,
        stageId: 4,
      );

      // Complete all 7 original stages with specific mistakes [2, 11]
      for (int s = 1; s <= 7; s++) {
        final ctrl = ArcadeGameController(level: s, progress: p);
        ctrl.start();
        for (final cp in ctrl.checkpoints) {
          ctrl.activeCheckpoint = cp;
          final bool makeMistake = cp.question.id == 2 || cp.question.id == 11;
          final optIdx = makeMistake
              ? (cp.question.correctOptionIndex + 1) % cp.question.options.length
              : cp.question.correctOptionIndex;
          ctrl.answerCheckpoint(selectedOptionIndex: optIdx, isCorrect: !makeMistake);
        }
        ctrl.answerBossQuestion(
          questionId: ctrl.boss.challengeQuestions.first.id,
          selectedOptionIndex: ctrl.boss.challengeQuestions.first.correctOptionIndex,
          isCorrect: true,
        );
        expect(ctrl.state, GameState.victory);
      }

      // Strictly 7 original stages; Stage 8 must NEVER unlock; ONE special Revision Stage unlocks
      expect(p.currentStage, 7);
      expect(p.isWorldUnlocked(8), false);
      expect(p.isRevisionStageUnlocked(1), true);
      expect(p.isRevisionStageUnlocked(2), false);
      expect(p.activePendingRevision, 1);
      expect(p.getMistakesForCycle(1), unorderedEquals([2, 11]));

      final originalStage1Score = p.stageResults[1]!.score;
      final originalStage1Stars = p.stageResults[1]!.stars;

      // Run Special Revision Stage -> asks ONLY Nadia's missed questions [2, 11] with original text & answers
      final revCtrl = ArcadeGameController(
        level: 7,
        revisionNumber: 1,
        progress: p,
      );
      expect(revCtrl.isRevisionStage, true);
      expect(revCtrl.checkpoints.map((c) => c.question.id).toList(), [2, 11]);
      for (final cp in revCtrl.checkpoints) {
        final original = allGastroQuestions.firstWhere((q) => q.id == cp.question.id);
        expect(cp.question.questionText, original.questionText);
        expect(cp.question.correctOptionIndex, original.correctOptionIndex);
        expect(cp.question.options, original.options);
      }

      // Master both missed questions in the Revision Stage
      revCtrl.start();
      for (final cp in revCtrl.checkpoints) {
        revCtrl.activeCheckpoint = cp;
        revCtrl.answerCheckpoint(
          selectedOptionIndex: cp.question.correctOptionIndex,
          isCorrect: true,
        );
      }
      revCtrl.answerBossQuestion(
        questionId: revCtrl.boss.challengeQuestions.first.id,
        selectedOptionIndex: revCtrl.boss.challengeQuestions.first.correctOptionIndex,
        isCorrect: true,
      );
      expect(revCtrl.state, GameState.victory);

      // Revision results stored separately; original Stage 1..7 untouched; still only 7 stages!
      expect(p.isRevisionStageCompleted(1), true);
      expect(p.revisionStageResults[1]!.correctCount, 2);
      expect(p.revisionStageResults[1]!.totalCount, 2);
      expect(p.stageResults[1]!.score, originalStage1Score);
      expect(p.stageResults[1]!.stars, originalStage1Stars);
      expect(p.currentStage, 7);
      expect(p.isWorldUnlocked(8), false);
      expect(p.getMistakesForCycle(1), isEmpty);

      // Clean-sweep 0-mistake player check
      final perfectPlayer = GameProgress(playerId: 'perfect', playerName: 'Sami');
      for (int s = 1; s <= 7; s++) {
        final ctrl = ArcadeGameController(level: s, progress: perfectPlayer);
        ctrl.start();
        for (final cp in ctrl.checkpoints) {
          ctrl.activeCheckpoint = cp;
          ctrl.answerCheckpoint(
            selectedOptionIndex: cp.question.correctOptionIndex,
            isCorrect: true,
          );
        }
        ctrl.answerBossQuestion(
          questionId: ctrl.boss.challengeQuestions.first.id,
          selectedOptionIndex: ctrl.boss.challengeQuestions.first.correctOptionIndex,
          isCorrect: true,
        );
      }
      expect(perfectPlayer.isRevisionStageUnlocked(1), true);
      expect(perfectPlayer.getMistakesForCycle(1), isEmpty);
    });

    testWidgets('Revision Stage Screen displays congratulatory UI on 0 mistakes & WorldSelect shows 7 stages + 1 revision card', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final p = GameProgress(playerId: 'perf', playerName: 'Amira');
      for (int s = 1; s <= 7; s++) {
        p.completeStage(s, 3, 1200);
      }

      await tester.pumpWidget(
        MaterialApp(
          home: CapsuleWarriorsRevisionStageScreen(
            revisionNumber: 1,
            progress: p,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(tester.takeException(), isNull);
      expect(find.text('STAGE DE RÉVISION SPÉCIAL'), findsOneWidget);
      expect(find.textContaining('FÉLICITATIONS'), findsOneWidget);
      expect(find.text('VOIR MON DIPLÔME FINAL'), findsOneWidget);
      expect(find.textContaining('STAGE 8'), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          home: CapsuleWarriorsWorldSelectScreen(progress: p),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('RÉVISION FINALE'),
        350.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('RÉVISION FINALE'), findsOneWidget);
      expect(find.textContaining('Cycle 2'), findsNothing);
    });
  });
}
