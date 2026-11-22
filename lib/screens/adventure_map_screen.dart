import 'package:flutter/material.dart';
import '../models/game_progress.dart';
import '../audio/audio_service.dart';
import '../widgets/adventure_map_widget.dart';
import 'question_level_screen.dart';
import 'rewards_screen.dart';

class AdventureMapScreen extends StatefulWidget {
  final GameProgress progress;

  const AdventureMapScreen({
    super.key,
    required this.progress,
  });

  @override
  State<AdventureMapScreen> createState() => _AdventureMapScreenState();
}

class _AdventureMapScreenState extends State<AdventureMapScreen> {
  final AudioService _audio = AudioService();

  void _openLevel(int level) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuestionLevelScreen(
          level: level,
          progress: widget.progress,
        ),
      ),
    );
    // Refresh progress state when returning
    setState(() {});
  }

  void _openRewards() {
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RewardsScreen(progress: widget.progress),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.progress.completedCount;
    final totalStars = widget.progress.totalStars;
    final xp = widget.progress.totalXp;

    return Scaffold(
      backgroundColor: const Color(0xFF040D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08172D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            _audio.playClick();
            Navigator.of(context).pop();
          },
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CARTE D\'AVENTURE',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
            Text(
              'GASTRO QUEST • 30 NIVEAUX',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.military_tech_rounded, color: Color(0xFFFFD166)),
            tooltip: 'Trophées & Badges',
            onPressed: _openRewards,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick HUD Stats Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            color: const Color(0xFF08172D),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHudPill(
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                  text: '$completed / 30 Niveaux',
                ),
                _buildHudPill(
                  icon: Icons.star_rounded,
                  color: const Color(0xFFFFD166),
                  text: '$totalStars / 90',
                ),
                _buildHudPill(
                  icon: Icons.bolt_rounded,
                  color: const Color(0xFF00E5FF),
                  text: '$xp XP',
                ),
              ],
            ),
          ),

          // 30 Levels Adventure Map
          Expanded(
            child: AdventureMapWidget(
              progress: widget.progress,
              onLevelSelected: _openLevel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHudPill({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF040D1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
