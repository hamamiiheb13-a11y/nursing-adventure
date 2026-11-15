// ============================================================================
// NURSING ADVENTURE - Web Audio Synthesizer & Sound Engine
// 100% Client-side Web Audio API (Zero external MP3 dependencies, 100% offline)
// Pirate Anime Adventurous Theme + Medical Sound Effects
// ============================================================================

(function () {
  let audioCtx = null;
  let bgmInterval = null;
  let isBgmPlaying = false;
  let sfxEnabled = true;
  let bgmEnabled = true;
  let bgmGainNode = null;
  let sfxGainNode = null;

  function getAudioContext() {
    if (!audioCtx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      if (AudioContext) {
        audioCtx = new AudioContext();
        sfxGainNode = audioCtx.createGain();
        sfxGainNode.gain.value = 0.85;
        sfxGainNode.connect(audioCtx.destination);

        bgmGainNode = audioCtx.createGain();
        bgmGainNode.gain.value = 0.35;
        bgmGainNode.connect(audioCtx.destination);
      }
    }
    if (audioCtx && audioCtx.state === 'suspended') {
      audioCtx.resume();
    }
    return audioCtx;
  }

  // Auto-unlock on first user interaction anywhere
  const unlockEvents = ['click', 'touchstart', 'keydown'];
  function unlockAudio() {
    getAudioContext();
    unlockEvents.forEach(e => window.removeEventListener(e, unlockAudio));
  }
  unlockEvents.forEach(e => window.addEventListener(e, unlockAudio, { passive: true }));

  // Sound Effects
  const SFX = {
    playClick: function () {
      if (!sfxEnabled) return;
      const ctx = getAudioContext();
      if (!ctx) return;
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(650, ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(1200, ctx.currentTime + 0.06);
      gain.gain.setValueAtTime(0.4, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.08);
      osc.connect(gain);
      gain.connect(sfxGainNode);
      osc.start();
      osc.stop(ctx.currentTime + 0.08);
    },

    playDice: function () {
      if (!sfxEnabled) return;
      const ctx = getAudioContext();
      if (!ctx) return;
      const clicks = 6;
      for (let i = 0; i < clicks; i++) {
        const time = ctx.currentTime + i * 0.07;
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'square';
        const freq = 200 + Math.random() * 350;
        osc.frequency.setValueAtTime(freq, time);
        gain.gain.setValueAtTime(0.3, time);
        gain.gain.exponentialRampToValueAtTime(0.001, time + 0.04);
        osc.connect(gain);
        gain.connect(sfxGainNode);
        osc.start(time);
        osc.stop(time + 0.04);
      }
    },

    playStep: function (pitchFactor) {
      if (!sfxEnabled) return;
      const ctx = getAudioContext();
      if (!ctx) return;
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      const baseFreq = 440 + ((pitchFactor || 0) % 8) * 45;
      osc.frequency.setValueAtTime(baseFreq, ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(baseFreq * 1.5, ctx.currentTime + 0.08);
      gain.gain.setValueAtTime(0.35, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.12);
      osc.connect(gain);
      gain.connect(sfxGainNode);
      osc.start();
      osc.stop(ctx.currentTime + 0.12);
    },

    playLadder: function () {
      if (!sfxEnabled) return;
      const ctx = getAudioContext();
      if (!ctx) return;
      // Ascending triumphant golden arpeggio: C5, E5, G5, B5, C6
      const notes = [523.25, 659.25, 783.99, 987.77, 1046.50, 1318.51];
      notes.forEach((freq, idx) => {
        const time = ctx.currentTime + idx * 0.09;
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(freq, time);
        gain.gain.setValueAtTime(0.4, time);
        gain.gain.exponentialRampToValueAtTime(0.001, time + 0.22);
        osc.connect(gain);
        gain.connect(sfxGainNode);
        osc.start(time);
        osc.stop(time + 0.22);
      });
    },

    playSnake: function () {
      if (!sfxEnabled) return;
      const ctx = getAudioContext();
      if (!ctx) return;
      // Ominous slide down with hiss / descending frequency
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(580, ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(90, ctx.currentTime + 0.55);
      gain.gain.setValueAtTime(0.45, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.6);
      osc.connect(gain);
      gain.connect(sfxGainNode);
      osc.start();
      osc.stop(ctx.currentTime + 0.6);

      // Noise burst for snake hiss
      try {
        const bufferSize = ctx.sampleRate * 0.45;
        const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
          data[i] = (Math.random() * 2 - 1) * Math.exp(-i / (ctx.sampleRate * 0.2));
        }
        const noise = ctx.createBufferSource();
        noise.buffer = buffer;
        const noiseFilter = ctx.createBiquadFilter();
        noiseFilter.type = 'bandpass';
        noiseFilter.frequency.value = 3200;
        const noiseGain = ctx.createGain();
        noiseGain.gain.setValueAtTime(0.2, ctx.currentTime);
        noiseGain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.45);
        noise.connect(noiseFilter);
        noiseFilter.connect(noiseGain);
        noiseGain.connect(sfxGainNode);
        noise.start();
      } catch (e) {}
    },

    playVictory: function () {
      if (!sfxEnabled) return;
      const ctx = getAudioContext();
      if (!ctx) return;
      // Grand anime triumphant fanfare: G4, C5, E5, G5, high C6 chord burst
      const melody = [
        { f: 392.00, t: 0.00, d: 0.15 },
        { f: 523.25, t: 0.15, d: 0.15 },
        { f: 659.25, t: 0.30, d: 0.18 },
        { f: 783.99, t: 0.48, d: 0.35 },
        { f: 659.25, t: 0.85, d: 0.15 },
        { f: 783.99, t: 1.00, d: 0.18 },
        { f: 1046.50, t: 1.20, d: 0.80 },
      ];
      melody.forEach(note => {
        const time = ctx.currentTime + note.t;
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(note.f, time);
        gain.gain.setValueAtTime(0.5, time);
        gain.gain.exponentialRampToValueAtTime(0.001, time + note.d);
        osc.connect(gain);
        gain.connect(sfxGainNode);
        osc.start(time);
        osc.stop(time + note.d);
      });
    }
  };

  // Background Music (BGM)
  // Upbeat, adventurous, nautical anime pirate melody (original composition)
  // Key of D Major / B Minor with maritime cadence
  const BGM = {
    notes: [
      // Measure 1
      { f: 293.66, d: 0.24 }, // D4
      { f: 369.99, d: 0.24 }, // F#4
      { f: 440.00, d: 0.24 }, // A4
      { f: 587.33, d: 0.48 }, // D5
      // Measure 2
      { f: 523.25, d: 0.24 }, // C5
      { f: 440.00, d: 0.24 }, // A4
      { f: 369.99, d: 0.48 }, // F#4
      // Measure 3
      { f: 329.63, d: 0.24 }, // E4
      { f: 369.99, d: 0.24 }, // F#4
      { f: 440.00, d: 0.48 }, // A4
      // Measure 4 (Resolution)
      { f: 587.33, d: 0.36 }, // D5
      { f: 659.25, d: 0.36 }, // E5
      { f: 739.99, d: 0.60 }, // F#5
      // Measure 5
      { f: 587.33, d: 0.24 },
      { f: 440.00, d: 0.24 },
      { f: 493.88, d: 0.48 }, // B4
      // Measure 6
      { f: 440.00, d: 0.24 },
      { f: 369.99, d: 0.24 },
      { f: 293.66, d: 0.60 }  // D4
    ],
    noteIdx: 0,

    playNextNote: function () {
      if (!isBgmPlaying || !bgmEnabled) return;
      const ctx = getAudioContext();
      if (!ctx) return;

      const note = BGM.notes[BGM.noteIdx];
      BGM.noteIdx = (BGM.noteIdx + 1) % BGM.notes.length;

      // Lead melodic flute/horn synth
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(note.f, ctx.currentTime);
      gain.gain.setValueAtTime(0.2, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + note.d * 0.95);
      osc.connect(gain);
      gain.connect(bgmGainNode);
      osc.start();
      osc.stop(ctx.currentTime + note.d);

      // Warm bass pulse
      const bass = ctx.createOscillator();
      const bassGain = ctx.createGain();
      bass.type = 'sine';
      bass.frequency.setValueAtTime(note.f / 2, ctx.currentTime);
      bassGain.gain.setValueAtTime(0.18, ctx.currentTime);
      bassGain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + note.d * 0.8);
      bass.connect(bassGain);
      bassGain.connect(bgmGainNode);
      bass.start();
      bass.stop(ctx.currentTime + note.d);

      bgmInterval = setTimeout(BGM.playNextNote, note.d * 1000);
    },

    start: function () {
      if (isBgmPlaying) return;
      isBgmPlaying = true;
      BGM.noteIdx = 0;
      BGM.playNextNote();
    },

    stop: function () {
      isBgmPlaying = false;
      if (bgmInterval) {
        clearTimeout(bgmInterval);
        bgmInterval = null;
      }
    }
  };

  // Global window API for Dart / Flutter
  window.NursingAudio = {
    init: function () {
      getAudioContext();
    },
    playClick: SFX.playClick,
    playDice: SFX.playDice,
    playStep: SFX.playStep,
    playLadder: SFX.playLadder,
    playSnake: SFX.playSnake,
    playVictory: SFX.playVictory,

    startBgm: function () {
      if (!bgmEnabled) return;
      BGM.start();
    },
    stopBgm: function () {
      BGM.stop();
    },
    toggleBgm: function () {
      bgmEnabled = !bgmEnabled;
      if (bgmEnabled) {
        BGM.start();
      } else {
        BGM.stop();
      }
      return bgmEnabled;
    },
    setBgmEnabled: function (enabled) {
      bgmEnabled = !!enabled;
      if (bgmEnabled) {
        BGM.start();
      } else {
        BGM.stop();
      }
    },
    toggleSfx: function () {
      sfxEnabled = !sfxEnabled;
      return sfxEnabled;
    },
    setSfxEnabled: function (enabled) {
      sfxEnabled = !!enabled;
    },
    isBgmEnabled: function () {
      return bgmEnabled;
    },
    isSfxEnabled: function () {
      return sfxEnabled;
    }
  };
})();
