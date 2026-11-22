import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_progress.dart';
import '../models/gastro_world.dart';
import '../models/gastro_question.dart';
import '../audio/audio_service.dart';
import '../arcade/weapon_system.dart';
import 'capsule_warriors_briefing_screen.dart';

class CapsuleWarriorsWorldSelectScreen extends StatefulWidget {
  final GameProgress progress;

  const CapsuleWarriorsWorldSelectScreen({super.key, required this.progress});

  @override
  State<CapsuleWarriorsWorldSelectScreen> createState() => _CapsuleWarriorsWorldSelectScreenState();
}

class _CapsuleWarriorsWorldSelectScreenState extends State<CapsuleWarriorsWorldSelectScreen> {
  final AudioService _audio = AudioService();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 750;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'CARTE DES 7 MONDES GASTRIQUES',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 15 : 18,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFFFFD166), size: 18),
                const SizedBox(width: 4),
                Text(
                  '${widget.progress.totalXp} XP',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFFD166),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 32,
          vertical: 20,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Subtitle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.explore_rounded, color: Color(0xFF00E5FF), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progression Anatomique du Tractus Digestif',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Explorez les 7 secteurs, répondez aux 33 questions validées du PFE, et débloquez les 6 armes médicales.',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // List of 7 Worlds
                ...allGastroWorlds.map((world) => _buildWorldCard(world, isMobile)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorldCard(GastroWorld world, bool isMobile) {
    final isUnlocked = widget.progress.isWorldUnlocked(world.id);
    final isCompleted = widget.progress.isWorldCompleted(world.id);

    // Count levels completed in this world
    int completedInWorld = 0;
    int totalStarsInWorld = 0;
    for (int lvl = world.startLevel; lvl <= world.endLevel; lvl++) {
      if (widget.progress.isLevelCompleted(lvl)) {
        completedInWorld++;
        totalStarsInWorld += widget.progress.getStars(lvl);
      }
    }
    final totalLevelsInWorld = world.endLevel - world.startLevel + 1;
    final maxStars = totalLevelsInWorld * 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: isUnlocked ? 0.92 : 0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF10B981)
              : isUnlocked
                  ? world.primaryColor.withValues(alpha: 0.6)
                  : const Color(0xFF1E293B),
          width: isUnlocked ? 1.8 : 1.0,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: world.primaryColor.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: isUnlocked
              ? () {
                  _audio.playClick();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CapsuleWarriorsBriefingScreen(
                        world: world,
                        progress: widget.progress,
                      ),
                    ),
                  ).then((_) => setState(() {}));
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: World Index, Title & Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // World Icon / Avatar
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isUnlocked
                              ? [world.primaryColor, world.secondaryColor]
                              : [const Color(0xFF334155), const Color(0xFF1E293B)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: world.primaryColor.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        isUnlocked ? world.icon : Icons.lock_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Title & Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: world.primaryColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: world.primaryColor.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  'MONDE ${world.id}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: isUnlocked ? world.primaryColor : const Color(0xFF94A3B8),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Niveaux ${world.startLevel} - ${world.endLevel} (Q${world.startLevel}-Q${world.endLevel})',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            world.title,
                            style: GoogleFonts.plusJakartaSans(
                              color: isUnlocked ? Colors.white : const Color(0xFF64748B),
                              fontSize: isMobile ? 16 : 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            world.description,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bottom Meta: Weapon reward, Boss, and Stars/Action
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF030712).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Row(
                    children: [
                      // Weapon Unlock Info
                      Icon(Icons.bolt_rounded, color: world.primaryColor, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        'Arme : ${world.unlockedWeaponName}',
                        style: GoogleFonts.inter(
                          color: isUnlocked ? world.primaryColor : const Color(0xFF64748B),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),

                      // Boss Info
                      const Icon(Icons.coronavirus_rounded, color: Color(0xFFEF4444), size: 16),
                      const SizedBox(width: 5),
                      Text(
                        'Boss : ${world.boss.name}',
                        style: GoogleFonts.inter(
                          color: isUnlocked ? const Color(0xFFFCA5A5) : const Color(0xFF64748B),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Stars or Lock
                      if (isUnlocked) ...[
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 16),
                            const SizedBox(width: 3),
                            Text(
                              '$totalStarsInWorld / $maxStars ★',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFFFD166),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00E5FF), size: 14),
                      ] else ...[
                        const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Verrouillé',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
