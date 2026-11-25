import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../models/gastro_question.dart';
import '../theme/capsule_theme.dart';
import '../widgets/tactile_button.dart';

class CheckpointQuestionDialog extends StatefulWidget {
  final GastroQuestion question;
  final int checkpointIndex;
  final bool isRevisionMode;
  final Function(int selectedOptionIndex, bool isCorrect) onAnswerValidated;

  const CheckpointQuestionDialog({
    super.key,
    required this.question,
    required this.checkpointIndex,
    this.isRevisionMode = false,
    required this.onAnswerValidated,
  });

  @override
  State<CheckpointQuestionDialog> createState() => _CheckpointQuestionDialogState();
}

class _CheckpointQuestionDialogState extends State<CheckpointQuestionDialog>
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  bool _isValidated = false;

  late final AnimationController _enterController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  final ScrollController _questionScroll = ScrollController();
  final ScrollController _optionsScroll = ScrollController();
  final ScrollController _explanationScroll = ScrollController();
  final AudioService _audio = AudioService();

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _scaleAnim = Tween<double>(begin: 0.93, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(parent: _enterController, curve: Curves.easeOut);
    _enterController.forward();
  }

  @override
  void didUpdateWidget(covariant CheckpointQuestionDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id ||
        oldWidget.checkpointIndex != widget.checkpointIndex) {
      _selectedIndex = null;
      _isValidated = false;
      _enterController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _enterController.dispose();
    _questionScroll.dispose();
    _optionsScroll.dispose();
    _explanationScroll.dispose();
    super.dispose();
  }

  void _onValidate() {
    if (_selectedIndex == null || _isValidated) return;
    final bool isCorrect = _selectedIndex == widget.question.correctOptionIndex;
    if (isCorrect) {
      _audio.playCorrect();
    } else {
      _audio.playWrong();
    }
    _audio.playExplanationOpen();
    setState(() {
      _isValidated = true;
    });
  }

  void _onContinue() {
    if (_selectedIndex == null) return;
    _audio.playClick();
    final bool isCorrect = _selectedIndex == widget.question.correctOptionIndex;
    widget.onAnswerValidated(_selectedIndex!, isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final bool isCorrect = _isValidated && _selectedIndex == q.correctOptionIndex;
    final media = MediaQuery.of(context);
    final bool isLandscape = media.size.width > media.size.height && media.size.width > 560;
    final bool isCompact = media.size.height < 430;

    final Color borderColor = _isValidated
        ? (isCorrect ? const Color(0xFF35D39A) : const Color(0xFFF16D78))
        : const Color(0xFF20D5E8).withValues(alpha: 0.72);

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          color: const Color(0xFF071629).withValues(alpha: 0.84),
          child: SafeArea(
            child: Center(
              child: Container(
                width: isLandscape
                    ? math.min(media.size.width * 0.94, 940)
                    : math.min(media.size.width * 0.94, 560),
                constraints: BoxConstraints(
                  maxHeight: isLandscape
                      ? math.min(media.size.height * 0.94, 560)
                      : media.size.height * 0.90,
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: isCompact ? 10 : 18,
                  vertical: isCompact ? 6 : 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0B2540),
                      Color(0xFF071629),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor, width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.22),
                      blurRadius: 28,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.96, end: 1.0).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _isValidated
                        ? _buildCentralExplanationWindow(q, isCorrect, isLandscape, isCompact)
                        : _buildQuestionSelectionView(q, isLandscape, isCompact),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PHASE A : QUESTION ÉPURÉE & PROPOSITIONS (AVANT VALIDATION)
  // ===========================================================================
  Widget _buildQuestionSelectionView(
    GastroQuestion q,
    bool isLandscape,
    bool isCompact,
  ) {
    final validateBtn = TactileButton(
      label: 'Valider ma réponse',
      icon: Icons.check_circle_rounded,
      style: TactileButtonStyle.primary,
      height: isCompact ? 42 : 48,
      onPressed: _selectedIndex != null ? _onValidate : null,
    );

    if (isLandscape) {
      return Padding(
        key: const ValueKey('question_phase_landscape'),
        padding: EdgeInsets.all(isCompact ? 14 : 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colonne Gauche (44%) : Badge + Question très lisible (sans explication)
            Expanded(
              flex: 44,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionHeader(q, isCompact),
                  SizedBox(height: isCompact ? 10 : 14),
                  Expanded(
                    child: Scrollbar(
                      controller: _questionScroll,
                      thumbVisibility: false,
                      child: SingleChildScrollView(
                        controller: _questionScroll,
                        physics: const BouncingScrollPhysics(),
                        child: Container(
                          padding: EdgeInsets.all(isCompact ? 12 : 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF123B5A).withValues(alpha: 0.42),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF20D5E8).withValues(alpha: 0.30),
                            ),
                          ),
                          child: Text(
                            q.questionText,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFF4F8FC),
                              fontSize: isCompact ? 14.5 : 17.5,
                              fontWeight: FontWeight.w700,
                              height: 1.40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.touch_app_rounded,
                        color: Color(0xFF20C9B0),
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Sélectionnez une réponse pour débloquer l\'explication.',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFA9BACB),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: isCompact ? 12 : 18),
            Container(width: 1, color: CapsuleColors.cardBorder),
            SizedBox(width: isCompact ? 12 : 18),

            // Colonne Droite (56%) : Propositions bien espacées + Bouton Valider fixé en bas
            Expanded(
              flex: 56,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Scrollbar(
                      controller: _optionsScroll,
                      thumbVisibility: q.options.length > 4,
                      child: SingleChildScrollView(
                        controller: _optionsScroll,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(right: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List.generate(
                            q.options.length,
                            (index) => _buildOptionTile(q, index, isCompact),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isCompact ? 8 : 12),
                  validateBtn,
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Portrait Layout
    return SingleChildScrollView(
      key: const ValueKey('question_phase_portrait'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuestionHeader(q, true),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF123B5A).withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF20D5E8).withValues(alpha: 0.30),
              ),
            ),
            child: Text(
              q.questionText,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFF4F8FC),
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                height: 1.38,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(q.options.length, (index) => _buildOptionTile(q, index, false)),
          const SizedBox(height: 10),
          validateBtn,
        ],
      ),
    );
  }

  // ===========================================================================
  // PHASE B : FENÊTRE CENTRALE « EXPLICATION PÉDAGOGIQUE » (APRÈS VALIDATION)
  // ===========================================================================
  Widget _buildCentralExplanationWindow(
    GastroQuestion q,
    bool isCorrect,
    bool isLandscape,
    bool isCompact,
  ) {
    final Color resultAccent = isCorrect ? const Color(0xFF35D39A) : const Color(0xFFF16D78);
    final String resultLabel = isCorrect ? 'Bonne réponse' : 'Réponse incorrecte';
    final String bonusLabel = isCorrect
        ? '+100 XP • +30% PUISSANCE D\'ARME'
        : '+35 XP • PROGRESSION CONSERVÉE';

    final topBanner = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 16,
        vertical: isCompact ? 8 : 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF123B5A).withValues(alpha: 0.55),
        border: Border(
          bottom: BorderSide(
            color: resultAccent.withValues(alpha: 0.40),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF20D5E8).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF20D5E8).withValues(alpha: 0.50)),
            ),
            child: const Icon(
              Icons.biotech_rounded,
              color: Color(0xFF20D5E8),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EXPLICATION PÉDAGOGIQUE',
                  style: GoogleFonts.orbitron(
                    color: const Color(0xFF20D5E8),
                    fontSize: isCompact ? 12.5 : 14.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  'Q${q.originalNumber} • ${q.anatomicalTheme}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF20C9B0),
                    fontSize: isCompact ? 10.5 : 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: resultAccent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: resultAccent, width: 1.4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: resultAccent,
                  size: 17,
                ),
                const SizedBox(width: 6),
                Text(
                  resultLabel,
                  style: GoogleFonts.plusJakartaSans(
                    color: resultAccent,
                    fontSize: isCompact ? 11.5 : 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final exactAnswerBox = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 11 : 14,
        vertical: isCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF35D39A).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF35D39A).withValues(alpha: 0.65), width: 1.3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.verified_rounded, color: Color(0xFF35D39A), size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BONNE RÉPONSE EXACTE',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF35D39A),
                    fontSize: 9.8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  q.correctOptionText,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFF4F8FC),
                    fontSize: isCompact ? 12.2 : 13.5,
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

    final diagramCard = _ClinicalMiniDiagram(
      diagramType: q.diagramType,
      accent: resultAccent,
      isCompact: isCompact,
      isCelebration: isCorrect,
      tallMode: isLandscape,
    );

    final scientificBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        exactAnswerBox,
        SizedBox(height: isCompact ? 9 : 12),
        Text(
          q.explanation,
          style: GoogleFonts.inter(
            color: const Color(0xFFF4F8FC),
            fontSize: isCompact ? 12.5 : 13.8,
            fontWeight: FontWeight.w500,
            height: 1.46,
          ),
        ),
        if (q.whyOthersWrong.isNotEmpty) ...[
          SizedBox(height: isCompact ? 9 : 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB547).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFFFFB547).withValues(alpha: 0.45)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POURQUOI LES AUTRES CHOIX NE CONVIENNENT PAS',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFFB547),
                    fontSize: 9.8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  q.whyOthersWrong,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFF4F8FC),
                    fontSize: isCompact ? 11.4 : 12.2,
                    height: 1.36,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (q.fichePoints.isNotEmpty) ...[
          SizedBox(height: isCompact ? 9 : 12),
          Container(
            padding: EdgeInsets.all(isCompact ? 9 : 11),
            decoration: BoxDecoration(
              color: const Color(0xFF071629).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFF20D5E8).withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school_rounded, color: Color(0xFF20D5E8), size: 15),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'À RETENIR : ${q.ficheTitle.toUpperCase()}',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF20D5E8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ...q.fichePoints.map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: Color(0xFF35D39A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFA9BACB),
                              fontSize: isCompact ? 11.2 : 12.0,
                              height: 1.34,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    final continueButton = TactileButton(
      label: 'CONTINUER LA MISSION',
      icon: Icons.play_arrow_rounded,
      style: TactileButtonStyle.primary,
      height: isCompact ? 42 : 48,
      onPressed: _onContinue,
    );

    return Column(
      key: const ValueKey('explanation_phase'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        topBanner,
        Flexible(
          child: isLandscape
              ? Padding(
                  padding: EdgeInsets.all(isCompact ? 12 : 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Colonne Gauche (38%) : Illustration médicale animée + Récompense
                      Expanded(
                        flex: 38,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: diagramCard),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: resultAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: resultAccent.withValues(alpha: 0.45),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isCorrect ? Icons.bolt_rounded : Icons.healing_rounded,
                                    color: resultAccent,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      bonusLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: resultAccent,
                                        fontSize: isCompact ? 10.0 : 11.0,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: isCompact ? 12 : 16),
                      Container(width: 1, color: CapsuleColors.cardBorder),
                      SizedBox(width: isCompact ? 12 : 16),
                      // Colonne Droite (62%) : Explication scientifique claire et défilable
                      Expanded(
                        flex: 62,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Scrollbar(
                                controller: _explanationScroll,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  controller: _explanationScroll,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.only(right: 6),
                                  child: scientificBody,
                                ),
                              ),
                            ),
                            SizedBox(height: isCompact ? 8 : 12),
                            continueButton,
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  controller: _explanationScroll,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      diagramCard,
                      const SizedBox(height: 10),
                      scientificBody,
                      const SizedBox(height: 14),
                      continueButton,
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildQuestionHeader(GastroQuestion q, bool isCompact) {
    final badgeAccent = widget.isRevisionMode
        ? const Color(0xFFFFB547)
        : const Color(0xFF20D5E8);
    return Wrap(
      spacing: 8,
      runSpacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 9 : 11,
            vertical: isCompact ? 4 : 5,
          ),
          decoration: BoxDecoration(
            color: badgeAccent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: badgeAccent.withValues(alpha: 0.65)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isRevisionMode ? Icons.replay_rounded : Icons.radar_rounded,
                color: badgeAccent,
                size: isCompact ? 13 : 15,
              ),
              const SizedBox(width: 5),
              Text(
                widget.isRevisionMode
                    ? 'RÉVISION #${widget.checkpointIndex}'
                    : 'CHECKPOINT #${widget.checkpointIndex}',
                style: GoogleFonts.plusJakartaSans(
                  color: badgeAccent,
                  fontSize: isCompact ? 10.5 : 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF123B5A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Q${q.originalNumber}',
            style: GoogleFonts.orbitron(
              color: const Color(0xFFF4F8FC),
              fontSize: isCompact ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          q.anatomicalTheme,
          style: GoogleFonts.inter(
            color: const Color(0xFF20C9B0),
            fontSize: isCompact ? 11.0 : 12.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(GastroQuestion q, int index, bool isCompact) {
    final option = q.options[index];
    final bool isSelected = _selectedIndex == index;

    final Color cardBg = isSelected
        ? const Color(0xFF20D5E8).withValues(alpha: 0.22)
        : const Color(0xFF123B5A).withValues(alpha: 0.68);
    final Color borderColor = isSelected
        ? const Color(0xFF20D5E8)
        : const Color(0xFF20D5E8).withValues(alpha: 0.25);
    final Color badgeBg = isSelected ? const Color(0xFF20D5E8) : const Color(0xFF071629);

    return Padding(
      padding: EdgeInsets.only(bottom: isCompact ? 6 : 9),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () {
          _audio.playClick();
          setState(() => _selectedIndex = index);
        },
        child: AnimatedScale(
          scale: isSelected ? 1.01 : 1.0,
          duration: const Duration(milliseconds: 140),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 11 : 14,
              vertical: isCompact ? 8 : 11,
            ),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.9 : 1.1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF20D5E8).withValues(alpha: 0.22),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: isCompact ? 23 : 26,
                  height: isCompact ? 23 : 26,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: GoogleFonts.inter(
                        color: isSelected
                            ? const Color(0xFF071629)
                            : const Color(0xFFF4F8FC),
                        fontSize: isCompact ? 10.5 : 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    option,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFF4F8FC),
                      fontSize: isCompact ? 12.2 : 13.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      height: 1.28,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected
                      ? const Color(0xFF20D5E8)
                      : const Color(0xFFA9BACB).withValues(alpha: 0.65),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClinicalMiniDiagram extends StatefulWidget {
  final String diagramType;
  final Color accent;
  final bool isCompact;
  final bool isCelebration;
  final bool tallMode;

  const _ClinicalMiniDiagram({
    required this.diagramType,
    required this.accent,
    required this.isCompact,
    required this.isCelebration,
    this.tallMode = false,
  });

  @override
  State<_ClinicalMiniDiagram> createState() => _ClinicalMiniDiagramState();
}

class _ClinicalMiniDiagramState extends State<_ClinicalMiniDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String label = switch (widget.diagramType) {
      'fistula_stenosis' => 'SCHÉMA • FISTULE VS STÉNOSE',
      'villi_absorption' => 'SCHÉMA • VILLOSITÉS INTESTINALES',
      'colon_water' => 'SCHÉMA • RÉABSORPTION COLIQUE (H₂O)',
      'ileum_valve' => 'SCHÉMA • ILÉON TERMINAL & VALVULE',
      'systemic_mici' => 'SCHÉMA • ATTEINTE SYSTÉMIQUE MICI',
      'biotherapy_tnf' => 'SCHÉMA • ACTION ANTI-TNF & OBSERVANCE',
      'biomarker_labs' => 'SCHÉMA • BIOLOGIE & DÉPISTAGE COLIQUE',
      'pregnancy_genetics' => 'SCHÉMA • SUSCEPTIBILITÉ GÉNÉTIQUE',
      'pregnancy_care' => 'SCHÉMA • GROSSESSE EN RÉMISSION',
      'breastfeeding_mici' => 'SCHÉMA • ALLAITEMENT SÉCURISÉ',
      'emergency_nursing' => 'SCHÉMA • SURVEILLANCE INFIRMIÈRE',
      _ => 'SCHÉMA • REPÈRE ANATOMIQUE',
    };

    return Container(
      height: widget.tallMode ? null : (widget.isCompact ? 76 : 96),
      constraints: widget.tallMode ? const BoxConstraints(minHeight: 96) : null,
      decoration: BoxDecoration(
        color: const Color(0xFF071629).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF20D5E8).withValues(alpha: 0.40)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, _) => CustomPaint(
                  painter: _ClinicalDiagramPainter(
                    diagramType: widget.diagramType,
                    t: _pulseCtrl.value,
                    accent: widget.accent,
                    isCelebration: widget.isCelebration,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 7,
            left: 10,
            right: 10,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accent,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF20D5E8),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
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
}

class _ClinicalDiagramPainter extends CustomPainter {
  final String diagramType;
  final double t;
  final Color accent;
  final bool isCelebration;

  const _ClinicalDiagramPainter({
    required this.diagramType,
    required this.t,
    required this.accent,
    required this.isCelebration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h * 0.57;
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);

    final gridPaint = Paint()
      ..color = const Color(0xFF20D5E8).withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (double x = 24; x < w; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 24; y < h; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Subtle celebration shimmer rings on correct answer
    if (isCelebration) {
      canvas.drawCircle(
        Offset(w * 0.5, cy),
        18.0 + pulse * 26.0,
        Paint()
          ..color = const Color(0xFF35D39A).withValues(alpha: (1.0 - pulse) * 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    final linePaint = Paint()
      ..color = const Color(0xFF20D5E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    switch (diagramType) {
      case 'fistula_stenosis':
        canvas.drawLine(Offset(w * 0.10, cy - 14), Offset(w * 0.42, cy - 14), linePaint);
        canvas.drawLine(Offset(w * 0.10, cy + 14), Offset(w * 0.42, cy + 14), linePaint);
        fillPaint.color = accent.withValues(alpha: 0.45 + 0.35 * pulse);
        canvas.drawRect(Rect.fromLTWH(w * 0.23, cy - 14, 10, 28), fillPaint);
        final pinch = 4.0 + pulse * 2.5;
        final topPath = Path()
          ..moveTo(w * 0.55, cy - 16)
          ..quadraticBezierTo(w * 0.72, cy - pinch, w * 0.90, cy - 16);
        final botPath = Path()
          ..moveTo(w * 0.55, cy + 16)
          ..quadraticBezierTo(w * 0.72, cy + pinch, w * 0.90, cy + 16);
        canvas.drawPath(topPath, linePaint);
        canvas.drawPath(botPath, linePaint);
        break;

      case 'villi_absorption':
        final villi = Path()..moveTo(w * 0.08, cy + 18);
        for (int i = 0; i < 6; i++) {
          final bx = w * (0.14 + i * 0.13);
          final tipY = cy - 12 - 4 * math.sin(t * math.pi * 2 + i);
          villi.quadraticBezierTo(bx, tipY, bx + w * 0.065, cy + 18);
        }
        canvas.drawPath(villi, linePaint..color = const Color(0xFF35D39A));
        fillPaint.color = const Color(0xFF20D5E8);
        for (int i = 0; i < 4; i++) {
          final dx = w * (0.20 + i * 0.18);
          final dy = cy - 10 - ((t * 16 + i * 5) % 16);
          canvas.drawCircle(Offset(dx, dy), 2.8, fillPaint);
        }
        break;

      case 'colon_water':
        final colon = Path()
          ..moveTo(w * 0.16, cy + 18)
          ..lineTo(w * 0.16, cy - 10)
          ..quadraticBezierTo(w * 0.5, cy - 20, w * 0.84, cy - 10)
          ..lineTo(w * 0.84, cy + 18);
        canvas.drawPath(colon, linePaint..strokeWidth = 3.5);
        fillPaint.color = const Color(0xFF20D5E8).withValues(alpha: 0.85);
        for (int i = 0; i < 4; i++) {
          final hx = w * (0.28 + i * 0.15);
          final hy = cy - 6 + pulse * 12;
          canvas.drawCircle(Offset(hx, hy), 3.3, fillPaint);
        }
        break;

      case 'ileum_valve':
        canvas.drawLine(Offset(w * 0.10, cy), Offset(w * 0.48, cy), linePaint..strokeWidth = 3.2);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(w * 0.68, cy), width: w * 0.30, height: 32),
          linePaint,
        );
        fillPaint.color = const Color(0xFFFFB547).withValues(alpha: 0.75 + 0.25 * pulse);
        canvas.drawCircle(Offset(w * (0.15 + 0.33 * t), cy), 4.5, fillPaint);
        break;

      case 'systemic_mici':
        // Central digestive core connected to systemic joints/eyes/skin nodes
        final center = Offset(w * 0.5, cy);
        canvas.drawCircle(center, 15, linePaint..color = const Color(0xFF20C9B0));
        for (int i = 0; i < 3; i++) {
          final a = -math.pi * 0.85 + i * math.pi * 0.85;
          final node = center + Offset(math.cos(a) * 34, math.sin(a) * 24);
          canvas.drawLine(
            center,
            node,
            Paint()
              ..color = accent.withValues(alpha: 0.55 + 0.35 * pulse)
              ..strokeWidth = 1.6,
          );
          fillPaint.color = i == 0 ? const Color(0xFFFFB547) : const Color(0xFF20D5E8);
          canvas.drawCircle(node, 5.0 + pulse * 1.5, fillPaint);
        }
        break;

      case 'biotherapy_tnf':
        final abPaint = Paint()
          ..color = const Color(0xFF20D5E8)
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round;
        for (int i = 0; i < 3; i++) {
          final ax = w * (0.22 + i * 0.28);
          final ay = cy + 8 - pulse * 6;
          canvas.drawLine(Offset(ax, ay + 9), Offset(ax, ay), abPaint);
          canvas.drawLine(Offset(ax, ay), Offset(ax - 8, ay - 8), abPaint);
          canvas.drawLine(Offset(ax, ay), Offset(ax + 8, ay - 8), abPaint);
          fillPaint.color = accent.withValues(alpha: 0.90);
          canvas.drawCircle(Offset(ax, ay - 11), 3.8, fillPaint);
        }
        break;

      case 'biomarker_labs':
      case 'emergency_nursing':
        final wave = Path()..moveTo(w * 0.08, cy);
        for (double x = w * 0.08; x <= w * 0.92; x += 4) {
          final norm = (x - w * 0.08) / (w * 0.84);
          final spike = (norm - t).abs() < 0.06
              ? -16 * math.sin(((norm - t) / 0.06) * math.pi)
              : 0.0;
          wave.lineTo(x, cy + spike);
        }
        canvas.drawPath(wave, linePaint..color = accent);
        break;

      case 'pregnancy_care':
        // Protective maternal shield cradling calm fetal remission core
        final c = Offset(w * 0.5, cy);
        canvas.drawCircle(
          c,
          22 + pulse * 4,
          linePaint..color = const Color(0xFF35D39A).withValues(alpha: 0.75),
        );
        fillPaint.color = const Color(0xFF20D5E8).withValues(alpha: 0.26);
        canvas.drawCircle(c, 18, fillPaint);
        fillPaint.color = const Color(0xFFFFB547).withValues(alpha: 0.85);
        canvas.drawCircle(c + const Offset(0, -2), 7.5 + pulse * 1.5, fillPaint);
        break;

      case 'breastfeeding_mici':
        // Gentle droplet & neonatal green protective shield aura
        final dropCenter = Offset(w * 0.42, cy + 4);
        final dropPath = Path()
          ..moveTo(dropCenter.dx, dropCenter.dy - 17)
          ..quadraticBezierTo(dropCenter.dx + 14, dropCenter.dy, dropCenter.dx, dropCenter.dy + 13)
          ..quadraticBezierTo(dropCenter.dx - 14, dropCenter.dy, dropCenter.dx, dropCenter.dy - 17);
        fillPaint.color = const Color(0xFFF4F8FC).withValues(alpha: 0.88);
        canvas.drawPath(dropPath, fillPaint);
        canvas.drawPath(dropPath, linePaint..color = const Color(0xFF20D5E8));
        // Protective check shield on right
        final shX = w * 0.64;
        canvas.drawCircle(
          Offset(shX, cy),
          14 + pulse * 3,
          Paint()
            ..color = const Color(0xFF35D39A).withValues(alpha: 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2,
        );
        canvas.drawCircle(Offset(shX, cy), 4.5, Paint()..color = const Color(0xFF35D39A));
        break;

      case 'pregnancy_genetics':
      default:
        final p1 = Path();
        final p2 = Path();
        for (double x = w * 0.12; x <= w * 0.88; x += 6) {
          final phase = (x / w) * math.pi * 4 + t * math.pi * 2;
          final y1 = cy + math.sin(phase) * 10;
          final y2 = cy - math.sin(phase) * 10;
          if (x == w * 0.12) {
            p1.moveTo(x, y1);
            p2.moveTo(x, y2);
          } else {
            p1.lineTo(x, y1);
            p2.lineTo(x, y2);
          }
        }
        canvas.drawPath(p1, linePaint..color = const Color(0xFF20D5E8));
        canvas.drawPath(p2, linePaint..color = const Color(0xFF35D39A));
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ClinicalDiagramPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.diagramType != diagramType ||
      oldDelegate.isCelebration != isCelebration;
}
