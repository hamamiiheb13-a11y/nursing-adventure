import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../arcade/gastro_arcade_screen.dart';
import '../audio/audio_service.dart';
import '../models/game_progress.dart';
import '../models/gastro_question.dart';
import '../services/storage_service.dart';
import '../theme/capsule_theme.dart';
import '../widgets/capsule_parallax_background.dart';
import 'capsule_warriors_final_screen.dart';

/// Special Revision Stage unlocked once all 7 original stages are completed:
/// Reviews ONLY questions the current player answered incorrectly during Stages 1–7,
/// or displays a congratulatory completion screen when 0 mistakes occurred.
class CapsuleWarriorsRevisionStageScreen extends StatefulWidget {
  final int revisionNumber;
  final GameProgress progress;
  final VoidCallback? onCompletedCycle;

  const CapsuleWarriorsRevisionStageScreen({
    super.key,
    this.revisionNumber = 1,
    required this.progress,
    this.onCompletedCycle,
  });

  @override
  State<CapsuleWarriorsRevisionStageScreen> createState() =>
      _CapsuleWarriorsRevisionStageScreenState();
}

class _CapsuleWarriorsRevisionStageScreenState
    extends State<CapsuleWarriorsRevisionStageScreen> {
  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();
  late List<GastroQuestion> _mistakeQuestions;

  int get _cycleStartStage => (widget.revisionNumber - 1) * 7 + 1;
  int get _cycleEndStage => widget.revisionNumber * 7;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _loadMistakes();
  }

  void _loadMistakes() {
    final ids = widget.progress.getMistakesForCycle(widget.revisionNumber);
    _mistakeQuestions = ids
        .map(
          (id) => allGastroQuestions.firstWhere(
            (q) => q.id == id,
            orElse: () => allGastroQuestions.first,
          ),
        )
        .toList();
  }

  void _launchArcadeRevision({required bool isBonus}) {
    _audio.playClick();
    _storage.saveProgress(widget.progress);
    Navigator.of(context)
        .push(
          buildCapsuleRoute(
            GastroArcadeScreen(
              stageId: _cycleEndStage,
              revisionNumber: widget.revisionNumber,
              isBonusRevisionChallenge: isBonus,
              progress: widget.progress,
            ),
          ),
        )
        .then((_) {
      if (mounted) {
        setState(() {
          _loadMistakes();
        });
        if (widget.progress.isRevisionStageCompleted(widget.revisionNumber)) {
          widget.onCompletedCycle?.call();
          Navigator.of(context).pop(true);
        }
      }
    });
  }

  Future<void> _completeCleanSweepAndFinish() async {
    _audio.playVictory();
    widget.progress.completeRevisionStage(
      revisionNumber: 1,
      score: 600,
      stars: 3,
      correctCount: 0,
      totalCount: 0,
      isBonusChallenge: false,
      questionIdsAsked: const [],
    );
    await _storage.saveProgress(widget.progress);
    widget.onCompletedCycle?.call();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        buildCapsuleRoute(
          CapsuleWarriorsFinalScreen(progress: widget.progress),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isCompact = media.size.height < 540 || media.size.width < 600;
    final hasMistakes = _mistakeQuestions.isNotEmpty;
    final prevResult = widget.progress.revisionStageResults[widget.revisionNumber];

    return Scaffold(
      backgroundColor: CapsuleColors.deepOcean,
      body: CapsuleParallaxBackground(
        showHeroCapsule: false,
        showEnemySilhouettes: true,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 14 : 28,
                vertical: isCompact ? 10 : 20,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Container(
                  padding: EdgeInsets.all(isCompact ? 16 : 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CapsuleColors.oceanSurface.withValues(alpha: 0.96),
                        CapsuleColors.cardOcean.withValues(alpha: 0.94),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: hasMistakes
                          ? CapsuleColors.gold
                          : CapsuleColors.mintGreen,
                      width: 1.8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Row: Back + Cycle Badge
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              _audio.playClick();
                              Navigator.of(context).pop(false);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: CapsuleColors.deepOcean.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: CapsuleColors.cardBorder),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back_rounded,
                                      color: CapsuleColors.cyanGlow, size: 16),
                                  SizedBox(width: 5),
                                  Text(
                                    'CARTE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 11, vertical: 5),
                            decoration: BoxDecoration(
                              color: (hasMistakes
                                      ? CapsuleColors.gold
                                      : CapsuleColors.mintGreen)
                                  .withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: hasMistakes
                                    ? CapsuleColors.gold.withValues(alpha: 0.7)
                                    : CapsuleColors.mintGreen.withValues(alpha: 0.7),
                              ),
                            ),
                            child: Text(
                              'STAGE SPÉCIAL • STAGES $_cycleStartStage–$_cycleEndStage',
                              style: GoogleFonts.orbitron(
                                color: hasMistakes
                                    ? CapsuleColors.gold
                                    : CapsuleColors.mintGreen,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Hero Icon + Title
                      Icon(
                        hasMistakes
                            ? Icons.auto_stories_rounded
                            : Icons.workspace_premium_rounded,
                        color: hasMistakes
                            ? CapsuleColors.gold
                            : CapsuleColors.mintGreen,
                        size: isCompact ? 38 : 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'STAGE DE RÉVISION SPÉCIAL',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: isCompact ? 18 : 23,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),

                      if (hasMistakes) ...[
                        Text(
                          '${widget.progress.playerName}, vous avez ${_mistakeQuestions.length} notion(s) manquée(s) parmi les Stages $_cycleStartStage à $_cycleEndStage à consolider avant le diplôme.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: const Color(0xFFE2E8F0),
                            fontSize: 13.5,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CapsuleColors.deepOcean.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: CapsuleColors.gold.withValues(alpha: 0.45)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'QUESTIONS CIBLÉES EXCLUSIVEMENT (${_mistakeQuestions.length})',
                                style: GoogleFonts.plusJakartaSans(
                                  color: CapsuleColors.gold,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 7,
                                runSpacing: 7,
                                children: _mistakeQuestions.map((q) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: CapsuleColors.cardOcean,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: CapsuleColors.amberGold
                                              .withValues(alpha: 0.55)),
                                    ),
                                    child: Text(
                                      'Q${q.id} • ${q.anatomicalTheme}',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFFEF3C7),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: math.max(46.0, isCompact ? 46.0 : 52.0),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CapsuleColors.gold,
                              foregroundColor: CapsuleColors.deepOcean,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, size: 22),
                            label: Text(
                              'LANCER LE STAGE DE RÉVISION',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: isCompact ? 13 : 14.5,
                              ),
                            ),
                            onPressed: () =>
                                _launchArcadeRevision(isBonus: false),
                          ),
                        ),
                      ] else ...[
                        // ZERO MISTAKES PATH: Congratulatory Completion Screen + Diploma
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: CapsuleColors.mintGreen.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: CapsuleColors.mintGreen.withValues(alpha: 0.6)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'FÉLICITATIONS ! PARCOURS PARFAIT !',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.orbitron(
                                  color: CapsuleColors.mintGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Vous n\'avez commis aucune erreur durant les 7 stages originaux ! Aucune révision n\'est nécessaire : vos connaissances MICI sont parfaitement maîtrisées.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (prevResult != null && prevResult.completed) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Révision validée • Score : ${prevResult.score} PTS (${prevResult.correctCount}/${prevResult.totalCount})',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: CapsuleColors.cyanGlow,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final narrow = constraints.maxWidth < 460;
                            final diplomaBtn = ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CapsuleColors.mintGreen,
                                foregroundColor: CapsuleColors.deepOcean,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 13),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)),
                              ),
                              icon: const Icon(Icons.workspace_premium_rounded,
                                  size: 19),
                              label: Text(
                                'VOIR MON DIPLÔME FINAL',
                                style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w900, fontSize: 12.5),
                              ),
                              onPressed: _completeCleanSweepAndFinish,
                            );
                            final bonusBtn = OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: CapsuleColors.cyanGlow,
                                side: const BorderSide(
                                    color: CapsuleColors.cyanGlow, width: 1.6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 13),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)),
                              ),
                              icon: const Icon(Icons.bolt_rounded, size: 19),
                              label: Text(
                                'DÉFI BONUS',
                                style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w900, fontSize: 12.5),
                              ),
                              onPressed: () =>
                                  _launchArcadeRevision(isBonus: true),
                            );

                            if (narrow) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  diplomaBtn,
                                  const SizedBox(height: 10),
                                  bonusBtn,
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(flex: 3, child: diplomaBtn),
                                const SizedBox(width: 12),
                                Expanded(flex: 2, child: bonusBtn),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
