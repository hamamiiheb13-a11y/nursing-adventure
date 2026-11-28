import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../models/gastro_question.dart';
import '../theme/capsule_theme.dart';

class CheckpointQuestionDialog extends StatefulWidget {
  final GastroQuestion question;
  final int checkpointIndex;
  final bool isRevisionMode;
  final int? totalQuestionsInStage;
  final int playerHearts;
  final int playerMaxHearts;
  final double damageMultiplier;
  final Function(int selectedOptionIndex, bool isCorrect) onAnswerValidated;

  const CheckpointQuestionDialog({
    super.key,
    required this.question,
    required this.checkpointIndex,
    this.isRevisionMode = false,
    this.totalQuestionsInStage,
    this.playerHearts = 3,
    this.playerMaxHearts = 3,
    this.damageMultiplier = 1.0,
    required this.onAnswerValidated,
  });

  @override
  State<CheckpointQuestionDialog> createState() =>
      _CheckpointQuestionDialogState();
}

class _CheckpointQuestionDialogState extends State<CheckpointQuestionDialog>
    with TickerProviderStateMixin {
  static const int _comfortSecondsTotal = 90;

  int? _selectedIndex;
  bool _isValidated = false;
  int _secondsRemaining = _comfortSecondsTotal;
  Timer? _comfortTimer;

  late final AnimationController _enterController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final AnimationController _celebrationController;

  final ScrollController _questionScroll = ScrollController();
  final ScrollController _optionsScroll = ScrollController();
  final ScrollController _explanationScroll = ScrollController();
  final AudioService _audio = AudioService();

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scaleAnim = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic);
    _enterController.forward();

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _startComfortTimer();
  }

  void _startComfortTimer() {
    _comfortTimer?.cancel();
    _secondsRemaining = _comfortSecondsTotal;
    _comfortTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isValidated) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void didUpdateWidget(covariant CheckpointQuestionDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id ||
        oldWidget.checkpointIndex != widget.checkpointIndex) {
      _selectedIndex = null;
      _isValidated = false;
      _celebrationController.reset();
      _enterController.forward(from: 0.0);
      _startComfortTimer();
    }
  }

  @override
  void dispose() {
    _comfortTimer?.cancel();
    _enterController.dispose();
    _celebrationController.dispose();
    _questionScroll.dispose();
    _optionsScroll.dispose();
    _explanationScroll.dispose();
    super.dispose();
  }

  void _onValidate() {
    if (_selectedIndex == null || _isValidated) return;
    _comfortTimer?.cancel();
    final bool isCorrect = _selectedIndex == widget.question.correctOptionIndex;
    if (isCorrect) {
      _audio.playCorrect();
      _celebrationController.repeat();
    } else {
      _audio.playWrong();
    }
    _audio.playExplanationOpen();

    setState(() {
      _isValidated = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_explanationScroll.hasClients) {
        _explanationScroll.jumpTo(0.0);
      }
    });
  }

  void _selectOptionByKey(int index) {
    if (_isValidated || index < 0 || index >= widget.question.options.length) return;
    _audio.playOptionSelect();
    setState(() => _selectedIndex = index);
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
    final bool isCorrect =
        _isValidated && _selectedIndex == q.correctOptionIndex;
    final media = MediaQuery.of(context);
    final bool isLandscape =
        media.size.width > media.size.height && media.size.width > 560;
    final bool isCompact = media.size.height < 440;

    final Color frameBorder = _isValidated
        ? (isCorrect ? CapsuleColors.mintGreen : CapsuleColors.coral)
        : (widget.isRevisionMode ? CapsuleColors.gold : CapsuleColors.cyanGlow);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1): () => _selectOptionByKey(0),
        const SingleActivator(LogicalKeyboardKey.digit2): () => _selectOptionByKey(1),
        const SingleActivator(LogicalKeyboardKey.digit3): () => _selectOptionByKey(2),
        const SingleActivator(LogicalKeyboardKey.digit4): () => _selectOptionByKey(3),
        const SingleActivator(LogicalKeyboardKey.enter): () {
          if (_isValidated) {
            _onContinue();
          } else {
            _onValidate();
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Container(
              color: CapsuleColors.deepOcean.withValues(alpha: 0.62),
              child: SafeArea(
                child: Center(
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: isLandscape
                          ? math.min(media.size.width * 0.96, 980)
                          : math.min(media.size.width * 0.96, 600),
                      constraints: BoxConstraints(
                        maxHeight: isLandscape
                            ? math.min(media.size.height * 0.94, 590)
                            : media.size.height * 0.92,
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: isCompact ? 10 : 18,
                        vertical: isCompact ? 5 : 12,
                      ),
                      decoration: BoxDecoration(
                        // Palette océanique bioluminescente intégrée au jeu (aucun fond blanc)
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.isRevisionMode
                              ? const [
                                  Color(0xFF103F70),
                                  Color(0xFF1A578F),
                                  Color(0xFF113966),
                                ]
                              : const [
                                  Color(0xFF10497A),
                                  Color(0xFF155B94),
                                  Color(0xFF0E4170),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: frameBorder, width: 2.4),
                        boxShadow: [
                          BoxShadow(
                            color: frameBorder.withValues(alpha: 0.34),
                            blurRadius: 28,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: const Color(0xFF062542).withValues(alpha: 0.45),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.97, end: 1.0).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _isValidated
                        ? _buildCentralExplanationWindow(
                            q,
                            isCorrect,
                            isLandscape,
                            isCompact,
                          )
                        : _buildQuestionSelectionView(
                            q,
                            isLandscape,
                            isCompact,
                          ),
                  ),
                ),
              ),
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
  // PHASE A : QUESTION INTÉGRÉE AU JEU (OCÉAN LUMINEUX + TEMPS CONFORTABLE)
  // ===========================================================================
  Widget _buildQuestionSelectionView(
    GastroQuestion q,
    bool isLandscape,
    bool isCompact,
  ) {
    final topHeaderBar = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 14 : 20,
        vertical: isCompact ? 7 : 11,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B365C), CapsuleColors.oceanSurface],
        ),
        border: Border(
          bottom: BorderSide(
            color: CapsuleColors.cyanGlow.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: _buildQuestionHeader(q, isCompact),
    );

    final questionPanel = Container(
      padding: EdgeInsets.all(isCompact ? 13 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF175E96),
            Color(0xFF134B7A),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CapsuleColors.cyanGlow.withValues(alpha: 0.48),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CapsuleColors.cyanGlow.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 4.5,
                height: 18,
                decoration: BoxDecoration(
                  color: CapsuleColors.cyanGlow,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'QUESTION CLINIQUE',
                style: GoogleFonts.plusJakartaSans(
                  color: CapsuleColors.cyanGlow,
                  fontSize: isCompact ? 10.5 : 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.85,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 8 : 11),
          Text(
            q.questionText,
            style: GoogleFonts.plusJakartaSans(
              color: CapsuleColors.textWhite,
              fontSize: isCompact ? 15.8 : 19.0,
              fontWeight: FontWeight.w800,
              height: 1.42,
            ),
          ),
        ],
      ),
    );

    final validateBtn = _GastroActionButton(
      label: 'Valider ma réponse',
      icon: Icons.check_circle_rounded,
      height: isCompact ? 40 : 54,
      onPressed: _selectedIndex != null ? _onValidate : null,
    );

    if (isLandscape) {
      return Column(
        key: const ValueKey('question_phase_landscape'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          topHeaderBar,
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 8 : 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Gauche (44%) : Grande carte question lisible
                    Expanded(
                      flex: 44,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Scrollbar(
                              controller: _questionScroll,
                              thumbVisibility: false,
                              child: SingleChildScrollView(
                                controller: _questionScroll,
                                physics: const BouncingScrollPhysics(),
                                child: questionPanel,
                              ),
                            ),
                          ),
                          SizedBox(height: isCompact ? 5 : 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.touch_app_rounded,
                                color: CapsuleColors.cyanGlow,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Choisissez une proposition puis validez.',
                                  style: GoogleFonts.inter(
                                    color: CapsuleColors.textSubtle,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  SizedBox(width: isCompact ? 10 : 18),

                  // Droite (56%) : Belles cartes de réponses + Valider en bas
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
                                  (index) => _staggerOption(
                                    index,
                                    _InteractiveOptionCard(
                                      letter: String.fromCharCode(65 + index),
                                      text: q.options[index],
                                      isSelected: _selectedIndex == index,
                                      isCompact: isCompact,
                                      onTap: () {
                                        _audio.playOptionSelect();
                                        setState(() => _selectedIndex = index);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isCompact ? 5 : 12),
                        validateBtn,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Portrait Layout (téléphone vertical)
    return Column(
      key: const ValueKey('question_phase_portrait'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        topHeaderBar,
        Flexible(
          child: SingleChildScrollView(
            controller: _questionScroll,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                questionPanel,
                const SizedBox(height: 14),
                ...List.generate(
                  q.options.length,
                  (index) => _staggerOption(
                    index,
                    _InteractiveOptionCard(
                      letter: String.fromCharCode(65 + index),
                      text: q.options[index],
                      isSelected: _selectedIndex == index,
                      isCompact: false,
                      onTap: () {
                        _audio.playOptionSelect();
                        setState(() => _selectedIndex = index);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: validateBtn,
        ),
      ],
    );
  }

  // ===========================================================================
  // PHASE B : GRANDE FENÊTRE CENTRALE « COMPRENDRE LA RÉPONSE »
  // ===========================================================================
  Widget _buildCentralExplanationWindow(
    GastroQuestion q,
    bool isCorrect,
    bool isLandscape,
    bool isCompact,
  ) {
    final Color resultColor =
        isCorrect ? CapsuleColors.mintGreen : CapsuleColors.coral;
    final String resultLabel =
        isCorrect ? 'Bonne réponse' : 'Réponse incorrecte';
    final String bonusLabel = isCorrect
        ? '+100 XP • +30% Puissance d\'arme'
        : '+35 XP • Progression conservée';

    // En-tête lumineux avec titre clair « Comprendre la réponse » + animation célébration
    final headerBanner = Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 14 : 20,
            vertical: isCompact ? 10 : 13,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCorrect
                  ? const [Color(0xFF0D7A6E), Color(0xFF10B981)]
                  : const [Color(0xFF0B365C), CapsuleColors.oceanSurface],
            ),
            border: Border(
              bottom: BorderSide(
                color: resultColor.withValues(alpha: 0.45),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCorrect ? Icons.celebration_rounded : Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Comprendre la réponse',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: isCompact ? 15.5 : 18.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Q${q.originalNumber} • ${q.anatomicalTheme}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.90),
                        fontSize: isCompact ? 10.8 : 11.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CapsuleColors.deepOcean,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: resultColor, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: resultColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.info_rounded,
                      color: resultColor,
                      size: 17,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      resultLabel,
                      style: GoogleFonts.plusJakartaSans(
                        color: resultColor,
                        fontSize: isCompact ? 11.8 : 12.8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isCorrect)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _celebrationController,
                builder: (context, _) => CustomPaint(
                  painter: _HeaderRewardSparklePainter(
                    t: _celebrationController.value,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    final String chosenText = (_selectedIndex != null &&
            _selectedIndex! >= 0 &&
            _selectedIndex! < q.options.length)
        ? q.options[_selectedIndex!]
        : '';

    final exactAnswerBox = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 15,
        vertical: isCompact ? 9 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0B4F4A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CapsuleColors.mintGreen, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCorrect && chosenText.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.close_rounded,
                  color: CapsuleColors.coral,
                  size: 17,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Votre choix : $chosenText',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFFE4E6),
                      fontSize: isCompact ? 12.2 : 13.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.verified_rounded,
                  color: CapsuleColors.mintGreen,
                  size: 19,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RÉPONSE EXACTE',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF6EE7B7),
                        fontSize: 10.2,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      q.correctOptionText,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFECFDF5),
                        fontSize: isCompact ? 13.2 : 14.8,
                        fontWeight: FontWeight.w800,
                        height: 1.32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final diagramCard = _ClinicalMiniDiagram(
      diagramType: q.diagramType,
      accent: resultColor,
      isCompact: isCompact,
      isCelebration: isCorrect,
      tallMode: isLandscape,
    );

    final scientificExplanationCard = Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF134A78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CapsuleColors.cyanGlow.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: CapsuleColors.cyanGlow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science_rounded,
                color: CapsuleColors.cyanGlow,
                size: 17,
              ),
              const SizedBox(width: 7),
              Text(
                'EXPLICATION SCIENTIFIQUE',
                style: GoogleFonts.plusJakartaSans(
                  color: CapsuleColors.cyanGlow,
                  fontSize: 10.8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            q.explanation,
            style: GoogleFonts.inter(
              color: CapsuleColors.textWhite,
              fontSize: isCompact ? 13.4 : 15.0,
              fontWeight: FontWeight.w500,
              height: 1.48,
            ),
          ),
        ],
      ),
    );

    final scientificBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        exactAnswerBox,
        SizedBox(height: isCompact ? 9 : 12),
        scientificExplanationCard,
        if (q.fichePoints.isNotEmpty) ...[
          SizedBox(height: isCompact ? 9 : 12),
          Container(
            padding: EdgeInsets.all(isCompact ? 11 : 13),
            decoration: BoxDecoration(
              color: const Color(0xFF104E75),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: CapsuleColors.turquoise.withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      color: CapsuleColors.turquoise,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'À RETENIR : ${q.ficheTitle.toUpperCase()}',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF99F6E4),
                          fontSize: 10.8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...q.fichePoints.map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: CapsuleColors.mintGreen,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: GoogleFonts.inter(
                              color: CapsuleColors.textWhite,
                              fontSize: isCompact ? 12.2 : 13.2,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
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
        if (q.whyOthersWrong.isNotEmpty) ...[
          SizedBox(height: isCompact ? 9 : 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF3E3019),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: CapsuleColors.gold.withValues(alpha: 0.55),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POURQUOI LES AUTRES CHOIX NE CONVIENNENT PAS',
                  style: GoogleFonts.plusJakartaSans(
                    color: CapsuleColors.gold,
                    fontSize: 10.2,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  q.whyOthersWrong,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFEF3C7),
                    fontSize: isCompact ? 12.2 : 13.2,
                    fontWeight: FontWeight.w500,
                    height: 1.38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    final continueButton = _GastroActionButton(
      label: 'Poursuivre la mission',
      icon: Icons.play_arrow_rounded,
      height: isCompact ? 42 : 54,
      onPressed: _onContinue,
    );

    return Column(
      key: const ValueKey('explanation_phase'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        headerBanner,
        Flexible(
          child: isLandscape
              ? Padding(
                  padding: EdgeInsets.all(isCompact ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Colonne Gauche (35%) : Illustration médicale animée + Récompense
                            Expanded(
                              flex: 35,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: diagramCard),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CapsuleColors.deepOcean,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: resultColor.withValues(alpha: 0.55),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCorrect
                                              ? Icons.bolt_rounded
                                              : Icons.healing_rounded,
                                          color: resultColor,
                                          size: 17,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            bonusLabel,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: CapsuleColors.textWhite,
                                              fontSize: isCompact ? 10.5 : 11.5,
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
                            // Colonne Droite (65%) : Explication centrée immédiatement lisible (démarre toujours à 0.0)
                            Expanded(
                              flex: 65,
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
                          ],
                        ),
                      ),
                      SizedBox(height: isCompact ? 8 : 12),
                      continueButton,
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        controller: _explanationScroll,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            diagramCard,
                            const SizedBox(height: 11),
                            scientificBody,
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 6, 15, 15),
                      child: continueButton,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _staggerOption(int index, Widget child) {
    final start = (index * 0.12).clamp(0.0, 0.55);
    final end = (start + 0.45).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _enterController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0.0),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  Widget _buildQuestionHeader(GastroQuestion q, bool isCompact) {
    final badgeAccent =
        widget.isRevisionMode ? CapsuleColors.gold : CapsuleColors.cyanGlow;
    final bool hasTimeLeft = _secondsRemaining > 0;
    final Color timerColor = _secondsRemaining > 25
        ? CapsuleColors.mintGreen
        : (hasTimeLeft ? CapsuleColors.gold : CapsuleColors.cyanGlow);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
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
                      color: badgeAccent.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: badgeAccent.withValues(alpha: 0.80)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isRevisionMode
                              ? Icons.replay_rounded
                              : Icons.radar_rounded,
                          color: badgeAccent,
                          size: isCompact ? 13 : 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.isRevisionMode
                              ? 'RÉVISION #${widget.checkpointIndex}'
                              : (widget.totalQuestionsInStage != null
                                  ? 'CHECKPOINT ${widget.checkpointIndex}/${widget.totalQuestionsInStage}'
                                  : 'CHECKPOINT #${widget.checkpointIndex}'),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: isCompact ? 10.5 : 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Integrated live mission telemetry pills (keeps HUD info visible!)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: CapsuleColors.deepOcean.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CapsuleColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_rounded, color: CapsuleColors.coral, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          '${widget.playerHearts}/${widget.playerMaxHearts}',
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 9.8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.bolt_rounded, color: CapsuleColors.gold, size: 12),
                        Text(
                          'x${widget.damageMultiplier.toStringAsFixed(1)}',
                          style: GoogleFonts.orbitron(
                            color: CapsuleColors.gold,
                            fontSize: 9.8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CapsuleColors.cardOcean,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: CapsuleColors.cyanGlow.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      'Q${q.originalNumber}',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: isCompact ? 10 : 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    q.anatomicalTheme,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF99F6E4),
                      fontSize: isCompact ? 11.0 : 12.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Indicateur de temps généreux (90s de confort, sans jamais pénaliser ni couper la lecture)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 9 : 11,
                vertical: isCompact ? 4 : 5,
              ),
              decoration: BoxDecoration(
                color: timerColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: timerColor.withValues(alpha: 0.72)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasTimeLeft ? Icons.timer_rounded : Icons.all_inclusive_rounded,
                    color: timerColor,
                    size: isCompact ? 13 : 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    hasTimeLeft ? '${_secondsRemaining}s' : 'Temps libre',
                    style: GoogleFonts.orbitron(
                      color: timerColor,
                      fontSize: isCompact ? 10.2 : 11.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: hasTimeLeft
                ? (_secondsRemaining / _comfortSecondsTotal).clamp(0.0, 1.0)
                : 1.0,
            minHeight: 3.2,
            backgroundColor: CapsuleColors.deepOcean,
            valueColor: AlwaysStoppedAnimation<Color>(timerColor),
          ),
        ),
      ],
    );
  }
}

class _GastroActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final double height;
  final VoidCallback? onPressed;

  const _GastroActionButton({
    required this.label,
    required this.icon,
    required this.height,
    required this.onPressed,
  });

  @override
  State<_GastroActionButton> createState() => _GastroActionButtonState();
}

class _GastroActionButtonState extends State<_GastroActionButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    final double scale = _pressed && enabled ? 0.98 : (_hovered && enabled ? 1.012 : 1.0);

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 110),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
            onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
            onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: enabled
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF22D3EE), Color(0xFF14B8A6)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF1A4F7A), Color(0xFF144269)],
                      ),
                border: Border.all(
                  color: enabled
                      ? const Color(0xFFA5F3FC)
                      : CapsuleColors.cyanGlow.withValues(alpha: 0.25),
                  width: enabled ? 1.8 : 1.2,
                ),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: CapsuleColors.cyanGlow.withValues(alpha: _hovered ? 0.45 : 0.28),
                          blurRadius: _hovered ? 18 : 12,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 20,
                    color: enabled ? CapsuleColors.deepOcean : CapsuleColors.textMuted,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    widget.label,
                    style: GoogleFonts.plusJakartaSans(
                      color: enabled ? CapsuleColors.deepOcean : CapsuleColors.textMuted,
                      fontSize: widget.height < 45 ? 13.5 : 15.2,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InteractiveOptionCard extends StatefulWidget {
  final String letter;
  final String text;
  final bool isSelected;
  final bool isCompact;
  final VoidCallback onTap;

  const _InteractiveOptionCard({
    required this.letter,
    required this.text,
    required this.isSelected,
    required this.isCompact,
    required this.onTap,
  });

  @override
  State<_InteractiveOptionCard> createState() => _InteractiveOptionCardState();
}

class _InteractiveOptionCardState extends State<_InteractiveOptionCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed
        ? 0.985
        : (widget.isSelected ? 1.012 : (_hovered ? 1.008 : 1.0));

    final List<Color> bgGradient = widget.isSelected
        ? const [Color(0xFF0EA5E9), Color(0xFF0284C7)]
        : (_hovered
            ? const [Color(0xFF1D67A3), Color(0xFF16578C)]
            : const [Color(0xFF155387), Color(0xFF124673)]);

    final Color borderColor = widget.isSelected
        ? const Color(0xFF5EEAD4)
        : (_hovered
            ? CapsuleColors.cyanGlow
            : CapsuleColors.cyanGlow.withValues(alpha: 0.35));

    return Padding(
      padding: EdgeInsets.only(bottom: widget.isCompact ? 4.0 : 10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOut,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isCompact ? 11 : 15,
                  vertical: widget.isCompact ? 5.2 : 13.0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: bgGradient,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor,
                    width: widget.isSelected ? 2.1 : 1.25,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isSelected
                          ? CapsuleColors.cyanGlow.withValues(alpha: 0.30)
                          : const Color(0xFF072947).withValues(alpha: 0.25),
                      blurRadius: widget.isSelected ? 12 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: widget.isCompact ? 23 : 30,
                      height: widget.isCompact ? 23 : 30,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? CapsuleColors.gold
                            : CapsuleColors.deepOcean,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 1.4),
                      ),
                      child: Center(
                        child: Text(
                          widget.letter,
                          style: GoogleFonts.plusJakartaSans(
                            color: widget.isSelected
                                ? CapsuleColors.deepOcean
                                : Colors.white,
                            fontSize: widget.isCompact ? 10.8 : 13.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.text,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: widget.isCompact ? 12.6 : 15.2,
                          fontWeight: widget.isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          height: widget.isCompact ? 1.22 : 1.34,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      widget.isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_off_rounded,
                      color: widget.isSelected
                          ? const Color(0xFF5EEAD4)
                          : CapsuleColors.cyanGlow.withValues(alpha: 0.55),
                      size: widget.isCompact ? 19 : 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderRewardSparklePainter extends CustomPainter {
  final double t;
  const _HeaderRewardSparklePainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      final frac = (t + i * 0.13) % 1.0;
      final x = size.width * (0.1 + (i * 0.11));
      final y = size.height * (0.8 - frac * 0.65);
      final alpha = math.sin(frac * math.pi) * 0.45;
      p.color = Colors.white.withValues(alpha: alpha.clamp(0.0, 0.5));
      canvas.drawCircle(Offset(x, y), 2.2 + (i % 2) * 1.2, p);
    }
  }

  @override
  bool shouldRepaint(covariant _HeaderRewardSparklePainter oldDelegate) =>
      oldDelegate.t != t;
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
      height: widget.tallMode ? null : (widget.isCompact ? 82 : 102),
      constraints: widget.tallMode ? const BoxConstraints(minHeight: 108) : null,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CapsuleColors.deepOcean, CapsuleColors.oceanSurface],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CapsuleColors.cyanGlow.withValues(alpha: 0.65),
          width: 1.4,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
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
            top: 8,
            left: 11,
            right: 11,
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
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
                      color: const Color(0xFFE0F7FA),
                      fontSize: 9.8,
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
    final cy = h * 0.58;
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);

    final gridPaint = Paint()
      ..color = CapsuleColors.cyanGlow.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (double x = 24; x < w; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 24; y < h; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    if (isCelebration) {
      canvas.drawCircle(
        Offset(w * 0.5, cy),
        18.0 + pulse * 26.0,
        Paint()
          ..color = const Color(0xFF34D399).withValues(alpha: (1.0 - pulse) * 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }

    final linePaint = Paint()
      ..color = const Color(0xFF67E8F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    switch (diagramType) {
      case 'fistula_stenosis':
        canvas.drawLine(Offset(w * 0.10, cy - 14), Offset(w * 0.42, cy - 14), linePaint);
        canvas.drawLine(Offset(w * 0.10, cy + 14), Offset(w * 0.42, cy + 14), linePaint);
        fillPaint.color = accent.withValues(alpha: 0.55 + 0.35 * pulse);
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
        canvas.drawPath(villi, linePaint..color = const Color(0xFF6EE7B7));
        fillPaint.color = const Color(0xFFFDE047);
        for (int i = 0; i < 4; i++) {
          final dx = w * (0.20 + i * 0.18);
          final dy = cy - 10 - ((t * 16 + i * 5) % 16);
          canvas.drawCircle(Offset(dx, dy), 3.0, fillPaint);
        }
        break;

      case 'colon_water':
        final colon = Path()
          ..moveTo(w * 0.16, cy + 18)
          ..lineTo(w * 0.16, cy - 10)
          ..quadraticBezierTo(w * 0.5, cy - 20, w * 0.84, cy - 10)
          ..lineTo(w * 0.84, cy + 18);
        canvas.drawPath(colon, linePaint..strokeWidth = 3.6);
        fillPaint.color = const Color(0xFF38BDF8);
        for (int i = 0; i < 4; i++) {
          final hx = w * (0.28 + i * 0.15);
          final hy = cy - 6 + pulse * 12;
          canvas.drawCircle(Offset(hx, hy), 3.4, fillPaint);
        }
        break;

      case 'ileum_valve':
        canvas.drawLine(Offset(w * 0.10, cy), Offset(w * 0.48, cy), linePaint..strokeWidth = 3.2);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(w * 0.68, cy), width: w * 0.30, height: 32),
          linePaint,
        );
        fillPaint.color = const Color(0xFFFBBF24).withValues(alpha: 0.80 + 0.20 * pulse);
        canvas.drawCircle(Offset(w * (0.15 + 0.33 * t), cy), 4.6, fillPaint);
        break;

      case 'systemic_mici':
        final center = Offset(w * 0.5, cy);
        canvas.drawCircle(center, 15, linePaint..color = const Color(0xFF5EEAD4));
        for (int i = 0; i < 3; i++) {
          final a = -math.pi * 0.85 + i * math.pi * 0.85;
          final node = center + Offset(math.cos(a) * 34, math.sin(a) * 24);
          canvas.drawLine(
            center,
            node,
            Paint()
              ..color = accent.withValues(alpha: 0.65 + 0.30 * pulse)
              ..strokeWidth = 1.8,
          );
          fillPaint.color = i == 0 ? const Color(0xFFFBBF24) : const Color(0xFF67E8F9);
          canvas.drawCircle(node, 5.2 + pulse * 1.5, fillPaint);
        }
        break;

      case 'biotherapy_tnf':
        final abPaint = Paint()
          ..color = const Color(0xFF67E8F9)
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round;
        for (int i = 0; i < 3; i++) {
          final ax = w * (0.22 + i * 0.28);
          final ay = cy + 8 - pulse * 6;
          canvas.drawLine(Offset(ax, ay + 9), Offset(ax, ay), abPaint);
          canvas.drawLine(Offset(ax, ay), Offset(ax - 8, ay - 8), abPaint);
          canvas.drawLine(Offset(ax, ay), Offset(ax + 8, ay - 8), abPaint);
          fillPaint.color = const Color(0xFFFBBF24);
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
        canvas.drawPath(wave, linePaint..color = const Color(0xFF6EE7B7));
        break;

      case 'pregnancy_care':
        final c = Offset(w * 0.5, cy);
        canvas.drawCircle(
          c,
          22 + pulse * 4,
          linePaint..color = const Color(0xFF6EE7B7).withValues(alpha: 0.85),
        );
        fillPaint.color = const Color(0xFF38BDF8).withValues(alpha: 0.30);
        canvas.drawCircle(c, 18, fillPaint);
        fillPaint.color = const Color(0xFFFDE047);
        canvas.drawCircle(c + const Offset(0, -2), 7.5 + pulse * 1.5, fillPaint);
        break;

      case 'breastfeeding_mici':
        final dropCenter = Offset(w * 0.42, cy + 4);
        final dropPath = Path()
          ..moveTo(dropCenter.dx, dropCenter.dy - 17)
          ..quadraticBezierTo(dropCenter.dx + 14, dropCenter.dy, dropCenter.dx, dropCenter.dy + 13)
          ..quadraticBezierTo(dropCenter.dx - 14, dropCenter.dy, dropCenter.dx, dropCenter.dy - 17);
        fillPaint.color = Colors.white.withValues(alpha: 0.92);
        canvas.drawPath(dropPath, fillPaint);
        canvas.drawPath(dropPath, linePaint..color = const Color(0xFF67E8F9));
        final shX = w * 0.64;
        canvas.drawCircle(
          Offset(shX, cy),
          14 + pulse * 3,
          Paint()
            ..color = const Color(0xFF6EE7B7).withValues(alpha: 0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
        canvas.drawCircle(Offset(shX, cy), 4.8, Paint()..color = const Color(0xFF6EE7B7));
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
        canvas.drawPath(p1, linePaint..color = const Color(0xFF67E8F9));
        canvas.drawPath(p2, linePaint..color = const Color(0xFF6EE7B7));
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ClinicalDiagramPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.diagramType != diagramType ||
      oldDelegate.isCelebration != isCelebration;
}
