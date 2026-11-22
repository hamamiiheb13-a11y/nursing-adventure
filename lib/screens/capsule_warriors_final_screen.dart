import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../models/game_progress.dart';
import '../models/gastro_question.dart';
import '../models/gastro_world.dart';
import '../theme/capsule_theme.dart';
import 'capsule_warriors_review_screen.dart';
import 'capsule_warriors_world_select_screen.dart';

class CapsuleWarriorsFinalScreen extends StatefulWidget {
  final GameProgress progress;

  const CapsuleWarriorsFinalScreen({
    super.key,
    required this.progress,
  });

  @override
  State<CapsuleWarriorsFinalScreen> createState() => _CapsuleWarriorsFinalScreenState();
}

class _CapsuleWarriorsFinalScreenState extends State<CapsuleWarriorsFinalScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _celebrationController;
  final AudioService _audio = AudioService();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _audio.playStageComplete();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  int get _correctQuestionsCount {
    int count = 0;
    for (final isCorrect in widget.progress.questionsAnswered.values) {
      if (isCorrect) count++;
    }
    return count > 0 ? count : widget.progress.masteredQuestions.length;
  }

  String _calculateGrade(int correctCount) {
    if (correctCount >= 28) return 'MAJOR DE PROMOTION • MENTION TRÈS BIEN';
    if (correctCount >= 22) return 'CERTIFIÉ AVEC ÉLOGES • MENTION BIEN';
    if (correctCount >= 16) return 'VALIDÉ AVEC SUCCÈS • MENTION ASSEZ BIEN';
    return 'ADMIS EN SOINS INFIRMIERS GASTRO-ENTÉROLOGIE';
  }

  void _onShare() {
    _audio.playClick();
    final correct = _correctQuestionsCount;
    final text = 'J\'ai terminé CAPSULE WARRIORS avec ${widget.progress.totalScore} PTS et $correct/33 questions correctes !';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CapsuleColors.cardNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: CapsuleColors.cyanGlow),
        ),
        content: Text(
          'Résultats copiés dans le presse-papier !',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isCompact = media.size.height < 550;
    final correctCount = _correctQuestionsCount;
    final grade = _calculateGrade(correctCount);

    return Scaffold(
      backgroundColor: CapsuleColors.darkNavy,
      body: Stack(
        children: [
          // 1. Massive Celebration Particle Burst Canvas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _celebrationController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _GrandCelebrationPainter(progress: _celebrationController.value),
                );
              },
            ),
          ),

          // 2. Foreground Results UI
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 18 : 36,
                vertical: isCompact ? 12 : 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    children: [
                      // Grand Header Certificate
                      _buildHeaderBanner(grade, isCompact),
                      const SizedBox(height: 18),

                      // Trophy & Key Metrics Card
                      _buildMetricsAndTrophy(correctCount, isCompact),
                      const SizedBox(height: 18),

                      // 7 Stages Breakdown Row
                      _buildStagesBreakdown(),
                      const SizedBox(height: 18),

                      // Topics Requiring Revision Section
                      _buildRevisionTopicsSection(),
                      const SizedBox(height: 24),

                      // Bottom Action Buttons: RÉVISER / REJOUER / PARTAGER
                      _buildActionButtons(),
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

  Widget _buildHeaderBanner(String grade, bool isCompact) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_rounded, color: CapsuleColors.gold, size: 28),
            const SizedBox(width: 10),
            Text(
              'ISSIT TUNIS • DIPLÔME OFFICIEL DE FIN D\'ÉTUDES',
              style: GoogleFonts.orbitron(
                color: CapsuleColors.gold,
                fontSize: isCompact ? 11 : 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'FÉLICITATIONS DOCTEUR !',
          textAlign: TextAlign.center,
          style: GoogleFonts.orbitron(
            fontSize: isCompact ? 24 : 36,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.5,
            color: Colors.white,
            shadows: [
              Shadow(
                color: CapsuleColors.cyanGlow.withValues(alpha: 0.8),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: CapsuleColors.purple.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: CapsuleColors.purple),
          ),
          child: Text(
            grade,
            style: GoogleFonts.orbitron(
              color: CapsuleColors.turquoise,
              fontSize: isCompact ? 10 : 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsAndTrophy(int correctCount, bool isCompact) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: CapsuleColors.gold.withValues(alpha: 0.8), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: CapsuleColors.gold.withValues(alpha: 0.2),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        children: [
          // Canvas Drawn Trophy / Medal
          SizedBox(
            width: 88,
            height: 88,
            child: CustomPaint(
              painter: _TrophyMedalPainter(correctCount: correctCount),
            ),
          ),
          const SizedBox(width: 20),

          // Summary Stats
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              runSpacing: 12,
              children: [
                _buildStatColumn('SCORE GLOBAL', '${widget.progress.totalScore} PTS', CapsuleColors.gold),
                _buildStatColumn('XP TOTAL', '${widget.progress.totalXP} XP', CapsuleColors.cyanGlow),
                _buildStatColumn('RÉPONSES CORRECTES', '$correctCount / 33', CapsuleColors.successGreen),
                _buildStatColumn('STAGES VALIDÉS', '7 / 7 COMPLÉTÉS', CapsuleColors.turquoise),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            color: CapsuleColors.textSubtle,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildStagesBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BILAN INDIVIDUEL DES 7 STAGES GASTRIQUES',
          style: GoogleFonts.orbitron(
            color: CapsuleColors.cyanGlow,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: GastroWorld.worlds.map((world) {
              final stars = widget.progress.getStars(world.id);
              final isDone = widget.progress.isWorldCompleted(world.id);

              return Container(
                width: 124,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDone ? world.primaryColor : const Color(0xFF334155),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'STAGE ${world.id}',
                      style: GoogleFonts.orbitron(
                        color: world.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      world.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (s) {
                        return Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: s < stars ? CapsuleColors.gold : const Color(0xFF334155),
                        );
                      }),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRevisionTopicsSection() {
    final revisionIds = widget.progress.revisionQueue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: revisionIds.isNotEmpty
              ? CapsuleColors.dangerOrange.withValues(alpha: 0.5)
              : CapsuleColors.successGreen.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                revisionIds.isNotEmpty ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                color: revisionIds.isNotEmpty ? CapsuleColors.dangerOrange : CapsuleColors.successGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                revisionIds.isNotEmpty
                    ? 'POINTS CLINIQUES RECOMMANDÉS POUR RÉVISION (${revisionIds.length})'
                    : 'MAÎTRISE CLINIQUE TOTALE • AUCUNE RÉVISION REQUISE',
                style: GoogleFonts.orbitron(
                  color: revisionIds.isNotEmpty ? CapsuleColors.dangerOrange : CapsuleColors.successGreen,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (revisionIds.isNotEmpty) ...[
            Text(
              'Les questions suivantes nécessitent une consolidation avant l\'exercice pratique :',
              style: GoogleFonts.inter(color: CapsuleColors.textSubtle, fontSize: 11.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: revisionIds.map((qId) {
                final q = allGastroQuestions.firstWhere((item) => item.id == qId);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CapsuleColors.dangerRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CapsuleColors.dangerRed.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'Q$qId: ${q.anatomicalTheme}',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFCA5A5),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Text(
              'Félicitations, vous avez validé avec succès l\'ensemble des 33 compétences cliniques en soins infirmiers MICI.',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // RÉVISER MES RÉPONSES
        Expanded(
          child: _buildFinalButton(
            label: 'RÉVISER MES RÉPONSES',
            icon: Icons.menu_book_rounded,
            color: CapsuleColors.cyanGlow,
            onTap: () {
              _audio.playClick();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CapsuleWarriorsReviewScreen(progress: widget.progress),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // REJOUER
        Expanded(
          child: _buildFinalButton(
            label: 'REJOUER',
            icon: Icons.replay_rounded,
            color: CapsuleColors.purple,
            onTap: () {
              _audio.playClick();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => CapsuleWarriorsWorldSelectScreen(progress: widget.progress),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // PARTAGER
        Expanded(
          child: _buildFinalButton(
            label: 'PARTAGER',
            icon: Icons.share_rounded,
            color: CapsuleColors.gold,
            onTap: _onShare,
          ),
        ),
      ],
    );
  }

  Widget _buildFinalButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrophyMedalPainter extends CustomPainter {
  final int correctCount;

  _TrophyMedalPainter({required this.correctCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Medal colors based on score
    final isGold = correctCount >= 24;
    final primaryMedal = isGold ? CapsuleColors.gold : const Color(0xFFCBD5E1);
    final secondaryMedal = isGold ? const Color(0xFFB45309) : const Color(0xFF64748B);

    // Outer aura
    canvas.drawCircle(
      center,
      size.width * 0.45,
      Paint()
        ..color = primaryMedal.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Cup base
    final cupPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryMedal, secondaryMedal],
      ).createShader(Rect.fromCircle(center: center, radius: 36));

    // Cup body
    final cupPath = Path()
      ..moveTo(center.dx - 22, center.dy - 20)
      ..lineTo(center.dx + 22, center.dy - 20)
      ..lineTo(center.dx + 16, center.dy + 10)
      ..quadraticBezierTo(center.dx, center.dy + 22, center.dx - 16, center.dy + 10)
      ..close();
    canvas.drawPath(cupPath, cupPaint);

    // Stem and base
    canvas.drawRect(Rect.fromCenter(center: Offset(center.dx, center.dy + 24), width: 8, height: 10), cupPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + 30), width: 34, height: 8),
        const Radius.circular(4),
      ),
      cupPaint,
    );

    // Star in center of cup
    canvas.drawCircle(Offset(center.dx, center.dy - 4), 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _TrophyMedalPainter oldDelegate) =>
      oldDelegate.correctCount != correctCount;
}

class _GrandCelebrationPainter extends CustomPainter {
  final double progress;

  _GrandCelebrationPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(999);
    final sparkPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 90; i++) {
      final seedX = rand.nextDouble();
      final speed = 0.2 + rand.nextDouble() * 0.5;
      final startY = rand.nextDouble() * size.height;

      final px = seedX * size.width + math.sin(progress * math.pi * 2 + i) * 20;
      final py = (startY + progress * size.height * speed) % size.height;

      final colorIndex = i % 4;
      final color = colorIndex == 0
          ? CapsuleColors.gold
          : colorIndex == 1
              ? CapsuleColors.cyanGlow
              : colorIndex == 2
                  ? CapsuleColors.purple
                  : CapsuleColors.successGreen;

      final alpha = (0.2 + 0.6 * math.sin(progress * math.pi * 2 + i)).clamp(0.1, 0.8);
      sparkPaint.color = color.withValues(alpha: alpha);

      canvas.drawCircle(Offset(px, py), 1.8 + rand.nextDouble() * 2.2, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrandCelebrationPainter oldDelegate) => true;
}
