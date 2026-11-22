abstract class AudioServiceInterface {
  void init();
  void playClick();
  void playDice();
  void playStep(int stepIndex);
  void playLadder();
  void playSnake();
  void playVictory();
  void playCorrect();
  void playWrong();
  void playStar();
  void playWorldUnlock();
  void playPagerBeep();
  void playTargetLock();
  void playCrystal();
  void playThruster();
  void playHit();
  void playBossLaser();
  void playCombo();
  void startBgm();
  void stopBgm();
  void setBgmEnabled(bool enabled);
  void setSfxEnabled(bool enabled);
}
