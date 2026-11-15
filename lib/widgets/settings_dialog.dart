import 'package:flutter/material.dart';
import '../audio/audio_service.dart';

class SettingsDialog extends StatefulWidget {
  final bool isFastSpeed;
  final ValueChanged<bool> onSpeedChanged;
  final VoidCallback? onRestartGame;
  final VoidCallback? onMainMenu;

  const SettingsDialog({
    super.key,
    required this.isFastSpeed,
    required this.onSpeedChanged,
    this.onRestartGame,
    this.onMainMenu,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final AudioService _audio = AudioService();
  late bool _sfx;
  late bool _bgm;
  late bool _fast;

  @override
  void initState() {
    super.initState();
    _sfx = _audio.sfxEnabled;
    _bgm = _audio.bgmEnabled;
    _fast = widget.isFastSpeed;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1E38),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 1,
            ),
            const BoxShadow(color: Colors.black87, blurRadius: 16),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.settings_rounded, color: Color(0xFF00E5FF), size: 24),
                    SizedBox(width: 10),
                    Text(
                      'SETTINGS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () {
                    _audio.playClick();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 24),

            // Sound Effects (SFX)
            _buildToggleRow(
              icon: Icons.volume_up_rounded,
              title: 'Sound Effects (SFX)',
              subtitle: 'Dice roll, pawns, ladders & snakes',
              value: _sfx,
              onChanged: (val) {
                setState(() => _sfx = val);
                _audio.setSfxEnabled(val);
                if (val) _audio.playClick();
              },
            ),

            const SizedBox(height: 12),

            // Background Music (BGM)
            _buildToggleRow(
              icon: Icons.music_note_rounded,
              title: 'Background Music',
              subtitle: 'Nautical adventure pirate synth theme',
              value: _bgm,
              onChanged: (val) {
                setState(() => _bgm = val);
                _audio.setBgmEnabled(val);
                _audio.playClick();
              },
            ),

            const SizedBox(height: 12),

            // Fast Hop Speed
            _buildToggleRow(
              icon: Icons.speed_rounded,
              title: 'Fast Pace Movement',
              subtitle: 'Speed up square hopping animations',
              value: _fast,
              onChanged: (val) {
                setState(() => _fast = val);
                widget.onSpeedChanged(val);
                _audio.playClick();
              },
            ),

            if (widget.onRestartGame != null || widget.onMainMenu != null) ...[
              const Divider(color: Colors.white12, height: 28),
              if (widget.onRestartGame != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('RESTART CURRENT MATCH'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFD166),
                      side: const BorderSide(color: Color(0xFFFFD166)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      _audio.playClick();
                      Navigator.of(context).pop();
                      widget.onRestartGame?.call();
                    },
                  ),
                ),
              if (widget.onMainMenu != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: const Text('RETURN TO MAIN MENU'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF233C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      _audio.playClick();
                      Navigator.of(context).pop();
                      widget.onMainMenu?.call();
                    },
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00E5FF), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFF00E5FF),
            activeTrackColor: const Color(0xFF0077B6),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.white12,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
