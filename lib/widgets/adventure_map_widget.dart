import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/gastro_question.dart';
import '../models/gastro_world.dart';
import '../models/game_progress.dart';
import '../audio/audio_service.dart';

class AdventureMapWidget extends StatefulWidget {
  final GameProgress progress;
  final Function(int level) onLevelSelected;

  const AdventureMapWidget({
    super.key,
    required this.progress,
    required this.onLevelSelected,
  });

  @override
  State<AdventureMapWidget> createState() => _AdventureMapWidgetState();
}

class _AdventureMapWidgetState extends State<AdventureMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLevel();
    });
  }

  void _scrollToCurrentLevel() {
    if (!_scrollController.hasClients) return;
    final currentLevel = widget.progress.currentUnlockedLevel.clamp(1, 30);
    // Estimated height per level item + world headers
    final targetOffset = ((currentLevel - 1) * 110.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      itemCount: 30,
      itemBuilder: (context, index) {
        final level = index + 1;
        final question = allGastroQuestions[index];
        final world = GastroWorld.getWorldForLevel(level);
        final isWorldStart = level == world.startLevel;

        return Column(
          children: [
            if (isWorldStart) _buildWorldBanner(world),
            _buildLevelNode(level, question, world),
            if (level < 30) _buildPathConnector(level),
          ],
        );
      },
    );
  }

  Widget _buildWorldBanner(GastroWorld world) {
    final isWorldUnlocked = widget.progress.isWorldUnlocked(world.id);
    final completedInWorld = widget.progress.getCompletedCountInWorld(world.id);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            world.primaryColor.withOpacity(0.20),
            world.secondaryColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: world.primaryColor.withOpacity(isWorldUnlocked ? 0.6 : 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: world.primaryColor.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: world.primaryColor.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: world.primaryColor, width: 1.5),
            ),
            child: Icon(world.icon, color: world.primaryColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      world.title,
                      style: TextStyle(
                        color: world.accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF040D1A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$completedInWorld / ${world.questionCount} MICI',
                        style: TextStyle(
                          color: world.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  world.subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  world.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelNode(int level, GastroQuestion question, GastroWorld world) {
    final isUnlocked = widget.progress.isLevelUnlocked(level);
    final isCompleted = widget.progress.isLevelCompleted(level);
    final isCurrent = level == widget.progress.currentUnlockedLevel && !isCompleted;
    final stars = widget.progress.getStars(level);

    // Zig-zag horizontal position for a natural adventure winding trail
    final double xOffset = math.sin((level - 1) * 0.9) * 75.0;

    return Transform.translate(
      offset: Offset(xOffset, 0),
      child: GestureDetector(
        onTap: () {
          if (isUnlocked) {
            AudioService().playClick();
            widget.onLevelSelected(level);
          } else {
            AudioService().playWrong();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Niveau $level verrouillé. Terminez d\'abord le niveau ${level - 1} !',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                duration: const Duration(milliseconds: 1400),
                backgroundColor: const Color(0xFF1E293B),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulseScale = isCurrent ? 1.0 + (_pulseController.value * 0.08) : 1.0;
            return Transform.scale(
              scale: pulseScale,
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getNodeBackgroundColor(isUnlocked, isCompleted, isCurrent, world),
                  border: Border.all(
                    color: _getNodeBorderColor(isUnlocked, isCompleted, isCurrent, world),
                    width: isCurrent ? 3.5 : 2.5,
                  ),
                  boxShadow: [
                    if (isCurrent)
                      BoxShadow(
                        color: world.primaryColor.withOpacity(0.55),
                        blurRadius: 22,
                        spreadRadius: 4,
                      )
                    else if (isCompleted)
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 6,
                      ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main Node Content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isCompleted) ...[
                          const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 24),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(3, (starIdx) {
                              final earned = starIdx < stars;
                              return Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: earned ? const Color(0xFFFFD166) : Colors.white24,
                              );
                            }),
                          ),
                        ] else if (isCurrent) ...[
                          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                          Text(
                            'NIV. $level',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.lock_rounded,
                            color: Colors.white.withOpacity(0.35),
                            size: 24,
                          ),
                          Text(
                            '$level',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Top Badge Label for original question number (ex: Q31)
                    Positioned(
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF071224),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isUnlocked ? world.primaryColor.withOpacity(0.5) : Colors.white12,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'Q${question.originalNumber}',
                          style: TextStyle(
                            color: isUnlocked ? world.accentColor : Colors.white30,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    // Current Player Avatar Marker
                    if (isCurrent)
                      Positioned(
                        top: -10,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD166),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Color(0xFFFFD166), blurRadius: 8),
                            ],
                          ),
                          child: const Icon(Icons.person, color: Color(0xFF040D1A), size: 14),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPathConnector(int level) {
    final nextLevel = level + 1;
    final isNextUnlocked = widget.progress.isLevelUnlocked(nextLevel);
    final isPassed = widget.progress.isLevelCompleted(level);
    final world = GastroWorld.getWorldForLevel(level);

    return SizedBox(
      height: 38,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (dotIdx) {
            final activeDot = isPassed;
            return Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activeDot
                    ? const Color(0xFF10B981)
                    : isNextUnlocked
                        ? world.primaryColor.withOpacity(0.7)
                        : Colors.white.withOpacity(0.18),
                boxShadow: [
                  if (activeDot)
                    const BoxShadow(
                      color: Color(0xFF10B981),
                      blurRadius: 4,
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Color _getNodeBackgroundColor(
    bool isUnlocked,
    bool isCompleted,
    bool isCurrent,
    GastroWorld world,
  ) {
    if (isCompleted) {
      return const Color(0xFF063A2F);
    }
    if (isCurrent) {
      return world.secondaryColor;
    }
    if (isUnlocked) {
      return const Color(0xFF0B1F38);
    }
    return const Color(0xFF070F1E);
  }

  Color _getNodeBorderColor(
    bool isUnlocked,
    bool isCompleted,
    bool isCurrent,
    GastroWorld world,
  ) {
    if (isCompleted) {
      return const Color(0xFF10B981);
    }
    if (isCurrent) {
      return const Color(0xFFFFD166);
    }
    if (isUnlocked) {
      return world.primaryColor.withOpacity(0.7);
    }
    return Colors.white.withOpacity(0.15);
  }
}
