import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nursing_adventure/arcade/checkpoint_question_dialog.dart';
import 'package:nursing_adventure/models/game_progress.dart';
import 'package:nursing_adventure/models/gastro_question.dart';
import 'package:nursing_adventure/models/gastro_world.dart';
import 'package:nursing_adventure/screens/capsule_warriors_briefing_screen.dart';
import 'package:nursing_adventure/screens/capsule_warriors_final_screen.dart';
import 'package:nursing_adventure/screens/capsule_warriors_how_to_play_screen.dart';
import 'package:nursing_adventure/screens/capsule_warriors_pause_screen.dart';
import 'package:nursing_adventure/screens/capsule_warriors_review_screen.dart';
import 'package:nursing_adventure/screens/capsule_warriors_settings_screen.dart';
import 'package:nursing_adventure/screens/capsule_warriors_stage_victory_screen.dart';
import 'package:nursing_adventure/screens/capsule_warriors_world_select_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpAtSize(
    WidgetTester tester,
    Size size,
    Widget child,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: child));
    await tester.pump(const Duration(milliseconds: 250));
  }

  group('Responsive Mobile Portrait & Landscape Screens (Zero Overflow & 27 PDF Questions)', () {
    testWidgets('WorldSelectScreen renders cleanly in portrait & landscape with 27 count', (tester) async {
      final progress = GameProgress();
      await pumpAtSize(tester, const Size(360, 780), CapsuleWarriorsWorldSelectScreen(progress: progress));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('27'), findsWidgets);
      expect(find.textContaining('33'), findsNothing);

      await pumpAtSize(tester, const Size(740, 340), CapsuleWarriorsWorldSelectScreen(progress: progress));
      expect(tester.takeException(), isNull);
    });

    testWidgets('BriefingScreen renders cleanly in portrait & landscape', (tester) async {
      final progress = GameProgress();
      final world2 = GastroWorld.getWorldForLevel(2);
      await pumpAtSize(
        tester,
        const Size(360, 780),
        CapsuleWarriorsBriefingScreen(world: world2, stageId: 2, progress: progress),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('COMMENCER LA MISSION'), findsOneWidget);

      await pumpAtSize(
        tester,
        const Size(740, 340),
        CapsuleWarriorsBriefingScreen(world: world2, stageId: 2, progress: progress),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('CheckpointQuestionDialog fits all 4 options cleanly and validates on short landscape screen', (tester) async {
      final q5 = allGastroQuestions[4]; // 4 options (a..d)
      expect(q5.options.length, 4);

      int? validatedIdx;
      bool? validatedCorrect;

      await pumpAtSize(
        tester,
        const Size(740, 340),
        Scaffold(
          body: CheckpointQuestionDialog(
            question: q5,
            checkpointIndex: 1,
            onAnswerValidated: (idx, isCorrect) {
              validatedIdx = idx;
              validatedCorrect = isCorrect;
            },
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      for (final opt in q5.options) {
        expect(find.textContaining(opt), findsOneWidget);
      }

      // Select the correct option, validate, inspect explanation + whyOthersWrong, then continue
      await tester.tap(find.textContaining(q5.options[q5.correctOptionIndex]));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Valider ma réponse'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.textContaining(q5.explanation), findsOneWidget);
      expect(find.textContaining('POURQUOI LES AUTRES CHOIX NE CONVIENNENT PAS'), findsOneWidget);
      expect(find.text('Poursuivre la mission'), findsOneWidget);

      await tester.tap(find.text('Poursuivre la mission'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(validatedIdx, q5.correctOptionIndex);
      expect(validatedCorrect, true);
    });

    testWidgets('Review, Final, Settings, Pause, Victory & Tutorial fit portrait & landscape cleanly', (tester) async {
      final progress = GameProgress();

      await pumpAtSize(tester, const Size(360, 780), CapsuleWarriorsReviewScreen(progress: progress));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('33'), findsNothing);

      await pumpAtSize(tester, const Size(360, 780), CapsuleWarriorsFinalScreen(progress: progress));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('/ 27'), findsWidgets);
      expect(find.textContaining('33'), findsNothing);

      await pumpAtSize(tester, const Size(360, 780), CapsuleWarriorsSettingsScreen(progress: progress));
      expect(tester.takeException(), isNull);

      await pumpAtSize(tester, const Size(740, 340), CapsuleWarriorsSettingsScreen(progress: progress));
      expect(tester.takeException(), isNull);

      await pumpAtSize(tester, const Size(360, 780), const CapsuleWarriorsHowToPlayScreen());
      expect(tester.takeException(), isNull);

      await pumpAtSize(
        tester,
        const Size(740, 340),
        Scaffold(
          body: CapsuleWarriorsPauseScreen(
            stageId: 1,
            score: 1200,
            onResume: () {},
            onRestart: () {},
            onQuit: () {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);

      await pumpAtSize(
        tester,
        const Size(360, 780),
        Scaffold(
          body: CapsuleWarriorsStageVictoryScreen(
            stageId: 1,
            score: 2400,
            starsOverride: 3,
            questionsCorrect: 4,
            questionsTotal: 4,
            onNextStage: () {},
            onReplay: () {},
            onStageMap: () {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Helicobacter Rex'), findsOneWidget);
      expect(find.textContaining('ERREURS'), findsOneWidget);
      expect(find.textContaining('COMPÉTENCES CLINIQUES ACQUISES'), findsOneWidget);

      await pumpAtSize(
        tester,
        const Size(740, 340),
        Scaffold(
          body: CapsuleWarriorsStageVictoryScreen(
            stageId: 1,
            score: 2400,
            starsOverride: 2,
            questionsCorrect: 3,
            questionsTotal: 4,
            onNextStage: () {},
            onReplay: () {},
            onStageMap: () {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
