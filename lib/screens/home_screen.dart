import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_progress.dart';
import '../models/hospital_service.dart';
import '../services/storage_service.dart';
import '../audio/audio_service.dart';
import '../widgets/tactile_button.dart';
import '../widgets/ecg_monitor_widget.dart';
import '../widgets/hospital_pager_widget.dart';
import '../arcade/gastro_arcade_screen.dart';
import 'arcade_mission_map_screen.dart';
import 'revision_queue_screen.dart';
import 'rewards_screen.dart';
import 'endoscopy_simulation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  GameProgress _progress = GameProgress();
  bool _isLoading = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _loadData();
  }

  Future<void> _loadData() async {
    final progress = await StorageService().loadProgress();
    if (mounted) {
      setState(() {
        _progress = progress;
        _isLoading = false;
      });
      _fadeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _startArcadeGame([int? level]) {
    _audio.init();
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GastroArcadeScreen(
          level: level ?? _progress.currentUnlockedLevel,
          progress: _progress,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _openMissionMap() {
    _audio.init();
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArcadeMissionMapScreen(progress: _progress),
      ),
    ).then((_) => _loadData());
  }

  void _openRevisionCenter() {
    _audio.init();
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RevisionQueueScreen(progress: _progress),
      ),
    ).then((_) => _loadData());
  }

  void _openRewards() {
    _audio.init();
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RewardsScreen(progress: _progress),
      ),
    );
  }

  void _enterEndoscopy() {
    _audio.init();
    _audio.playPagerBeep();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EndoscopySimulationScreen(progress: _progress),
      ),
    ).then((_) => _loadData());
  }

  void _showServicesDrawer() {
    _audio.playClick();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 28,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SERVICES DE GARDE HOSPITALIÈRE',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF2DD4BF),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Planning de rotation clinique',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
              const SizedBox(height: 14),
              const Divider(color: Color(0xFF1E293B), height: 1),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: HospitalService.services.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final service = HospitalService.services[index];
                    final bool isService1 = service.id == 1;
                    final bool isCompleted = service.isCompleted(_progress);

                    String statusText;
                    Color statusColor;
                    Color statusBg;

                    if (isCompleted) {
                      statusText = 'Stabilisé ✓';
                      statusColor = const Color(0xFF34D399);
                      statusBg = const Color(0xFF064E3B);
                    } else if (isService1) {
                      statusText = 'Garde active';
                      statusColor = const Color(0xFF5EEAD4);
                      statusBg = const Color(0xFF134E4A);
                    } else if (service.id == 2) {
                      statusText = 'Prochaine garde';
                      statusColor = const Color(0xFFFBBF24);
                      statusBg = const Color(0xFF78350F).withValues(alpha: 0.5);
                    } else {
                      statusText = 'Verrouillé';
                      statusColor = const Color(0xFF94A3B8);
                      statusBg = const Color(0xFF1E293B);
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: isService1 ? const Color(0xFF1E293B) : const Color(0xFF09111E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isService1 ? const Color(0xFF0D9488) : const Color(0xFF1E293B),
                          width: isService1 ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            service.serviceIcon,
                            color: isService1 ? const Color(0xFF2DD4BF) : const Color(0xFF64748B),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${service.name} • ${service.patient.name} (${service.patient.age} ans)',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Outil : ${service.tool.name}',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: GoogleFonts.inter(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              TactileButton(
                label: 'Fermer',
                style: TactileButtonStyle.secondary,
                height: 46,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B132B),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0D9488)),
        ),
      );
    }

    final bool isSoundOn = _audio.bgmEnabled || _audio.sfxEnabled;
    final int revCount = _progress.questionsInRevisionCount;

    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Top Bar
                    _buildTopBar(isSoundOn, revCount),
                    const SizedBox(height: 14),

                    // 2. Hero 2D Arcade Visual Banner
                    _buildArcadeHeroBanner(),
                    const SizedBox(height: 16),

                    // 3. Primary Hero Action: Play 2D Arcade Game
                    TactileButton(
                      label: 'JOUER À GASTRO QUEST (2D ARCADE)',
                      subtitle: 'Contrôler la capsule médicale • Niveau ${_progress.currentUnlockedLevel}',
                      icon: Icons.rocket_launch_rounded,
                      style: TactileButtonStyle.primary,
                      height: 58,
                      onPressed: () => _startArcadeGame(_progress.currentUnlockedLevel),
                    ),
                    const SizedBox(height: 10),

                    // 4. Secondary Action: Mission Map
                    TactileButton(
                      label: 'CARTE DES MISSIONS (6 MONDES • 30 NIVEAUX)',
                      subtitle: '${_progress.completedCount}/30 complétés • ${_progress.totalStars} étoiles',
                      icon: Icons.map_rounded,
                      style: TactileButtonStyle.secondary,
                      height: 50,
                      onPressed: _openMissionMap,
                    ),
                    const SizedBox(height: 10),

                    // 5. Revision Center Shortcut
                    if (revCount > 0) ...[
                      TactileButton(
                        label: 'CENTRE DE RÉVISION ESPACÉE',
                        subtitle: '$revCount question(s) à consolider',
                        icon: Icons.replay_rounded,
                        style: TactileButtonStyle.secondary,
                        height: 50,
                        onPressed: _openRevisionCenter,
                      ),
                      const SizedBox(height: 10),
                    ],

                    // 6. Hospital Simulation Section (Preserving existing mode)
                    _buildHospitalModeSection(),
                    const SizedBox(height: 16),

                    // Medical credibility disclaimer
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '🩺 Simulateur clinique et jeu arcade éducatif MICI conforme aux recommandations médicales',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isSoundOn, int revCount) {
    return Row(
      children: [
        // Brand logo
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D9488).withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.biotech_rounded, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GASTRO QUEST',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                '2D SIDE-SCROLLING ARCADE',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: const Color(0xFF2DD4BF),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),

        // Action icons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Revision Queue Icon
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.replay_rounded, color: Color(0xFF38BDF8), size: 22),
                  if (revCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '$revCount',
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
              tooltip: 'Centre de Révision',
              onPressed: _openRevisionCenter,
            ),

            // Trophies Icon
            IconButton(
              icon: const Icon(Icons.military_tech_rounded, color: Color(0xFFFFD166), size: 22),
              tooltip: 'Trophées',
              onPressed: _openRewards,
            ),

            // Sound Toggle
            IconButton(
              icon: Icon(
                isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: isSoundOn ? const Color(0xFF2DD4BF) : const Color(0xFF64748B),
                size: 20,
              ),
              tooltip: 'Son',
              onPressed: () {
                setState(() {
                  _audio.toggleBgm();
                  _audio.toggleSfx();
                });
                _audio.playClick();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArcadeHeroBanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D060D),
            Color(0xFF4C0519),
            Color(0xFF131D2E),
          ],
        ),
        border: Border.all(color: const Color(0xFFD44357), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD44357).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sports_esports_rounded, color: Color(0xFF00E5FF), size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'JEU 2D ARCADE PLAYABLE',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF00E5FF),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '60 FPS CANVAS',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title & Description
          Text(
            'Explorez le Système Digestif',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilotez la micro-capsule d\'exploration médicale, évitez les agents pathogènes, collectez les cristaux et validez les décisions cliniques.',
            style: GoogleFonts.inter(
              color: const Color(0xFFE2E8F0),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Stats Chips Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMiniChip(Icons.military_tech_rounded, const Color(0xFFFFD166), '${_progress.totalStars} Étoiles'),
              _buildMiniChip(Icons.bolt_rounded, const Color(0xFF38BDF8), '${_progress.totalXp} XP'),
              _buildMiniChip(Icons.leaderboard_rounded, const Color(0xFF34D399), 'Record: ${_progress.arcadeHighScore}'),
              _buildMiniChip(Icons.check_circle_rounded, const Color(0xFFA78BFA), 'Niveau ${_progress.currentUnlockedLevel} / 30'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChip(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0B121E).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalModeSection() {
    final bool isService1Completed = HospitalService.services[0].isCompleted(_progress);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_hospital_rounded, color: Color(0xFF2DD4BF), size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'MODULE DE GARDE & ENDOSCOPIE',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF2DD4BF),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showServicesDrawer,
                child: Text(
                  'Voir services >',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF38BDF8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Compact ECG Monitor
          EcgMonitorWidget(
            bpm: isService1Completed ? 74 : 88,
            spo2: 98,
            statusText: isService1Completed ? 'SAMI STABILISÉ • GARDE CLOSE' : 'GARDE ACTIVE • ENDOSCOPIE REQUIS',
            isAlert: !isService1Completed,
            height: 95,
          ),
          const SizedBox(height: 10),

          // Enter endoscopy button
          TactileButton(
            label: isService1Completed
                ? 'Rejouer l\'Endoscopie (Service 1)'
                : 'Prendre l\'appel de garde (Endoscopie)',
            icon: Icons.emergency_rounded,
            style: TactileButtonStyle.secondary,
            height: 44,
            onPressed: _enterEndoscopy,
          ),
        ],
      ),
    );
  }
}
