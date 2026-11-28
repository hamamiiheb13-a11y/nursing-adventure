import 'dart:convert';
import 'dart:math' as math;
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

class RevisionStageResult {
  final int revisionNumber; // 1 after Stage 7, 2 after Stage 14, ...
  final int cycleStartStage;
  final int cycleEndStage;
  final List<int> questionIdsAsked;
  final Map<int, bool> answersCorrectMap;
  final int correctCount;
  final int totalCount;
  final int score;
  final int stars;
  final bool isBonusChallenge;
  final bool completed;
  final DateTime? completedAt;

  const RevisionStageResult({
    required this.revisionNumber,
    required this.cycleStartStage,
    required this.cycleEndStage,
    this.questionIdsAsked = const [],
    this.answersCorrectMap = const {},
    this.correctCount = 0,
    this.totalCount = 0,
    this.score = 0,
    this.stars = 3,
    this.isBonusChallenge = false,
    this.completed = true,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'revisionNumber': revisionNumber,
        'cycleStartStage': cycleStartStage,
        'cycleEndStage': cycleEndStage,
        'questionIdsAsked': questionIdsAsked,
        'answersCorrectMap':
            answersCorrectMap.map((k, v) => MapEntry(k.toString(), v)),
        'correctCount': correctCount,
        'totalCount': totalCount,
        'score': score,
        'stars': stars,
        'isBonusChallenge': isBonusChallenge,
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory RevisionStageResult.fromJson(Map<String, dynamic> json) {
    final answers = <int, bool>{};
    if (json['answersCorrectMap'] is Map) {
      (json['answersCorrectMap'] as Map).forEach((k, v) {
        final id = int.tryParse(k.toString());
        if (id != null && v is bool) {
          answers[id] = v;
        }
      });
    }
    return RevisionStageResult(
      revisionNumber: json['revisionNumber'] as int? ?? 1,
      cycleStartStage: json['cycleStartStage'] as int? ?? 1,
      cycleEndStage: json['cycleEndStage'] as int? ?? 7,
      questionIdsAsked: (json['questionIdsAsked'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      answersCorrectMap: answers,
      correctCount: json['correctCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
      stars: json['stars'] as int? ?? 3,
      isBonusChallenge: json['isBonusChallenge'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }
}

class GameProgress {
  String playerId;
  String playerName;
  int currentStage; // 1+ across cycles (1-7 Cycle 1, 8-14 Cycle 2, ...)
  Map<int, bool> questionsAnswered; // questionId -> isCorrect
  Map<int, StageResult> stageResults; // stageId -> StageResult
  Map<int, List<int>> cycleMistakeQuestionIds; // cycleIndex (1,2,3...) -> missed questionIds
  Map<int, RevisionStageResult> revisionStageResults; // revisionNumber -> RevisionStageResult
  int? pendingRevisionNumber;
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
  double masterVolume;
  double musicVolume;
  double sfxVolume;
  bool musicEnabled;
  bool sfxEnabled;
  bool isMuted;
  bool hasSeenTutorial;

  GameProgress({
    this.playerId = '',
    this.playerName = 'Explorateur',
    this.currentStage = 1,
    Map<int, bool>? questionsAnswered,
    Map<int, StageResult>? stageResults,
    Map<int, List<int>>? cycleMistakeQuestionIds,
    Map<int, RevisionStageResult>? revisionStageResults,
    this.pendingRevisionNumber,
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
    this.masterVolume = 1.0,
    this.musicVolume = 0.75,
    this.sfxVolume = 0.85,
    this.musicEnabled = true,
    this.sfxEnabled = true,
    this.isMuted = false,
    this.hasSeenTutorial = false,
  })  : questionsAnswered = questionsAnswered ?? <int, bool>{},
        stageResults = stageResults ?? <int, StageResult>{},
        cycleMistakeQuestionIds =
            cycleMistakeQuestionIds ?? <int, List<int>>{},
        revisionStageResults =
            revisionStageResults ?? <int, RevisionStageResult>{},
        unlockedWeapons = unlockedWeapons ?? <String>['Laser Médical MK-I'],
        revisionQueue = revisionQueue ?? <int>[],
        masteredQuestions = masteredQuestions ?? <int>{},
        unlockedBadges = unlockedBadges ?? <String>{},
        userAnswers = userAnswers ?? <int, int>{},
        questionAttempts = questionAttempts ?? <int, int>{},
        questionCorrectCount = questionCorrectCount ?? <int, int>{},
        questionIncorrectCount = questionIncorrectCount ?? <int, int>{};

  static GameProgress freshForPlayer({
    required String playerId,
    required String playerName,
    GameProgress? preserveAudioFrom,
  }) {
    return GameProgress(
      playerId: playerId,
      playerName: playerName,
      masterVolume: preserveAudioFrom?.masterVolume ?? 1.0,
      musicVolume: preserveAudioFrom?.musicVolume ?? 0.75,
      sfxVolume: preserveAudioFrom?.sfxVolume ?? 0.85,
      musicEnabled: preserveAudioFrom?.musicEnabled ?? true,
      sfxEnabled: preserveAudioFrom?.sfxEnabled ?? true,
      isMuted: preserveAudioFrom?.isMuted ?? false,
    );
  }

  static const int maxOriginalStages = 7;

  static int cycleForStage(int stageId) => 1;

  int get currentCycleIndex => 1;

  bool get hasPlayableProgress =>
      totalScore > 0 ||
      totalXP > 0 ||
      stageResults.isNotEmpty ||
      revisionStageResults.isNotEmpty ||
      questionsAnswered.isNotEmpty;

  // Backward compatibility getters & setters
  int get currentUnlockedLevel => currentStage;
  set currentUnlockedLevel(int val) {
    currentStage = val < 1 ? 1 : val;
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
    return isWorldUnlocked(level);
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

  List<int> getMistakesForCycle([int revisionNumber = 1]) {
    if (revisionNumber != 1) return const <int>[];
    final ids = cycleMistakeQuestionIds[1] ?? const <int>[];
    return ids.where((id) => questionsAnswered[id] != true).toList();
  }

  bool isRevisionStageUnlocked([int revisionNumber = 1]) {
    if (revisionNumber != 1) return false;
    return isLevelCompleted(maxOriginalStages);
  }

  bool isRevisionStageCompleted([int revisionNumber = 1]) {
    if (revisionNumber != 1) return false;
    return revisionStageResults[1]?.completed ?? false;
  }

  int? get activePendingRevision {
    if (isLevelCompleted(maxOriginalStages) && !isRevisionStageCompleted(1)) {
      return 1;
    }
    return null;
  }

  void recordQuestionAnswer({
    required int questionId,
    required int selectedOptionIndex,
    required bool isCorrect,
    int earnedXp = 0,
    int? stageId,
  }) {
    answerQuestion(
      questionId,
      isCorrect,
      selectedOptionIndex: selectedOptionIndex,
      stageId: stageId,
    );
    if (earnedXp > 0) totalXP += earnedXp;
  }

  void recordRevisionAnswer({
    required int revisionNumber,
    required int questionId,
    required int selectedOptionIndex,
    required bool isCorrect,
    int earnedXp = 0,
  }) {
    questionsAnswered[questionId] = isCorrect;
    userAnswers[questionId] = selectedOptionIndex;
    questionAttempts[questionId] = (questionAttempts[questionId] ?? 0) + 1;

    if (isCorrect) {
      questionCorrectCount[questionId] =
          (questionCorrectCount[questionId] ?? 0) + 1;
      totalXP += 50 + earnedXp;
      markMastered(questionId);
      cycleMistakeQuestionIds[revisionNumber]?.remove(questionId);
    } else {
      questionIncorrectCount[questionId] =
          (questionIncorrectCount[questionId] ?? 0) + 1;
      if (earnedXp > 0) totalXP += earnedXp;
      if (!revisionQueue.contains(questionId)) {
        revisionQueue.add(questionId);
      }
    }

    final existing = revisionStageResults[revisionNumber];
    final cycleStart = (revisionNumber - 1) * 7 + 1;
    final cycleEnd = revisionNumber * 7;
    final updatedAnswers = Map<int, bool>.from(existing?.answersCorrectMap ?? {});
    updatedAnswers[questionId] = isCorrect;
    final askedIds = List<int>.from(existing?.questionIdsAsked ?? []);
    if (!askedIds.contains(questionId)) {
      askedIds.add(questionId);
    }

    revisionStageResults[revisionNumber] = RevisionStageResult(
      revisionNumber: revisionNumber,
      cycleStartStage: cycleStart,
      cycleEndStage: cycleEnd,
      questionIdsAsked: askedIds,
      answersCorrectMap: updatedAnswers,
      correctCount: updatedAnswers.values.where((v) => v).length,
      totalCount: askedIds.length,
      score: existing?.score ?? 0,
      stars: existing?.stars ?? 0,
      isBonusChallenge: existing?.isBonusChallenge ?? false,
      completed: existing?.completed ?? false,
      completedAt: existing?.completedAt,
    );

    lastPlayed = DateTime.now();
  }

  void completeRevisionStage({
    required int revisionNumber,
    required int score,
    required int stars,
    required int correctCount,
    required int totalCount,
    required bool isBonusChallenge,
    List<int> questionIdsAsked = const [],
  }) {
    final existing = revisionStageResults[revisionNumber];
    final cycleStart = (revisionNumber - 1) * 7 + 1;
    final cycleEnd = revisionNumber * 7;
    final bestScore =
        existing != null && existing.score > score ? existing.score : score;
    final bestStars =
        existing != null && existing.stars > stars ? existing.stars : stars;
    final mergedAsked = List<int>.from(
      questionIdsAsked.isNotEmpty
          ? questionIdsAsked
          : (existing?.questionIdsAsked ?? const []),
    );
    final mergedAnswers = Map<int, bool>.from(existing?.answersCorrectMap ?? {});

    revisionStageResults[revisionNumber] = RevisionStageResult(
      revisionNumber: revisionNumber,
      cycleStartStage: cycleStart,
      cycleEndStage: cycleEnd,
      questionIdsAsked: mergedAsked,
      answersCorrectMap: mergedAnswers,
      correctCount: correctCount,
      totalCount: totalCount,
      score: bestScore,
      stars: bestStars,
      isBonusChallenge: isBonusChallenge,
      completed: true,
      completedAt: DateTime.now(),
    );

    if (pendingRevisionNumber == revisionNumber) {
      pendingRevisionNumber = null;
    }

    totalScore += score;
    totalXP += stars * 100 + (isBonusChallenge ? 150 : 100);
    unlockedBadges.add('revision_cycle_$revisionNumber');

    // Game keeps strictly 7 original stages (never advance past Stage 7)
    currentStage = maxOriginalStages;

    lastPlayed = DateTime.now();
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
    completeStage(level, stars, score);
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

  bool isWorldUnlocked(int stageId) {
    if (stageId <= 1) return true;
    if (stageId > maxOriginalStages) return false;
    return isLevelCompleted(stageId - 1);
  }

  bool isWorldCompleted(int stageId) {
    return isLevelCompleted(stageId);
  }

  double calculateWorldCompletion(int worldId) {
    final world = GastroWorld.getWorldForLevel(worldId);
    if (world.questionIds.isEmpty) return 0.0;
    int answered = 0;
    for (final qId in world.questionIds) {
      if (questionsAnswered.containsKey(qId)) answered++;
    }
    return (answered / world.questionIds.length).clamp(0.0, 1.0);
  }

  // Core API Methods

  void answerQuestion(
    int questionId,
    bool isCorrect, {
    int? selectedOptionIndex,
    int? stageId,
  }) {
    questionsAnswered[questionId] = isCorrect;
    if (selectedOptionIndex != null) {
      userAnswers[questionId] = selectedOptionIndex;
    }

    questionAttempts[questionId] = (questionAttempts[questionId] ?? 0) + 1;
    if (isCorrect) {
      questionCorrectCount[questionId] = (questionCorrectCount[questionId] ?? 0) + 1;
      totalXP += 50;
      markMastered(questionId);
      cycleMistakeQuestionIds[1]?.remove(questionId);
    } else {
      questionIncorrectCount[questionId] = (questionIncorrectCount[questionId] ?? 0) + 1;
      if (stageId == null || (stageId >= 1 && stageId <= maxOriginalStages)) {
        final list = cycleMistakeQuestionIds.putIfAbsent(1, () => <int>[]);
        if (!list.contains(questionId)) {
          list.add(questionId);
        }
        masteredQuestions.remove(questionId);
      }
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

    final clampedNext = math.min(maxOriginalStages, stageId + 1);
    if (clampedNext > currentStage) {
      currentStage = clampedNext;
    }

    if (stageId == maxOriginalStages && !isRevisionStageCompleted(1)) {
      pendingRevisionNumber = 1;
    }

    // Unlock and auto-equip new weapon corresponding to world sector
    final world = GastroWorld.getWorldForLevel(stageId);
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
        'playerId': playerId,
        'playerName': playerName,
        'currentStage': currentStage,
        'questionsAnswered': questionsAnswered.map((k, v) => MapEntry(k.toString(), v)),
        'stageResults': stageResults.map((k, v) => MapEntry(k.toString(), v.toJson())),
        'cycleMistakeQuestionIds': cycleMistakeQuestionIds.map(
          (k, v) => MapEntry(k.toString(), v),
        ),
        'revisionStageResults': revisionStageResults.map(
          (k, v) => MapEntry(k.toString(), v.toJson()),
        ),
        'pendingRevisionNumber': pendingRevisionNumber,
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
        'masterVolume': masterVolume,
        'musicVolume': musicVolume,
        'sfxVolume': sfxVolume,
        'musicEnabled': musicEnabled,
        'sfxEnabled': sfxEnabled,
        'isMuted': isMuted,
        'hasSeenTutorial': hasSeenTutorial,
      };

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    final progress = GameProgress(
      playerId: json['playerId'] as String? ?? '',
      playerName: json['playerName'] as String? ?? 'Explorateur',
      currentStage: json['currentStage'] as int? ?? 1,
      pendingRevisionNumber: json['pendingRevisionNumber'] as int?,
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
      masterVolume: (json['masterVolume'] as num?)?.toDouble() ?? 1.0,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.75,
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 0.85,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      sfxEnabled: json['sfxEnabled'] as bool? ?? true,
      isMuted: json['isMuted'] as bool? ?? false,
      hasSeenTutorial: json['hasSeenTutorial'] as bool? ?? false,
    );

    if (json['cycleMistakeQuestionIds'] is Map) {
      (json['cycleMistakeQuestionIds'] as Map).forEach((k, v) {
        final cycleId = int.tryParse(k.toString());
        if (cycleId != null && v is List) {
          progress.cycleMistakeQuestionIds[cycleId] =
              v.map((e) => (e as num).toInt()).toList();
        }
      });
    }

    if (json['revisionStageResults'] is Map) {
      (json['revisionStageResults'] as Map).forEach((k, v) {
        final revId = int.tryParse(k.toString());
        if (revId != null && v is Map<String, dynamic>) {
          progress.revisionStageResults[revId] =
              RevisionStageResult.fromJson(v);
        }
      });
    }

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
