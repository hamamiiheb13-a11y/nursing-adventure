import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_progress.dart';
import '../models/gastro_question.dart';
import '../services/storage_service.dart';
import '../audio/audio_service.dart';
import '../arcade/gastro_arcade_screen.dart';

class RevisionQueueScreen extends StatefulWidget {
  final GameProgress progress;

  const RevisionQueueScreen({
    super.key,
    required this.progress,
  });

  @override
  State<RevisionQueueScreen> createState() => _RevisionQueueScreenState();
}

class _RevisionQueueScreenState extends State<RevisionQueueScreen>
    with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startRevisionArcadeRun(int questionId) {
    _audio.playClick();

    // Map question to level
    final targetLevel = questionId.clamp(1, 30);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GastroArcadeScreen(
          level: targetLevel,
          progress: widget.progress,
        ),
      ),
    ).then((_) {
      setState(() {});
      StorageService().saveProgress(widget.progress);
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress;
    final revCount = progress.questionsInRevisionCount;
    final masteredCount = progress.questionsMasteredCount;

    return Scaffold(
      backgroundColor: const Color(0xFF090E17),
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
              'RÉPÉTITION ESPACÉE INTELLIGENTE',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF00E5FF),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Centre de Révision & Maîtrise Clinique',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00E5FF),
          indicatorWeight: 3,
          labelColor: const Color(0xFF00E5FF),
          unselectedLabelColor: const Color(0xFF94A3B8),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.replay_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text('À Réviser ($revCount)'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text('Maîtrisées ($masteredCount)'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Global Stats Bar
          _buildStatsSummaryBar(progress),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRevisionList(progress),
                _buildMasteredList(progress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummaryBar(GameProgress progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF0F172A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatBox('TENTATIVES', '${progress.totalAttemptsCount}', const Color(0xFF94A3B8)),
          _buildStatBox('RÉPONSES JUSTES', '${progress.totalCorrectAnswersCount}', const Color(0xFF34D399)),
          _buildStatBox('ERREURS', '${progress.totalIncorrectAnswersCount}', const Color(0xFFF87171)),
          _buildStatBox('MAÎTRISÉES', '${progress.questionsMasteredCount} / 30', const Color(0xFF38BDF8)),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildRevisionList(GameProgress progress) {
    final queue = progress.revisionQueue;

    if (queue.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 64),
              const SizedBox(height: 14),
              Text(
                'Aucune question en attente de révision !',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toutes les questions abordées ont été répondues correctement ou sont déjà maîtrisées. Continuez à explorer les mondes !',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: queue.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final qId = queue[index];
        final q = allGastroQuestions.firstWhere((item) => item.id == qId);
        final attempts = progress.questionAttempts[qId] ?? 1;
        final wrongs = progress.questionIncorrectCount[qId] ?? 1;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF131D2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F1D1D),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PDF Question ${q.originalNumber}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFCA5A5),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '$attempts tentative(s) • $wrongs erreur(s)',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                q.questionText,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thème : ${q.anatomicalTheme}',
                style: GoogleFonts.inter(
                  color: const Color(0xFF38BDF8),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                  label: Text(
                    'Rejouer dans l\'Arcade',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () => _startRevisionArcadeRun(qId),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMasteredList(GameProgress progress) {
    final mastered = progress.masteredQuestions.toList();

    if (mastered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.military_tech_outlined, color: Color(0xFF64748B), size: 64),
              const SizedBox(height: 14),
              Text(
                'Pas encore de questions maîtrisées',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Répondez correctement aux questions au sein des niveaux ou des sessions de révision pour les marquer comme maîtrisées.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: mastered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final qId = mastered[index];
        final q = allGastroQuestions.firstWhere((item) => item.id == qId);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1E1B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.45)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF064E3B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded, color: Color(0xFF34D399), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PDF Question ${q.originalNumber} • ${q.anatomicalTheme}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34D399),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      q.questionText,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
