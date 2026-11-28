import 'dart:ui';

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

      // Progressive challenge across stages 1..7..14
      final c7 = ArcadeGameController(level: 7, progress: GameProgress());
      final c14 = ArcadeGameController(level: 14, progress: GameProgress());
      expect(c7.stagePaceMultiplier, greaterThan(c1.stagePaceMultiplier));
      expect(c14.stagePaceMultiplier, greaterThan(c7.stagePaceMultiplier));
    });
  });

  group('Automatic Revision Stage Every 7 Stages Full Cycle Verification', () {
    test('Complete Cycle: Stages 1-7 -> Revision Stage 1 -> Stages 8-14 -> Revision Stage 2 -> Zero-Mistake Cycle 3', () {
      final p = GameProgress(playerId: 'cycle_tester', playerName: 'Nadia');

      // Ensure another player's mistake cannot enter Nadia's cycle
      final otherPlayer = GameProgress(playerId: 'other', playerName: 'Other');
      otherPlayer.recordQuestionAnswer(
        questionId: 17,
        selectedOptionIndex: 0,
        isCorrect: false,
        stageId: 4,
      );

      // === CYCLE 1: Complete Stages 1..7 with specific mistakes [2, 11] ===
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

      // Automatically triggers Revision Stage 1, locking Stage 8 until completed
      expect(p.isRevisionStageUnlocked(1), true);
      expect(p.activePendingRevision, 1);
      expect(p.isWorldUnlocked(8), false);
      expect(p.getMistakesForCycle(1), unorderedEquals([2, 11]));

      final originalStage1Score = p.stageResults[1]!.score;
      final originalStage1Stars = p.stageResults[1]!.stars;

      // Run Revision Stage 1 -> asks ONLY Nadia's missed questions [2, 11] with original text & answers
      final rev1Ctrl = ArcadeGameController(
        level: 7,
        revisionNumber: 1,
        progress: p,
      );
      expect(rev1Ctrl.isRevisionStage, true);
      expect(rev1Ctrl.checkpoints.map((c) => c.question.id).toList(), [2, 11]);
      for (final cp in rev1Ctrl.checkpoints) {
        final original = allGastroQuestions.firstWhere((q) => q.id == cp.question.id);
        expect(cp.question.questionText, original.questionText);
        expect(cp.question.correctOptionIndex, original.correctOptionIndex);
        expect(cp.question.options, original.options);
      }

      // Master both missed questions in Revision Stage 1
      rev1Ctrl.start();
      for (final cp in rev1Ctrl.checkpoints) {
        rev1Ctrl.activeCheckpoint = cp;
        rev1Ctrl.answerCheckpoint(
          selectedOptionIndex: cp.question.correctOptionIndex,
          isCorrect: true,
        );
      }
      rev1Ctrl.answerBossQuestion(
        questionId: rev1Ctrl.boss.challengeQuestions.first.id,
        selectedOptionIndex: rev1Ctrl.boss.challengeQuestions.first.correctOptionIndex,
        isCorrect: true,
      );
      expect(rev1Ctrl.state, GameState.victory);

      // Revision results stored SEPARATELY; original Stage 1..7 untouched; Stage 8 now unlocked!
      expect(p.isRevisionStageCompleted(1), true);
      expect(p.revisionStageResults[1]!.correctCount, 2);
      expect(p.revisionStageResults[1]!.totalCount, 2);
      expect(p.stageResults[1]!.score, originalStage1Score);
      expect(p.stageResults[1]!.stars, originalStage1Stars);
      expect(p.isWorldUnlocked(8), true);

      // === CYCLE 2: Complete Stages 8..14 with mistake [Q6, Q21] -> Revision Stage 2 ===
      for (int s = 8; s <= 14; s++) {
        final ctrl = ArcadeGameController(level: s, progress: p);
        ctrl.start();
        for (final cp in ctrl.checkpoints) {
          ctrl.activeCheckpoint = cp;
          final bool makeMistake =
              (s == 9 && cp.question.id == 6) || (s == 12 && cp.question.id == 21);
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
      }

      expect(p.isRevisionStageUnlocked(2), true);
      expect(p.activePendingRevision, 2);
      expect(p.isWorldUnlocked(15), false);
      expect(p.getMistakesForCycle(2), unorderedEquals([6, 21]));

      final rev2Ctrl = ArcadeGameController(
        level: 14,
        revisionNumber: 2,
        progress: p,
      );
      expect(rev2Ctrl.checkpoints.map((c) => c.question.id).toList(), [6, 21]);
      rev2Ctrl.start();
      for (final cp in rev2Ctrl.checkpoints) {
        rev2Ctrl.activeCheckpoint = cp;
        rev2Ctrl.answerCheckpoint(
          selectedOptionIndex: cp.question.correctOptionIndex,
          isCorrect: true,
        );
      }
      rev2Ctrl.answerBossQuestion(
        questionId: rev2Ctrl.boss.challengeQuestions.first.id,
        selectedOptionIndex: rev2Ctrl.boss.challengeQuestions.first.correctOptionIndex,
        isCorrect: true,
      );
      expect(p.isRevisionStageCompleted(2), true);
      expect(p.isWorldUnlocked(15), true);

      // === CYCLE 3: Complete Stages 15..21 with 0 mistakes -> Revision Stage 3 clean-sweep ===
      for (int s = 15; s <= 21; s++) {
        final ctrl = ArcadeGameController(level: s, progress: p);
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
      expect(p.isRevisionStageUnlocked(3), true);
      expect(p.getMistakesForCycle(3), isEmpty);

      // Bonus revision challenge produces 3 curated questions when 0 mistakes were made
      final bonusRev3Ctrl = ArcadeGameController(
        level: 21,
        revisionNumber: 3,
        isBonusRevisionChallenge: true,
        progress: p,
      );
      expect(bonusRev3Ctrl.checkpoints.length, 3);
      bonusRev3Ctrl.start();
      for (final cp in bonusRev3Ctrl.checkpoints) {
        bonusRev3Ctrl.activeCheckpoint = cp;
        bonusRev3Ctrl.answerCheckpoint(
          selectedOptionIndex: cp.question.correctOptionIndex,
          isCorrect: true,
        );
      }
      bonusRev3Ctrl.answerBossQuestion(
        questionId: bonusRev3Ctrl.boss.challengeQuestions.first.id,
        selectedOptionIndex: bonusRev3Ctrl.boss.challengeQuestions.first.correctOptionIndex,
        isCorrect: true,
      );
      expect(p.revisionStageResults[3]!.isBonusChallenge, true);
      expect(p.isRevisionStageCompleted(3), true);
      expect(p.isWorldUnlocked(22), true);
    });

    testWidgets('Revision Stage Screen displays congratulatory bonus UI on 0 mistakes & WorldSelect renders revision card cleanly', (tester) async {
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
      expect(find.text('STAGE DE RÉVISION 1'), findsOneWidget);
      expect(find.textContaining('FÉLICITATIONS'), findsOneWidget);
      expect(find.text('DÉFI BONUS DE RÉVISION'), findsOneWidget);
      expect(find.text('CONTINUER AU STAGE 8'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: CapsuleWarriorsWorldSelectScreen(progress: p),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(tester.takeException(), isNull);
    });
  });
}
