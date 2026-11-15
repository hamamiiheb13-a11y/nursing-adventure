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

@JS('NursingAudio.startBgm')
external void _nursingAudioStartBgm();

@JS('NursingAudio.stopBgm')
external void _nursingAudioStopBgm();

@JS('NursingAudio.setBgmEnabled')
external void _nursingAudioSetBgmEnabled(bool enabled);

@JS('NursingAudio.setSfxEnabled')
external void _nursingAudioSetSfxEnabled(bool enabled);

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
  void startBgm() {
    try {
      _nursingAudioStartBgm();
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
}

AudioServiceInterface getAudioPlatformService() => AudioPlatformService();
