import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../theme/capsule_theme.dart';
import 'capsule_warriors_settings_screen.dart';

class CapsuleWarriorsPauseScreen extends StatefulWidget {
  final int score;
  final int stageId;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback? onSettings;
  final VoidCallback onQuit;

  const CapsuleWarriorsPauseScreen({
    super.key,
    required this.score,
    required this.stageId,
    required this.onResume,
    required this.onRestart,
    this.onSettings,
    required this.onQuit,
  });

  @override
  State<CapsuleWarriorsPauseScreen> createState() => _CapsuleWarriorsPauseScreenState();
}

class _CapsuleWarriorsPauseScreenState extends State<CapsuleWarriorsPauseScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  final AudioService _audio = AudioService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openSettings() {
    _audio.playClick();
    if (widget.onSettings != null) {
      widget.onSettings!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CapsuleWarriorsSettingsScreen(
            onProgressReset: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: 440,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: CapsuleColors.cyanGlow, width: 2),
            boxShadow: [
              BoxShadow(
                color: CapsuleColors.cyanGlow.withValues(alpha: 0.3),
                blurRadius: 30,
              ),
              const BoxShadow(color: Colors.black, blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing "EN PAUSE" Header
              ScaleTransition(
                scale: _pulseAnimation,
                child: Column(
                  children: [
                    const Icon(
                      Icons.pause_circle_filled_rounded,
                      color: CapsuleColors.cyanGlow,
                      size: 48,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'EN PAUSE',
                      style: GoogleFonts.orbitron(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: CapsuleColors.cyanGlow.withValues(alpha: 0.8),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Current Score & Progress Info Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF030712).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'STAGE ACTUEL',
                          style: GoogleFonts.orbitron(
                            color: CapsuleColors.textSubtle,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Stage ${widget.stageId} / 7',
                          style: GoogleFonts.orbitron(
                            color: CapsuleColors.turquoise,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 28, color: const Color(0xFF334155)),
                    Column(
                      children: [
                        Text(
                          'SCORE COURANT',
                          style: GoogleFonts.orbitron(
                            color: CapsuleColors.textSubtle,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.score} PTS',
                          style: GoogleFonts.orbitron(
                            color: CapsuleColors.gold,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4 Arcade Buttons: REPRENDRE, RECOMMENCER, PARAMÈTRES, QUITTER
              _buildPauseButton(
                label: 'REPRENDRE',
                icon: Icons.play_arrow_rounded,
                isPrimary: true,
                onTap: () {
                  _audio.playClick();
                  widget.onResume();
                },
              ),
              const SizedBox(height: 10),

              _buildPauseButton(
                label: 'RECOMMENCER',
                icon: Icons.replay_rounded,
                accentColor: CapsuleColors.dangerOrange,
                onTap: () {
                  _audio.playClick();
                  widget.onRestart();
                },
              ),
              const SizedBox(height: 10),

              _buildPauseButton(
                label: 'PARAMÈTRES',
                icon: Icons.settings_rounded,
                accentColor: CapsuleColors.purple,
                onTap: _openSettings,
              ),
              const SizedBox(height: 10),

              _buildPauseButton(
                label: 'QUITTER',
                icon: Icons.exit_to_app_rounded,
                accentColor: CapsuleColors.dangerRed,
                onTap: () {
                  _audio.playClick();
                  widget.onQuit();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPauseButton({
    required String label,
    required IconData icon,
    bool isPrimary = false,
    Color? accentColor,
    required VoidCallback onTap,
  }) {
    final effectiveColor = isPrimary ? CapsuleColors.cyanGlow : (accentColor ?? CapsuleColors.electricBlue);

    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        color: isPrimary
            ? CapsuleColors.electricBlue
            : const Color(0xFF1E293B).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? CapsuleColors.cyanGlow : effectiveColor.withValues(alpha: 0.6),
          width: isPrimary ? 2.0 : 1.2,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: CapsuleColors.cyanGlow.withValues(alpha: 0.35),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isPrimary ? Colors.white : effectiveColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
