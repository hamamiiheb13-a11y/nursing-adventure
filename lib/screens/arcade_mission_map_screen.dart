import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_progress.dart';
import '../models/gastro_world.dart';
import '../services/storage_service.dart';
import '../audio/audio_service.dart';
import '../arcade/gastro_arcade_screen.dart';
import 'revision_queue_screen.dart';
import 'rewards_screen.dart';

class ArcadeMissionMapScreen extends StatefulWidget {
  final GameProgress progress;

  const ArcadeMissionMapScreen({
    super.key,
    required this.progress,
  });

  @override
  State<ArcadeMissionMapScreen> createState() => _ArcadeMissionMapScreenState();
}

class _ArcadeMissionMapScreenState extends State<ArcadeMissionMapScreen> {
  final AudioService _audio = AudioService();

  void _openArcadeLevel(int level) async {
    _audio.playClick();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GastroArcadeScreen(
          level: level,
          progress: widget.progress,
        ),
      ),
    );
    setState(() {});
    StorageService().saveProgress(widget.progress);
  }

  void _openRevisionCenter() {
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RevisionQueueScreen(progress: widget.progress),
      ),
    ).then((_) => setState(() {}));
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
    final progress = widget.progress;

    return Scaffold(
      backgroundColor: const Color(0xFF070D18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            _audio.playClick();
            Navigator.of(context).pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CARTE DES MISSIONS ARCADE',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF00E5FF),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'GASTRO QUEST • 6 MONDES DIGESTIFS',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Revision Queue Shortcut Badge
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.replay_rounded, color: Color(0xFF38BDF8)),
                if (progress.questionsInRevisionCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        '${progress.questionsInRevisionCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Centre de Révision Spacée',
            onPressed: _openRevisionCenter,
          ),
          IconButton(
            icon: const Icon(Icons.military_tech_rounded, color: Color(0xFFFFD166)),
            tooltip: 'Trophées & Badges',
            onPressed: _openRewards,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Stats Bar
          _buildTopStatsBar(progress),

          // Scrollable Worlds List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: GastroWorld.worlds.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final world = GastroWorld.worlds[index];
                return _buildWorldCard(world, progress);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            border: Border(top: BorderSide(color: Color(0xFF1E293B))),
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
            icon: const Icon(Icons.rocket_launch_rounded),
            label: Text(
              'Lancer la Mission Active (Niveau ${progress.currentUnlockedLevel})',
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            onPressed: () => _openArcadeLevel(progress.currentUnlockedLevel),
          ),
        ),
      ),
    );
  }

  Widget _buildTopStatsBar(GameProgress progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      color: const Color(0xFF0F172A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTopStatItem(Icons.star_rounded, const Color(0xFFFFD166), '${progress.totalStars}', 'ÉTOILES'),
          _buildTopStatItem(Icons.bolt_rounded, const Color(0xFF38BDF8), '${progress.totalXp}', 'XP TOTAL'),
          _buildTopStatItem(Icons.leaderboard_rounded, const Color(0xFF34D399), '${progress.arcadeHighScore}', 'RECORD'),
          _buildTopStatItem(Icons.verified_rounded, const Color(0xFFA78BFA), '${progress.completedCount} / 30', 'PROGRÈS'),
        ],
      ),
    );
  }

  Widget _buildTopStatItem(IconData icon, Color color, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorldCard(GastroWorld world, GameProgress progress) {
    final bool isUnlocked = progress.isWorldUnlocked(world.id);
    final bool isCompleted = progress.isWorldCompleted(world.id);
    final int completedCount = progress.getCompletedCountInWorld(world.id);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131D2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? world.primaryColor
              : (isUnlocked ? const Color(0xFF334155) : const Color(0xFF1E293B)),
          width: isCompleted ? 2.0 : 1.2,
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: world.primaryColor.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // World Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: world.primaryColor.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isUnlocked ? world.primaryColor.withValues(alpha: 0.25) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isUnlocked ? world.icon : Icons.lock_rounded,
                    color: isUnlocked ? world.primaryColor : const Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            world.title,
                            style: GoogleFonts.plusJakartaSans(
                              color: world.primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            '$completedCount / ${world.questionCount} complétés',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        world.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // World Description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              world.description,
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),

          // Levels Grid inside this world
          Padding(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(world.questionCount, (i) {
                final level = world.startLevel + i;
                final bool isLevelUnlocked = progress.isLevelUnlocked(level);
                final bool isLevelDone = progress.isLevelCompleted(level);
                final int stars = progress.getStars(level);

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: isLevelUnlocked ? () => _openArcadeLevel(level) : null,
                  child: Container(
                    width: 72,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isLevelDone
                          ? const Color(0xFF0F766E).withValues(alpha: 0.35)
                          : (isLevelUnlocked ? const Color(0xFF1E293B) : const Color(0xFF0B121E)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isLevelDone
                            ? const Color(0xFF10B981)
                            : (isLevelUnlocked ? world.primaryColor : const Color(0xFF1E293B)),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'N$level',
                          style: GoogleFonts.plusJakartaSans(
                            color: isLevelUnlocked ? Colors.white : const Color(0xFF475569),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isLevelDone)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(stars, (_) {
                              return const Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 12);
                            }),
                          )
                        else if (isLevelUnlocked)
                          const Icon(Icons.play_arrow_rounded, color: Color(0xFF00E5FF), size: 14)
                        else
                          const Icon(Icons.lock_outline_rounded, color: Color(0xFF475569), size: 14),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // Boss Badge Footnote
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF0A101C),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(19)),
            ),
            child: Row(
              children: [
                Icon(world.boss.icon, color: world.boss.auraColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Boss de fin de monde : ${world.boss.name} • ${world.boss.title}',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
