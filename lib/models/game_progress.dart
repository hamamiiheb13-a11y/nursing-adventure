import 'dart:convert';
import 'gastro_world.dart';

class StageResult {
  final int stageId;
  final int score;
  final int stars; // 0-3
  final bool completed;
  final DateTime? completedAt;

  const StageResult({
    required this.stageId,
    required this.score,
    required this.stars,
    this.completed = true,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'stageId': stageId,
        'score': score,
        'stars': stars,
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory StageResult.fromJson(Map<String, dynamic> json) {
    return StageResult(
      stageId: json['stageId'] as int? ?? 1,
      score: json['score'] as int? ?? 0,
      stars: json['stars'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }
}

class GameProgress {
  int currentStage; // 1-7
  Map<int, bool> questionsAnswered; // questionId -> isCorrect
  Map<int, StageResult> stageResults; // stageId -> StageResult
  int totalScore;
  int totalXP;
  List<String> unlockedWeapons;
  List<int> revisionQueue; // questionIds to repeat
  Set<int> masteredQuestions;

  // Additional backward-compatible stats
  Set<String> unlockedBadges;
  DateTime? lastPlayed;
  Map<int, int> userAnswers; // questionId -> selectedOptionIndex
  Map<int, int> questionAttempts; // questionId -> attempts
  Map<int, int> questionCorrectCount;
  Map<int, int> questionIncorrectCount;
  int maxCombo;
  int totalCrystals;
  String equippedWeapon;
  double musicVolume;
  double sfxVolume;
  bool isMuted;

  GameProgress({
    this.currentStage = 1,
    Map<int, bool>? questionsAnswered,
    Map<int, StageResult>? stageResults,
    this.totalScore = 0,
    this.totalXP = 0,
    List<String>? unlockedWeapons,
    List<int>? revisionQueue,
    Set<int>? masteredQuestions,
    Set<String>? unlockedBadges,
    this.lastPlayed,
    Map<int, int>? userAnswers,
    Map<int, int>? questionAttempts,
    Map<int, int>? questionCorrectCount,
    Map<int, int>? questionIncorrectCount,
    this.maxCombo = 0,
    this.totalCrystals = 0,
    this.equippedWeapon = 'Laser Médical MK-I',
    this.musicVolume = 0.75,
    this.sfxVolume = 0.85,
    this.isMuted = false,
  })  : questionsAnswered = questionsAnswered ?? <int, bool>{},
        stageResults = stageResults ?? <int, StageResult>{},
        unlockedWeapons = unlockedWeapons ?? <String>['Laser Médical MK-I'],
        revisionQueue = revisionQueue ?? <int>[],
        masteredQuestions = masteredQuestions ?? <int>{},
        unlockedBadges = unlockedBadges ?? <String>{},
        userAnswers = userAnswers ?? <int, int>{},
        questionAttempts = questionAttempts ?? <int, int>{},
        questionCorrectCount = questionCorrectCount ?? <int, int>{},
        questionIncorrectCount = questionIncorrectCount ?? <int, int>{};

  // Backward compatibility getters & setters
  int get currentUnlockedLevel => currentStage;
  set currentUnlockedLevel(int val) {
    currentStage = val.clamp(1, 7);
  }

  int get totalXp => totalXP;
  set totalXp(int val) => totalXP = val;

  int get arcadeHighScore => totalScore;
  set arcadeHighScore(int val) => totalScore = val;

  Map<int, bool> get isCorrectMap => questionsAnswered;

  Set<int> get completedLevels => stageResults.entries
      .where((e) => e.value.completed)
      .map((e) => e.key)
      .toSet();

  Map<int, int> get levelStars =>
      stageResults.map((k, v) => MapEntry(k, v.stars));

  int get completedCount => stageResults.values.where((r) => r.completed).length;
  int get totalStars => stageResults.values.fold(0, (sum, r) => sum + r.stars);
  int get questionsInRevisionCount => revisionQueue.length;
  int get questionsMasteredCount => masteredQuestions.length;
  int get totalAttemptsCount => questionAttempts.values.fold(0, (sum, a) => sum + a);
  int get totalCorrectAnswersCount => questionCorrectCount.values.fold(0, (sum, c) => sum + c);
  int get totalIncorrectAnswersCount => questionIncorrectCount.values.fold(0, (sum, i) => sum + i);
  int get correctCount => questionsAnswered.values.where((c) => c).length;
  int get wrongCount => totalIncorrectAnswersCount;
  double get accuracyRate {
    final total = questionsAnswered.length;
    if (total == 0) return 0.0;
    return (correctCount / total) * 100.0;
  }

  bool isLevelUnlocked(int level) {
    if (level <= 1) return true;
    final world = GastroWorld.getWorldForLevel(level);
    return isWorldUnlocked(world.id);
  }

  int getCompletedCountInWorld(int worldId) {
    final world = GastroWorld.worlds.firstWhere(
      (w) => w.id == worldId,
      orElse: () => GastroWorld.worlds.first,
    );
    int count = 0;
    for (final qId in world.questionIds) {
      if (questionsAnswered[qId] == true) count++;
    }
    return count;
  }

  void recordQuestionAnswer({
    required int questionId,
    required int selectedOptionIndex,
    required bool isCorrect,
    int earnedXp = 0,
  }) {
    answerQuestion(questionId, isCorrect, selectedOptionIndex: selectedOptionIndex);
    if (earnedXp > 0) totalXP += earnedXp;
  }

  void completeLevel(int level, [dynamic p1, dynamic p2, dynamic p3]) {
    int stars = 3;
    int score = 0;
    int crystals = 0;

    if (p1 is int) {
      stars = p1;
    }
    if (p2 is int) {
      score = p2;
    }
    if (p3 is int) {
      crystals = p3;
    }

    totalCrystals += crystals;
    final world = GastroWorld.getWorldForLevel(level);
    completeStage(world.id, stars, score);
  }

  void updateArcadeStats({
    required int score,
    int? maxCombo,
    int? combo,
    int crystals = 0,
  }) {
    if (score > totalScore) totalScore = score;
    final finalCombo = maxCombo ?? combo ?? 0;
    if (finalCombo > this.maxCombo) this.maxCombo = finalCombo;
    totalCrystals += crystals;
    lastPlayed = DateTime.now();
  }

  bool isLevelCompleted(int stageId) {
    return stageResults[stageId]?.completed ?? false;
  }

  int getStars(int stageId) {
    return stageResults[stageId]?.stars ?? 0;
  }

  bool isWorldUnlocked(int worldId) {
    if (worldId == 1) return true;
    return isLevelCompleted(worldId - 1);
  }

  bool isWorldCompleted(int worldId) {
    return isLevelCompleted(worldId);
  }

  double calculateWorldCompletion(int worldId) {
    final world = GastroWorld.worlds.firstWhere(
      (w) => w.id == worldId,
      orElse: () => GastroWorld.worlds.first,
    );
    if (world.questionIds.isEmpty) return 0.0;
    int answered = 0;
    for (final qId in world.questionIds) {
      if (questionsAnswered.containsKey(qId)) answered++;
    }
    return (answered / world.questionIds.length).clamp(0.0, 1.0);
  }

  // Core API Methods

  void answerQuestion(int questionId, bool isCorrect, {int? selectedOptionIndex}) {
    questionsAnswered[questionId] = isCorrect;
    if (selectedOptionIndex != null) {
      userAnswers[questionId] = selectedOptionIndex;
    }

    questionAttempts[questionId] = (questionAttempts[questionId] ?? 0) + 1;
    if (isCorrect) {
      questionCorrectCount[questionId] = (questionCorrectCount[questionId] ?? 0) + 1;
      totalXP += 50;
      markMastered(questionId);
    } else {
      questionIncorrectCount[questionId] = (questionIncorrectCount[questionId] ?? 0) + 1;
      addToRevision(questionId);
    }
    lastPlayed = DateTime.now();
  }

  void completeStage(int stageId, int stars, int score) {
    final prevResult = stageResults[stageId];
    final bestScore = prevResult != null && prevResult.score > score ? prevResult.score : score;
    final bestStars = prevResult != null && prevResult.stars > stars ? prevResult.stars : stars;

    stageResults[stageId] = StageResult(
      stageId: stageId,
      score: bestScore,
      stars: bestStars,
      completed: true,
      completedAt: DateTime.now(),
    );

    totalScore += score;
    totalXP += stars * 100;

    if (stageId >= currentStage && currentStage < 7) {
      currentStage = stageId + 1;
    }

    // Unlock and auto-equip new weapon corresponding to world
    final world = GastroWorld.worlds.firstWhere(
      (w) => w.id == stageId,
      orElse: () => GastroWorld.worlds.first,
    );
    if (!unlockedWeapons.contains(world.unlockedWeaponName)) {
      unlockedWeapons.add(world.unlockedWeaponName);
      equippedWeapon = world.unlockedWeaponName;
    }

    lastPlayed = DateTime.now();
  }

  void equipWeapon(String weaponName) {
    if (unlockedWeapons.contains(weaponName)) {
      equippedWeapon = weaponName;
    }
  }

  void addToRevision(int questionId) {
    if (!revisionQueue.contains(questionId) && !masteredQuestions.contains(questionId)) {
      revisionQueue.add(questionId);
    }
  }

  void markMastered(int questionId) {
    masteredQuestions.add(questionId);
    revisionQueue.remove(questionId);
  }

  // Serialization

  Map<String, dynamic> toJson() => {
        'currentStage': currentStage,
        'questionsAnswered': questionsAnswered.map((k, v) => MapEntry(k.toString(), v)),
        'stageResults': stageResults.map((k, v) => MapEntry(k.toString(), v.toJson())),
        'totalScore': totalScore,
        'totalXP': totalXP,
        'unlockedWeapons': unlockedWeapons,
        'revisionQueue': revisionQueue,
        'masteredQuestions': masteredQuestions.toList(),
        'unlockedBadges': unlockedBadges.toList(),
        'lastPlayed': lastPlayed?.toIso8601String(),
        'userAnswers': userAnswers.map((k, v) => MapEntry(k.toString(), v)),
        'questionAttempts': questionAttempts.map((k, v) => MapEntry(k.toString(), v)),
        'questionCorrectCount': questionCorrectCount.map((k, v) => MapEntry(k.toString(), v)),
        'questionIncorrectCount': questionIncorrectCount.map((k, v) => MapEntry(k.toString(), v)),
        'maxCombo': maxCombo,
        'totalCrystals': totalCrystals,
        'equippedWeapon': equippedWeapon,
        'musicVolume': musicVolume,
        'sfxVolume': sfxVolume,
        'isMuted': isMuted,
      };

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    final progress = GameProgress(
      currentStage: json['currentStage'] as int? ?? 1,
      totalScore: json['totalScore'] as int? ?? (json['arcadeHighScore'] as int? ?? 0),
      totalXP: json['totalXP'] as int? ?? (json['totalXp'] as int? ?? 0),
      unlockedWeapons: (json['unlockedWeapons'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      revisionQueue: (json['revisionQueue'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      masteredQuestions: (json['masteredQuestions'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet(),
      unlockedBadges: (json['unlockedBadges'] as List<dynamic>?)?.map((e) => e.toString()).toSet(),
      lastPlayed: json['lastPlayed'] != null ? DateTime.tryParse(json['lastPlayed'] as String) : null,
      maxCombo: json['maxCombo'] as int? ?? 0,
      totalCrystals: json['totalCrystals'] as int? ?? 0,
      equippedWeapon: json['equippedWeapon'] as String? ?? 'Laser Médical MK-I',
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.75,
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 0.85,
      isMuted: json['isMuted'] as bool? ?? false,
    );

    if (json['questionsAnswered'] is Map) {
      final map = json['questionsAnswered'] as Map;
      map.forEach((k, v) {
        final id = int.tryParse(k.toString());
        if (id != null && v is bool) {
          progress.questionsAnswered[id] = v;
        }
      });
    } else if (json['isCorrectMap'] is Map) {
      final map = json['isCorrectMap'] as Map;
      map.forEach((k, v) {
        final id = int.tryParse(k.toString());
        if (id != null && v is bool) {
          progress.questionsAnswered[id] = v;
        }
      });
    }

    if (json['stageResults'] is Map) {
      final map = json['stageResults'] as Map;
      map.forEach((k, v) {
        final id = int.tryParse(k.toString());
        if (id != null && v is Map<String, dynamic>) {
          progress.stageResults[id] = StageResult.fromJson(v);
        }
      });
    }

    if (json['userAnswers'] is Map) {
      final map = json['userAnswers'] as Map;
      map.forEach((k, v) {
        final id = int.tryParse(k.toString());
        if (id != null && v is num) {
          progress.userAnswers[id] = v.toInt();
        }
      });
    }

    if (json['questionAttempts'] is Map) {
      final map = json['questionAttempts'] as Map;
      map.forEach((k, v) {
        final id = int.tryParse(k.toString());
        if (id != null && v is num) {
          progress.questionAttempts[id] = v.toInt();
        }
      });
    }

    if (json['questionCorrectCount'] is Map) {
      final map = json['questionCorrectCount'] as Map;
      map.forEach((k, v) {
        final id = int.tryParse(k.toString());
        if (id != null && v is num) {
          progress.questionCorrectCount[id] = v.toInt();
        }
      });
    }

    if (json['questionIncorrectCount'] is Map) {
      final map = json['questionIncorrectCount'] as Map;
      map.forEach((k, v) {
        final id = int.tryParse(k.toString());
        if (id != null && v is num) {
          progress.questionIncorrectCount[id] = v.toInt();
        }
      });
    }

    return progress;
  }

  String serialize() => jsonEncode(toJson());

  static GameProgress deserialize(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      return GameProgress.fromJson(data);
    } catch (_) {
      return GameProgress();
    }
  }
}
