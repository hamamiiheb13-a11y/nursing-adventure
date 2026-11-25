import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../models/game_progress.dart';
import '../services/storage_service.dart';
import '../theme/capsule_theme.dart';
import '../utils/fullscreen_util.dart';
import '../widgets/capsule_parallax_background.dart';

class CapsuleWarriorsSettingsScreen extends StatefulWidget {
  final GameProgress? progress;
  final VoidCallback? onProgressReset;

  const CapsuleWarriorsSettingsScreen({
    super.key,
    this.progress,
    this.onProgressReset,
  });

  @override
  State<CapsuleWarriorsSettingsScreen> createState() =>
      _CapsuleWarriorsSettingsScreenState();
}

class _CapsuleWarriorsSettingsScreenState
    extends State<CapsuleWarriorsSettingsScreen> {
  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();

  double _masterVolume = 100.0;
  double _musicVolume = 75.0;
  double _sfxVolume = 90.0;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _isMuted = false;
  bool _isFullscreen = false;
  String _selectedLanguage = 'FR'; // 'FR' or 'EN'

  @override
  void initState() {
    super.initState();
    final progress = widget.progress ?? _storage.currentProgress;
    _masterVolume = (progress.masterVolume * 100).clamp(0.0, 100.0);
    _musicVolume = (progress.musicVolume * 100).clamp(0.0, 100.0);
    _sfxVolume = (progress.sfxVolume * 100).clamp(0.0, 100.0);
    _musicEnabled = progress.musicEnabled;
    _sfxEnabled = progress.sfxEnabled;
    _isMuted = progress.isMuted;
    _isFullscreen = FullscreenUtil.isFullscreen;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _persistAudio() async {
    final targets = <GameProgress>{
      _storage.currentProgress,
      if (widget.progress != null) widget.progress!,
    };
    for (final p in targets) {
      p.masterVolume = (_masterVolume / 100.0).clamp(0.0, 1.0);
      p.musicVolume = (_musicVolume / 100.0).clamp(0.0, 1.0);
      p.sfxVolume = (_sfxVolume / 100.0).clamp(0.0, 1.0);
      p.musicEnabled = _musicEnabled;
      p.sfxEnabled = _sfxEnabled;
      p.isMuted = _isMuted;
    }
    await _storage.saveProgress(_storage.currentProgress);
    if (widget.progress != null &&
        !identical(widget.progress, _storage.currentProgress)) {
      await _storage.saveProgress(widget.progress!);
    }
  }

  void _toggleFullscreen(bool val) {
    if (FullscreenUtil.isFullscreen != val) {
      FullscreenUtil.toggle();
    }
    setState(() => _isFullscreen = FullscreenUtil.isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _confirmReset() {
    _audio.playTargetLock();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CapsuleColors.oceanSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: CapsuleColors.dangerRed, width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: CapsuleColors.dangerRed, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'RÉINITIALISATION',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Voulez-vous réinitialiser toute votre progression ?\n(Niveaux, scores, armes débloquées et questions révisées seront effacés).\nCette action est irréversible.',
          style: GoogleFonts.plusJakartaSans(color: CapsuleColors.textSubtle, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'ANNULER',
              style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CapsuleColors.dangerRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _storage.clearProgress();
              if (widget.onProgressReset != null) {
                widget.onProgressReset!();
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: CapsuleColors.oceanSurface,
                    content: Text(
                      'Progression réinitialisée avec succès.',
                      style: GoogleFonts.plusJakartaSans(color: CapsuleColors.cyanGlow, fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              }
            },
            child: Text(
              'EFFACER TOUT',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isCompact = media.size.height < 520;

    final isNarrow = media.size.width < 600;

    return Scaffold(
      backgroundColor: CapsuleColors.deepOcean,
      body: CapsuleParallaxBackground(
        showHeroCapsule: false,
        showEnemySilhouettes: false,
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar: RETOUR button + Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isNarrow ? 14 : 24, vertical: 12),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _audio.playClick();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: CapsuleColors.oceanSurface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_rounded, color: CapsuleColors.cyanGlow, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'RETOUR',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PARAMÈTRES & CONFIGURATION',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isNarrow || isCompact ? 15 : 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: CapsuleColors.cyanGlow.withValues(alpha: 0.55),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Settings Sections
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isNarrow ? 14 : (isCompact ? 20 : 36),
                    vertical: 8,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Column(
                        children: [
                          // Audio Settings: Music & SFX Sliders + Mute Toggle
                          _buildCard(
                            title: 'VOLUME AUDIO & EFFETS SONORES',
                            icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                            color: CapsuleColors.cyanGlow,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _isMuted ? 'Audio global coupé' : 'Audio actif',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: _isMuted ? CapsuleColors.dangerOrange : CapsuleColors.mintGlow,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Switch(
                                      value: !_isMuted,
                                      activeThumbColor: CapsuleColors.cyanGlow,
                                      onChanged: (enabled) {
                                        setState(() => _isMuted = !enabled);
                                        _audio.setMuted(_isMuted);
                                        _persistAudio();
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Master Volume Slider
                                Row(
                                  children: [
                                    const Icon(Icons.speaker_rounded, color: CapsuleColors.gold, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'VOLUME GÉNÉRAL : ${_masterVolume.toInt()}%',
                                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                          ),
                                          Slider(
                                            value: _masterVolume,
                                            min: 0,
                                            max: 100,
                                            activeColor: CapsuleColors.gold,
                                            inactiveColor: CapsuleColors.cardOcean,
                                            onChanged: (val) {
                                              setState(() {
                                                _masterVolume = val;
                                                if (val > 0 && _isMuted) _isMuted = false;
                                              });
                                              _audio.setMuted(_isMuted);
                                              _audio.setMasterVolume(val / 100.0);
                                            },
                                            onChangeEnd: (_) => _persistAudio(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Music Volume Slider & Independent Toggle
                                Row(
                                  children: [
                                    Icon(
                                      _musicEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                                      color: _musicEnabled ? CapsuleColors.turquoise : CapsuleColors.textMuted,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'MUSIQUE BIO-GASTRIQUE : ${_musicEnabled ? "${_musicVolume.toInt()}%" : "DÉSACTIVÉE"}',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: _musicEnabled ? CapsuleColors.textWhite : CapsuleColors.textMuted,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              Transform.scale(
                                                scale: 0.84,
                                                child: Switch(
                                                  key: const Key('music_toggle_switch'),
                                                  value: _musicEnabled,
                                                  thumbColor: WidgetStateProperty.resolveWith(
                                                    (states) => states.contains(WidgetState.selected)
                                                        ? Colors.white
                                                        : CapsuleColors.textMuted,
                                                  ),
                                                  trackColor: WidgetStateProperty.resolveWith(
                                                    (states) => states.contains(WidgetState.selected)
                                                        ? CapsuleColors.cyanGlow.withValues(alpha: 0.65)
                                                        : CapsuleColors.cardOcean,
                                                  ),
                                                  onChanged: (val) {
                                                    setState(() => _musicEnabled = val);
                                                    _audio.setBgmEnabled(val);
                                                    _persistAudio();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          Slider(
                                            value: _musicVolume,
                                            min: 0,
                                            max: 100,
                                            activeColor: _musicEnabled ? CapsuleColors.cyanGlow : CapsuleColors.textMuted,
                                            inactiveColor: CapsuleColors.cardOcean,
                                            onChanged: (val) {
                                              setState(() {
                                                _musicVolume = val;
                                                if (val > 0) {
                                                  if (_isMuted) _isMuted = false;
                                                  if (!_musicEnabled) _musicEnabled = true;
                                                }
                                              });
                                              _audio.setMuted(_isMuted);
                                              _audio.setBgmEnabled(_musicEnabled);
                                              _audio.setMusicVolume(val / 100.0);
                                            },
                                            onChangeEnd: (_) => _persistAudio(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // SFX Volume Slider & Independent Toggle
                                Row(
                                  children: [
                                    Icon(
                                      _sfxEnabled ? Icons.graphic_eq_rounded : Icons.volume_off_rounded,
                                      color: _sfxEnabled ? CapsuleColors.softViolet : CapsuleColors.textMuted,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'EFFETS SONORES & TIRS : ${_sfxEnabled ? "${_sfxVolume.toInt()}%" : "DÉSACTIVÉS"}',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: _sfxEnabled ? CapsuleColors.textWhite : CapsuleColors.textMuted,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              Transform.scale(
                                                scale: 0.84,
                                                child: Switch(
                                                  key: const Key('sfx_toggle_switch'),
                                                  value: _sfxEnabled,
                                                  thumbColor: WidgetStateProperty.resolveWith(
                                                    (states) => states.contains(WidgetState.selected)
                                                        ? Colors.white
                                                        : CapsuleColors.textMuted,
                                                  ),
                                                  trackColor: WidgetStateProperty.resolveWith(
                                                    (states) => states.contains(WidgetState.selected)
                                                        ? CapsuleColors.softViolet.withValues(alpha: 0.7)
                                                        : CapsuleColors.cardOcean,
                                                  ),
                                                  onChanged: (val) {
                                                    setState(() => _sfxEnabled = val);
                                                    _audio.setSfxEnabled(val);
                                                    if (val) _audio.playClick();
                                                    _persistAudio();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          Slider(
                                            value: _sfxVolume,
                                            min: 0,
                                            max: 100,
                                            activeColor: _sfxEnabled ? CapsuleColors.softViolet : CapsuleColors.textMuted,
                                            inactiveColor: CapsuleColors.cardOcean,
                                            onChanged: (val) {
                                              setState(() {
                                                _sfxVolume = val;
                                                if (val > 0) {
                                                  if (_isMuted) _isMuted = false;
                                                  if (!_sfxEnabled) _sfxEnabled = true;
                                                }
                                              });
                                              _audio.setMuted(_isMuted);
                                              _audio.setSfxEnabled(_sfxEnabled);
                                              _audio.setSfxVolume(val / 100.0);
                                            },
                                            onChangeEnd: (_) {
                                              _persistAudio();
                                              if (_sfxEnabled) _audio.playClick();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Display & Language Options (Responsive on narrow phones)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final stackCols = constraints.maxWidth < 560;
                              final fullscreenCard = _buildCard(
                                title: 'PLEIN ÉCRAN',
                                icon: Icons.fullscreen_rounded,
                                color: CapsuleColors.electricBlue,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _isFullscreen ? 'Activé (Immersion)' : 'Désactivé (Fenêtré)',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12.5),
                                      ),
                                    ),
                                    Switch(
                                      value: _isFullscreen,
                                      activeThumbColor: CapsuleColors.cyanGlow,
                                      onChanged: _toggleFullscreen,
                                    ),
                                  ],
                                ),
                              );
                              final languageCard = _buildCard(
                                title: 'LANGUE / LANGUAGE',
                                icon: Icons.language_rounded,
                                color: CapsuleColors.turquoise,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _selectedLanguage == 'FR' ? 'Français (Officiel ISSIT)' : 'English',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12.5),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildLangButton('FR'),
                                        const SizedBox(width: 6),
                                        _buildLangButton('EN'),
                                      ],
                                    ),
                                  ],
                                ),
                              );

                              if (stackCols) {
                                return Column(
                                  children: [
                                    fullscreenCard,
                                    const SizedBox(height: 12),
                                    languageCard,
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(child: fullscreenCard),
                                  const SizedBox(width: 14),
                                  Expanded(child: languageCard),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 14),

                          // Control Remapping Hint Card
                          _buildCard(
                            title: 'AIDE AUX COMMANDES (CONTRÔLES DU JEU)',
                            icon: Icons.sports_esports_rounded,
                            color: CapsuleColors.gold,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildControlBadge('[Z, Q, S, D] ou Flèches', 'Déplacement 360°'),
                                    _buildControlBadge('[ESPACE]', 'Tir Continu'),
                                    _buildControlBadge('[E] ou [Shift]', 'Bouclier'),
                                    _buildControlBadge('[Q / F]', 'Onde Spéciale'),
                                    _buildControlBadge('[ÉCHAP] ou [P]', 'Pause'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '* Sur mobile, un joystick analogique 360° et des boutons tactiles s\'affichent automatiquement.',
                                  style: GoogleFonts.plusJakartaSans(color: CapsuleColors.textSubtle, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Reset Progress Card
                          _buildCard(
                            title: 'ZONE DE DANGER • DONNÉES DE SAUVEGARDE',
                            icon: Icons.delete_forever_rounded,
                            color: CapsuleColors.dangerRed,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 520),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Réinitialiser toute la progression',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        'Efface les scores, les étoiles, les checkpoints et les armes débloquées.',
                                        style: GoogleFonts.plusJakartaSans(color: CapsuleColors.textSubtle, fontSize: 11.5),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CapsuleColors.dangerRed.withValues(alpha: 0.88),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: _confirmReset,
                                  icon: const Icon(Icons.refresh_rounded, size: 16),
                                  label: Text(
                                    'RÉINITIALISER',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CapsuleColors.oceanSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CapsuleColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildLangButton(String lang) {
    final isSelected = _selectedLanguage == lang;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => _selectedLanguage = lang),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? CapsuleColors.cyanGlow : CapsuleColors.cardOcean,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? CapsuleColors.cyanGlow : CapsuleColors.cardBorder),
        ),
        child: Text(
          lang,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected ? CapsuleColors.deepOcean : Colors.white70,
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildControlBadge(String keyText, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: CapsuleColors.cardOcean,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CapsuleColors.cardBorder),
      ),
      child: Column(
        children: [
          Text(keyText, style: GoogleFonts.plusJakartaSans(color: CapsuleColors.gold, fontSize: 10.5, fontWeight: FontWeight.w800)),
          Text(label, style: GoogleFonts.plusJakartaSans(color: CapsuleColors.textSubtle, fontSize: 10)),
        ],
      ),
    );
  }
}
