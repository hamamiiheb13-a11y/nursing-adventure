import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../audio/audio_service.dart';
import '../models/player.dart';
import 'anime_avatar.dart';

class VictoryDialog extends StatefulWidget {
  final Player winner;
  final List<Player> allPlayers;
  final VoidCallback onPlayAgain;
  final VoidCallback onMainMenu;

  const VictoryDialog({
    super.key,
    required this.winner,
    required this.allPlayers,
    required this.onPlayAgain,
    required this.onMainMenu,
  });

  @override
  State<VictoryDialog> createState() => _VictoryDialogState();
}

class _VictoryDialogState extends State<VictoryDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;
  final List<_ConfettiParticle> _confetti = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    AudioService().playVictory();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Create 45 confetti particles
    for (int i = 0; i < 45; i++) {
      _confetti.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble() * -0.5,
        vx: (_random.nextDouble() - 0.5) * 0.4,
        vy: 0.3 + _random.nextDouble() * 0.6,
        size: 5 + _random.nextDouble() * 9,
        color: [
          const Color(0xFFFFD166),
          const Color(0xFF00E5FF),
          const Color(0xFFFF4D6D),
          const Color(0xFF00F5D4),
          const Color(0xFF70E000),
          Colors.white,
        ][_random.nextInt(6)],
        rotation: _random.nextDouble() * math.pi * 2,
        rotSpeed: (_random.nextDouble() - 0.5) * 6,
      ));
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Confetti Layer
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      confetti: _confetti,
                      progress: _confettiController.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Victory Modal Card
          Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D2137),
                  Color(0xFF081422),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFFFD166),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD166).withOpacity(0.4),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
                const BoxShadow(
                  color: Colors.black87,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Crown / Trophy Icon
                const Icon(
                  Icons.military_tech_rounded,
                  size: 48,
                  color: Color(0xFFFFD166),
                ),
                const SizedBox(height: 6),

                // Victory Header
                const Text(
                  'VICTORY AT SQUARE 100!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Color(0xFFFFD166),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Grand Line Master Nurse Awarded!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF90E0EF),
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 18),

                // Champion Avatar
                AnimeAvatar(
                  characterId: widget.winner.character.id,
                  size: 88,
                  showBadge: true,
                  isWinner: true,
                ),

                const SizedBox(height: 12),

                // Winner Name & Character Title
                Text(
                  widget.winner.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  widget.winner.character.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: widget.winner.character.accentColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '"${widget.winner.character.motto}"',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 18),

                // Match Statistics Grid
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Dice Rolls', '${widget.winner.diceRolls}', Icons.casino_rounded, const Color(0xFF00E5FF)),
                      _buildStatColumn('Ladders', '${widget.winner.laddersClimbed}', Icons.trending_up_rounded, const Color(0xFFFFD166)),
                      _buildStatColumn('Snakes', '${widget.winner.snakesBitten}', Icons.warning_rounded, const Color(0xFFFF5252)),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          AudioService().playClick();
                          widget.onMainMenu();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'MAIN MENU',
                          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          AudioService().playClick();
                          widget.onPlayAgain();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD166),
                          foregroundColor: const Color(0xFF061121),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'PLAY AGAIN',
                          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  final double vx;
  final double vy;
  final double size;
  final Color color;
  double rotation;
  final double rotSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> confetti;
  final double progress;

  _ConfettiPainter({required this.confetti, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (final p in confetti) {
      final curY = ((p.y + progress * p.vy) % 1.2) * h;
      final curX = ((p.x + progress * p.vx) % 1.0) * w;
      final rot = p.rotation + progress * p.rotSpeed;

      canvas.save();
      canvas.translate(curX, curY);
      canvas.rotate(rot);

      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.45), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
