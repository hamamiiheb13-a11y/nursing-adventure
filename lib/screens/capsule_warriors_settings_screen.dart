import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../models/game_progress.dart';
import '../services/storage_service.dart';
import '../theme/capsule_theme.dart';
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

  double _musicVolume = 80.0;
  double _sfxVolume = 90.0;
  bool _isFullscreen = false;
  String _selectedLanguage = 'FR'; // 'FR' or 'EN'

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  void _toggleFullscreen(bool val) {
    setState(() => _isFullscreen = val);
    if (val) {
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
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: CapsuleColors.dangerRed, width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: CapsuleColors.dangerRed, size: 28),
            const SizedBox(width: 10),
            Text(
              'RÉINITIALISATION',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'Voulez-vous réinitialiser toute votre progression ?\n(Niveaux, scores, armes débloquées et questions révisées seront effacés).\nCette action est irréversible.',
          style: GoogleFonts.inter(color: CapsuleColors.textSubtle, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'ANNULER',
              style: GoogleFonts.orbitron(color: Colors.white70, fontWeight: FontWeight.w700),
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
                    backgroundColor: const Color(0xFF0F172A),
                    content: Text(
                      'Progression réinitialisée avec succès.',
                      style: GoogleFonts.inter(color: CapsuleColors.cyanGlow),
                    ),
                  ),
                );
              }
            },
            child: Text(
              'EFFACER TOUT',
              style: GoogleFonts.orbitron(fontWeight: FontWeight.w800),
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

    return Scaffold(
      backgroundColor: CapsuleColors.darkNavy,
      body: CapsuleParallaxBackground(
        showHeroCapsule: false,
        showEnemySilhouettes: false,
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar: RETOUR button + Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _audio.playClick();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back_rounded, color: CapsuleColors.cyanGlow, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'RETOUR',
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'PARAMÈTRES & CONFIGURATION',
                      style: GoogleFonts.orbitron(
                        fontSize: isCompact ? 15 : 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: CapsuleColors.cyanGlow.withValues(alpha: 0.7),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Settings Sections
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 20 : 36,
                    vertical: 8,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Column(
                        children: [
                          // Audio Settings: Music & SFX Sliders
                          _buildCard(
                            title: 'VOLUME AUDIO & EFFETS SONORES',
                            icon: Icons.volume_up_rounded,
                            color: CapsuleColors.cyanGlow,
                            child: Column(
                              children: [
                                // Music Volume Slider
                                Row(
                                  children: [
                                    const Icon(Icons.music_note_rounded, color: CapsuleColors.turquoise, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'MUSIQUE BIO-GASTRIQUE : ${_musicVolume.toInt()}%',
                                            style: GoogleFonts.orbitron(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                                          ),
                                          Slider(
                                            value: _musicVolume,
                                            min: 0,
                                            max: 100,
                                            activeColor: CapsuleColors.cyanGlow,
                                            inactiveColor: const Color(0xFF1E293B),
                                            onChanged: (val) => setState(() => _musicVolume = val),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // SFX Volume Slider
                                Row(
                                  children: [
                                    const Icon(Icons.graphic_eq_rounded, color: CapsuleColors.purple, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'EFFETS SONORES & TIRS : ${_sfxVolume.toInt()}%',
                                            style: GoogleFonts.orbitron(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                                          ),
                                          Slider(
                                            value: _sfxVolume,
                                            min: 0,
                                            max: 100,
                                            activeColor: CapsuleColors.purple,
                                            inactiveColor: const Color(0xFF1E293B),
                                            onChanged: (val) => setState(() => _sfxVolume = val),
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

                          // Display & Language Options
                          Row(
                            children: [
                              // Fullscreen Toggle
                              Expanded(
                                child: _buildCard(
                                  title: 'PLEIN ÉCRAN',
                                  icon: Icons.fullscreen_rounded,
                                  color: CapsuleColors.electricBlue,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _isFullscreen ? 'Activé (Immersion)' : 'Désactivé (Fenêtré)',
                                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                                      ),
                                      Switch(
                                        value: _isFullscreen,
                                        activeColor: CapsuleColors.cyanGlow,
                                        onChanged: _toggleFullscreen,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Language Toggle (FR / EN)
                              Expanded(
                                child: _buildCard(
                                  title: 'LANGUE / LANGUAGE',
                                  icon: Icons.language_rounded,
                                  color: CapsuleColors.turquoise,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedLanguage == 'FR' ? 'Français (Officiel ISSIT)' : 'English',
                                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                                      ),
                                      Row(
                                        children: [
                                          _buildLangButton('FR'),
                                          const SizedBox(width: 6),
                                          _buildLangButton('EN'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
                                Row(
                                  children: [
                                    _buildControlBadge('[Z, Q, S, D] ou Flèches', 'Déplacement'),
                                    const SizedBox(width: 10),
                                    _buildControlBadge('[ESPACE]', 'Tir Laser'),
                                    const SizedBox(width: 10),
                                    _buildControlBadge('[E] ou [Shift]', 'Bouclier'),
                                    const SizedBox(width: 10),
                                    _buildControlBadge('[ÉCHAP] ou [P]', 'Pause'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '* Sur mobile, des commandes tactiles virtuelles s\'affichent automatiquement à l\'écran.',
                                  style: GoogleFonts.inter(color: CapsuleColors.textSubtle, fontSize: 11),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Réinitialiser toute la progression',
                                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        'Efface les scores, les étoiles, les checkpoints et les armes débloquées.',
                                        style: GoogleFonts.inter(color: CapsuleColors.textSubtle, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CapsuleColors.dangerRed.withValues(alpha: 0.85),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: _confirmReset,
                                  icon: const Icon(Icons.refresh_rounded, size: 16),
                                  label: Text(
                                    'RÉINITIALISER',
                                    style: GoogleFonts.orbitron(fontSize: 10.5, fontWeight: FontWeight.w800),
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
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
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
          color: isSelected ? CapsuleColors.cyanGlow : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          lang,
          style: GoogleFonts.orbitron(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 11,
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
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          Text(keyText, style: GoogleFonts.orbitron(color: CapsuleColors.gold, fontSize: 10, fontWeight: FontWeight.w800)),
          Text(label, style: GoogleFonts.inter(color: CapsuleColors.textSubtle, fontSize: 9)),
        ],
      ),
    );
  }
}
