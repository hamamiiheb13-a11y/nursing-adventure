import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_progress.dart';
import '../services/storage_service.dart';
import '../audio/audio_service.dart';
import '../widgets/tactile_button.dart';

class CapsuleWarriorsSettingsScreen extends StatefulWidget {
  final GameProgress progress;
  final VoidCallback onProgressReset;

  const CapsuleWarriorsSettingsScreen({
    super.key,
    required this.progress,
    required this.onProgressReset,
  });

  @override
  State<CapsuleWarriorsSettingsScreen> createState() => _CapsuleWarriorsSettingsScreenState();
}

class _CapsuleWarriorsSettingsScreenState extends State<CapsuleWarriorsSettingsScreen> {
  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();

  bool _bgmEnabled = true;
  bool _sfxEnabled = true;
  bool _screenShakeEnabled = true;

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEF4444)),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 26),
            const SizedBox(width: 8),
            Text(
              'RÉINITIALISATION',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'Voulez-vous réinitialiser toute votre progression (score, niveaux, armes débloquées, questions maîtrisées) ?\nCette action est irréversible.',
          style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Annuler', style: GoogleFonts.inter(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _storage.clearProgress();
              widget.onProgressReset();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text('Confirmer la réinitialisation', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 750;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          'PARAMÈTRES DU JEU',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 15 : 18,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
              vertical: 24,
            ),
            children: [
              // Audio Settings
              _buildSectionHeader('AUDIO & SONS SYNTHÉTISÉS'),
              const SizedBox(height: 12),
              _buildSwitchTile(
                title: 'Effets Sonores Arcade (SFX)',
                subtitle: 'Tirs laser, propulseur, collecte de cristaux et alertes boss',
                value: _sfxEnabled,
                onChanged: (val) => setState(() => _sfxEnabled = val),
                icon: Icons.volume_up_rounded,
                color: const Color(0xFF00E5FF),
              ),
              const SizedBox(height: 10),
              _buildSwitchTile(
                title: 'Ambiance Sonore Bio-Gastrique',
                subtitle: 'Génération de bruits hydrostatiques gastriques et échos',
                value: _bgmEnabled,
                onChanged: (val) => setState(() => _bgmEnabled = val),
                icon: Icons.music_note_rounded,
                color: const Color(0xFF38BDF8),
              ),
              const SizedBox(height: 28),

              // Visual Settings
              _buildSectionHeader('GRAPHISMES & EFFETS VISUELS'),
              const SizedBox(height: 12),
              _buildSwitchTile(
                title: 'Secousses d\'Écran (Screen Shake)',
                subtitle: 'Impact cinétique lors des collisions et tirs ennemis',
                value: _screenShakeEnabled,
                onChanged: (val) => setState(() => _screenShakeEnabled = val),
                icon: Icons.vibration_rounded,
                color: const Color(0xFFFFD166),
              ),
              const SizedBox(height: 28),

              // Data & Reset
              _buildSectionHeader('DONNÉES & PROGRESSION'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progression Actuelle Enregistrée',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Score : ${widget.progress.totalScore} pts  •  XP : ${widget.progress.totalXp} XP  •  Armes débloquées : ${widget.progress.unlockedWeapons.length}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.delete_forever_rounded),
                      label: Text(
                        'Réinitialiser toute la progression',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                      onPressed: _confirmReset,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF00E5FF),
        fontSize: 11.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
