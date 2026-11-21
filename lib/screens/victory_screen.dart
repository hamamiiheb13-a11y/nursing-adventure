import 'package:flutter/material.dart';
import '../models/game_progress.dart';
import '../models/gastro_world.dart';
import '../audio/audio_service.dart';
import '../widgets/gastro_guide_avatar.dart';
import '../widgets/confetti_overlay.dart';
import 'review_answers_screen.dart';
import 'home_screen.dart';

class VictoryScreen extends StatefulWidget {
  final GameProgress progress;

  const VictoryScreen({
    super.key,
    required this.progress,
  });

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen> {
  final AudioService _audio = AudioService();

  @override
  void initState() {
    super.initState();
    _audio.playVictory();
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = widget.progress.accuracyRate;
    final correct = widget.progress.correctCount;
    final total = widget.progress.completedCount.clamp(1, 30);
    final wrong = total - correct;

    String medicalRank = 'Interne Spécialiste MICI';
    if (accuracy >= 90) {
      medicalRank = 'Praticien Hospitalier Expert MICI';
    } else if (accuracy >= 75) {
      medicalRank = 'Chef de Clinique en Gastro-Entérologie';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF040D1A),
      body: ConfettiOverlay(
        isPlaying: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Top Trophy Header
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD166).withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD166), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD166).withOpacity(0.4),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD166), size: 48),
                ),
                const SizedBox(height: 18),

                const Text(
                  'MISSION ACCOMPLIE !',
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'FÉLICITATIONS DOCTEUR !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Text(
                    medicalRank,
                    style: const TextStyle(
                      color: Color(0xFFA7F3D0),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Guide Dialogue Bubble
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1E38),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.35)),
                  ),
                  child: Row(
                    children: [
                      const GastroGuideAvatar(
                        size: 64,
                        mood: GuideMood.celebrating,
                        animate: true,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Vous avez exploré les 6 Mondes et validé les 30 questions médicales sur les MICI. Vos compétences cliniques sont remarquables !',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Score Grid
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF08172D),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildStatCard(
                            title: 'SCORE TOTAL',
                            value: '${widget.progress.totalXp} XP',
                            icon: Icons.bolt_rounded,
                            color: const Color(0xFFFFD166),
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            title: 'RÉUSSITE',
                            value: '${accuracy.toStringAsFixed(1)} %',
                            icon: Icons.analytics_rounded,
                            color: const Color(0xFF00E5FF),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatCard(
                            title: 'BONNES RÉPONSES',
                            value: '$correct / 30',
                            icon: Icons.check_circle_rounded,
                            color: const Color(0xFF10B981),
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            title: 'À RÉVISER',
                            value: '$wrong / 30',
                            icon: Icons.lightbulb_outline_rounded,
                            color: const Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 6 Worlds Progression Recap
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF08172D),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PROGRESSION PAR MONDE (6/6 TERMINÉS) :',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...GastroWorld.worlds.map((world) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(world.icon, color: world.primaryColor, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${world.title} : ${world.subtitle}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _audio.playClick();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ReviewAnswersScreen(progress: widget.progress),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history_edu_rounded, color: Color(0xFF040D1A)),
                    label: const Text(
                      'REVOIR TOUTES MES RÉPONSES',
                      style: TextStyle(
                        color: Color(0xFF040D1A),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _audio.playClick();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home_rounded, color: Colors.white),
                    label: const Text(
                      'RETOUR À L\'ACCUEIL DU JEU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
