import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

import '../models/game_progress.dart';
import '../services/storage_service.dart';
import '../theme/capsule_theme.dart';
import '../widgets/rotation_warning_overlay.dart';
import 'arcade_game_controller.dart';
import 'arcade_game_painter.dart';
import 'arcade_hud_overlay.dart';
import 'checkpoint_question_dialog.dart';
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
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final progress = widget.progress ?? StorageService().currentProgress;

    _controller = ArcadeGameController(
      level: widget.stageId,
      progress: progress,
    );

    _ticker = createTicker(_onTick);
    _controller.addListener(_syncTickerState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.start();
      _syncTickerState();
      _focusNode.requestFocus();
    });
  }

  void _syncTickerState() {
    if (!mounted) return;
    final shouldTick = _controller.state == GameState.playing ||
        _controller.state == GameState.bossIntro ||
        _controller.state == GameState.bossFight ||
        _controller.state == GameState.bossDefeatAnim;
    if (shouldTick && !_ticker.isActive) {
      _lastElapsed = Duration.zero;
      _ticker.start();
    } else if (!shouldTick && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_syncTickerState);
    _ticker.dispose();
    _controller.audio.stopBgm();
    _controller.dispose();
    _focusNode.dispose();

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

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }

    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (event is KeyDownEvent) {
        _controller.setShooting(true, _mousePosition);
      } else if (event is KeyUpEvent) {
        _controller.setShooting(false);
      }
    }

    if ((event.logicalKey == LogicalKeyboardKey.keyQ ||
            event.logicalKey == LogicalKeyboardKey.keyF) &&
        event is KeyDownEvent) {
      _controller.triggerSpecialSkill();
    }

    if ((event.logicalKey == LogicalKeyboardKey.keyE ||
            event.logicalKey == LogicalKeyboardKey.shiftLeft ||
            event.logicalKey == LogicalKeyboardKey.shiftRight) &&
        event is KeyDownEvent) {
      _controller.activateShield();
    }

    final bool isUp = _pressedKeys.contains(LogicalKeyboardKey.keyW) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp);
    final bool isDown = _pressedKeys.contains(LogicalKeyboardKey.keyS) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown);
    final bool isLeft = _pressedKeys.contains(LogicalKeyboardKey.keyA) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft);
    final bool isRight = _pressedKeys.contains(LogicalKeyboardKey.keyD) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight);

    _controller.updateKeyboardDirection(isUp, isDown, isLeft, isRight);

    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.escape ||
            event.logicalKey == LogicalKeyboardKey.keyP)) {
      if (_controller.state == GameState.playing ||
          _controller.state == GameState.bossFight ||
          _controller.state == GameState.bossIntro) {
        _controller.pause();
      } else if (_controller.state == GameState.paused) {
        _controller.resume();
      }
    }
  }

  void _saveAndExit() {
    _controller.audio.stopBgm();
    StorageService().saveProgress(_controller.progress);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bool isDesktopWide = media.size.width > 960 &&
        (!kIsWeb || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux || media.size.width > 1100);
    final bool isTouchLayout = media.size.width < 920 || media.size.height < 520;

    return RotationWarningWrapper(
      child: Scaffold(
        backgroundColor: CapsuleColors.deepOcean,
        body: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: Center(
            child: Container(
              constraints: isDesktopWide
                  ? const BoxConstraints(maxWidth: 1280, maxHeight: 780)
                  : const BoxConstraints.expand(),
              decoration: isDesktopWide
                  ? BoxDecoration(
                      border: Border.symmetric(
                        vertical: BorderSide(color: CapsuleColors.cardBorder, width: 1.5),
                      ),
                    )
                  : null,
              child: Stack(
                children: [
                  // 1. Live 2D Canvas isolated in RepaintBoundary + Mouse Aiming Listener
                  Positioned.fill(
                    child: MouseRegion(
                      onHover: (event) {
                        _mousePosition = event.localPosition;
                      },
                      child: Listener(
                        onPointerDown: (event) {
                          if (event.kind == PointerDeviceKind.mouse &&
                              (_controller.state == GameState.playing ||
                                  _controller.state == GameState.bossFight)) {
                            _mousePosition = event.localPosition;
                            _controller.setShooting(true, _mousePosition);
                          }
                        },
                        onPointerUp: (event) {
                          if (event.kind == PointerDeviceKind.mouse) {
                            _controller.setShooting(false);
                          }
                        },
                        onPointerCancel: (event) {
                          _controller.setShooting(false);
                        },
                        child: RepaintBoundary(
                          child: ClipRect(
                            child: CustomPaint(
                              painter: ArcadeGamePainter(controller: _controller),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Reactive HUD & Interactive Overlays (only rebuild when needed)
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          return Stack(
                            children: [
                              // Clean Responsive HUD Overlay
                              Positioned.fill(
                                child: ArcadeHudOverlay(
                                  controller: _controller,
                                  isMobileTouch: isTouchLayout,
                                  onPause: _controller.pause,
                                  onResume: _controller.resume,
                                  onExitToMap: _saveAndExit,
                                  onTutorialComplete: () {
                                    _controller.progress.hasSeenTutorial = true;
                                    StorageService().saveProgress(_controller.progress);
                                  },
                                ),
                              ),

                              // 3. Educational Question Dialog (Checkpoints)
                              if (_controller.state == GameState.checkpoint &&
                                  _controller.activeCheckpoint != null)
                                Positioned.fill(
                                  child: CheckpointQuestionDialog(
                                    question: _controller.activeCheckpoint!.question,
                                    checkpointIndex: _controller.activeCheckpoint!.index,
                                    isRevisionMode: _controller.activeCheckpoint!.isRevision,
                                    onAnswerValidated: (selectedIdx, isCorrect) {
                                      _controller.answerCheckpoint(
                                        selectedOptionIndex: selectedIdx,
                                        isCorrect: isCorrect,
                                      );
                                      StorageService().saveProgress(_controller.progress);
                                      _focusNode.requestFocus();
                                    },
                                  ),
                                ),

                              // 4. Stage Victory Overlay (with real Star & Weapon Rewards)
                              if (_controller.state == GameState.victory)
                                Positioned.fill(
                                  child: CapsuleWarriorsStageVictoryScreen(
                                    stageId: _controller.level,
                                    score: _controller.score,
                                    starsOverride: _controller.lastStarsEarned,
                                    questionsCorrect: _controller.correctAnswersInStage,
                                    questionsTotal: _controller.checkpoints.isNotEmpty
                                        ? _controller.checkpoints.length
                                        : 1,
                                    deaths: _controller.revivesCount,
                                    collectibles: _controller.crystalsCollected,
                                    secondsElapsed: _controller.gameTime.toInt(),
                                    unlockedWeapon: _controller.newlyUnlockedWeapon ??
                                        _controller.world.unlockedWeaponName,
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
                                    onStageMap: _saveAndExit,
                                  ),
                                ),

                              // 5. Clean Pause Screen
                              if (_controller.state == GameState.paused)
                                Positioned.fill(
                                  child: CapsuleWarriorsPauseScreen(
                                    score: _controller.score,
                                    stageId: _controller.level,
                                    onResume: () {
                                      _controller.resume();
                                      _focusNode.requestFocus();
                                    },
                                    onRestart: () {
                                      _controller.audio.stopBgm();
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) => GastroArcadeScreen(
                                            stageId: _controller.level,
                                            progress: _controller.progress,
                                          ),
                                        ),
                                      );
                                    },
                                    onQuit: _saveAndExit,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
