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

  GameProgress({
    this.currentUnlockedLevel = 1,
    Set<int>? completedLevels,
    Map<int, int>? levelStars,
    Map<int, int>? userAnswers,
    Map<int, bool>? isCorrectMap,
    this.totalXp = 0,
    Set<String>? unlockedBadges,
    this.lastPlayed,
  })  : completedLevels = completedLevels ?? <int>{},
        levelStars = levelStars ?? <int, int>{},
        userAnswers = userAnswers ?? <int, int>{},
        isCorrectMap = isCorrectMap ?? <int, bool>{},
        unlockedBadges = unlockedBadges ?? <String>{};

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

  double get completionPercentage => (completedCount / 30.0).clamp(0.0, 1.0);

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

  void completeLevel(int level, int selectedOptionIndex, bool isCorrect) {
    completedLevels.add(level);
    userAnswers[level] = selectedOptionIndex;
    isCorrectMap[level] = isCorrect;

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
    if (level == currentUnlockedLevel && currentUnlockedLevel < 30) {
      currentUnlockedLevel = level + 1;
    }

    // Check badges
    _evaluateBadges();
    lastPlayed = DateTime.now();
  }

  void _evaluateBadges() {
    // World completion badges
    for (final world in GastroWorld.worlds) {
      if (isWorldCompleted(world.id)) {
        unlockedBadges.add('badge_world_${world.id}');
      }
    }

    // Global achievements
    if (completedLevels.isNotEmpty) {
      unlockedBadges.add('badge_first_step');
    }
    if (completedCount >= 15) {
      unlockedBadges.add('badge_halfway');
    }
    if (completedCount >= 30) {
      unlockedBadges.add('badge_master_gastro');
    }
    if (completedCount >= 30 && correctCount == 30) {
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
  }
}
