import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_progress.dart';
import '../models/gastro_world.dart';
import '../services/storage_service.dart';
import '../audio/audio_service.dart';
import '../widgets/animated_digestive_system.dart';
import '../widgets/gastro_guide_avatar.dart';
import 'adventure_map_screen.dart';
import 'question_level_screen.dart';
import 'rewards_screen.dart';
import 'review_answers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  GameProgress _progress = GameProgress();
  bool _isLoading = true;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _loadData();
  }

  Future<void> _loadData() async {
    final progress = await StorageService().loadProgress();
    setState(() {
      _progress = progress;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startAdventure() {
    _audio.init();
    _audio.playClick();
    _audio.startBgm();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdventureMapScreen(progress: _progress),
      ),
    ).then((_) => _loadData());
  }

  void _resumeAdventure() {
    _audio.init();
    _audio.playClick();
    _audio.startBgm();

    final nextLevel = _progress.currentUnlockedLevel.clamp(1, 30);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuestionLevelScreen(
          level: nextLevel,
          progress: _progress,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _openRewards() {
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RewardsScreen(progress: _progress),
      ),
    ).then((_) => _loadData());
  }

  void _openReview() {
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewAnswersScreen(progress: _progress),
      ),
    );
  }

  void _showSettingsDialog() {
    _audio.playClick();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1E38),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5), width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 24)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tune_rounded, color: Color(0xFF00E5FF), size: 22),
                        SizedBox(width: 10),
                        Text(
                          'PARAMÈTRES DU JEU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
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
                const SizedBox(height: 16),

                // Audio switches
                SwitchListTile(
                  title: const Text('Effets Sonores (SFX)', style: TextStyle(color: Colors.white, fontSize: 13)),
                  subtitle: const Text('Bruits de validation, étoiles et carillons', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  value: _audio.sfxEnabled,
                  activeColor: const Color(0xFF00E5FF),
                  onChanged: (val) {
                    setDialogState(() => _audio.setSfxEnabled(val));
                    setState(() {});
                  },
                ),
                SwitchListTile(
                  title: const Text('Musique d\'ambiance (BGM)', style: TextStyle(color: Colors.white, fontSize: 13)),
                  subtitle: const Text('Thème sonore aventureux et calme', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  value: _audio.bgmEnabled,
                  activeColor: const Color(0xFF00E5FF),
                  onChanged: (val) {
                    setDialogState(() => _audio.setBgmEnabled(val));
                    setState(() {});
                  },
                ),
                const SizedBox(height: 14),
                const Divider(color: Colors.white24),
                const SizedBox(height: 10),

                // Reset Progress Button
                ListTile(
                  leading: const Icon(Icons.restart_alt_rounded, color: Color(0xFFEF4444)),
                  title: const Text('Réinitialiser ma progression', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Effacer les scores, niveaux et réponses', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF0F1E36),
                        title: const Text('Confirmer la réinitialisation ?', style: TextStyle(color: Colors.white, fontSize: 14)),
                        content: const Text(
                          'Toute votre progression (30 niveaux, étoiles et XP) sera effacée.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Annuler', style: TextStyle(color: Colors.white60)),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                            child: const Text('Réinitialiser', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await StorageService().resetProgress();
                      _loadData();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF040D1A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
        ),
      );
    }

    final hasStarted = _progress.completedLevels.isNotEmpty;
    final completedCount = _progress.completedCount;
    final percentage = (_progress.completionPercentage * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: const Color(0xFF040D1A),
      body: Stack(
        children: [
          // Background subtle ambient lights
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Status Bar (Audio & Settings)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1E38),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_hospital_rounded, color: Color(0xFF00E5FF), size: 14),
                            SizedBox(width: 6),
                            Text(
                              'FORMATION MÉDICALE MICI',
                              style: TextStyle(
                                color: Color(0xFF00E5FF),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _audio.bgmEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                              color: _audio.bgmEnabled ? const Color(0xFF00E5FF) : Colors.white38,
                              size: 22,
                            ),
                            tooltip: 'Son d\'ambiance',
                            onPressed: () {
                              _audio.toggleBgm();
                              setState(() {});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_rounded, color: Colors.white70, size: 22),
                            tooltip: 'Paramètres',
                            onPressed: _showSettingsDialog,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Hero Logo GASTRO QUEST
                  _buildHeroLogo(),
                  const SizedBox(height: 18),

                  // Guide Character Welcome Dialogue
                  _buildGuideWelcomeCard(),
                  const SizedBox(height: 20),

                  // Centerpiece: Animated Interactive Digestive System
                  AnimatedDigestiveSystem(
                    width: math.min(MediaQuery.of(context).size.width - 40, 360),
                    height: 290,
                    interactive: true,
                    onHotspotTapped: (hotspot) {
                      _audio.playClick();
                    },
                  ),
                  const SizedBox(height: 22),

                  // Progression Metrics Card
                  _buildProgressionCard(completedCount, percentage),
                  const SizedBox(height: 22),

                  // Primary Action Buttons
                  _buildActionButtons(hasStarted),
                  const SizedBox(height: 18),

                  // Secondary Shortcuts (Badges & Historique)
                  _buildSecondaryActions(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroLogo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
              ),
              child: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF00E5FF), size: 28),
            ),
            const SizedBox(width: 12),
            const Text(
              'GASTRO QUEST',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: Color(0xFF00E5FF),
                    blurRadius: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'L\'AVENTURE ÉDUCATIVE CLINIQUE DES MICI • 30 NIVEAUX',
          style: TextStyle(
            color: const Color(0xFFFFD166).withOpacity(0.9),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideWelcomeCard() {
    final welcomeText = _progress.completedCount == 0
        ? 'Bienvenue, futur praticien ! Je suis le Dr. Alex. Préparez-vous à traverser les 6 mondes et maîtriser les MICI grâce aux 30 QCM officiels !'
        : 'Ravi de vous revoir ! Vous avez déjà validé ${_progress.completedCount} sur 30 niveaux. Poursuivons votre progression médicale !';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1E38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.08),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          const GastroGuideAvatar(
            size: 60,
            mood: GuideMood.neutral,
            animate: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Dr. Alex • Guide Gastro Quest',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  welcomeText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionCard(int completedCount, String percentage) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1E38),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROGRESSION GLOBALE',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$completedCount / 30 NIVEAUX TERMINÉS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Text(
                  '$percentage %',
                  style: const TextStyle(
                    color: Color(0xFFA7F3D0),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress indicator bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _progress.completionPercentage,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
            ),
          ),
          const SizedBox(height: 14),

          // Stats badges (XP & Stars)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatBadge(
                icon: Icons.bolt_rounded,
                color: const Color(0xFFFFD166),
                title: 'EXPÉRIENCE',
                value: '${_progress.totalXp} XP',
              ),
              Container(width: 1, height: 26, color: Colors.white12),
              _buildStatBadge(
                icon: Icons.star_rounded,
                color: const Color(0xFFFFD166),
                title: 'ÉTOILES',
                value: '${_progress.totalStars} / 90',
              ),
              Container(width: 1, height: 26, color: Colors.white12),
              _buildStatBadge(
                icon: Icons.military_tech_rounded,
                color: const Color(0xFF10B981),
                title: 'BADGES',
                value: '${_progress.unlockedBadges.length} / 11',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool hasStarted) {
    return Column(
      children: [
        // "Commencer / Ouvrir la Carte"
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _startAdventure,
            icon: const Icon(Icons.map_rounded, color: Color(0xFF040D1A), size: 22),
            label: const Text(
              'CARTE D\'AVENTURE (30 NIVEAUX)',
              style: TextStyle(
                color: Color(0xFF040D1A),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        // "Reprendre ma partie"
        if (hasStarted && _progress.completedCount < 30) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _resumeAdventure,
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
              label: Text(
                'REPRENDRE AU NIVEAU ${_progress.currentUnlockedLevel}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSecondaryActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _openRewards,
            icon: const Icon(Icons.military_tech_rounded, color: Color(0xFFFFD166), size: 18),
            label: const Text(
              'Récompenses',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _openReview,
            icon: const Icon(Icons.history_edu_rounded, color: Color(0xFF00E5FF), size: 18),
            label: const Text(
              'Revoir QCM',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}
