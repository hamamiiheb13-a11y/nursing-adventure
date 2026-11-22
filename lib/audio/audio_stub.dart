import 'audio_interface.dart';

class AudioPlatformService implements AudioServiceInterface {
  @override
  void init() {}

  @override
  void playClick() {}

  @override
  void playDice() {}

  @override
  void playStep(int stepIndex) {}

  @override
  void playLadder() {}

  @override
  void playSnake() {}

  @override
  void playVictory() {}

  @override
  void playCorrect() {}

  @override
  void playWrong() {}

  @override
  void playStar() {}

  @override
  void playWorldUnlock() {}

  @override
  void playPagerBeep() {}

  @override
  void playTargetLock() {}

  @override
  void playCrystal() {}

  @override
  void playThruster() {}

  @override
  void playHit() {}

  @override
  void playBossLaser() {}

  @override
  void playCombo() {}

  @override
  void startBgm() {}

  @override
  void stopBgm() {}

  @override
  void setBgmEnabled(bool enabled) {}

  @override
  void setSfxEnabled(bool enabled) {}
}

AudioServiceInterface getAudioPlatformService() => AudioPlatformService();
