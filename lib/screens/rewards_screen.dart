import 'package:flutter/material.dart';
import '../models/game_progress.dart';
import '../audio/audio_service.dart';

class RewardsScreen extends StatelessWidget {
  final GameProgress progress;

  const RewardsScreen({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final audio = AudioService();

    final worldBadges = [
      _BadgeItem(
        id: 'badge_world_1',
        title: 'Pionnier Anatomique',
        desc: 'Monde 1 validé : Maîtrise de l\'anatomie et des lésions intestinales',
        icon: Icons.biotech_rounded,
        color: const Color(0xFF00E5FF),
        unlocked: progress.isWorldCompleted(1),
      ),
      _BadgeItem(
        id: 'badge_world_2',
        title: 'Sentinelle Clinique',
        desc: 'Monde 2 validé : Reconnaissance des symptômes et rémission clinique',
        icon: Icons.medical_services_rounded,
        color: const Color(0xFF818CF8),
        unlocked: progress.isWorldCompleted(2),
      ),
      _BadgeItem(
        id: 'badge_world_3',
        title: 'Maître Pharmacologique',
        desc: 'Monde 3 validé : Sécurité des anti-TNF et observance thérapeutique',
        icon: Icons.medication_rounded,
        color: const Color(0xFF10B981),
        unlocked: progress.isWorldCompleted(3),
      ),
      _BadgeItem(
        id: 'badge_world_4',
        title: 'Expert Biologique',
        desc: 'Monde 4 validé : Interprétation de la CRP et dépistage coloscopique',
        icon: Icons.science_rounded,
        color: const Color(0xFF38BDF8),
        unlocked: progress.isWorldCompleted(4),
      ),
      _BadgeItem(
        id: 'badge_world_5',
        title: 'Guide de Vie Saine',
        desc: 'Monde 5 validé : Nutrition entérale, sevrage tabagique et voyages',
        icon: Icons.restaurant_rounded,
        color: const Color(0xFFF59E0B),
        unlocked: progress.isWorldCompleted(5),
      ),
      _BadgeItem(
        id: 'badge_world_6',
        title: 'Protecteur de la Lignée',
        desc: 'Monde 6 validé : Grossesse, fertilité et allaitement au cours des MICI',
        icon: Icons.favorite_rounded,
        color: const Color(0xFFEC4899),
        unlocked: progress.isWorldCompleted(6),
      ),
    ];

    final globalBadges = [
      _BadgeItem(
        id: 'badge_first_step',
        title: 'Premier Pas Médical',
        desc: 'Premier niveau de Gastro Quest franchi',
        icon: Icons.flag_rounded,
        color: const Color(0xFF00E5FF),
        unlocked: progress.completedLevels.isNotEmpty,
      ),
      _BadgeItem(
        id: 'badge_halfway',
        title: 'Mi-Parcours MICI',
        desc: '15 niveaux complétés avec succès',
        icon: Icons.military_tech_rounded,
        color: const Color(0xFF818CF8),
        unlocked: progress.completedCount >= 15,
      ),
      _BadgeItem(
        id: 'badge_master_gastro',
        title: 'Grand Praticien Gastro Quest',
        desc: 'Les 30 niveaux de la formation MICI terminés',
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFFFFD166),
        unlocked: progress.completedCount >= 30,
      ),
      _BadgeItem(
        id: 'badge_perfection',
        title: 'Score Parfait 30/30',
        desc: 'Sans aucune erreur médicale sur l\'ensemble des 30 QCM',
        icon: Icons.star_rounded,
        color: const Color(0xFF10B981),
        unlocked: progress.completedCount >= 30 && progress.correctCount == 30,
      ),
      _BadgeItem(
        id: 'badge_xp_veteran',
        title: 'Vétéran de l\'Excellence',
        desc: 'Plus de 1500 XP accumulés au cours de votre cursus',
        icon: Icons.bolt_rounded,
        color: const Color(0xFFF59E0B),
        unlocked: progress.totalXp >= 1500,
      ),
    ];

    final unlockedCount = worldBadges.where((b) => b.unlocked).length +
        globalBadges.where((b) => b.unlocked).length;
    final totalBadgesCount = worldBadges.length + globalBadges.length;

    return Scaffold(
      backgroundColor: const Color(0xFF040D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08172D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            audio.playClick();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'TROPHÉES & RÉCOMPENSES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Overview Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B1E38), Color(0xFF081426)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD166).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD166), width: 2),
                    ),
                    child: const Icon(Icons.military_tech_rounded, color: Color(0xFFFFD166), size: 34),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$unlockedCount / $totalBadgesCount BADGES DÉBLOQUÉS',
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded, color: Color(0xFFFFD166), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${progress.totalXp} XP',
                              style: const TextStyle(
                                color: Color(0xFFFFD166),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${progress.totalStars} / 90 Étoiles',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // World Mastery Badges
            const Text(
              'BADGES DE MAÎTRISE DES 6 MONDES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            ...worldBadges.map((b) => _buildBadgeCard(b)),

            const SizedBox(height: 24),

            // Global Achievements
            const Text(
              'HAUTS FAITS CLINIQUES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            ...globalBadges.map((b) => _buildBadgeCard(b)),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard(_BadgeItem badge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: badge.unlocked ? const Color(0xFF0B1E38) : const Color(0xFF081220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: badge.unlocked ? badge.color.withOpacity(0.6) : Colors.white12,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: badge.unlocked ? badge.color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: badge.unlocked ? badge.color : Colors.white24,
                width: 1.5,
              ),
            ),
            child: Icon(
              badge.unlocked ? badge.icon : Icons.lock_rounded,
              color: badge.unlocked ? badge.color : Colors.white24,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.title,
                  style: TextStyle(
                    color: badge.unlocked ? Colors.white : Colors.white38,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  badge.desc,
                  style: TextStyle(
                    color: badge.unlocked ? Colors.white70 : Colors.white24,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            badge.unlocked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: badge.unlocked ? const Color(0xFF10B981) : Colors.white12,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _BadgeItem {
  final String id;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final bool unlocked;

  _BadgeItem({
    required this.id,
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.unlocked,
  });
}
