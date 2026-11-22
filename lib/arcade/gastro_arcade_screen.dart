import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

import '../models/game_progress.dart';
import '../services/storage_service.dart';
import '../widgets/rotation_warning_overlay.dart';
import 'arcade_game_controller.dart';
import 'arcade_game_painter.dart';
import 'arcade_hud_overlay.dart';
import 'checkpoint_question_dialog.dart';
import 'boss_challenge_dialog.dart';
import '../screens/capsule_warriors_pause_screen.dart';
import '../screens/capsule_warriors_stage_victory_screen.dart';
import '../screens/capsule_warriors_briefing_screen.dart';
import '../screens/capsule_warriors_final_screen.dart';

class GastroArcadeScreen extends StatefulWidget {
  final int stageId;
  final int? level;
  final GameProgress? progress;

  const GastroArcadeScreen({
    super.key,
    int? stageId,
    this.level,
    this.progress,
  }) : stageId = stageId ?? level ?? 1;

  @override
  State<GastroArcadeScreen> createState() => _GastroArcadeScreenState();
}

class _GastroArcadeScreenState extends State<GastroArcadeScreen>
    with SingleTickerProviderStateMixin {
  late final ArcadeGameController _controller;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  final FocusNode _focusNode = FocusNode();
  Offset? _mousePosition;

  @override
  void initState() {
    super.initState();

    // 1. Lock screen to landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // 2. Initialize progress if not provided
    final progress = widget.progress ?? StorageService().currentProgress;

    // 3. Initialize Game Controller with stageId / level
    _controller = ArcadeGameController(
      level: widget.stageId,
      progress: progress,
    );

    // 4. Initialize 60 FPS Ticker Game Loop using dt (delta time)
    _ticker = createTicker(_onTick);
    _ticker.start();

    // 5. Start game and focus keyboard after first frame
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

    // Restore device orientation flexibility
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final dt = ((elapsed - _lastElapsed).inMicroseconds / 1000000.0).clamp(0.001, 0.05);
    _lastElapsed = elapsed;
    _controller.update(dt);
  }

  // --- KEYBOARD CONTROLS (WASD, Arrows, Space, E, Escape) ---
  void _handleKeyEvent(KeyEvent event) {
    final isDown = event is KeyDownEvent || event is KeyRepeatEvent;

    // Shoot (Space)
    if (event.logicalKey == LogicalKeyboardKey.space && isDown) {
      _controller.shoot(_mousePosition);
    }

    // Shield (Key E, Shift)
    if ((event.logicalKey == LogicalKeyboardKey.keyE ||
            event.logicalKey == LogicalKeyboardKey.shiftLeft ||
            event.logicalKey == LogicalKeyboardKey.shiftRight) &&
        isDown) {
      _controller.activateShield();
    }

    // Thrust / Move Up (W, Up Arrow)
    if (event.logicalKey == LogicalKeyboardKey.keyW ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _controller.setThrust(isDown);
    }

    // Move Down (S, Down Arrow)
    if (event.logicalKey == LogicalKeyboardKey.keyS ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _controller.setMoveDown(isDown);
    }

    // Move Left (A, Left Arrow)
    if (event.logicalKey == LogicalKeyboardKey.keyA ||
        event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _controller.setMoveLeft(isDown);
    }

    // Move Right (D, Right Arrow)
    if (event.logicalKey == LogicalKeyboardKey.keyD ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _controller.setMoveRight(isDown);
    }

    // Pause / Resume (Escape, P)
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.escape ||
            event.logicalKey == LogicalKeyboardKey.keyP)) {
      if (_controller.state == GameState.playing) {
        _controller.pause();
      } else if (_controller.state == GameState.paused) {
        _controller.resume();
      }
    }
  }

  void _onVictoryClaimed() {
    StorageService().saveProgress(_controller.progress);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return RotationWarningWrapper(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: MouseRegion(
            onHover: (event) {
              _mousePosition = event.localPosition;
            },
            child: Listener(
              onPointerDown: (event) {
                if (event.kind == PointerDeviceKind.mouse) {
                  _mousePosition = event.localPosition;
                  _controller.shoot(_mousePosition);
                }
              },
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Stack(
                    children: [
                      // 1. Core 2D Game Canvas (Parallax background, walls, enemies, capsule, etc.)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ArcadeGamePainter(controller: _controller),
                        ),
                      ),

                      // 2. Complete Landscape HUD Overlay (Hearts, Stage Progress, Score/XP, Weapon, Touch Controls)
                      Positioned.fill(
                        child: ArcadeHudOverlay(
                          controller: _controller,
                          onPause: _controller.pause,
                          onResume: _controller.resume,
                          onExitToMap: () => Navigator.of(context).pop(),
                        ),
                      ),

                      // 3. Checkpoint Educational Question Overlay Dialog
                      if (_controller.state == GameState.checkpoint &&
                          _controller.activeCheckpoint != null)
                        Positioned.fill(
                          child: CheckpointQuestionDialog(
                            question: _controller.activeCheckpoint!.question,
                            checkpointIndex: _controller.activeCheckpoint!.index,
                            onAnswerValidated: (selectedIdx, isCorrect) {
                              _controller.answerCheckpoint(
                                selectedOptionIndex: selectedIdx,
                                isCorrect: isCorrect,
                              );
                              StorageService().saveProgress(_controller.progress);
                            },
                          ),
                        ),

                      // 4. Boss Encounter & Battle Dialog
                      if (_controller.state == GameState.bossFight)
                        Positioned.fill(
                          child: BossChallengeDialog(
                            boss: _controller.boss,
                            onAnswerValidated: (qId, selectedIdx, isCorrect) {
                              _controller.answerBossQuestion(
                                questionId: qId,
                                selectedOptionIndex: selectedIdx,
                                isCorrect: isCorrect,
                              );
                              StorageService().saveProgress(_controller.progress);
                            },
                            onVictoryClaimed: _onVictoryClaimed,
                          ),
                        ),

                      // 5. Stage Victory Overlay
                      if (_controller.state == GameState.victory)
                        Positioned.fill(
                          child: CapsuleWarriorsStageVictoryScreen(
                            stageId: _controller.level,
                            score: _controller.score,
                            questionsCorrect: _controller.checkpoints.where((c) => c.isAnswerCorrect == true).length,
                            questionsTotal: _controller.checkpoints.isNotEmpty ? _controller.checkpoints.length : 4,
                            collectibles: _controller.crystalsCollected,
                            secondsElapsed: _controller.gameTime.toInt(),
                            onNextStage: () {
                              StorageService().saveProgress(_controller.progress);
                              if (_controller.level < 7) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => CapsuleWarriorsBriefingScreen(
                                      stageId: _controller.level + 1,
                                      progress: _controller.progress,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => CapsuleWarriorsFinalScreen(
                                      progress: _controller.progress,
                                    ),
                                  ),
                                );
                              }
                            },
                            onReplay: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => GastroArcadeScreen(
                                    stageId: _controller.level,
                                    progress: _controller.progress,
                                  ),
                                ),
                              );
                            },
                            onStageMap: () {
                              StorageService().saveProgress(_controller.progress);
                              Navigator.of(context).pop();
                            },
                          ),
                        ),

                      // 6. Pause Overlay
                      if (_controller.state == GameState.paused)
                        Positioned.fill(
                          child: CapsuleWarriorsPauseScreen(
                            score: _controller.score,
                            stageId: _controller.level,
                            onResume: _controller.resume,
                            onRestart: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => GastroArcadeScreen(
                                    stageId: _controller.level,
                                    progress: _controller.progress,
                                  ),
                                ),
                              );
                            },
                            onQuit: () => Navigator.of(context).pop(),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
