import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_progress.dart';
import '../models/gastro_question.dart';
import '../models/gastro_world.dart';
import '../services/storage_service.dart';
import '../audio/audio_service.dart';
import '../widgets/tactile_button.dart';
import '../widgets/tactile_card.dart';
import '../arcade/gastro_arcade_screen.dart';
import 'capsule_warriors_world_select_screen.dart';
import 'capsule_warriors_intro_screen.dart';
import 'capsule_warriors_how_to_play_screen.dart';
import 'capsule_warriors_settings_screen.dart';
import 'capsule_warriors_review_screen.dart';
import 'capsule_warriors_final_screen.dart';
import 'home_screen.dart';

class CapsuleWarriorsHomeScreen extends StatefulWidget {
  const CapsuleWarriorsHomeScreen({super.key});

  @override
  State<CapsuleWarriorsHomeScreen> createState() => _CapsuleWarriorsHomeScreenState();
}

class _CapsuleWarriorsHomeScreenState extends State<CapsuleWarriorsHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final StorageService _storageService = StorageService();
  final AudioService _audio = AudioService();
  GameProgress _progress = GameProgress();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _loadProgress();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final prog = await _storageService.loadProgress();
    if (mounted) {
      setState(() {
        _progress = prog;
        _isLoading = false;
      });
    }
  }

  void _onPlayPressed() {
    _audio.playClick();
    if (_progress.completedCount == 0) {
      // First time playing: offer intro narrative
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CapsuleWarriorsIntroScreen(
            progress: _progress,
            onContinue: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => CapsuleWarriorsWorldSelectScreen(progress: _progress),
                ),
              );
            },
          ),
        ),
      ).then((_) => _loadProgress());
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CapsuleWarriorsWorldSelectScreen(progress: _progress),
        ),
      ).then((_) => _loadProgress());
    }
  }

  void _onResumePressed() {
    _audio.playClick();
    final currentLevel = _progress.currentUnlockedLevel.clamp(1, allGastroQuestions.length);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GastroArcadeScreen(
          level: currentLevel,
          progress: _progress,
        ),
      ),
    ).then((_) => _loadProgress());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF030712),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
        ),
      );
    }

    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 750;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Stack(
        children: [
          // 1. Dynamic 2D Living Stomach Canvas Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _StomachLivingBgPainter(progress: _animController.value),
                );
              },
            ),
          ),

          // 2. Interactive Foreground UI
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1050),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                    vertical: isMobile ? 16 : 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top Institutional & PFE Banner
                      _buildInstitutionBadge(),
                      const SizedBox(height: 16),

                      // Hero Logo & Title
                      _buildHeroTitle(isMobile),
                      const SizedBox(height: 10),

                      // Subtitle & Educational Scope
                      Text(
                        'EXPÉDITION MÉDICALE 2D DANS L\'ESTOMAC HUMAIN',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF38BDF8),
                          fontSize: isMobile ? 12.5 : 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pilotez la capsule, neutralisez les pathogènes, répondez aux 33 questions cliniques et terrassez les 7 Boss MICI.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: isMobile ? 12 : 13.5,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Student Progression Quick Bar
                      _buildStudentStatsBar(isMobile),
                      const SizedBox(height: 28),

                      // Action Button Matrix
                      _buildActionGrid(isMobile),
                      const SizedBox(height: 32),

                      // Footer & Version
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstitutionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.school_rounded, color: Color(0xFF00E5FF), size: 16),
          const SizedBox(width: 8),
          Text(
            'ISSIT PFE • SOINS INFIRMIERS & GASTRO-ENTÉROLOGIE',
            style: GoogleFonts.inter(
              color: const Color(0xFFE2E8F0),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTitle(bool isMobile) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFF38BDF8),
              Color(0xFF00E5FF),
              Color(0xFF0284C7),
            ],
            stops: [0.0, 0.4, 0.75, 1.0],
          ).createShader(bounds),
          child: Text(
            'CAPSULE WARRIORS',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: isMobile ? 32 : 56,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              height: 1.05,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.6)),
          ),
          child: Text(
            'THE STOMACH MISSION',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFFDA4AF),
              fontSize: isMobile ? 13 : 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentStatsBar(bool isMobile) {
    final masteredCount = _progress.masteredQuestions.length;
    final revisionCount = _progress.revisionQueue.length;
    final totalCompleted = _progress.completedCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
        runSpacing: 12,
        children: [
          _buildStatPill(
            icon: Icons.flash_on_rounded,
            iconColor: const Color(0xFFFFD166),
            label: 'SCORE GLOBAL',
            value: '${_progress.totalScore} PTS',
          ),
          _buildStatPill(
            icon: Icons.bolt_rounded,
            iconColor: const Color(0xFF00E5FF),
            label: 'EXPÉRIENCE (XP)',
            value: '${_progress.totalXp} XP',
          ),
          _buildStatPill(
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF10B981),
            label: 'QUESTIONS MAÎTRISÉES',
            value: '$masteredCount / ${allGastroQuestions.length}',
          ),
          _buildStatPill(
            icon: Icons.sync_problem_rounded,
            iconColor: revisionCount > 0 ? const Color(0xFFF87171) : const Color(0xFF94A3B8),
            label: 'FILE DE RÉVISION',
            value: '$revisionCount question${revisionCount > 1 ? 's' : ''}',
          ),
          _buildStatPill(
            icon: Icons.military_tech_rounded,
            iconColor: const Color(0xFFA78BFA),
            label: 'MONDE ACTUEL',
            value: 'Monde ${GastroWorld.getWorldForLevel(_progress.currentUnlockedLevel).id} / 7',
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionGrid(bool isMobile) {
    final playBtn = TactileButton(
      label: _progress.completedCount == 0 ? 'Commencer la Mission' : 'Carte des Mondes (7 Mondes)',
      subtitle: 'Sélectionnez un monde gastrique et lancez la capsule',
      icon: Icons.rocket_launch_rounded,
      style: TactileButtonStyle.primary,
      height: 64,
      onPressed: _onPlayPressed,
    );

    final resumeBtn = _progress.completedCount > 0
        ? TactileButton(
            label: 'Reprendre N${_progress.currentUnlockedLevel}',
            subtitle: 'Niveau ${_progress.currentUnlockedLevel} en cours',
            icon: Icons.play_arrow_rounded,
            style: TactileButtonStyle.accent,
            height: 64,
            onPressed: _onResumePressed,
          )
        : null;

    final reviewCard = _buildNavCard(
      title: 'Centre de Révision',
      subtitle: '33 Questions officielles ISSIT & explications cliniques',
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF00E5FF),
      onTap: () {
        _audio.playClick();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CapsuleWarriorsReviewScreen(progress: _progress),
          ),
        ).then((_) => _loadProgress());
      },
    );

    final howToPlayCard = _buildNavCard(
      title: 'Comment Jouer & Arsenal',
      subtitle: 'Commandes, 6 armes évolutives & bestiaire des 5 pathogènes',
      icon: Icons.sports_esports_rounded,
      color: const Color(0xFF38BDF8),
      onTap: () {
        _audio.playClick();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CapsuleWarriorsHowToPlayScreen(),
          ),
        );
      },
    );

    final diplomaCard = _buildNavCard(
      title: 'Diplôme & Succès PFE',
      subtitle: 'Certificat d\'excellence en soins infirmiers MICI',
      icon: Icons.military_tech_rounded,
      color: const Color(0xFFFFD166),
      onTap: () {
        _audio.playClick();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CapsuleWarriorsFinalScreen(progress: _progress),
          ),
        );
      },
    );

    final settingsCard = _buildNavCard(
      title: 'Paramètres Audio & Jeu',
      subtitle: 'BGM, effets sonores, secousses et réinitialisation',
      icon: Icons.settings_rounded,
      color: const Color(0xFFA78BFA),
      onTap: () {
        _audio.playClick();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CapsuleWarriorsSettingsScreen(
              progress: _progress,
              onProgressReset: _loadProgress,
            ),
          ),
        );
      },
    );

    return Column(
      children: [
        // Primary big actions
        if (resumeBtn != null && !isMobile)
          Row(
            children: [
              Expanded(flex: 3, child: playBtn),
              const SizedBox(width: 14),
              Expanded(flex: 2, child: resumeBtn),
            ],
          )
        else if (resumeBtn != null && isMobile)
          Column(
            children: [
              playBtn,
              const SizedBox(height: 12),
              resumeBtn,
            ],
          )
        else
          playBtn,
        const SizedBox(height: 14),

        // Secondary cards
        if (isMobile) ...[
          reviewCard,
          const SizedBox(height: 12),
          howToPlayCard,
          const SizedBox(height: 12),
          diplomaCard,
          const SizedBox(height: 12),
          settingsCard,
        ] else ...[
          Row(
            children: [
              Expanded(child: reviewCard),
              const SizedBox(width: 14),
              Expanded(child: howToPlayCard),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: diplomaCard),
              const SizedBox(width: 14),
              Expanded(child: settingsCard),
            ],
          ),
        ],
        const SizedBox(height: 14),

        // Legacy / Clinical services tool bridge (preserves all existing app features)
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            _audio.playClick();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_hospital_rounded, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Accéder aux Outils de Simulation Clinique & Services Hospitaliers',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, color: Color(0xFF94A3B8), size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 84,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1E293B)),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'CAPSULE WARRIORS : THE STOMACH MISSION • Version 2.0 (Release 2D Arcade)',
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Basé sur les travaux de recherche clinique ISSIT Tunis • Prise en charge infirmière des MICI',
          style: GoogleFonts.inter(
            color: const Color(0xFF475569),
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}

/// Custom 2D living stomach canvas painter for home screen
class _StomachLivingBgPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  _StomachLivingBgPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;

    // Deep organic vascular background gradient
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF030712),
          Color(0xFF0B192C),
          Color(0xFF450A0A),
          Color(0xFF030712),
        ],
        stops: [0.0, 0.35, 0.75, 1.0],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // Stomach peristaltic wall waves (upper & lower curves)
    final wallPaint = Paint()
      ..color = const Color(0xFF881337).withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;

    // Top rugae fold
    final topFold = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.18 + math.sin(t) * 15.0);
    for (double x = 0; x <= size.width; x += 40) {
      final y = size.height * 0.16 + math.sin(t + x * 0.008) * 16.0 + math.cos(t * 0.5 + x * 0.012) * 8.0;
      topFold.lineTo(x, y);
    }
    topFold.lineTo(size.width, 0);
    topFold.close();
    canvas.drawPath(topFold, wallPaint);

    // Bottom stomach curve with gastric fluid glow
    final bottomFold = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.82 + math.sin(t + 1.0) * 18.0);
    for (double x = 0; x <= size.width; x += 40) {
      final y = size.height * 0.84 + math.cos(t + x * 0.007) * 15.0 + math.sin(t * 0.8 + x * 0.015) * 8.0;
      bottomFold.lineTo(x, y);
    }
    bottomFold.lineTo(size.width, size.height);
    bottomFold.close();
    canvas.drawPath(bottomFold, wallPaint);

    // Floating background erythrocytes (red blood cells)
    final rand = math.Random(1337);
    for (int i = 0; i < 22; i++) {
      final baseX = rand.nextDouble() * size.width;
      final baseY = rand.nextDouble() * size.height;
      final depth = 0.2 + rand.nextDouble() * 0.7;
      final floatX = (baseX + progress * size.width * (0.3 + depth * 0.5)) % (size.width + 80) - 40;
      final floatY = baseY + math.sin(t * 1.5 + i) * 18.0;
      final r = (10.0 + rand.nextDouble() * 16.0) * depth;

      final cellPaint = Paint()
        ..color = const Color(0xFFE11D48).withValues(alpha: 0.12 * depth);
      canvas.drawCircle(Offset(floatX, floatY), r, cellPaint);
      canvas.drawCircle(Offset(floatX, floatY), r * 0.45, Paint()..color = const Color(0xFF4C0519).withValues(alpha: 0.18 * depth));
    }

    // Floating Hero Medical Capsule in center-right
    final capsuleX = size.width * 0.82;
    final capsuleY = size.height * 0.35 + math.sin(t) * 16.0;
    _drawHeroCapsule(canvas, Offset(capsuleX, capsuleY), t);
  }

  void _drawHeroCapsule(Canvas canvas, Offset pos, double t) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(math.sin(t * 0.8) * 0.08);

    // Headlight cone
    final lightCone = Path()
      ..moveTo(20, -5)
      ..lineTo(140, -45)
      ..lineTo(140, 45)
      ..lineTo(20, 5)
      ..close();
    final lightPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(const Rect.fromLTWH(20, -45, 120, 90));
    canvas.drawPath(lightCone, lightPaint);

    // Thruster glow
    final flame = Path()
      ..moveTo(-22, -6)
      ..lineTo(-45 + math.sin(t * 8.0) * 8.0, 0)
      ..lineTo(-22, 6)
      ..close();
    canvas.drawPath(flame, Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.8));

    // Capsule Pod Body
    const podRect = Rect.fromLTWH(-24, -16, 48, 32);
    final podPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFE2E8F0), Color(0xFF94A3B8)],
      ).createShader(podRect);
    canvas.drawRRect(RRect.fromRectAndRadius(podRect, const Radius.circular(16)), podPaint);

    // Visor dome
    const visorRect = Rect.fromLTWH(4, -11, 16, 22);
    final visorPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFE0F2FE), Color(0xFF00E5FF), Color(0xFF0369A1)],
      ).createShader(visorRect);
    canvas.drawOval(visorRect, visorPaint);

    // Medical teal stripe
    canvas.drawArc(
      podRect,
      -math.pi * 0.3,
      math.pi * 0.6,
      false,
      Paint()
        ..color = const Color(0xFF0D9488)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StomachLivingBgPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
