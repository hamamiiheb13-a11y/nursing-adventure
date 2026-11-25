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
  void playWeaponShot(int weaponIndex) {}
  @override
  void playSpecialSkill() {}
  @override
  void playShieldActivate() {}
  @override
  void playBossEntrance() {}
  @override
  void playBossAttack() {}
  @override
  void playBossDefeat() {}
  @override
  void playRevive() {}
  @override
  void playGameStart() {}
  @override
  void playStageSelect() {}
  @override
  void playExplanationOpen() {}
  @override
  void startBgm([int stageId = 1]) {}
  @override
  void startBossBgm() {}
  @override
  void stopBgm() {}
  @override
  void setBgmEnabled(bool enabled) {}
  @override
  void setSfxEnabled(bool enabled) {}
  @override
  void setMasterVolume(double volume) {}
  @override
  void setMusicVolume(double volume) {}
  @override
  void setSfxVolume(double volume) {}
  @override
  void setMuted(bool muted) {}
}

AudioServiceInterface getAudioPlatformService() => AudioPlatformService();
