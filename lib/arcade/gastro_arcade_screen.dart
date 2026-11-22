import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_progress.dart';
import '../services/storage_service.dart';
import '../widgets/tactile_button.dart';
import 'arcade_models.dart';
import 'arcade_game_controller.dart';
import 'arcade_game_painter.dart';
import 'arcade_hud_overlay.dart';
import 'checkpoint_question_dialog.dart';
import 'boss_challenge_dialog.dart';

class GastroArcadeScreen extends StatefulWidget {
  final int level;
  final GameProgress progress;

  const GastroArcadeScreen({
    super.key,
    required this.level,
    required this.progress,
  });

  @override
  State<GastroArcadeScreen> createState() => _GastroArcadeScreenState();
}

class _GastroArcadeScreenState extends State<GastroArcadeScreen>
    with SingleTickerProviderStateMixin {
  late final ArcadeGameController _controller;
  late final AnimationController _ticker;
  DateTime _lastTickTime = DateTime.now();

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = ArcadeGameController(
      level: widget.level,
      progress: widget.progress,
    );

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onTick);

    _lastTickTime = DateTime.now();
    _ticker.repeat();

    // Auto start game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.start();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTick() {
    final now = DateTime.now();
    final dt = (now.difference(_lastTickTime).inMicroseconds / 1000000.0).clamp(0.001, 0.05);
    _lastTickTime = now;
    _controller.update(dt);
  }

  void _handleKeyEvent(KeyEvent event) {
    final isDown = event is KeyDownEvent || event is KeyRepeatEvent;

    // Shoot (Space)
    if (event.logicalKey == LogicalKeyboardKey.space && isDown) {
      _controller.shoot();
    }

    // Shield (Key E, Shift)
    if ((event.logicalKey == LogicalKeyboardKey.keyE ||
            event.logicalKey == LogicalKeyboardKey.shiftLeft ||
            event.logicalKey == LogicalKeyboardKey.shiftRight) &&
        isDown) {
      _controller.activateShield();
    }

    // Thruster / Up (Up Arrow, W)
    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyW) {
      _controller.setThrust(isDown);
    }

    // Move Left (Left Arrow, A)
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      _controller.setMoveLeft(isDown);
    }

    // Move Right (Right Arrow, D)
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD) {
      _controller.setMoveRight(isDown);
    }

    // Move Down (Down Arrow, S)
    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyS) {
      _controller.setMoveDown(isDown);
    }

    // Pause (P, Escape)
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.keyP ||
            event.logicalKey == LogicalKeyboardKey.escape)) {
      if (_controller.state == GameState.playing) {
        _controller.pause();
      } else if (_controller.state == GameState.paused) {
        _controller.resume();
      }
    }
  }

  void _onVictoryClaimed() {
    StorageService().saveProgress(widget.progress);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: [
                // 1. Core 2D Side-Scrolling Canvas
                Positioned.fill(
                  child: CustomPaint(
                    painter: ArcadeGamePainter(controller: _controller),
                  ),
                ),

                // 2. Arcade HUD (Hearts, Score, Combo, Progress, Touch Controls)
                Positioned.fill(
                  child: ArcadeHudOverlay(
                    controller: _controller,
                    onPause: _controller.pause,
                    onResume: _controller.resume,
                    onExitToMap: () => Navigator.of(context).pop(),
                  ),
                ),

                // 3. Checkpoint Educational Question Dialog
                if (_controller.state == GameState.checkpoint &&
                    _controller.activeCheckpoint != null)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: CheckpointQuestionDialog(
                        question: _controller.activeCheckpoint!.question,
                        checkpointIndex: _controller.activeCheckpoint!.index,
                        onAnswerValidated: (selectedIdx, isCorrect) {
                          _controller.answerCheckpoint(
                            selectedOptionIndex: selectedIdx,
                            isCorrect: isCorrect,
                          );
                          StorageService().saveProgress(widget.progress);
                        },
                      ),
                    ),
                  ),

                // 4. Boss Challenge Dialog
                if (_controller.state == GameState.bossFight)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: BossChallengeDialog(
                        boss: _controller.boss,
                        onAnswerValidated: (qId, selectedIdx, isCorrect) {
                          _controller.answerBossQuestion(
                            questionId: qId,
                            selectedOptionIndex: selectedIdx,
                            isCorrect: isCorrect,
                          );
                          StorageService().saveProgress(widget.progress);
                        },
                        onVictoryClaimed: _onVictoryClaimed,
                      ),
                    ),
                  ),

                // 5. Level Victory Modal
                if (_controller.state == GameState.victory)
                  _buildVictoryOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVictoryOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 440,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD166), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD166).withValues(alpha: 0.35),
                blurRadius: 30,
              ),
              const BoxShadow(color: Colors.black, blurRadius: 24),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.military_tech_rounded, color: Color(0xFFFFD166), size: 64),
              const SizedBox(height: 10),
              Text(
                'MISSION DIGESTIVE ACCOMPLIE !',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_controller.world.title} • Niveau ${_controller.level}',
                style: GoogleFonts.inter(
                  color: _controller.world.primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // Stars (1-3)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 36),
                  );
                }),
              ),
              const SizedBox(height: 18),

              // Stats Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('SCORE', '${_controller.score}'),
                    _buildStatItem('XP GAGNÉS', '+${_controller.earnedXp}'),
                    _buildStatItem('MAX COMBO', 'x${_controller.highestCombo}'),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              TactileButton(
                label: 'Continuer l\'Aventure',
                icon: Icons.arrow_forward_rounded,
                style: TactileButtonStyle.primary,
                height: 52,
                onPressed: _onVictoryClaimed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
