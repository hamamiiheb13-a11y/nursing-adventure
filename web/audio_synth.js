// ============================================================================
// CAPSULE WARRIORS / NURSING ADVENTURE - Web Audio Synthesizer & Sound Engine
// 100% Client-side Web Audio API (Zero external MP3 dependencies, 100% mobile friendly)
// Coherent Medical Arcade Exploration BGM + Dynamic Boss BGM + Distinct Weapon SFX
// ============================================================================

(function () {
  let audioCtx = null;
  let bgmTimer = null;
  let isBgmPlaying = false;
  let activeTrackMode = 'exploration'; // 'exploration' | 'boss'

  let sfxEnabled = true;
  let bgmEnabled = true;
  let isMuted = false;

  let masterVol = 1.0;
  let musicVol = 0.75;
  let sfxVol = 0.85;

  let masterGainNode = null;
  let bgmGainNode = null;
  let sfxGainNode = null;

  function syncGains() {
    if (!audioCtx) return;
    const effectiveMaster = isMuted ? 0.0 : masterVol;
    if (masterGainNode) {
      masterGainNode.gain.setTargetAtTime(effectiveMaster, audioCtx.currentTime, 0.02);
    }
    if (bgmGainNode) {
      const effectiveBgm = bgmEnabled && !isMuted ? musicVol * 0.28 : 0.0;
      bgmGainNode.gain.setTargetAtTime(effectiveBgm, audioCtx.currentTime, 0.04);
    }
    if (sfxGainNode) {
      const effectiveSfx = sfxEnabled && !isMuted ? sfxVol * 0.85 : 0.0;
      sfxGainNode.gain.setTargetAtTime(effectiveSfx, audioCtx.currentTime, 0.02);
    }
  }

  function getAudioContext() {
    if (!audioCtx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      if (AudioContext) {
        audioCtx = new AudioContext();
        masterGainNode = audioCtx.createGain();
        masterGainNode.gain.value = isMuted ? 0.0 : masterVol;
        masterGainNode.connect(audioCtx.destination);

        sfxGainNode = audioCtx.createGain();
        sfxGainNode.gain.value = sfxEnabled ? sfxVol * 0.85 : 0.0;
        sfxGainNode.connect(masterGainNode);

        bgmGainNode = audioCtx.createGain();
        bgmGainNode.gain.value = bgmEnabled ? musicVol * 0.28 : 0.0;
        bgmGainNode.connect(masterGainNode);
      }
    }
    if (audioCtx && audioCtx.state === 'suspended') {
      audioCtx.resume().catch(() => {});
    }
    return audioCtx;
  }

  // Auto-unlock WebAudio on first user interaction anywhere
  const unlockEvents = ['click', 'touchstart', 'pointerdown', 'keydown'];
  function unlockAudio() {
    getAudioContext();
    unlockEvents.forEach(e => window.removeEventListener(e, unlockAudio));
  }
  unlockEvents.forEach(e => window.addEventListener(e, unlockAudio, { passive: true }));

  function playTone(freq, startOffset, duration, type, volume, endFreq) {
    const ctx = getAudioContext();
    if (!ctx || !sfxEnabled || isMuted) return;
    try {
      const t0 = ctx.currentTime + (startOffset || 0);
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = type || 'sine';
      osc.frequency.setValueAtTime(freq, t0);
      if (endFreq && endFreq !== freq) {
        osc.frequency.exponentialRampToValueAtTime(Math.max(20, endFreq), t0 + duration);
      }
      gain.gain.setValueAtTime(Math.max(0.001, volume || 0.3), t0);
      gain.gain.exponentialRampToValueAtTime(0.001, t0 + duration);
      osc.connect(gain);
      gain.connect(sfxGainNode);
      osc.start(t0);
      osc.stop(t0 + duration + 0.01);
    } catch (_) {}
  }

  // Sound Effects
  const SFX = {
    playClick: function () {
      playTone(680, 0, 0.065, 'triangle', 0.28, 1180);
    },

    playDice: function () {
      for (let i = 0; i < 6; i++) {
        playTone(220 + Math.random() * 320, i * 0.065, 0.04, 'square', 0.22);
      }
    },

    playStep: function (pitchFactor) {
      const baseFreq = 440 + ((pitchFactor || 0) % 8) * 45;
      playTone(baseFreq, 0, 0.11, 'sine', 0.28, baseFreq * 1.45);
    },

    playLadder: function () {
      [523.25, 659.25, 783.99, 987.77, 1046.50, 1318.51].forEach((freq, idx) => {
        playTone(freq, idx * 0.08, 0.20, 'triangle', 0.34);
      });
    },

    playSnake: function () {
      playTone(540, 0, 0.50, 'sawtooth', 0.32, 95);
    },

    playVictory: function () {
      const melody = [
        { f: 523.25, t: 0.00, d: 0.14 },
        { f: 659.25, t: 0.12, d: 0.14 },
        { f: 783.99, t: 0.24, d: 0.16 },
        { f: 1046.50, t: 0.40, d: 0.34 },
        { f: 880.00, t: 0.76, d: 0.14 },
        { f: 1046.50, t: 0.90, d: 0.55 },
      ];
      melody.forEach(n => playTone(n.f, n.t, n.d, 'triangle', 0.42));
    },

    playCorrect: function () {
      // Bright sparkling major chord arpeggio
      playTone(523.25, 0.00, 0.18, 'sine', 0.32);
      playTone(659.25, 0.07, 0.20, 'sine', 0.34);
      playTone(783.99, 0.14, 0.24, 'triangle', 0.36);
      playTone(1046.50, 0.22, 0.42, 'sine', 0.38);
    },

    playWrong: function () {
      // Soft, calm educational chime (encouraging, non-punishing)
      playTone(392.00, 0.00, 0.20, 'sine', 0.24);
      playTone(329.63, 0.14, 0.30, 'triangle', 0.22);
    },

    playStar: function () {
      [1174.66, 1567.98, 2093.00].forEach((f, idx) => {
        playTone(f, idx * 0.06, 0.16, 'sine', 0.25);
      });
    },

    playWorldUnlock: function () {
      [392.00, 493.88, 587.33, 783.99].forEach((f, idx) => {
        playTone(f, idx * 0.09, 0.32, 'triangle', 0.34);
      });
    },

    playPagerBeep: function () {
      playTone(880, 0.00, 0.08, 'sine', 0.28);
      playTone(1175, 0.11, 0.10, 'sine', 0.30);
    },

    playTargetLock: function () {
      playTone(660, 0.00, 0.11, 'sine', 0.28, 1320);
      playTone(1568, 0.12, 0.18, 'triangle', 0.30);
    },

    playCrystal: function () {
      playTone(987.77, 0.00, 0.10, 'sine', 0.24, 1567.98);
    },

    playThruster: function () {
      playTone(160, 0.00, 0.09, 'triangle', 0.12, 95);
    },

    playHit: function () {
      playTone(210, 0.00, 0.18, 'sawtooth', 0.28, 58);
    },

    playBossLaser: function () {
      playTone(1480, 0.00, 0.16, 'sine', 0.24, 420);
    },

    playCombo: function () {
      playTone(659.25, 0.00, 0.10, 'triangle', 0.26);
      playTone(830.61, 0.05, 0.10, 'triangle', 0.28);
      playTone(1046.50, 0.10, 0.18, 'triangle', 0.30);
    },

    playWeaponShot: function (weaponIndex) {
      const idx = weaponIndex || 0;
      switch (idx) {
        case 0: // Laser Médical MK-I (Crisp cyan laser)
          playTone(1350, 0, 0.09, 'sine', 0.22, 480);
          break;
        case 1: // Double Laser Océan (Twin crisp harmonic)
          playTone(1520, 0, 0.08, 'triangle', 0.20, 560);
          playTone(1140, 0.02, 0.08, 'sine', 0.18, 420);
          break;
        case 2: // Canon Antibactérien (Punchy burst pop)
          playTone(540, 0, 0.11, 'triangle', 0.28, 160);
          playTone(980, 0.01, 0.07, 'sine', 0.18, 420);
          break;
        case 3: // Orbes Thérapeutiques (Sparkling homing ping)
          playTone(740, 0, 0.12, 'sine', 0.22, 1320);
          break;
        case 4: // Plasma Bio-Émeraude (Resonant ion pulse)
          playTone(620, 0, 0.14, 'triangle', 0.26, 280);
          break;
        case 5: // Bouclier Déflecteur Pulsé (Magnetic ring tone)
          playTone(880, 0, 0.12, 'sine', 0.22, 660);
          break;
        case 6: // Onde Anti-Inflammatoire (Harmonic sweep)
          playTone(680, 0, 0.16, 'sine', 0.25, 1180);
          break;
        case 7: // Rayon Thérapeutique Ultime (Rich cosmic triad)
        default:
          playTone(1100, 0, 0.13, 'triangle', 0.25, 440);
          playTone(1650, 0, 0.12, 'sine', 0.20, 660);
          break;
      }
    },

    playSpecialSkill: function () {
      // Sweeping anti-inflammatory shockwave pulse
      playTone(320, 0.00, 0.34, 'sine', 0.34, 1280);
      playTone(640, 0.06, 0.28, 'triangle', 0.26, 1760);
    },

    playShieldActivate: function () {
      playTone(523.25, 0.00, 0.14, 'sine', 0.26, 1046.50);
      playTone(783.99, 0.06, 0.18, 'triangle', 0.22);
    },

    playBossEntrance: function () {
      playTone(220, 0.00, 0.22, 'sawtooth', 0.26, 330);
      playTone(196, 0.24, 0.38, 'triangle', 0.32, 146.83);
      playTone(587.33, 0.26, 0.36, 'sine', 0.24);
    },

    playBossAttack: function () {
      playTone(340, 0.00, 0.14, 'sawtooth', 0.22, 140);
      playTone(620, 0.03, 0.12, 'triangle', 0.18, 220);
    },

    playBossDefeat: function () {
      playTone(320, 0.00, 0.35, 'sawtooth', 0.32, 65);
      playTone(523.25, 0.20, 0.16, 'triangle', 0.36);
      playTone(659.25, 0.34, 0.16, 'triangle', 0.38);
      playTone(783.99, 0.48, 0.20, 'triangle', 0.40);
      playTone(1046.50, 0.66, 0.65, 'sine', 0.44);
    },

    playRevive: function () {
      playTone(440, 0.00, 0.16, 'sine', 0.30, 880);
      playTone(659.25, 0.10, 0.24, 'triangle', 0.32, 1318.5);
    }
  };

  // ============================================================================
  // MULTI-STAGE & BOSS BACKGROUND MUSIC ENGINE (Per-organ ambient themes)
  // Guaranteed single active loop: always stops prior timer before starting!
  // ============================================================================
  const BGM_TRACKS = {
    // Stage 1 (Œsophage) - Flowing bright C Major exploration
    stage1: [
      { f: 523.25, b: 261.63, d: 0.26 },
      { f: 587.33, b: 261.63, d: 0.26 },
      { f: 659.25, b: 329.63, d: 0.26 },
      { f: 783.99, b: 329.63, d: 0.42 },
      { f: 659.25, b: 293.66, d: 0.26 },
      { f: 587.33, b: 293.66, d: 0.26 },
      { f: 523.25, b: 246.94, d: 0.42 },
      { f: 440.00, b: 220.00, d: 0.26 },
      { f: 523.25, b: 220.00, d: 0.26 },
      { f: 659.25, b: 261.63, d: 0.26 },
      { f: 587.33, b: 196.00, d: 0.52 },
      { f: 392.00, b: 196.00, d: 0.26 },
      { f: 440.00, b: 220.00, d: 0.26 },
      { f: 523.25, b: 261.63, d: 0.52 }
    ],
    // Stage 2 (Estomac) - Warm bubbling G Major rhythm
    stage2: [
      { f: 392.00, b: 196.00, d: 0.24 },
      { f: 493.88, b: 196.00, d: 0.24 },
      { f: 587.33, b: 246.94, d: 0.24 },
      { f: 783.99, b: 293.66, d: 0.36 },
      { f: 659.25, b: 261.63, d: 0.24 },
      { f: 587.33, b: 246.94, d: 0.24 },
      { f: 493.88, b: 196.00, d: 0.36 },
      { f: 440.00, b: 220.00, d: 0.24 },
      { f: 523.25, b: 261.63, d: 0.24 },
      { f: 587.33, b: 196.00, d: 0.48 }
    ],
    // Stage 3 (Intestin Grêle) - Crystal absorbing F Major arpeggio
    stage3: [
      { f: 349.23, b: 174.61, d: 0.22 },
      { f: 440.00, b: 174.61, d: 0.22 },
      { f: 523.25, b: 220.00, d: 0.22 },
      { f: 698.46, b: 261.63, d: 0.34 },
      { f: 659.25, b: 220.00, d: 0.22 },
      { f: 587.33, b: 196.00, d: 0.22 },
      { f: 523.25, b: 174.61, d: 0.34 },
      { f: 440.00, b: 146.83, d: 0.22 },
      { f: 523.25, b: 174.61, d: 0.44 }
    ],
    // Stage 4 (Iléon Terminal) - Tech immune D Dorian groove
    stage4: [
      { f: 293.66, b: 146.83, d: 0.21 },
      { f: 440.00, b: 146.83, d: 0.21 },
      { f: 523.25, b: 174.61, d: 0.21 },
      { f: 587.33, b: 220.00, d: 0.32 },
      { f: 493.88, b: 196.00, d: 0.21 },
      { f: 440.00, b: 174.61, d: 0.21 },
      { f: 392.00, b: 146.83, d: 0.32 },
      { f: 329.63, b: 130.81, d: 0.21 },
      { f: 440.00, b: 146.83, d: 0.42 }
    ],
    // Stage 5 (Côlon Transverse) - Calming azure Em/C osmotic motif
    stage5: [
      { f: 329.63, b: 164.81, d: 0.25 },
      { f: 392.00, b: 164.81, d: 0.25 },
      { f: 493.88, b: 196.00, d: 0.25 },
      { f: 659.25, b: 246.94, d: 0.38 },
      { f: 587.33, b: 220.00, d: 0.25 },
      { f: 523.25, b: 196.00, d: 0.25 },
      { f: 493.88, b: 164.81, d: 0.38 },
      { f: 392.00, b: 130.81, d: 0.25 },
      { f: 440.00, b: 164.81, d: 0.45 }
    ],
    // Stage 6 (Rectum & Urgences) - Crisp clinical alert A Minor pulse
    stage6: [
      { f: 440.00, b: 110.00, d: 0.19 },
      { f: 523.25, b: 110.00, d: 0.19 },
      { f: 659.25, b: 164.81, d: 0.19 },
      { f: 587.33, b: 146.83, d: 0.28 },
      { f: 523.25, b: 130.81, d: 0.19 },
      { f: 493.88, b: 123.47, d: 0.19 },
      { f: 440.00, b: 110.00, d: 0.32 },
      { f: 659.25, b: 164.81, d: 0.19 },
      { f: 783.99, b: 196.00, d: 0.36 }
    ],
    // Stage 7 (Sanctuaire Final) - Radiant Lydian championship finale
    stage7: [
      { f: 523.25, b: 261.63, d: 0.20 },
      { f: 659.25, b: 261.63, d: 0.20 },
      { f: 739.99, b: 293.66, d: 0.20 },
      { f: 987.77, b: 329.63, d: 0.36 },
      { f: 783.99, b: 293.66, d: 0.20 },
      { f: 659.25, b: 261.63, d: 0.20 },
      { f: 783.99, b: 246.94, d: 0.36 },
      { f: 1046.50, b: 261.63, d: 0.48 }
    ],
    // Energetic heroic arcade Boss Fight rhythm
    boss: [
      { f: 440.00, b: 110.00, d: 0.18 },
      { f: 523.25, b: 110.00, d: 0.18 },
      { f: 659.25, b: 130.81, d: 0.18 },
      { f: 587.33, b: 110.00, d: 0.18 },
      { f: 659.25, b: 130.81, d: 0.24 },
      { f: 880.00, b: 146.83, d: 0.30 },
      { f: 783.99, b: 146.83, d: 0.18 },
      { f: 659.25, b: 130.81, d: 0.18 },
      { f: 587.33, b: 116.54, d: 0.18 },
      { f: 523.25, b: 98.00,  d: 0.18 },
      { f: 659.25, b: 123.47, d: 0.24 },
      { f: 783.99, b: 123.47, d: 0.30 }
    ]
  };

  const BGM = {
    noteIdx: 0,

    playNextNote: function () {
      if (!isBgmPlaying || !bgmEnabled || isMuted) return;
      const ctx = getAudioContext();
      if (!ctx) return;

      const track = BGM_TRACKS[activeTrackMode] || BGM_TRACKS.stage1;
      const note = track[BGM.noteIdx % track.length];
      BGM.noteIdx = (BGM.noteIdx + 1) % track.length;

      try {
        const now = ctx.currentTime;
        // Lead melody
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = activeTrackMode === 'boss' ? 'triangle' : 'sine';
        osc.frequency.setValueAtTime(note.f, now);
        gain.gain.setValueAtTime(activeTrackMode === 'boss' ? 0.32 : 0.24, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + note.d * 0.92);
        osc.connect(gain);
        gain.connect(bgmGainNode);
        osc.start(now);
        osc.stop(now + note.d);

        // Warm Bass Pulse
        const bass = ctx.createOscillator();
        const bassGain = ctx.createGain();
        bass.type = 'triangle';
        bass.frequency.setValueAtTime(note.b, now);
        bassGain.gain.setValueAtTime(activeTrackMode === 'boss' ? 0.26 : 0.16, now);
        bassGain.gain.exponentialRampToValueAtTime(0.001, now + note.d * 0.85);
        bass.connect(bassGain);
        bassGain.connect(bgmGainNode);
        bass.start(now);
        bass.stop(now + note.d);
      } catch (_) {}

      bgmTimer = setTimeout(BGM.playNextNote, note.d * 1000);
    },

    start: function (mode) {
      const targetMode = mode || 'exploration';
      // Always stop any running track cleanly first (no double-playing music!)
      if (isBgmPlaying && activeTrackMode === targetMode) {
        return;
      }
      BGM.stop();
      activeTrackMode = targetMode;
      if (!bgmEnabled || isMuted) return;
      isBgmPlaying = true;
      BGM.noteIdx = 0;
      BGM.playNextNote();
    },

    stop: function () {
      isBgmPlaying = false;
      if (bgmTimer) {
        clearTimeout(bgmTimer);
        bgmTimer = null;
      }
    }
  };

  // Global window API for Dart / Flutter
  window.NursingAudio = {
    init: function () {
      getAudioContext();
      syncGains();
    },
    playClick: SFX.playClick,
    playDice: SFX.playDice,
    playStep: SFX.playStep,
    playLadder: SFX.playLadder,
    playSnake: SFX.playSnake,
    playVictory: SFX.playVictory,
    playCorrect: SFX.playCorrect,
    playWrong: SFX.playWrong,
    playStar: SFX.playStar,
    playWorldUnlock: SFX.playWorldUnlock,
    playPagerBeep: SFX.playPagerBeep,
    playTargetLock: SFX.playTargetLock,
    playCrystal: SFX.playCrystal,
    playThruster: SFX.playThruster,
    playHit: SFX.playHit,
    playBossLaser: SFX.playBossLaser,
    playCombo: SFX.playCombo,
    playWeaponShot: SFX.playWeaponShot,
    playSpecialSkill: SFX.playSpecialSkill,
    playShieldActivate: SFX.playShieldActivate,
    playBossEntrance: SFX.playBossEntrance,
    playBossAttack: SFX.playBossAttack,
    playBossDefeat: SFX.playBossDefeat,
    playRevive: SFX.playRevive,

    startBgm: function (stageId) {
      const id = (stageId && stageId >= 1 && stageId <= 7) ? stageId : 1;
      BGM.start('stage' + id);
    },
    startBossBgm: function () {
      BGM.start('boss');
    },
    stopBgm: function () {
      BGM.stop();
    },
    toggleBgm: function () {
      bgmEnabled = !bgmEnabled;
      syncGains();
      if (bgmEnabled && !isMuted) {
        BGM.start(activeTrackMode);
      } else {
        BGM.stop();
      }
      return bgmEnabled;
    },
    setBgmEnabled: function (enabled) {
      bgmEnabled = !!enabled;
      syncGains();
      if (bgmEnabled && !isMuted) {
        BGM.start(activeTrackMode);
      } else {
        BGM.stop();
      }
    },
    toggleSfx: function () {
      sfxEnabled = !sfxEnabled;
      syncGains();
      return sfxEnabled;
    },
    setSfxEnabled: function (enabled) {
      sfxEnabled = !!enabled;
      syncGains();
    },
    setMasterVolume: function (vol) {
      masterVol = Math.max(0.0, Math.min(1.0, vol));
      syncGains();
    },
    setMusicVolume: function (vol) {
      musicVol = Math.max(0.0, Math.min(1.0, vol));
      syncGains();
    },
    setSfxVolume: function (vol) {
      sfxVol = Math.max(0.0, Math.min(1.0, vol));
      syncGains();
    },
    setMuted: function (muted) {
      isMuted = !!muted;
      syncGains();
      if (isMuted) {
        BGM.stop();
      }
    },
    isBgmEnabled: function () {
      return bgmEnabled && !isMuted;
    },
    isSfxEnabled: function () {
      return sfxEnabled && !isMuted;
    }
  };
  window.GastroAudio = window.NursingAudio;
})();
