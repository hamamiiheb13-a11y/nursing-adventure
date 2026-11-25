import 'package:flutter_test/flutter_test.dart';
import 'package:nursing_adventure/models/gastro_question.dart';
import 'package:nursing_adventure/models/gastro_world.dart';
import 'package:nursing_adventure/models/game_progress.dart';

void main() {
  group('Gastro Quest 27 Questions & 7 Worlds Validation', () {
    test('Must contain exactly 27 questions from the official PFE questionnaire and 7 worlds', () {
      expect(allGastroQuestions.length, 27);
      expect(GastroWorld.worlds.length, 7);
      for (int i = 0; i < 7; i++) {
        expect(GastroWorld.worlds[i].id, i + 1);
        expect(GastroWorld.worlds[i].bossName.isNotEmpty, true);
        expect(GastroWorld.worlds[i].organZone.isNotEmpty, true);
        expect(GastroWorld.worlds[i].acquiredSkills.isNotEmpty, true);
      }
    });

    test('Questions distribution across worlds must be 4, 5, 3, 5, 7, 3, and dynamic revision in World 7', () {
      final w1 = allGastroQuestions.where((q) => q.worldId == 1).toList();
      final w2 = allGastroQuestions.where((q) => q.worldId == 2).toList();
      final w3 = allGastroQuestions.where((q) => q.worldId == 3).toList();
      final w4 = allGastroQuestions.where((q) => q.worldId == 4).toList();
      final w5 = allGastroQuestions.where((q) => q.worldId == 5).toList();
      final w6 = allGastroQuestions.where((q) => q.worldId == 6).toList();

      expect(w1.length, 4, reason: 'Monde 1 must have 4 questions (Q1-Q4)');
      expect(w2.length, 5, reason: 'Monde 2 must have 5 questions (Q5-Q9)');
      expect(w3.length, 3, reason: 'Monde 3 must have 3 questions (Q10-Q12)');
      expect(w4.length, 5, reason: 'Monde 4 must have 5 questions (Q13-Q17)');
      expect(w5.length, 7, reason: 'Monde 5 must have 7 questions (Q18-Q24)');
      expect(w6.length, 3, reason: 'Monde 6 must have 3 questions (Q25-Q27)');
      expect(GastroWorld.worlds[6].questionIds.isEmpty, true, reason: 'Monde 7 is dynamic revision mode');

      expect(w1.length + w2.length + w3.length + w4.length + w5.length + w6.length, 27);
    });

    test('Every question has valid options, correct index, explanation, and educational summary card', () {
      for (int i = 0; i < allGastroQuestions.length; i++) {
        final q = allGastroQuestions[i];
        expect(q.id, i + 1, reason: 'Question id must match index + 1');
        expect(q.questionText.isNotEmpty, true);
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.correctOptionIndex, inInclusiveRange(0, q.options.length - 1));
        expect(q.explanation.isNotEmpty, true);
        expect(q.anatomicalTheme.isNotEmpty, true);
        expect(q.ficheTitle.isNotEmpty, true);
        expect(q.fichePoints.isNotEmpty, true);

        // Check options are non-empty
        for (final opt in q.options) {
          expect(opt.isNotEmpty, true);
        }
      }
    });

    test('Question IDs are consecutive from 1 to 27', () {
      for (int i = 0; i < 27; i++) {
        expect(allGastroQuestions[i].id, i + 1);
        expect(allGastroQuestions[i].originalNumber, i + 1);
      }
    });
  });

  group('GameProgress Logic & Persistence', () {
    test('Initial progress starts at Stage 1 unlocked', () {
      final progress = GameProgress();
      expect(progress.currentStage, 1);
      expect(progress.isWorldUnlocked(1), true);
      expect(progress.isWorldUnlocked(2), false);
      expect(progress.completedCount, 0);
      expect(progress.totalXP, 0);
    });

    test('Completing Stage 1 unlocks Stage 2 and updates stats', () {
      final progress = GameProgress();
      progress.answerQuestion(1, true);
      progress.completeStage(1, 3, 500);

      expect(progress.isWorldCompleted(1), true);
      expect(progress.currentStage, 2);
      expect(progress.isWorldUnlocked(2), true);
      expect(progress.isWorldUnlocked(3), false);
      expect(progress.totalXP, 350); // 50 for question + 3*100 for stage
      expect(progress.getStars(1), 3);
      expect(progress.correctCount, 1);
    });

    test('Incorrect answer adds question to revision queue', () {
      final progress = GameProgress();
      progress.answerQuestion(1, false);

      expect(progress.revisionQueue.contains(1), true);
      expect(progress.masteredQuestions.contains(1), false);
      expect(progress.questionsInRevisionCount, 1);

      // Answering correctly later removes it from revision and masters it
      progress.answerQuestion(1, true);
      expect(progress.revisionQueue.contains(1), false);
      expect(progress.masteredQuestions.contains(1), true);
    });

    test('Serialization and deserialization preserve full state', () {
      final progress = GameProgress();
      progress.answerQuestion(1, true, selectedOptionIndex: 0);
      progress.answerQuestion(2, false, selectedOptionIndex: 1);
      progress.completeStage(1, 3, 1000);

      final jsonString = progress.serialize();
      final restored = GameProgress.deserialize(jsonString);

      expect(restored.currentStage, 2);
      expect(restored.completedCount, 1);
      expect(restored.getStars(1), 3);
      expect(restored.userAnswers[1], 0);
      expect(restored.userAnswers[2], 1);
      expect(restored.questionsAnswered[1], true);
      expect(restored.questionsAnswered[2], false);
      expect(restored.revisionQueue.contains(2), true);
    });

    test('Completing all 7 stages unlocks final state', () {
      final progress = GameProgress();
      for (int i = 1; i <= 7; i++) {
        progress.completeStage(i, 3, 1000);
      }
      expect(progress.completedCount, 7);
      for (int i = 1; i <= 7; i++) {
        expect(progress.isWorldCompleted(i), true);
      }
    });
  });
}
