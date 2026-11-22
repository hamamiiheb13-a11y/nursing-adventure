import 'package:flutter_test/flutter_test.dart';
import 'package:nursing_adventure/models/gastro_question.dart';
import 'package:nursing_adventure/models/gastro_world.dart';
import 'package:nursing_adventure/models/game_progress.dart';

void main() {
  group('Gastro Quest 33 Questions & 7 Worlds Validation', () {
    test('Must contain exactly 33 questions', () {
      expect(allGastroQuestions.length, 33);
    });

    test('Questions distribution across 7 worlds must be 4, 5, 5, 4, 4, 8, 3', () {
      final w1 = allGastroQuestions.where((q) => q.worldId == 1).toList();
      final w2 = allGastroQuestions.where((q) => q.worldId == 2).toList();
      final w3 = allGastroQuestions.where((q) => q.worldId == 3).toList();
      final w4 = allGastroQuestions.where((q) => q.worldId == 4).toList();
      final w5 = allGastroQuestions.where((q) => q.worldId == 5).toList();
      final w6 = allGastroQuestions.where((q) => q.worldId == 6).toList();
      final w7 = allGastroQuestions.where((q) => q.worldId == 7).toList();

      expect(w1.length, 4, reason: 'Monde 1 must have 4 questions (Q1-Q4)');
      expect(w2.length, 5, reason: 'Monde 2 must have 5 questions (Q5-Q9)');
      expect(w3.length, 5, reason: 'Monde 3 must have 5 questions (Q10-Q14)');
      expect(w4.length, 4, reason: 'Monde 4 must have 4 questions (Q15-Q18)');
      expect(w5.length, 4, reason: 'Monde 5 must have 4 questions (Q19-Q22)');
      expect(w6.length, 8, reason: 'Monde 6 must have 8 questions (Q23-Q30)');
      expect(w7.length, 3, reason: 'Monde 7 must have 3 questions (Q31-Q33)');

      expect(w1.length + w2.length + w3.length + w4.length + w5.length + w6.length + w7.length, 33);
    });

    test('Every question has valid options, correct index, and explanation', () {
      for (int i = 0; i < allGastroQuestions.length; i++) {
        final q = allGastroQuestions[i];
        expect(q.id, i + 1, reason: 'Question id must match index + 1');
        expect(q.questionText.isNotEmpty, true);
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.correctOptionIndex, inInclusiveRange(0, q.options.length - 1));
        expect(q.explanation.isNotEmpty, true);
        expect(q.anatomicalTheme.isNotEmpty, true);

        // Check options are non-empty
        for (final opt in q.options) {
          expect(opt.isNotEmpty, true);
        }
      }
    });

    test('Question IDs are consecutive from 1 to 33', () {
      for (int i = 0; i < 33; i++) {
        expect(allGastroQuestions[i].id, i + 1);
        expect(allGastroQuestions[i].originalNumber, i + 1);
      }
    });
  });

  group('GameProgress Logic & Persistence', () {
    test('Initial progress starts at Level 1 unlocked', () {
      final progress = GameProgress();
      expect(progress.currentUnlockedLevel, 1);
      expect(progress.isLevelUnlocked(1), true);
      expect(progress.isLevelUnlocked(2), false);
      expect(progress.completedCount, 0);
      expect(progress.totalXp, 0);
    });

    test('Completing a level unlocks next level and updates stats', () {
      final progress = GameProgress();
      progress.completeLevel(1, 0, true);

      expect(progress.isLevelCompleted(1), true);
      expect(progress.currentUnlockedLevel, 2);
      expect(progress.isLevelUnlocked(2), true);
      expect(progress.isLevelUnlocked(3), false);
      expect(progress.totalXp, 100);
      expect(progress.getStars(1), 3);
      expect(progress.correctCount, 1);
      expect(progress.wrongCount, 0);
    });

    test('Incorrect answer still unlocks next level for pedagogical progression', () {
      final progress = GameProgress();
      progress.completeLevel(1, 1, false);

      expect(progress.isLevelCompleted(1), true);
      expect(progress.currentUnlockedLevel, 2);
      expect(progress.totalXp, 30);
      expect(progress.getStars(1), 1);
      expect(progress.correctCount, 0);
      expect(progress.wrongCount, 1);
    });

    test('Serialization and deserialization preserve full state', () {
      final progress = GameProgress();
      progress.completeLevel(1, 0, true);
      progress.completeLevel(2, 1, true);
      progress.completeLevel(3, 0, false);

      final jsonString = progress.serialize();
      final restored = GameProgress.deserialize(jsonString);

      expect(restored.currentUnlockedLevel, 4);
      expect(restored.completedCount, 3);
      expect(restored.totalXp, 230); // 100 + 100 + 30
      expect(restored.getStars(1), 3);
      expect(restored.getStars(3), 1);
      expect(restored.userAnswers[2], 1);
      expect(restored.isCorrectMap[2], true);
      expect(restored.isCorrectMap[3], false);
    });

    test('Completing all levels in World 1 unlocks World 1 badge', () {
      final progress = GameProgress();
      progress.completeLevel(1, 0, true);
      progress.completeLevel(2, 1, true);
      progress.completeLevel(3, 2, true);
      progress.completeLevel(4, 0, true);

      expect(progress.isWorldCompleted(1), true);
      expect(progress.unlockedBadges.contains('badge_world_1'), true);
      expect(progress.isWorldUnlocked(2), true);
    });
  });
}
