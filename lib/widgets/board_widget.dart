import 'package:flutter/material.dart';
import '../models/board_tile.dart';
import '../models/player.dart';
import 'board_painter.dart';
import 'player_token.dart';

class BoardWidget extends StatelessWidget {
  final List<Player> players;
  final int activePlayerIndex;
  final int? highlightTile;
  final bool isHighlightLadder;
  final double animationProgress;
  final Function(BoardTile)? onTileTapped;

  const BoardWidget({
    super.key,
    required this.players,
    required this.activePlayerIndex,
    this.highlightTile,
    this.isHighlightLadder = false,
    this.animationProgress = 0.0,
    this.onTileTapped,
  });

  @override
  Widget build(BuildContext context) {
    final allTiles = BoardDefinition.generateTiles();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Maintain square board aspect ratio while taking maximum screen estate
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        final tileW = size / 10;
        final tileH = size / 10;

        return Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00E5FF).withOpacity(0.6),
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                const BoxShadow(
                  color: Colors.black87,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Stack(
                children: [
                  // 1. Grid of 100 Squares
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 100,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 10,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final gridRow = index ~/ 10;
                      final gridCol = index % 10;

                      // Find matching tile
                      final tile = allTiles.firstWhere(
                        (t) => t.row == gridRow && t.col == gridCol,
                      );

                      return _buildTileCell(tile, tileW);
                    },
                  ),

                  // 2. Custom Painter Layer: Golden Rescue Ladders & Scary Red Snakes
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: BoardPainter(
                          highlightTile: highlightTile,
                          isHighlightLadder: isHighlightLadder,
                          animationValue: animationProgress,
                        ),
                      ),
                    ),
                  ),

                  // 3. Player Pawns Layer (Positioned smoothly per tile)
                  ..._buildPlayerTokens(size, tileW, tileH),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTileCell(BoardTile tile, double tileW) {
    final isEvenSquare = (tile.row + tile.col) % 2 == 0;
    final is100 = tile.number == 100;
    final isStart = tile.number == 1;

    Color cellColor = isEvenSquare ? const Color(0xFF0B2239) : const Color(0xFF071829);

    if (is100) {
      cellColor = const Color(0xFF1E3A8A); // Victory goal square
    } else if (isStart) {
      cellColor = const Color(0xFF064E3B); // Safe harbor start
    } else if (tile.hasLadder) {
      cellColor = const Color(0xFF0C383F); // Ladder base teal tint
    } else if (tile.hasSnake) {
      cellColor = const Color(0xFF3B1218); // Snake head warning tint
    }

    return InkWell(
      onTap: onTileTapped != null ? () => onTileTapped!(tile) : null,
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          border: Border.all(
            color: is100
                ? const Color(0xFFFFD166)
                : const Color(0xFF00E5FF).withOpacity(0.12),
            width: is100 ? 1.5 : 0.5,
          ),
        ),
        child: Stack(
          children: [
            // Medical watermark icon
            if (tile.icon != null)
              Positioned(
                bottom: 2,
                right: 2,
                child: Opacity(
                  opacity: 0.18,
                  child: Icon(
                    tile.icon,
                    size: tileW * 0.42,
                    color: tile.hasSnake
                        ? const Color(0xFFFF5252)
                        : tile.hasLadder
                            ? const Color(0xFFFFD166)
                            : const Color(0xFF00E5FF),
                  ),
                ),
              ),

            // Square Number
            Positioned(
              top: 2,
              left: 3,
              child: Text(
                '${tile.number}',
                style: TextStyle(
                  fontSize: tileW * 0.28,
                  fontWeight: FontWeight.w800,
                  color: is100
                      ? const Color(0xFFFFD166)
                      : tile.number % 10 == 0
                          ? const Color(0xFF00E5FF)
                          : Colors.white70,
                ),
              ),
            ),

            // Victory Goal Trophy
            if (is100)
              Center(
                child: Icon(
                  Icons.military_tech_rounded,
                  size: tileW * 0.55,
                  color: const Color(0xFFFFD166),
                ),
              ),

            // Ladder Up Indicator
            if (tile.hasLadder)
              Positioned(
                bottom: 2,
                left: 3,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: tileW * 0.24,
                      color: const Color(0xFFFFD166),
                    ),
                    Text(
                      '${tile.ladderTo}',
                      style: TextStyle(
                        fontSize: tileW * 0.22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFFD166),
                      ),
                    ),
                  ],
                ),
              ),

            // Snake Down Indicator
            if (tile.hasSnake)
              Positioned(
                bottom: 2,
                left: 3,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: tileW * 0.24,
                      color: const Color(0xFFFF1744),
                    ),
                    Text(
                      '${tile.snakeTo}',
                      style: TextStyle(
                        fontSize: tileW * 0.22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFF1744),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Position player pawns with smooth coordinate calculation
  List<Widget> _buildPlayerTokens(double boardSize, double tileW, double tileH) {
    final List<Widget> tokenWidgets = [];

    // Group players by current square to compute clean offsets
    final Map<int, List<int>> squareGroups = {};
    for (int i = 0; i < players.length; i++) {
      final sq = players[i].currentSquare;
      squareGroups.putIfAbsent(sq, () => []).add(i);
    }

    squareGroups.forEach((square, playerIndices) {
      final center = BoardPainter.getTileCenter(square, Size(boardSize, boardSize));

      for (int i = 0; i < playerIndices.length; i++) {
        final pIdx = playerIndices[i];
        final player = players[pIdx];
        final tokenSize = tileW * 0.72;

        tokenWidgets.add(
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            left: center.dx - tokenSize / 2,
            top: center.dy - tokenSize / 2,
            child: PlayerToken(
              player: player,
              size: tokenSize,
              isCurrentPlayer: pIdx == activePlayerIndex,
              offsetIndex: i,
              totalOnSquare: playerIndices.length,
            ),
          ),
        );
      }
    });

    return tokenWidgets;
  }
}
