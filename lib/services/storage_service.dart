import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_progress.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _kProgressKey = 'gastro_quest_progress_v1';
  GameProgress? _cachedProgress;

  GameProgress get currentProgress => _cachedProgress ?? GameProgress();

  Future<GameProgress> loadProgress() async {
    if (_cachedProgress != null) return _cachedProgress!;
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_kProgressKey);
      if (data != null && data.isNotEmpty) {
        _cachedProgress = GameProgress.deserialize(data);
      } else {
        _cachedProgress = GameProgress();
      }
    } catch (_) {
      _cachedProgress = GameProgress();
    }
    return _cachedProgress!;
  }

  Future<void> saveProgress(GameProgress progress) async {
    _cachedProgress = progress;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kProgressKey, progress.serialize());
    } catch (_) {}
  }

  Future<void> resetProgress() async {
    _cachedProgress = GameProgress();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kProgressKey);
    } catch (_) {}
  }
}
