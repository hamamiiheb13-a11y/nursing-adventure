import 'dart:js_interop';
import 'audio_interface.dart';

@JS('NursingAudio.init')
external void _nursingAudioInit();

@JS('NursingAudio.playClick')
external void _nursingAudioPlayClick();

@JS('NursingAudio.playDice')
external void _nursingAudioPlayDice();

@JS('NursingAudio.playStep')
external void _nursingAudioPlayStep(int stepIndex);

@JS('NursingAudio.playLadder')
external void _nursingAudioPlayLadder();

@JS('NursingAudio.playSnake')
external void _nursingAudioPlaySnake();

@JS('NursingAudio.playVictory')
external void _nursingAudioPlayVictory();

@JS('NursingAudio.playCorrect')
external void _nursingAudioPlayCorrect();

@JS('NursingAudio.playWrong')
external void _nursingAudioPlayWrong();

@JS('NursingAudio.playStar')
external void _nursingAudioPlayStar();

@JS('NursingAudio.playWorldUnlock')
external void _nursingAudioPlayWorldUnlock();

@JS('NursingAudio.playPagerBeep')
external void _nursingAudioPlayPagerBeep();

@JS('NursingAudio.playTargetLock')
external void _nursingAudioPlayTargetLock();

@JS('NursingAudio.playCrystal')
external void _nursingAudioPlayCrystal();

@JS('NursingAudio.playThruster')
external void _nursingAudioPlayThruster();

@JS('NursingAudio.playHit')
external void _nursingAudioPlayHit();

@JS('NursingAudio.playBossLaser')
external void _nursingAudioPlayBossLaser();

@JS('NursingAudio.playCombo')
external void _nursingAudioPlayCombo();

@JS('NursingAudio.playWeaponShot')
external void _nursingAudioPlayWeaponShot(int weaponIndex);

@JS('NursingAudio.playSpecialSkill')
external void _nursingAudioPlaySpecialSkill();

@JS('NursingAudio.playShieldActivate')
external void _nursingAudioPlayShieldActivate();

@JS('NursingAudio.playBossEntrance')
external void _nursingAudioPlayBossEntrance();

@JS('NursingAudio.playBossAttack')
external void _nursingAudioPlayBossAttack();

@JS('NursingAudio.playBossDefeat')
external void _nursingAudioPlayBossDefeat();

@JS('NursingAudio.playRevive')
external void _nursingAudioPlayRevive();

@JS('NursingAudio.playGameStart')
external void _nursingAudioPlayGameStart();

@JS('NursingAudio.playStageSelect')
external void _nursingAudioPlayStageSelect();

@JS('NursingAudio.playExplanationOpen')
external void _nursingAudioPlayExplanationOpen();

@JS('NursingAudio.startBgm')
external void _nursingAudioStartBgm(int stageId);

@JS('NursingAudio.startBossBgm')
external void _nursingAudioStartBossBgm();

@JS('NursingAudio.stopBgm')
external void _nursingAudioStopBgm();

@JS('NursingAudio.setBgmEnabled')
external void _nursingAudioSetBgmEnabled(bool enabled);

@JS('NursingAudio.setSfxEnabled')
external void _nursingAudioSetSfxEnabled(bool enabled);

@JS('NursingAudio.setMasterVolume')
external void _nursingAudioSetMasterVolume(double volume);

@JS('NursingAudio.setMusicVolume')
external void _nursingAudioSetMusicVolume(double volume);

@JS('NursingAudio.setSfxVolume')
external void _nursingAudioSetSfxVolume(double volume);

@JS('NursingAudio.setMuted')
external void _nursingAudioSetMuted(bool muted);

class AudioPlatformService implements AudioServiceInterface {
  @override
  void init() {
    try {
      _nursingAudioInit();
    } catch (_) {}
  }

  @override
  void playClick() {
    try {
      _nursingAudioPlayClick();
    } catch (_) {}
  }

  @override
  void playDice() {
    try {
      _nursingAudioPlayDice();
    } catch (_) {}
  }

  @override
  void playStep(int stepIndex) {
    try {
      _nursingAudioPlayStep(stepIndex);
    } catch (_) {}
  }

  @override
  void playLadder() {
    try {
      _nursingAudioPlayLadder();
    } catch (_) {}
  }

  @override
  void playSnake() {
    try {
      _nursingAudioPlaySnake();
    } catch (_) {}
  }

  @override
  void playVictory() {
    try {
      _nursingAudioPlayVictory();
    } catch (_) {}
  }

  @override
  void playCorrect() {
    try {
      _nursingAudioPlayCorrect();
    } catch (_) {}
  }

  @override
  void playWrong() {
    try {
      _nursingAudioPlayWrong();
    } catch (_) {}
  }

  @override
  void playStar() {
    try {
      _nursingAudioPlayStar();
    } catch (_) {}
  }

  @override
  void playWorldUnlock() {
    try {
      _nursingAudioPlayWorldUnlock();
    } catch (_) {}
  }

  @override
  void playPagerBeep() {
    try {
      _nursingAudioPlayPagerBeep();
    } catch (_) {}
  }

  @override
  void playTargetLock() {
    try {
      _nursingAudioPlayTargetLock();
    } catch (_) {}
  }

  @override
  void playCrystal() {
    try {
      _nursingAudioPlayCrystal();
    } catch (_) {}
  }

  @override
  void playThruster() {
    try {
      _nursingAudioPlayThruster();
    } catch (_) {}
  }

  @override
  void playHit() {
    try {
      _nursingAudioPlayHit();
    } catch (_) {}
  }

  @override
  void playBossLaser() {
    try {
      _nursingAudioPlayBossLaser();
    } catch (_) {}
  }

  @override
  void playCombo() {
    try {
      _nursingAudioPlayCombo();
    } catch (_) {}
  }

  @override
  void playWeaponShot(int weaponIndex) {
    try {
      _nursingAudioPlayWeaponShot(weaponIndex);
    } catch (_) {}
  }

  @override
  void playSpecialSkill() {
    try {
      _nursingAudioPlaySpecialSkill();
    } catch (_) {}
  }

  @override
  void playShieldActivate() {
    try {
      _nursingAudioPlayShieldActivate();
    } catch (_) {}
  }

  @override
  void playBossEntrance() {
    try {
      _nursingAudioPlayBossEntrance();
    } catch (_) {}
  }

  @override
  void playBossAttack() {
    try {
      _nursingAudioPlayBossAttack();
    } catch (_) {}
  }

  @override
  void playBossDefeat() {
    try {
      _nursingAudioPlayBossDefeat();
    } catch (_) {}
  }

  @override
  void playRevive() {
    try {
      _nursingAudioPlayRevive();
    } catch (_) {}
  }

  @override
  void playGameStart() {
    try {
      _nursingAudioPlayGameStart();
    } catch (_) {}
  }

  @override
  void playStageSelect() {
    try {
      _nursingAudioPlayStageSelect();
    } catch (_) {}
  }

  @override
  void playExplanationOpen() {
    try {
      _nursingAudioPlayExplanationOpen();
    } catch (_) {}
  }

  @override
  void startBgm([int stageId = 1]) {
    try {
      _nursingAudioStartBgm(stageId);
    } catch (_) {}
  }

  @override
  void startBossBgm() {
    try {
      _nursingAudioStartBossBgm();
    } catch (_) {}
  }

  @override
  void stopBgm() {
    try {
      _nursingAudioStopBgm();
    } catch (_) {}
  }

  @override
  void setBgmEnabled(bool enabled) {
    try {
      _nursingAudioSetBgmEnabled(enabled);
    } catch (_) {}
  }

  @override
  void setSfxEnabled(bool enabled) {
    try {
      _nursingAudioSetSfxEnabled(enabled);
    } catch (_) {}
  }

  @override
  void setMasterVolume(double volume) {
    try {
      _nursingAudioSetMasterVolume(volume);
    } catch (_) {}
  }

  @override
  void setMusicVolume(double volume) {
    try {
      _nursingAudioSetMusicVolume(volume);
    } catch (_) {}
  }

  @override
  void setSfxVolume(double volume) {
    try {
      _nursingAudioSetSfxVolume(volume);
    } catch (_) {}
  }

  @override
  void setMuted(bool muted) {
    try {
      _nursingAudioSetMuted(muted);
    } catch (_) {}
  }
}

AudioServiceInterface getAudioPlatformService() => AudioPlatformService();
