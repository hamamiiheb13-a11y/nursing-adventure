import 'package:flutter_test/flutter_test.dart';
import 'package:nursing_adventure/models/gastro_question.dart';
import 'package:nursing_adventure/models/gastro_world.dart';
import 'package:nursing_adventure/models/game_progress.dart';

void main() {
  group('Gastro Quest 30 Questions Validation', () {
    test('Must contain exactly 30 questions', () {
      expect(allGastroQuestions.length, 30);
    });

    test('Questions distribution across 6 worlds must be 4, 5, 5, 4, 4, 8', () {
      final w1 = allGastroQuestions.where((q) => q.worldId == 1).toList();
      final w2 = allGastroQuestions.where((q) => q.worldId == 2).toList();
      final w3 = allGastroQuestions.where((q) => q.worldId == 3).toList();
      final w4 = allGastroQuestions.where((q) => q.worldId == 4).toList();
      final w5 = allGastroQuestions.where((q) => q.worldId == 5).toList();
      final w6 = allGastroQuestions.where((q) => q.worldId == 6).toList();

      expect(w1.length, 4, reason: 'Monde 1 must have 4 questions');
      expect(w2.length, 5, reason: 'Monde 2 must have 5 questions');
      expect(w3.length, 5, reason: 'Monde 3 must have 5 questions');
      expect(w4.length, 4, reason: 'Monde 4 must have 4 questions');
      expect(w5.length, 4, reason: 'Monde 5 must have 4 questions');
      expect(w6.length, 8, reason: 'Monde 6 must have 8 questions');

      expect(w1.length + w2.length + w3.length + w4.length + w5.length + w6.length, 30);
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

        // Check options start with letter (A), B), etc.)
        for (final opt in q.options) {
          expect(opt.isNotEmpty, true);
          expect(RegExp(r'^[A-E]\)').hasMatch(opt), true,
              reason: 'Option "$opt" in question ${q.id} must start with letter like A), B), etc.');
        }
      }
    });

    test('Specific PDF question numbers match the original document', () {
      // Q31, Q32, Q42, Q46 in World 1
      expect(allGastroQuestions[0].originalNumber, 31);
      expect(allGastroQuestions[1].originalNumber, 32);
      expect(allGastroQuestions[2].originalNumber, 42);
      expect(allGastroQuestions[3].originalNumber, 46);

      // Q18, Q20, Q30, Q47, Q48 in World 2
      expect(allGastroQuestions[4].originalNumber, 18);
      expect(allGastroQuestions[5].originalNumber, 20);
      expect(allGastroQuestions[6].originalNumber, 30);
      expect(allGastroQuestions[7].originalNumber, 47);
      expect(allGastroQuestions[8].originalNumber, 48);

      // Q5, Q6, Q8, Q10, Q11 in World 3
      expect(allGastroQuestions[9].originalNumber, 5);
      expect(allGastroQuestions[10].originalNumber, 6);
      expect(allGastroQuestions[11].originalNumber, 8);
      expect(allGastroQuestions[12].originalNumber, 10);
      expect(allGastroQuestions[13].originalNumber, 11);

      // Q14, Q16, Q33, Q45 in World 4
      expect(allGastroQuestions[14].originalNumber, 14);
      expect(allGastroQuestions[15].originalNumber, 16);
      expect(allGastroQuestions[16].originalNumber, 33);
      expect(allGastroQuestions[17].originalNumber, 45);

      // Q3, Q12, Q23, Q26 in World 5
      expect(allGastroQuestions[18].originalNumber, 3);
      expect(allGastroQuestions[19].originalNumber, 12);
      expect(allGastroQuestions[20].originalNumber, 23);
      expect(allGastroQuestions[21].originalNumber, 26);

      // Q29, Q38, Q51, Q52, Q60, Q62, Q63, Q65 in World 6
      expect(allGastroQuestions[22].originalNumber, 29);
      expect(allGastroQuestions[23].originalNumber, 38);
      expect(allGastroQuestions[24].originalNumber, 51);
      expect(allGastroQuestions[25].originalNumber, 52);
      expect(allGastroQuestions[26].originalNumber, 60);
      expect(allGastroQuestions[27].originalNumber, 62);
      expect(allGastroQuestions[28].originalNumber, 63);
      expect(allGastroQuestions[29].originalNumber, 65);
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
