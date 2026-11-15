import 'package:flutter/material.dart';
import '../models/player.dart';
import 'anime_avatar.dart';

class PlayerToken extends StatefulWidget {
  final Player player;
  final double size;
  final bool isCurrentPlayer;
  final int offsetIndex;
  final int totalOnSquare;

  const PlayerToken({
    super.key,
    required this.player,
    this.size = 32,
    this.isCurrentPlayer = false,
    this.offsetIndex = 0,
    this.totalOnSquare = 1,
  });

  @override
  State<PlayerToken> createState() => _PlayerTokenState();
}

class _PlayerTokenState extends State<PlayerToken> with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isCurrentPlayer) {
      _bounceController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PlayerToken oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentPlayer && !oldWidget.isCurrentPlayer) {
      _bounceController.repeat(reverse: true);
    } else if (!widget.isCurrentPlayer && oldWidget.isCurrentPlayer) {
      _bounceController.stop();
      _bounceController.reset();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate intelligent offset when multiple tokens share a tile
    Offset tileOffset = Offset.zero;
    if (widget.totalOnSquare > 1) {
      final spread = widget.size * 0.35;
      switch (widget.offsetIndex) {
        case 0:
          tileOffset = Offset(-spread, -spread);
          break;
        case 1:
          tileOffset = Offset(spread, -spread);
          break;
        case 2:
          tileOffset = Offset(-spread, spread);
          break;
        case 3:
        default:
          tileOffset = Offset(spread, spread);
          break;
      }
    }

    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        final bounce = widget.isCurrentPlayer ? (_bounceController.value * -6.0) : 0.0;
        return Transform.translate(
          offset: tileOffset + Offset(0, bounce),
          child: child,
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Glowing aura for current turn player
          if (widget.isCurrentPlayer)
            Container(
              width: widget.size + 10,
              height: widget.size + 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFD166),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD166).withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

          // Main character circular token
          AnimeAvatar(
            characterId: widget.player.character.id,
            size: widget.size,
            showBadge: false,
            isWinner: widget.player.hasWon,
          ),

          // Mini Player Badge (P1, P2, AI)
          Positioned(
            top: -widget.size * 0.2,
            right: -widget.size * 0.2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
              decoration: BoxDecoration(
                color: widget.player.isAI ? const Color(0xFF64748B) : widget.player.character.accentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 3),
                ],
              ),
              child: Text(
                widget.player.isAI ? 'AI' : 'P${widget.player.id}',
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
