import 'dart:convert';
import 'gastro_world.dart';

class GameProgress {
  int currentUnlockedLevel;
  Set<int> completedLevels;
  Map<int, int> levelStars; // level -> stars (1, 2, 3)
  Map<int, int> userAnswers; // level -> selectedOptionIndex
  Map<int, bool> isCorrectMap; // level -> boolean
  int totalXp;
  Set<String> unlockedBadges;
  DateTime? lastPlayed;

  // Spaced Repetition & Revision Queue
  List<int> revisionQueue; // Question IDs requiring revision
  Set<int> masteredQuestions; // Question IDs mastered after revision
  Map<int, int> questionAttempts; // questionId -> total attempts
  Map<int, int> questionCorrectCount; // questionId -> correct count
  Map<int, int> questionIncorrectCount; // questionId -> incorrect count

  // Arcade & Weapons specific stats
  int arcadeHighScore;
  int maxCombo;
  int totalCrystals;
  Set<String> unlockedWeapons;
  String equippedWeapon;

  int get totalScore => arcadeHighScore;
  set totalScore(int val) => arcadeHighScore = val;

  GameProgress({
    this.currentUnlockedLevel = 1,
    Set<int>? completedLevels,
    Map<int, int>? levelStars,
    Map<int, int>? userAnswers,
    Map<int, bool>? isCorrectMap,
    this.totalXp = 0,
    Set<String>? unlockedBadges,
    this.lastPlayed,
    List<int>? revisionQueue,
    Set<int>? masteredQuestions,
    Map<int, int>? questionAttempts,
    Map<int, int>? questionCorrectCount,
    Map<int, int>? questionIncorrectCount,
    this.arcadeHighScore = 0,
    this.maxCombo = 0,
    this.totalCrystals = 0,
    Set<String>? unlockedWeapons,
    this.equippedWeapon = 'Laser Médical MK-I',
  })  : completedLevels = completedLevels ?? <int>{},
        levelStars = levelStars ?? <int, int>{},
        userAnswers = userAnswers ?? <int, int>{},
        isCorrectMap = isCorrectMap ?? <int, bool>{},
        unlockedBadges = unlockedBadges ?? <String>{},
        revisionQueue = revisionQueue ?? <int>[],
        masteredQuestions = masteredQuestions ?? <int>{},
        questionAttempts = questionAttempts ?? <int, int>{},
        questionCorrectCount = questionCorrectCount ?? <int, int>{},
        questionIncorrectCount = questionIncorrectCount ?? <int, int>{},
        unlockedWeapons = unlockedWeapons ?? <String>{'Laser Médical MK-I'};

  bool isLevelUnlocked(int level) {
    if (level <= 1) return true;
    return level <= currentUnlockedLevel;
  }

  bool isLevelCompleted(int level) {
    return completedLevels.contains(level);
  }

  int getStars(int level) {
    return levelStars[level] ?? 0;
  }

  int get totalStars {
    return levelStars.values.fold(0, (sum, val) => sum + val);
  }

  int get completedCount => completedLevels.length;

  double get completionPercentage => (completedCount / 33.0).clamp(0.0, 1.0);

  int get correctCount {
    return isCorrectMap.values.where((c) => c == true).length;
  }

  int get wrongCount {
    return completedLevels.length - correctCount;
  }

  double get accuracyRate {
    if (completedLevels.isEmpty) return 0.0;
    return (correctCount / completedLevels.length.toDouble()) * 100.0;
  }

  bool isWorldCompleted(int worldId) {
    final world = GastroWorld.worlds.firstWhere((w) => w.id == worldId);
    for (int lvl = world.startLevel; lvl <= world.endLevel; lvl++) {
      if (!completedLevels.contains(lvl)) return false;
    }
    return true;
  }

  bool isWorldUnlocked(int worldId) {
    if (worldId == 1) return true;
    final world = GastroWorld.worlds.firstWhere((w) => w.id == worldId);
    return isLevelUnlocked(world.startLevel);
  }

  int getCompletedCountInWorld(int worldId) {
    final world = GastroWorld.worlds.firstWhere((w) => w.id == worldId);
    int count = 0;
    for (int lvl = world.startLevel; lvl <= world.endLevel; lvl++) {
      if (completedLevels.contains(lvl)) count++;
    }
    return count;
  }

  int get questionsInRevisionCount => revisionQueue.length;
  int get questionsMasteredCount => masteredQuestions.length;
  int get totalAttemptsCount => questionAttempts.values.fold(0, (sum, val) => sum + val);
  int get totalCorrectAnswersCount => questionCorrectCount.values.fold(0, (sum, val) => sum + val);
  int get totalIncorrectAnswersCount => questionIncorrectCount.values.fold(0, (sum, val) => sum + val);

  void recordQuestionAnswer({
    required int questionId,
    required int selectedOptionIndex,
    required bool isCorrect,
    int earnedXp = 0,
  }) {
    // Record attempts
    questionAttempts[questionId] = (questionAttempts[questionId] ?? 0) + 1;
    userAnswers[questionId] = selectedOptionIndex;
    isCorrectMap[questionId] = isCorrect;

    if (isCorrect) {
      questionCorrectCount[questionId] = (questionCorrectCount[questionId] ?? 0) + 1;
      // If it was in the revision queue, remove it and mark as mastered!
      if (revisionQueue.contains(questionId)) {
        revisionQueue.remove(questionId);
        masteredQuestions.add(questionId);
      } else if (!masteredQuestions.contains(questionId)) {
        masteredQuestions.add(questionId);
      }
    } else {
      questionIncorrectCount[questionId] = (questionIncorrectCount[questionId] ?? 0) + 1;
      // Add to revision queue if not present, and unmark from mastered
      if (!revisionQueue.contains(questionId)) {
        revisionQueue.add(questionId);
      }
      masteredQuestions.remove(questionId);
    }

    if (earnedXp > 0) {
      totalXp += earnedXp;
    }

    lastPlayed = DateTime.now();
    _evaluateBadges();
  }

  void completeLevel(int level, int selectedOptionIndex, bool isCorrect) {
    completedLevels.add(level);

    // Integrate with question repetition tracking
    recordQuestionAnswer(
      questionId: level,
      selectedOptionIndex: selectedOptionIndex,
      isCorrect: isCorrect,
    );

    // Stars: 3 stars if correct, 1 star if incorrect (completed for learning)
    final earnedStars = isCorrect ? 3 : 1;
    final prevStars = levelStars[level] ?? 0;
    if (earnedStars > prevStars) {
      levelStars[level] = earnedStars;
    }

    // XP calculation: 100 XP for correct, 30 XP for learning completion
    final addedXp = isCorrect ? 100 : 30;
    totalXp += addedXp;

    // Unlock next level if not already unlocked
    if (level == currentUnlockedLevel && currentUnlockedLevel < 33) {
      currentUnlockedLevel = level + 1;
    }

    // Unlock weapon for this world if world is completed
    for (final world in GastroWorld.worlds) {
      if (isWorldCompleted(world.id)) {
        unlockedWeapons.add(world.unlockedWeaponName);
      }
    }

    // Check badges
    _evaluateBadges();
    lastPlayed = DateTime.now();
  }

  void equipWeapon(String weaponName) {
    if (unlockedWeapons.contains(weaponName)) {
      equippedWeapon = weaponName;
    }
  }

  void updateArcadeStats({int? score, int? combo, int? crystals}) {
    if (score != null && score > arcadeHighScore) {
      arcadeHighScore = score;
    }
    if (combo != null && combo > maxCombo) {
      maxCombo = combo;
    }
    if (crystals != null) {
      totalCrystals += crystals;
    }
    if (totalCrystals >= 100) {
      unlockedBadges.add('badge_collector');
    }
    if (arcadeHighScore >= 2000) {
      unlockedBadges.add('badge_arcade_pro');
    }
  }

  void _evaluateBadges() {
    // World completion badges
    for (final world in GastroWorld.worlds) {
      if (isWorldCompleted(world.id)) {
        unlockedBadges.add('badge_world_${world.id}');
      }
    }

    // Revision mastery badges
    if (masteredQuestions.length >= 10) {
      unlockedBadges.add('badge_revision_apprentice');
    }
    if (masteredQuestions.length >= 33) {
      unlockedBadges.add('badge_revision_master');
    }

    // Global achievements
    if (completedLevels.isNotEmpty) {
      unlockedBadges.add('badge_first_step');
    }
    if (completedCount >= 16) {
      unlockedBadges.add('badge_halfway');
    }
    if (completedCount >= 33) {
      unlockedBadges.add('badge_master_gastro');
    }
    if (completedCount >= 33 && correctCount == 33) {
      unlockedBadges.add('badge_perfection');
    }
    if (totalXp >= 1500) {
      unlockedBadges.add('badge_xp_veteran');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'currentUnlockedLevel': currentUnlockedLevel,
      'completedLevels': completedLevels.toList(),
      'levelStars': levelStars.map((k, v) => MapEntry(k.toString(), v)),
      'userAnswers': userAnswers.map((k, v) => MapEntry(k.toString(), v)),
      'isCorrectMap': isCorrectMap.map((k, v) => MapEntry(k.toString(), v)),
      'totalXp': totalXp,
      'unlockedBadges': unlockedBadges.toList(),
      'lastPlayed': lastPlayed?.toIso8601String(),
      'revisionQueue': revisionQueue,
      'masteredQuestions': masteredQuestions.toList(),
      'questionAttempts': questionAttempts.map((k, v) => MapEntry(k.toString(), v)),
      'questionCorrectCount': questionCorrectCount.map((k, v) => MapEntry(k.toString(), v)),
      'questionIncorrectCount': questionIncorrectCount.map((k, v) => MapEntry(k.toString(), v)),
      'arcadeHighScore': arcadeHighScore,
      'maxCombo': maxCombo,
      'totalCrystals': totalCrystals,
      'unlockedWeapons': unlockedWeapons.toList(),
      'equippedWeapon': equippedWeapon,
    };
  }

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    final Map<int, int> stars = {};
    if (json['levelStars'] != null) {
      (json['levelStars'] as Map<String, dynamic>).forEach((k, v) {
        final key = int.tryParse(k);
        if (key != null && v is int) stars[key] = v;
      });
    }

    final Map<int, int> answers = {};
    if (json['userAnswers'] != null) {
      (json['userAnswers'] as Map<String, dynamic>).forEach((k, v) {
        final key = int.tryParse(k);
        if (key != null && v is int) answers[key] = v;
      });
    }

    final Map<int, bool> correctMap = {};
    if (json['isCorrectMap'] != null) {
      (json['isCorrectMap'] as Map<String, dynamic>).forEach((k, v) {
        final key = int.tryParse(k);
        if (key != null && v is bool) correctMap[key] = v;
      });
    }

    final completed = (json['completedLevels'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toSet() ??
        <int>{};

    final badges = (json['unlockedBadges'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toSet() ??
        <String>{};

    final revQueue = (json['revisionQueue'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        <int>[];

    final mastered = (json['masteredQuestions'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toSet() ??
        <int>{};

    final Map<int, int> attempts = {};
    if (json['questionAttempts'] != null) {
      (json['questionAttempts'] as Map<String, dynamic>).forEach((k, v) {
        final key = int.tryParse(k);
        if (key != null && v is int) attempts[key] = v;
      });
    }

    final Map<int, int> correctCountMap = {};
    if (json['questionCorrectCount'] != null) {
      (json['questionCorrectCount'] as Map<String, dynamic>).forEach((k, v) {
        final key = int.tryParse(k);
        if (key != null && v is int) correctCountMap[key] = v;
      });
    }

    final Map<int, int> incorrectCountMap = {};
    if (json['questionIncorrectCount'] != null) {
      (json['questionIncorrectCount'] as Map<String, dynamic>).forEach((k, v) {
        final key = int.tryParse(k);
        if (key != null && v is int) incorrectCountMap[key] = v;
      });
    }

    final weapons = (json['unlockedWeapons'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toSet() ??
        <String>{'Laser Médical MK-I'};

    return GameProgress(
      currentUnlockedLevel: (json['currentUnlockedLevel'] as num?)?.toInt() ?? 1,
      completedLevels: completed,
      levelStars: stars,
      userAnswers: answers,
      isCorrectMap: correctMap,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      unlockedBadges: badges,
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.tryParse(json['lastPlayed'] as String)
          : null,
      revisionQueue: revQueue,
      masteredQuestions: mastered,
      questionAttempts: attempts,
      questionCorrectCount: correctCountMap,
      questionIncorrectCount: incorrectCountMap,
      arcadeHighScore: (json['arcadeHighScore'] as num?)?.toInt() ?? 0,
      maxCombo: (json['maxCombo'] as num?)?.toInt() ?? 0,
      totalCrystals: (json['totalCrystals'] as num?)?.toInt() ?? 0,
      unlockedWeapons: weapons,
      equippedWeapon: (json['equippedWeapon'] as String?) ?? 'Laser Médical MK-I',
    );
  }

  String serialize() => jsonEncode(toJson());

  static GameProgress deserialize(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      return GameProgress.fromJson(json);
    } catch (_) {
      return GameProgress();
    }
  }

  void reset() {
    currentUnlockedLevel = 1;
    completedLevels.clear();
    levelStars.clear();
    userAnswers.clear();
    isCorrectMap.clear();
    totalXp = 0;
    unlockedBadges.clear();
    lastPlayed = null;
    revisionQueue.clear();
    masteredQuestions.clear();
    questionAttempts.clear();
    questionCorrectCount.clear();
    questionIncorrectCount.clear();
    arcadeHighScore = 0;
    maxCombo = 0;
    totalCrystals = 0;
    unlockedWeapons = {'Laser Médical MK-I'};
    equippedWeapon = 'Laser Médical MK-I';
  }
}
