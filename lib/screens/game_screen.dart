import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../audio/audio_service.dart';
import '../models/board_tile.dart';
import '../models/game_event.dart';
import '../models/player.dart';
import '../widgets/action_banner.dart';
import '../widgets/anime_avatar.dart';
import '../widgets/anime_background.dart';
import '../widgets/board_widget.dart';
import '../widgets/dice_widget.dart';
import '../widgets/instructions_dialog.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/victory_dialog.dart';
import 'main_menu_screen.dart';

class GameScreen extends StatefulWidget {
  final List<Player> players;
  final bool isFastSpeed;

  const GameScreen({
    super.key,
    required this.players,
    this.isFastSpeed = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final AudioService _audio = AudioService();
  final math.Random _random = math.Random();

  late final List<Player> _players;
  int _activePlayerIndex = 0;
  int _diceValue = 1;
  bool _isDiceRolling = false;
  bool _isMoving = false;
  bool _isFastSpeed = false;

  // Highlights on board
  int? _highlightTile;
  bool _isHighlightLadder = false;

  // Banner status
  String _statusText = '';
  String? _eventSubtitle;
  bool _isSpecialEvent = false;
  bool _isSpecialLadder = false;

  // Activity Log
  final List<GameEvent> _eventLog = [];

  // Animation controller for ladder/snake highlights
  late final AnimationController _highlightController;

  @override
  void initState() {
    super.initState();
    _players = widget.players;
    _isFastSpeed = widget.isFastSpeed;

    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    final firstPlayer = _players[_activePlayerIndex];
    _statusText = "${firstPlayer.name}'s Turn - Roll the dice!";
    _eventSubtitle = 'Race to reach Square 100 first!';

    _logEvent(
      GameEventType.turnStart,
      'Match Commenced',
      'The Grand Medical Sea race has begun!',
      firstPlayer.id,
      firstPlayer.name,
    );

    // If first player is AI, trigger auto-roll
    if (firstPlayer.isAI) {
      _scheduleAIRoll();
    }
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  void _logEvent(GameEventType type, String title, String msg, int pId, String pName) {
    setState(() {
      _eventLog.insert(
        0,
        GameEvent(
          type: type,
          title: title,
          message: msg,
          playerId: pId,
          playerName: pName,
        ),
      );
    });
  }

  void _scheduleAIRoll() {
    setState(() {
      _statusText = 'Dr. Bot (AI) is calculating move...';
      _eventSubtitle = 'Analyzing medical board trajectory';
    });
    Timer(const Duration(milliseconds: 1100), () {
      if (mounted && _players[_activePlayerIndex].isAI && !_isMoving && !_isDiceRolling) {
        _rollDice();
      }
    });
  }

  Future<void> _rollDice() async {
    if (_isDiceRolling || _isMoving) return;

    final activePlayer = _players[_activePlayerIndex];

    setState(() {
      _isDiceRolling = true;
      _highlightTile = null;
      _isSpecialEvent = false;
      _statusText = '${activePlayer.name} is rolling...';
    });

    // Animate dice for 900ms
    await Future.delayed(const Duration(milliseconds: 900));

    final rollResult = 1 + _random.nextInt(6);
    activePlayer.diceRolls++;

    if (!mounted) return;

    setState(() {
      _isDiceRolling = false;
      _diceValue = rollResult;
      _statusText = '${activePlayer.name} rolled a $rollResult!';
    });

    _logEvent(
      GameEventType.roll,
      'Dice Rolled',
      '${activePlayer.name} rolled a $rollResult',
      activePlayer.id,
      activePlayer.name,
    );

    // Advance player pawn
    await _movePlayerSteps(activePlayer, rollResult);
  }

  Future<void> _movePlayerSteps(Player player, int steps) async {
    setState(() {
      _isMoving = true;
    });

    final hopDelay = _isFastSpeed ? 140 : 250;

    for (int step = 1; step <= steps; step++) {
      if (player.currentSquare >= 100) break;

      player.currentSquare++;
      player.totalSteps++;
      _audio.playStep(step);

      if (mounted) setState(() {});
      await Future.delayed(Duration(milliseconds: hopDelay));
    }

    // Check if reached square 100
    if (player.currentSquare >= 100) {
      player.currentSquare = 100;
      _onPlayerWon(player);
      return;
    }

    // Check for Ladder or Snake on current square
    final currentTile = player.currentSquare;
    final ladderData = BoardDefinition.ladders[currentTile];
    final snakeData = BoardDefinition.snakes[currentTile];

    if (ladderData != null) {
      // CLIMB LADDER
      final destination = ladderData['to'] as int;
      final ladderName = ladderData['name'] as String;
      final tip = ladderData['tip'] as String;

      player.laddersClimbed++;

      setState(() {
        _highlightTile = currentTile;
        _isHighlightLadder = true;
        _isSpecialEvent = true;
        _isSpecialLadder = true;
        _statusText = 'LADDER: $ladderName! (Sq $currentTile ➔ Sq $destination)';
        _eventSubtitle = tip;
      });

      _audio.playLadder();
      _logEvent(
        GameEventType.ladder,
        'Climbed Ladder',
        '$ladderName: Surged to Square $destination! $tip',
        player.id,
        player.name,
      );

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;
      setState(() {
        player.currentSquare = destination;
      });

      await Future.delayed(const Duration(milliseconds: 600));

      // Check if ladder reached 100
      if (player.currentSquare >= 100) {
        player.currentSquare = 100;
        _onPlayerWon(player);
        return;
      }
    } else if (snakeData != null) {
      // SLIDE DOWN SNAKE
      final destination = snakeData['to'] as int;
      final snakeName = snakeData['name'] as String;
      final tip = snakeData['tip'] as String;

      player.snakesBitten++;

      setState(() {
        _highlightTile = currentTile;
        _isHighlightLadder = false;
        _isSpecialEvent = true;
        _isSpecialLadder = false;
        _statusText = 'SNAKE: $snakeName! (Sq $currentTile ➔ Sq $destination)';
        _eventSubtitle = tip;
      });

      _audio.playSnake();
      _logEvent(
        GameEventType.snake,
        'Snake Complication',
        '$snakeName: Slid back to Square $destination! $tip',
        player.id,
        player.name,
      );

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;
      setState(() {
        player.currentSquare = destination;
      });

      await Future.delayed(const Duration(milliseconds: 600));
    }

    // Switch turn to next player
    _nextTurn();
  }

  void _nextTurn() {
    if (!mounted) return;

    setState(() {
      _isMoving = false;
      _activePlayerIndex = (_activePlayerIndex + 1) % _players.length;
      final nextPlayer = _players[_activePlayerIndex];
      _isSpecialEvent = false;
      _highlightTile = null;
      _statusText = "${nextPlayer.name}'s Turn - Roll the dice!";
      _eventSubtitle = 'Currently on Square ${nextPlayer.currentSquare}';
    });

    final nextPlayer = _players[_activePlayerIndex];
    if (nextPlayer.isAI) {
      _scheduleAIRoll();
    }
  }

  void _onPlayerWon(Player winner) {
    setState(() {
      _isMoving = false;
      _statusText = 'VICTORY! ${winner.name} reached Square 100!';
      _eventSubtitle = 'Grand Line Master Nurse Awarded!';
    });

    _logEvent(
      GameEventType.win,
      'Match Concluded',
      '${winner.name} achieved victory at Square 100!',
      winner.id,
      winner.name,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VictoryDialog(
        winner: winner,
        allPlayers: _players,
        onPlayAgain: _restartMatch,
        onMainMenu: _returnToMainMenu,
      ),
    );
  }

  void _restartMatch() {
    Navigator.of(context).pop(); // dismiss victory or settings
    setState(() {
      for (final p in _players) {
        p.reset();
      }
      _activePlayerIndex = 0;
      _diceValue = 1;
      _isDiceRolling = false;
      _isMoving = false;
      _highlightTile = null;
      _isSpecialEvent = false;
      final firstPlayer = _players[0];
      _statusText = "${firstPlayer.name}'s Turn - Roll the dice!";
      _eventSubtitle = 'Match restarted. Good luck!';
    });

    if (_players[0].isAI) {
      _scheduleAIRoll();
    }
  }

  void _returnToMainMenu() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
      (route) => false,
    );
  }

  void _openSettings() {
    _audio.playClick();
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        isFastSpeed: _isFastSpeed,
        onSpeedChanged: (val) {
          setState(() => _isFastSpeed = val);
        },
        onRestartGame: _restartMatch,
        onMainMenu: _returnToMainMenu,
      ),
    );
  }

  void _openInstructions() {
    _audio.playClick();
    showDialog(
      context: context,
      builder: (context) => const InstructionsDialog(),
    );
  }

  void _openEventLog() {
    _audio.playClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B1E38),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history_rounded, color: Color(0xFF00E5FF), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'MATCH ACTIVITY LOG',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: Colors.white12),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _eventLog.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final ev = _eventLog[idx];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              ev.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00E5FF),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${ev.timestamp.hour.toString().padLeft(2, '0')}:${ev.timestamp.minute.toString().padLeft(2, '0')}:${ev.timestamp.second.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 10, color: Colors.white38),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ev.message,
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePlayer = _players[_activePlayerIndex];
    final media = MediaQuery.of(context);
    final isDesktop = media.size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFF040D1A),
      body: AnimeBackground(
        showFloatingElements: false,
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top HUD Bar
              _buildTopHud(activePlayer),

              const Divider(color: Colors.white12, height: 1),

              // 2. Main Game Viewport
              Expanded(
                child: isDesktop ? _buildDesktopLayout(activePlayer) : _buildMobileLayout(activePlayer),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHud(Player activePlayer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          // Home / Settings
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
            onPressed: _openSettings,
          ),

          // Active Player Info
          AnimeAvatar(
            characterId: activePlayer.character.id,
            size: 38,
            showBadge: false,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      activePlayer.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: activePlayer.character.accentColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'TURN',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Square ${activePlayer.currentSquare} / 100',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: activePlayer.character.accentColor,
                  ),
                ),
              ],
            ),
          ),

          // Quick Action Icons
          IconButton(
            icon: Icon(
              _audio.sfxEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _audio.sfxEnabled ? const Color(0xFF00E5FF) : Colors.white38,
              size: 20,
            ),
            onPressed: () => setState(() => _audio.toggleSfx()),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Color(0xFF90E0EF), size: 20),
            onPressed: _openEventLog,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Color(0xFFFFD166), size: 20),
            onPressed: _openInstructions,
          ),
        ],
      ),
    );
  }

  // Mobile portrait layout: Board on top, Action Banner & Dice Controls below
  Widget _buildMobileLayout(Player activePlayer) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Column(
        children: [
          // Action Status Banner
          ActionBanner(
            activePlayer: activePlayer,
            statusText: _statusText,
            eventSubtitle: _eventSubtitle,
            isSpecialEvent: _isSpecialEvent,
            isLadder: _isSpecialLadder,
          ),

          const SizedBox(height: 8),

          // The 10x10 Snakes & Ladders Board
          Expanded(
            child: AnimatedBuilder(
              animation: _highlightController,
              builder: (context, _) {
                return BoardWidget(
                  players: _players,
                  activePlayerIndex: _activePlayerIndex,
                  highlightTile: _highlightTile,
                  isHighlightLadder: _isHighlightLadder,
                  animationProgress: _highlightController.value,
                  onTileTapped: (tile) {
                    if (tile.medicalTip != null) {
                      setState(() {
                        _statusText = 'Sq ${tile.number}: ${tile.ladderName ?? tile.snakeName ?? "Clinical Square"}';
                        _eventSubtitle = tile.medicalTip;
                      });
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Bottom Bar: Interactive Dice & Scoreboard Pills
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // All players mini progress tokens
              Expanded(
                child: _buildMiniScoreboard(),
              ),

              const SizedBox(width: 12),

              // Animated 3D Dice
              DiceWidget(
                value: _diceValue,
                isRolling: _isDiceRolling,
                enabled: !activePlayer.isAI && !_isMoving && !_isDiceRolling,
                playerTurnText: activePlayer.name,
                playerColor: activePlayer.character.accentColor,
                onRoll: _rollDice,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Desktop / Tablet landscape layout
  Widget _buildDesktopLayout(Player activePlayer) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left: Side Control Panel & Scoreboard
          SizedBox(
            width: 280,
            child: Column(
              children: [
                ActionBanner(
                  activePlayer: activePlayer,
                  statusText: _statusText,
                  eventSubtitle: _eventSubtitle,
                  isSpecialEvent: _isSpecialEvent,
                  isLadder: _isSpecialLadder,
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildFullScoreboard()),
                const SizedBox(height: 16),
                DiceWidget(
                  value: _diceValue,
                  isRolling: _isDiceRolling,
                  enabled: !activePlayer.isAI && !_isMoving && !_isDiceRolling,
                  playerTurnText: activePlayer.name,
                  playerColor: activePlayer.character.accentColor,
                  onRoll: _rollDice,
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Center/Right: Maximized Board
          Expanded(
            child: AnimatedBuilder(
              animation: _highlightController,
              builder: (context, _) {
                return BoardWidget(
                  players: _players,
                  activePlayerIndex: _activePlayerIndex,
                  highlightTile: _highlightTile,
                  isHighlightLadder: _isHighlightLadder,
                  animationProgress: _highlightController.value,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniScoreboard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2238),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'CREW PROGRESS',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Color(0xFF90E0EF),
            ),
          ),
          const SizedBox(height: 6),
          ..._players.map((p) {
            final isTurn = p.id == _players[_activePlayerIndex].id;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(
                children: [
                  AnimeAvatar(characterId: p.character.id, size: 20, showBadge: false),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      p.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isTurn ? FontWeight.w900 : FontWeight.w600,
                        color: isTurn ? p.character.accentColor : Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Sq ${p.currentSquare}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isTurn ? const Color(0xFFFFD166) : Colors.white60,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFullScoreboard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2238),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.leaderboard_rounded, color: Color(0xFFFFD166), size: 18),
              SizedBox(width: 8),
              Text(
                'CLINICAL STANDINGS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Color(0xFFFFD166),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _players.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final p = _players[idx];
                final isTurn = idx == _activePlayerIndex;

                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isTurn ? p.character.accentColor.withOpacity(0.12) : Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTurn ? p.character.accentColor : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimeAvatar(characterId: p.character.id, size: 36, showBadge: false),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: isTurn ? Colors.white : Colors.white70,
                              ),
                            ),
                            Text(
                              'Rolls: ${p.diceRolls} • Ladders: ${p.laddersClimbed} • Snakes: ${p.snakesBitten}',
                              style: const TextStyle(fontSize: 9.5, color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: p.character.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${p.currentSquare}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: p.character.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
