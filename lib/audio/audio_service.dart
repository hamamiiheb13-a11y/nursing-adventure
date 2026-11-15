import 'audio_interface.dart';
import 'audio_stub.dart' if (dart.library.js_interop) 'audio_web.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioServiceInterface _platform = getAudioPlatformService();

  bool _sfxEnabled = true;
  bool _bgmEnabled = true;

  bool get sfxEnabled => _sfxEnabled;
  bool get bgmEnabled => _bgmEnabled;

  void init() {
    _platform.init();
  }

  void playClick() {
    if (_sfxEnabled) {
      _platform.playClick();
    }
  }

  void playDice() {
    if (_sfxEnabled) {
      _platform.playDice();
    }
  }

  void playStep(int stepIndex) {
    if (_sfxEnabled) {
      _platform.playStep(stepIndex);
    }
  }

  void playLadder() {
    if (_sfxEnabled) {
      _platform.playLadder();
    }
  }

  void playSnake() {
    if (_sfxEnabled) {
      _platform.playSnake();
    }
  }

  void playVictory() {
    if (_sfxEnabled) {
      _platform.playVictory();
    }
  }

  void startBgm() {
    if (_bgmEnabled) {
      _platform.startBgm();
    }
  }

  void stopBgm() {
    _platform.stopBgm();
  }

  void toggleBgm() {
    _bgmEnabled = !_bgmEnabled;
    _platform.setBgmEnabled(_bgmEnabled);
  }

  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
    _platform.setSfxEnabled(_sfxEnabled);
  }

  void setBgmEnabled(bool value) {
    _bgmEnabled = value;
    _platform.setBgmEnabled(value);
  }

  void setSfxEnabled(bool value) {
    _sfxEnabled = value;
    _platform.setSfxEnabled(value);
  }
}
