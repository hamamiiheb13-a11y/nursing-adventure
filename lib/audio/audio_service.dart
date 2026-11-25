import 'audio_interface.dart';
import 'audio_stub.dart' if (dart.library.js_interop) 'audio_web.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioServiceInterface _platform = getAudioPlatformService();

  bool _sfxEnabled = true;
  bool _bgmEnabled = true;
  bool _isMuted = false;
  double _masterVolume = 1.0;
  double _musicVolume = 0.75;
  double _sfxVolume = 0.85;

  bool get sfxEnabled => _sfxEnabled && !_isMuted;
  bool get bgmEnabled => _bgmEnabled && !_isMuted;
  bool get isMuted => _isMuted;
  double get masterVolume => _masterVolume;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  void init() {
    _platform.init();
  }

  void applySettings({
    double? masterVolume,
    double? musicVolume,
    double? sfxVolume,
    bool? isMuted,
  }) {
    if (masterVolume != null) setMasterVolume(masterVolume);
    if (musicVolume != null) setMusicVolume(musicVolume);
    if (sfxVolume != null) setSfxVolume(sfxVolume);
    if (isMuted != null) setMuted(isMuted);
  }

  void playClick() {
    if (sfxEnabled) _platform.playClick();
  }

  void playDice() {
    if (sfxEnabled) _platform.playDice();
  }

  void playStep(int stepIndex) {
    if (sfxEnabled) _platform.playStep(stepIndex);
  }

  void playLadder() {
    if (sfxEnabled) _platform.playLadder();
  }

  void playSnake() {
    if (sfxEnabled) _platform.playSnake();
  }

  void playVictory() {
    if (sfxEnabled) _platform.playVictory();
  }

  void playCorrect() {
    if (sfxEnabled) _platform.playCorrect();
  }

  void playWrong() {
    if (sfxEnabled) _platform.playWrong();
  }

  void playStar() {
    if (sfxEnabled) _platform.playStar();
  }

  void playWorldUnlock() {
    if (sfxEnabled) _platform.playWorldUnlock();
  }

  void playPagerBeep() {
    if (sfxEnabled) _platform.playPagerBeep();
  }

  void playTargetLock() {
    if (sfxEnabled) _platform.playTargetLock();
  }

  void playCrystal() {
    if (sfxEnabled) _platform.playCrystal();
  }

  void playThruster() {
    if (sfxEnabled) _platform.playThruster();
  }

  void playHit() {
    if (sfxEnabled) _platform.playHit();
  }

  void playBossLaser() {
    if (sfxEnabled) _platform.playBossLaser();
  }

  void playCombo() {
    if (sfxEnabled) _platform.playCombo();
  }

  void playWeaponShot(int weaponIndex) {
    if (sfxEnabled) _platform.playWeaponShot(weaponIndex);
  }

  void playSpecialSkill() {
    if (sfxEnabled) _platform.playSpecialSkill();
  }

  void playShieldActivate() {
    if (sfxEnabled) _platform.playShieldActivate();
  }

  void playBossEntrance() {
    if (sfxEnabled) _platform.playBossEntrance();
  }

  void playBossAttack() {
    if (sfxEnabled) _platform.playBossAttack();
  }

  void playBossDefeat() {
    if (sfxEnabled) _platform.playBossDefeat();
  }

  void playRewardUnlock() {
    if (sfxEnabled) _platform.playWorldUnlock();
  }

  void playRevive() {
    if (sfxEnabled) _platform.playRevive();
  }

  void playStageComplete() {
    if (sfxEnabled) _platform.playVictory();
  }

  void startBgm([int stageId = 1]) {
    if (bgmEnabled) {
      _platform.startBgm(stageId);
    }
  }

  void startBossBgm() {
    if (bgmEnabled) {
      _platform.startBossBgm();
    }
  }

  void stopBgm() {
    _platform.stopBgm();
  }

  void toggleBgm() {
    _bgmEnabled = !_bgmEnabled;
    _platform.setBgmEnabled(_bgmEnabled && !_isMuted);
  }

  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
    _platform.setSfxEnabled(_sfxEnabled && !_isMuted);
  }

  void setBgmEnabled(bool value) {
    _bgmEnabled = value;
    _platform.setBgmEnabled(value && !_isMuted);
  }

  void setSfxEnabled(bool value) {
    _sfxEnabled = value;
    _platform.setSfxEnabled(value && !_isMuted);
  }

  void setMasterVolume(double value) {
    _masterVolume = value.clamp(0.0, 1.0);
    _platform.setMasterVolume(_masterVolume);
  }

  void setMusicVolume(double value) {
    _musicVolume = value.clamp(0.0, 1.0);
    _platform.setMusicVolume(_musicVolume);
    _platform.setBgmEnabled(_musicVolume > 0.01 && _bgmEnabled && !_isMuted);
  }

  void setSfxVolume(double value) {
    _sfxVolume = value.clamp(0.0, 1.0);
    _platform.setSfxVolume(_sfxVolume);
    _platform.setSfxEnabled(_sfxVolume > 0.01 && _sfxEnabled && !_isMuted);
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    _platform.setMuted(_isMuted);
  }
}
