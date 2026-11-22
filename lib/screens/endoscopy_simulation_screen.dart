import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_progress.dart';
import '../models/gastro_question.dart';
import '../services/storage_service.dart';
import '../audio/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/tactile_button.dart';
import '../widgets/endoscopy_canvas_widget.dart';

class EndoscopySimulationScreen extends StatefulWidget {
  final GameProgress progress;

  const EndoscopySimulationScreen({
    super.key,
    required this.progress,
  });

  @override
  State<EndoscopySimulationScreen> createState() => _EndoscopySimulationScreenState();
}

class _EndoscopySimulationScreenState extends State<EndoscopySimulationScreen> {
  final AudioService _audio = AudioService();

  int _currentStepIndex = 0; // 0 to 3 (representing Q1 to Q4)
  int _inflammation = 100; // 100% -> 75% -> 50% -> 25% -> 0%
  int _bpm = 88;
  int _scoreXp = 0;
  int _correctCount = 0;

  bool _isTargetLocked = false;
  int? _selectedOptionIndex;
  bool? _isAnswerCorrect;
  bool _isServiceCompleted = false;

  late final List<GastroQuestion> _monde1Questions;

  @override
  void initState() {
    super.initState();
    // Retrieve strictly the 4 questions of Monde 1 (IDs 1, 2, 3, 4)
    _monde1Questions = allGastroQuestions.where((q) => q.worldId == 1).toList();
  }

  GastroQuestion get _currentQuestion => _monde1Questions[_currentStepIndex];

  String _getMentorContext() {
    switch (_currentStepIndex) {
      case 0:
        return 'Dr. Benali (Chef de service) : « Observez ce pertuis muqueux anormal. Quelle est votre analyse anatomopathologique ? »';
      case 1:
        return 'Dr. Benali : « Nous franchissons la valvule iléo-cæcale. Précisez la situation anatomique de ce segment. »';
      case 2:
        return 'Dr. Benali : « Nous explorons le cadre colique. Rappelez-vous la fonction physiologique majeure de ce segment. »';
      case 3:
      default:
        return 'Dr. Benali : « Admirez au fort grossissement ces millions de replis muqueux optimisant les échanges. »';
    }
  }

  void _onTargetLocked() {
    if (_isTargetLocked) return;
    _audio.playTargetLock();
    setState(() {
      _isTargetLocked = true;
    });
  }

  void _selectOption(int optionIndex) {
    if (_selectedOptionIndex != null) return; // already answered

    final bool isCorrect = optionIndex == _currentQuestion.correctOptionIndex;

    setState(() {
      _selectedOptionIndex = optionIndex;
      _isAnswerCorrect = isCorrect;

      if (isCorrect) {
        _audio.playCorrect();
        _correctCount++;
        _scoreXp += 100;
        // Inflammation reduction
        _inflammation = (_inflammation - 25).clamp(0, 100);
        _bpm = (_bpm - 4).clamp(72, 100);
      } else {
        _audio.playWrong();
        _scoreXp += 30; // learning XP
        _bpm = (_bpm + 6).clamp(72, 105);
      }
    });

    // Save progress in StorageService
    final int questionId = _currentQuestion.id;
    widget.progress.completeLevel(questionId, optionIndex, isCorrect);
    StorageService().saveProgress(widget.progress);
  }

  void _nextStep() {
    _audio.playClick();

    if (_currentStepIndex < _monde1Questions.length - 1) {
      setState(() {
        _currentStepIndex++;
        _isTargetLocked = false;
        _selectedOptionIndex = null;
        _isAnswerCorrect = null;
      });
    } else {
      // Completed all 4 steps!
      _audio.playVictory();
      setState(() {
        _isServiceCompleted = true;
        _inflammation = 0;
        _bpm = 72;
      });

      // Save tool unlock & ensure level 5 is unlocked
      if (widget.progress.currentUnlockedLevel < 5) {
        widget.progress.currentUnlockedLevel = 5;
      }
      widget.progress.unlockedBadges.add('Endoscope HD');
      StorageService().saveProgress(widget.progress);
    }
  }

  void _restartService() {
    _audio.playClick();
    setState(() {
      _currentStepIndex = 0;
      _inflammation = 100;
      _bpm = 88;
      _scoreXp = 0;
      _correctCount = 0;
      _isTargetLocked = false;
      _selectedOptionIndex = null;
      _isAnswerCorrect = null;
      _isServiceCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Clinical dark ambient theater for endoscopy
      body: SafeArea(
        child: _isServiceCompleted ? _buildCompletionView() : _buildSimulationView(),
      ),
    );
  }

  Widget _buildSimulationView() {
    final bool isSoundOn = _audio.bgmEnabled || _audio.sfxEnabled;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Column(
          children: [
            // Top Navigation & Stats Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Poste de garde',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Center Service + Step Pills
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF0D9488), width: 1.0),
                        ),
                        child: Text(
                          'ENDOSCOPIE • SERVICE 1/6',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF5EEAD4),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Étape ${_currentStepIndex + 1} / 4',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Sound toggle
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() {
                          _audio.toggleBgm();
                          _audio.toggleSfx();
                        });
                        _audio.playClick();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Icon(
                          isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          color: isSoundOn ? const Color(0xFF2DD4BF) : const Color(0xFF94A3B8),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area (Responsive Layout)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth >= 720;

                  if (isWide) {
                    // Desktop two-column layout
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left: Endoscopy Live Canvas Monitor
                          Expanded(
                            flex: 5,
                            child: EndoscopyCanvasWidget(
                              step: _currentStepIndex + 1,
                              inflammationPercentage: _inflammation,
                              bpm: _bpm,
                              isTargetLocked: _isTargetLocked,
                              isAnswerCorrect: _isAnswerCorrect,
                              onTargetLocked: _onTargetLocked,
                              height: double.infinity,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Right: Decision & QCM Zone
                          Expanded(
                            flex: 6,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: _buildDecisionCard(),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Mobile stacked vertical layout
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Endoscopy Live Canvas
                          EndoscopyCanvasWidget(
                            step: _currentStepIndex + 1,
                            inflammationPercentage: _inflammation,
                            bpm: _bpm,
                            isTargetLocked: _isTargetLocked,
                            isAnswerCorrect: _isAnswerCorrect,
                            onTargetLocked: _onTargetLocked,
                            height: 290,
                          ),
                          const SizedBox(height: 14),

                          // Decision & QCM Zone
                          _buildDecisionCard(),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecisionCard() {
    // If target not locked yet, show discovery prompt
    if (!_isTargetLocked) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.travel_explore_rounded, color: AppColors.primaryTeal, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPLORATION ENDOSCOPIQUE EN COURS',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primaryTeal,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Patient : Sami (24 ans)',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 16),

            // Mentor instruction
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                _getMentorContext(),
                style: GoogleFonts.inter(
                  color: const Color(0xFF334155),
                  fontSize: 13,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Instruction guidance card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_rounded, color: Color(0xFF16A34A), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Glissez votre doigt sur la caméra pour placer le réticule sur la lésion, ou cliquez sur « Ciblage auto ».',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF15803D),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Target is locked: Display clinical question & options
    final bool hasAnswered = _selectedOptionIndex != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: hasAnswered
              ? (_isAnswerCorrect! ? AppColors.successGreen : AppColors.alertCoral)
              : AppColors.border,
          width: 1.5,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mentor dialogue bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.record_voice_over_rounded, color: AppColors.accentCobalt, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getMentorContext(),
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Sacred question text from PDF
          Text(
            _currentQuestion.questionText,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textPrimary,
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // List of sacred options from PDF
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _currentQuestion.options.length,
            separatorBuilder: (context, _) => const SizedBox(height: 9),
            itemBuilder: (context, index) {
              final String optionText = _currentQuestion.options[index];
              final bool isSelected = _selectedOptionIndex == index;
              final bool isCorrect = index == _currentQuestion.correctOptionIndex;

              Color optionBg = const Color(0xFFF8FAFC);
              Color optionBorder = AppColors.border;
              Color textColor = AppColors.textPrimary;
              Widget? trailingIcon;

              if (hasAnswered) {
                if (isCorrect) {
                  optionBg = const Color(0xFFECFDF5);
                  optionBorder = const Color(0xFF10B981);
                  textColor = const Color(0xFF065F46);
                  trailingIcon = const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18);
                } else if (isSelected) {
                  optionBg = const Color(0xFFFFF1F2);
                  optionBorder = const Color(0xFFE11D48);
                  textColor = const Color(0xFF9F1239);
                  trailingIcon = const Icon(Icons.cancel_rounded, color: Color(0xFFE11D48), size: 18);
                }
              }

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: hasAnswered ? null : () => _selectOption(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: optionBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: optionBorder, width: isSelected || (hasAnswered && isCorrect) ? 1.8 : 1.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            optionText,
                            style: GoogleFonts.inter(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: isSelected || (hasAnswered && isCorrect) ? FontWeight.w700 : FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) ...[
                          const SizedBox(width: 8),
                          trailingIcon,
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Feedback & Explanation Card
          if (hasAnswered) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isAnswerCorrect! ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isAnswerCorrect! ? const Color(0xFFBBF7D0) : const Color(0xFFFED7AA),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isAnswerCorrect! ? Icons.verified_rounded : Icons.info_outline_rounded,
                        color: _isAnswerCorrect! ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isAnswerCorrect! ? 'DÉCISION CLINIQUE EXACTE (+100 XP)' : 'ANALYSE DU MÉDECIN RÉFÉRENT (+30 XP)',
                        style: GoogleFonts.plusJakartaSans(
                          color: _isAnswerCorrect! ? const Color(0xFF15803D) : const Color(0xFFB45309),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentQuestion.explanation,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF334155),
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Continue Button
            TactileButton(
              label: _currentStepIndex < _monde1Questions.length - 1
                  ? 'Explorer la zone suivante →'
                  : 'Clôturer l\'examen et stabiliser Sami →',
              subtitle: _isAnswerCorrect! ? 'Inflammation en baisse nette' : 'Correction appliquée',
              style: _isAnswerCorrect! ? TactileButtonStyle.primary : TactileButtonStyle.accent,
              height: 52,
              onPressed: _nextStep,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionView() {
    final double accuracy = (_correctCount / _monde1Questions.length) * 100.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Celebration badge
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF047857),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF34D399), width: 2.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x3310B981), blurRadius: 20, spreadRadius: 4),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 42),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'PATIENT STABILISÉ !',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF34D399),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sami (24 ans) • Inflammation maîtrisée (0%)',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFFE2E8F0),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // Summary Stats Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Précision', '${accuracy.toInt()}%', const Color(0xFF38BDF8)),
                    _buildStatCol('Décisions', '$_correctCount / ${_monde1Questions.length}', const Color(0xFF34D399)),
                    _buildStatCol('Score XP', '+$_scoreXp XP', const Color(0xFFFBBF24)),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Reward Card: Endoscope HD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF0F766E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2DD4BF), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x28000000), blurRadius: 16, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFF134E4A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF5EEAD4)),
                      ),
                      child: const Icon(Icons.camera_enhance_rounded, color: Color(0xFF5EEAD4), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'NOUVEL OUTIL GAGNÉ !',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFFDE68A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Endoscope HD',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Visualisation haute définition de la muqueuse digestive',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFCCFBF1),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Pager preview for Service 2
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF475569)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_rounded, color: Color(0xFFF59E0B), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROCHAINE GARDE : SERVICE 2 — URGENCES GASTRO',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFFBBF24),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Patiente : Nadia, 31 ans — Poussée active aiguë',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFE2E8F0),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Navigation Buttons
              TactileButton(
                label: 'Retour au Poste de Garde',
                style: TactileButtonStyle.primary,
                height: 54,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 10),
              TactileButton(
                label: 'Rejouer l\'Endoscopie',
                style: TactileButtonStyle.secondary,
                height: 48,
                onPressed: _restartService,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
