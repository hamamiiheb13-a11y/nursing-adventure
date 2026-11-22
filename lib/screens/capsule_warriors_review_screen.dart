import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../models/game_progress.dart';
import '../models/gastro_question.dart';
import '../models/gastro_world.dart';
import '../services/storage_service.dart';
import '../theme/capsule_theme.dart';
import '../widgets/capsule_parallax_background.dart';

class CapsuleWarriorsReviewScreen extends StatefulWidget {
  final GameProgress? progress;

  const CapsuleWarriorsReviewScreen({
    super.key,
    this.progress,
  });

  @override
  State<CapsuleWarriorsReviewScreen> createState() =>
      _CapsuleWarriorsReviewScreenState();
}

class _CapsuleWarriorsReviewScreenState
    extends State<CapsuleWarriorsReviewScreen> {
  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();
  late GameProgress _progress;

  String _filter = 'ALL'; // 'ALL', 'CORRECT', 'TO_REVIEW'
  int _selectedWorldFilter = 0; // 0 = all

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _progress = widget.progress ?? _storage.currentProgress;
  }

  List<GastroQuestion> get _filteredQuestions {
    return allGastroQuestions.where((q) {
      if (_selectedWorldFilter != 0 && q.worldId != _selectedWorldFilter) {
        return false;
      }
      final isAnswered = _progress.questionsAnswered.containsKey(q.id);
      final isCorrect = _progress.questionsAnswered[q.id] == true;
      final inRevision = _progress.revisionQueue.contains(q.id) ||
          (_progress.questionsAnswered.containsKey(q.id) && !isCorrect);

      if (_filter == 'CORRECT') {
        return isAnswered && isCorrect;
      } else if (_filter == 'TO_REVIEW') {
        return inRevision;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isCompact = media.size.height < 520;

    int correctCount = 0;
    for (final isCorrect in _progress.questionsAnswered.values) {
      if (isCorrect) correctCount++;
    }
    final masteredCount = correctCount > 0 ? correctCount : _progress.masteredQuestions.length;
    final revisionCount = _progress.revisionQueue.length;
    final questions = _filteredQuestions;

    return Scaffold(
      backgroundColor: CapsuleColors.darkNavy,
      body: CapsuleParallaxBackground(
        showHeroCapsule: false,
        showEnemySilhouettes: false,
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar: RETOUR button + Title + Progress Header (X mastered, Y to review)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _audio.playClick();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back_rounded, color: CapsuleColors.cyanGlow, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'RETOUR',
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'RÉVISION DES 33 QUESTIONS CLINIQUES',
                      style: GoogleFonts.orbitron(
                        fontSize: isCompact ? 13 : 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    // Progress Header: X mastered, Y to review
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: CapsuleColors.successGreen, size: 15),
                          const SizedBox(width: 5),
                          Text(
                            '$masteredCount maîtrisées',
                            style: GoogleFonts.orbitron(
                              color: CapsuleColors.successGreen,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.warning_amber_rounded, color: CapsuleColors.dangerOrange, size: 15),
                          const SizedBox(width: 5),
                          Text(
                            '$revisionCount à réviser',
                            style: GoogleFonts.orbitron(
                              color: CapsuleColors.dangerOrange,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Filter Bar (ALL / CORRECT / TO REVIEW + Stage filter chips)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  border: Border(
                    top: BorderSide(color: Color(0xFF1E293B)),
                    bottom: BorderSide(color: Color(0xFF1E293B)),
                  ),
                ),
                child: Row(
                  children: [
                    // Filter Mode
                    _buildFilterButton('ALL', 'TOUTES (33)', Icons.list_alt_rounded),
                    const SizedBox(width: 8),
                    _buildFilterButton('CORRECT', 'CORRECTES ($masteredCount)', Icons.check_circle_outline_rounded, activeColor: CapsuleColors.successGreen),
                    const SizedBox(width: 8),
                    _buildFilterButton('TO_REVIEW', 'À RÉVISER ($revisionCount)', Icons.replay_rounded, activeColor: CapsuleColors.dangerOrange),

                    const Spacer(),

                    // Stage Selector Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedWorldFilter,
                          dropdownColor: const Color(0xFF0F172A),
                          isDense: true,
                          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          items: [
                            const DropdownMenuItem(value: 0, child: Text('Tous les Stages')),
                            ...GastroWorld.worlds.map((w) => DropdownMenuItem(value: w.id, child: Text('Stage ${w.id}'))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedWorldFilter = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Question List with Expandable Clinical Explanation
              Expanded(
                child: questions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off_rounded, color: CapsuleColors.textSubtle, size: 40),
                            const SizedBox(height: 10),
                            Text(
                              'Aucune question pour ce filtre.',
                              style: GoogleFonts.inter(color: CapsuleColors.textSubtle, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        itemCount: questions.length,
                        itemBuilder: (context, idx) {
                          final q = questions[idx];
                          return _buildQuestionTile(q);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String key, String label, IconData icon, {Color? activeColor}) {
    final isSelected = _filter == key;
    final color = activeColor ?? CapsuleColors.cyanGlow;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _filter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : const Color(0xFF334155)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : CapsuleColors.textSubtle, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.orbitron(
                color: isSelected ? Colors.white : CapsuleColors.textSubtle,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTile(GastroQuestion q) {
    final hasAnswered = _progress.questionsAnswered.containsKey(q.id);
    final isCorrect = _progress.questionsAnswered[q.id] == true;
    final studentSelectedIdx = _progress.userAnswers[q.id];

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (!hasAnswered) {
      statusColor = const Color(0xFF64748B);
      statusText = 'NON TENTÉE';
      statusIcon = Icons.help_outline_rounded;
    } else if (isCorrect) {
      statusColor = CapsuleColors.successGreen;
      statusText = 'CORRECT';
      statusIcon = Icons.check_circle_rounded;
    } else {
      statusColor = CapsuleColors.dangerRed;
      statusText = 'ERREUR';
      statusIcon = Icons.cancel_rounded;
    }

    final world = GastroWorld.getWorldForLevel(q.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: hasAnswered ? 0.6 : 0.25),
          width: hasAnswered ? 1.5 : 1.0,
        ),
        boxShadow: hasAnswered
            ? [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: world.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q${q.id} • STAGE ${q.worldId}',
                  style: GoogleFonts.orbitron(
                    color: world.primaryColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  q.anatomicalTheme,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: CapsuleColors.textSubtle,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.orbitron(
                    color: statusColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              q.questionText,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFF1E293B)),
                  const SizedBox(height: 6),

                  // Options list showing student selection vs correct option
                  ...List.generate(q.options.length, (optIdx) {
                    final isOptionCorrect = optIdx == q.correctOptionIndex;
                    final isStudentSelected = optIdx == studentSelectedIdx;

                    Color optBg = const Color(0xFF1E293B).withValues(alpha: 0.5);
                    Color optBorder = const Color(0xFF334155);

                    if (isOptionCorrect) {
                      optBg = CapsuleColors.successGreen.withValues(alpha: 0.15);
                      optBorder = CapsuleColors.successGreen;
                    } else if (isStudentSelected && !isOptionCorrect) {
                      optBg = CapsuleColors.dangerRed.withValues(alpha: 0.15);
                      optBorder = CapsuleColors.dangerRed;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: optBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: optBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isOptionCorrect
                                ? Icons.check_circle_rounded
                                : (isStudentSelected ? Icons.cancel_rounded : Icons.radio_button_unchecked_rounded),
                            color: isOptionCorrect
                                ? CapsuleColors.successGreen
                                : (isStudentSelected ? CapsuleColors.dangerRed : const Color(0xFF64748B)),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              q.options[optIdx],
                              style: GoogleFonts.inter(
                                color: isOptionCorrect ? Colors.white : const Color(0xFFCBD5E1),
                                fontSize: 12,
                                fontWeight: isOptionCorrect ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isOptionCorrect)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: CapsuleColors.successGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'BONNE RÉPONSE',
                                style: GoogleFonts.orbitron(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900),
                              ),
                            ),
                          if (isStudentSelected && !isOptionCorrect)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: CapsuleColors.dangerRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'VOTRE RÉPONSE',
                                style: GoogleFonts.orbitron(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 10),

                  // Expandable Clinical Explanation Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CapsuleColors.electricBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CapsuleColors.electricBlue.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: CapsuleColors.cyanGlow, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EXPLICATION CLINIQUE OFFICIELLE (PFE ISSIT) :',
                                style: GoogleFonts.orbitron(
                                  color: CapsuleColors.cyanGlow,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                q.explanation,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFE2E8F0),
                                  fontSize: 11.5,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
