import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_progress.dart';
import '../utils/player_session.dart' as player_session;

class PlayerProfile {
  final String id;
  String name;
  int currentStage;
  int totalScore;
  int totalXP;
  int completedStages;
  int completedRevisions;
  DateTime createdAt;
  DateTime lastPlayedAt;

  PlayerProfile({
    required this.id,
    required this.name,
    this.currentStage = 1,
    this.totalScore = 0,
    this.totalXP = 0,
    this.completedStages = 0,
    this.completedRevisions = 0,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastPlayedAt = lastPlayedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'currentStage': currentStage,
        'totalScore': totalScore,
        'totalXP': totalXP,
        'completedStages': completedStages,
        'completedRevisions': completedRevisions,
        'createdAt': createdAt.toIso8601String(),
        'lastPlayedAt': lastPlayedAt.toIso8601String(),
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Explorateur',
      currentStage: json['currentStage'] as int? ?? 1,
      totalScore: json['totalScore'] as int? ?? 0,
      totalXP: json['totalXP'] as int? ?? 0,
      completedStages: json['completedStages'] as int? ?? 0,
      completedRevisions: json['completedRevisions'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.tryParse(json['lastPlayedAt'] as String)
          : null,
    );
  }
}

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _kProfilesIndexKey = 'gastro_quest_profiles_v2';
  static const String _kPlayerPrefix = 'gastro_quest_player_v2_';

  // Custom session hooks for multi-tab / refresh isolation testing in VM tests
  String? Function() _readSessionId = player_session.getSessionPlayerId;
  void Function(String) _writeSessionId = player_session.setSessionPlayerId;
  void Function() _eraseSessionId = player_session.clearSessionPlayerId;
  String? Function() _readUrlPlayerId = player_session.getUrlPlayerId;

  GameProgress? _cachedProgress;
  String? _activePlayerId;

  String get activePlayerId {
    if (_activePlayerId != null && _activePlayerId!.isNotEmpty) {
      return _activePlayerId!;
    }
    final existing = _readSessionId();
    if (existing != null && existing.isNotEmpty) {
      _activePlayerId = existing;
      return existing;
    }
    return '';
  }

  GameProgress get currentProgress =>
      _cachedProgress ?? GameProgress(playerId: activePlayerId);

  @visibleForTesting
  void configureForTest({
    String? Function()? readSessionId,
    void Function(String)? writeSessionId,
    void Function()? eraseSessionId,
    String? Function()? readUrlPlayerId,
  }) {
    _readSessionId = readSessionId ?? player_session.getSessionPlayerId;
    _writeSessionId = writeSessionId ?? player_session.setSessionPlayerId;
    _eraseSessionId = eraseSessionId ?? player_session.clearSessionPlayerId;
    _readUrlPlayerId = readUrlPlayerId ?? player_session.getUrlPlayerId;
    _cachedProgress = null;
    _activePlayerId = null;
  }

  @visibleForTesting
  void resetInMemorySession({bool eraseSessionToken = true}) {
    _cachedProgress = null;
    _activePlayerId = null;
    if (eraseSessionToken) {
      _eraseSessionId();
    }
  }

  String _generatePlayerId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rand = math.Random().nextInt(99999).toString().padLeft(5, '0');
    return 'p_${now}_$rand';
  }

  String _playerStorageKey(String playerId) => '$_kPlayerPrefix$playerId';

  Future<List<PlayerProfile>> listSavedPlayers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kProfilesIndexKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final profiles = decoded
          .whereType<Map<String, dynamic>>()
          .map(PlayerProfile.fromJson)
          .where((p) => p.id.isNotEmpty)
          .toList();
      profiles.sort((a, b) => b.lastPlayedAt.compareTo(a.lastPlayedAt));
      return profiles;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveProfilesIndex(List<PlayerProfile> profiles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = profiles.map((p) => p.toJson()).toList();
      await prefs.setString(_kProfilesIndexKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<GameProgress> loadProgress() async {
    if (_cachedProgress != null && _activePlayerId != null) {
      return _cachedProgress!;
    }

    // 1. Determine isolated identity for THIS session (URL query > sessionStorage > brand-new player)
    final urlId = _readUrlPlayerId();
    String? sessionId = urlId ?? _readSessionId();

    if (sessionId == null || sessionId.isEmpty) {
      // Every new visitor opening the link gets a fresh unique identity at Stage 1
      final existingCount = (await listSavedPlayers()).length;
      sessionId = _generatePlayerId();
      _writeSessionId(sessionId);
      _activePlayerId = sessionId;
      _cachedProgress = GameProgress.freshForPlayer(
        playerId: sessionId,
        playerName: 'Joueur ${existingCount + 1}',
      );
      return _cachedProgress!;
    }

    // Returning / refreshed tab session: load ONLY this player's isolated key
    _writeSessionId(sessionId);
    _activePlayerId = sessionId;

    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_playerStorageKey(sessionId));
      if (data != null && data.isNotEmpty) {
        final loaded = GameProgress.deserialize(data);
        loaded.playerId = sessionId;
        if (loaded.playerName.trim().isEmpty) {
          loaded.playerName = 'Explorateur';
        }
        _cachedProgress = loaded;
      } else {
        final profiles = await listSavedPlayers();
        final match = profiles.where((p) => p.id == sessionId).toList();
        _cachedProgress = GameProgress.freshForPlayer(
          playerId: sessionId,
          playerName: match.isNotEmpty ? match.first.name : 'Nouveau Joueur',
        );
      }
    } catch (_) {
      _cachedProgress = GameProgress.freshForPlayer(
        playerId: sessionId,
        playerName: 'Nouveau Joueur',
      );
    }

    return _cachedProgress!;
  }

  Future<void> saveProgress(GameProgress progress) async {
    String pid = progress.playerId.isNotEmpty
        ? progress.playerId
        : activePlayerId;
    if (pid.isEmpty) {
      pid = _generatePlayerId();
    }
    progress.playerId = pid;
    if (progress.playerName.trim().isEmpty) {
      progress.playerName = 'Explorateur';
    }
    _activePlayerId = pid;
    _writeSessionId(pid);
    _cachedProgress = progress;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_playerStorageKey(pid), progress.serialize());

      final profiles = await listSavedPlayers();
      final existingIdx = profiles.indexWhere((p) => p.id == pid);
      final updatedProfile = PlayerProfile(
        id: pid,
        name: progress.playerName,
        currentStage: progress.currentStage,
        totalScore: progress.totalScore,
        totalXP: progress.totalXP,
        completedStages: progress.completedCount,
        completedRevisions: progress.revisionStageResults.values
            .where((r) => r.completed)
            .length,
        createdAt: existingIdx >= 0 ? profiles[existingIdx].createdAt : null,
        lastPlayedAt: DateTime.now(),
      );
      if (existingIdx >= 0) {
        profiles[existingIdx] = updatedProfile;
      } else {
        profiles.add(updatedProfile);
      }
      await _saveProfilesIndex(profiles);
    } catch (_) {}
  }

  /// Creates and switches to a brand-new player starting at Stage 1 without deleting existing players.
  Future<GameProgress> startNewPlayerSession({
    String? customName,
    GameProgress? preserveAudioFrom,
  }) async {
    final profiles = await listSavedPlayers();
    final newId = _generatePlayerId();
    final name = (customName != null && customName.trim().isNotEmpty)
        ? customName.trim()
        : 'Joueur ${profiles.length + 1}';

    _activePlayerId = newId;
    _writeSessionId(newId);
    final fresh = GameProgress.freshForPlayer(
      playerId: newId,
      playerName: name,
      preserveAudioFrom: preserveAudioFrom ?? _cachedProgress,
    );
    _cachedProgress = fresh;
    if (customName != null && customName.trim().isNotEmpty) {
      await saveProgress(fresh);
    }
    return fresh;
  }

  /// Switches the current session to a returning player using their own isolated key.
  Future<GameProgress> switchPlayer(String targetPlayerId) async {
    _activePlayerId = targetPlayerId;
    _writeSessionId(targetPlayerId);
    _cachedProgress = null;
    return loadProgress();
  }

  Future<void> renameCurrentPlayer(String newName) async {
    final cleaned = newName.trim();
    if (cleaned.isEmpty) return;
    final progress = await loadProgress();
    progress.playerName = cleaned;
    await saveProgress(progress);
  }

  /// Resets ONLY the currently active player's progress back to Stage 1 cleanly.
  Future<void> clearProgress() async {
    final current = _cachedProgress ?? await loadProgress();
    final pid = current.playerId.isNotEmpty ? current.playerId : activePlayerId;
    final fresh = GameProgress.freshForPlayer(
      playerId: pid.isNotEmpty ? pid : _generatePlayerId(),
      playerName: current.playerName,
      preserveAudioFrom: current,
    );
    _activePlayerId = fresh.playerId;
    _writeSessionId(fresh.playerId);
    _cachedProgress = fresh;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_playerStorageKey(fresh.playerId));
      final profiles = await listSavedPlayers();
      final idx = profiles.indexWhere((p) => p.id == fresh.playerId);
      if (idx >= 0) {
        profiles[idx] = PlayerProfile(
          id: fresh.playerId,
          name: fresh.playerName,
          currentStage: 1,
          totalScore: 0,
          totalXP: 0,
          completedStages: 0,
          completedRevisions: 0,
          createdAt: profiles[idx].createdAt,
          lastPlayedAt: DateTime.now(),
        );
        await _saveProfilesIndex(profiles);
      }
    } catch (_) {}
  }

  Future<void> resetProgress() => clearProgress();

  Future<bool> hasExistingProgress() async {
    final progress = await loadProgress();
    return progress.hasPlayableProgress;
  }
}
