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

    final totalQuestions = allGastroQuestions.length;
    return Scaffold(
      backgroundColor: CapsuleColors.deepOcean,
      body: CapsuleParallaxBackground(
        showHeroCapsule: false,
        showEnemySilhouettes: false,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 680;
              return Column(
                children: [
                  // 1. Top Bar: RETOUR + Title + Progress Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 20, vertical: 10),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                _audio.playClick();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: CapsuleColors.oceanSurface.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.6)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.arrow_back_rounded, color: CapsuleColors.cyanGlow, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'RETOUR',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'FICHES & RÉVISION ($totalQuestions QUESTIONS)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: isCompact || isNarrow ? 13 : 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Progress Header: X mastered, Y to review
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: CapsuleColors.oceanSurface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: CapsuleColors.cardBorder),
                          ),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: CapsuleColors.successGreen, size: 15),
                                  const SizedBox(width: 5),
                                  Text(
                                    '$masteredCount maîtrisées',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: CapsuleColors.successGreen,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: CapsuleColors.dangerOrange, size: 15),
                                  const SizedBox(width: 5),
                                  Text(
                                    '$revisionCount à réviser',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: CapsuleColors.dangerOrange,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
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

                  // 2. Filter Bar (ALL / CORRECT / TO REVIEW + Stage dropdown)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: CapsuleColors.oceanSurface.withValues(alpha: 0.92),
                      border: Border(
                        top: BorderSide(color: CapsuleColors.cardBorder),
                        bottom: BorderSide(color: CapsuleColors.cardBorder),
                      ),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFilterButton('ALL', 'TOUTES ($totalQuestions)', Icons.list_alt_rounded),
                            _buildFilterButton('CORRECT', 'CORRECTES ($masteredCount)', Icons.check_circle_outline_rounded, activeColor: CapsuleColors.successGreen),
                            _buildFilterButton('TO_REVIEW', 'À RÉVISER ($revisionCount)', Icons.replay_rounded, activeColor: CapsuleColors.dangerOrange),
                          ],
                        ),
                        // Stage Selector Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: CapsuleColors.cardOcean,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: CapsuleColors.cardBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedWorldFilter,
                              dropdownColor: CapsuleColors.oceanSurface,
                              isDense: true,
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
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
                                  style: GoogleFonts.plusJakartaSans(color: CapsuleColors.textSubtle, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 24, vertical: 12),
                            itemCount: questions.length,
                            itemBuilder: (context, idx) {
                              final q = questions[idx];
                              return _buildQuestionTile(q);
                            },
                          ),
                  ),
                ],
              );
            },
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
          color: isSelected ? color.withValues(alpha: 0.22) : CapsuleColors.cardOcean,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : CapsuleColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : CapsuleColors.textSubtle, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? Colors.white : CapsuleColors.textSubtle,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: CapsuleColors.oceanSurface.withValues(alpha: 0.94),
        elevation: hasAnswered ? 3 : 1,
        shadowColor: hasAnswered ? statusColor.withValues(alpha: 0.25) : Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: statusColor.withValues(alpha: hasAnswered ? 0.65 : 0.35),
            width: hasAnswered ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
          title: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: world.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q${q.id} • STAGE ${q.worldId}',
                  style: GoogleFonts.plusJakartaSans(
                    color: world.primaryColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.plusJakartaSans(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                q.anatomicalTheme,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: CapsuleColors.textSubtle,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              q.questionText,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 13.5,
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
                  Divider(color: CapsuleColors.cardBorder),
                  const SizedBox(height: 6),

                  // Options list showing student selection vs correct option
                  ...List.generate(q.options.length, (optIdx) {
                    final isOptionCorrect = optIdx == q.correctOptionIndex;
                    final isStudentSelected = optIdx == studentSelectedIdx;

                    Color optBg = CapsuleColors.cardOcean.withValues(alpha: 0.65);
                    Color optBorder = CapsuleColors.cardBorder;

                    if (isOptionCorrect) {
                      optBg = CapsuleColors.successGreen.withValues(alpha: 0.16);
                      optBorder = CapsuleColors.successGreen;
                    } else if (isStudentSelected && !isOptionCorrect) {
                      optBg = CapsuleColors.dangerRed.withValues(alpha: 0.16);
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
                                : (isStudentSelected ? CapsuleColors.dangerRed : const Color(0xFF94A3B8)),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              q.options[optIdx],
                              style: GoogleFonts.plusJakartaSans(
                                color: isOptionCorrect ? Colors.white : const Color(0xFFE2E8F0),
                                fontSize: 12.5,
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
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
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
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
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
                      color: CapsuleColors.electricBlue.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.45)),
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
                                style: GoogleFonts.plusJakartaSans(
                                  color: CapsuleColors.cyanGlow,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                q.explanation,
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFF1F5F9),
                                  fontSize: 12,
                                  height: 1.45,
                                ),
                              ),
                              if (q.fichePoints.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ...q.fichePoints.map(
                                  (pt) => Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      '• $pt',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: CapsuleColors.mintGlow,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}
