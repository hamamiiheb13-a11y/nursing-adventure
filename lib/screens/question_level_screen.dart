import 'package:flutter/material.dart';
import '../models/gastro_question.dart';
import '../models/gastro_world.dart';
import '../models/game_progress.dart';
import '../services/storage_service.dart';
import '../audio/audio_service.dart';
import '../widgets/gastro_guide_avatar.dart';
import '../widgets/confetti_overlay.dart';
import 'victory_screen.dart';

class QuestionLevelScreen extends StatefulWidget {
  final int level; // 1 to 30
  final GameProgress progress;

  const QuestionLevelScreen({
    super.key,
    required this.level,
    required this.progress,
  });

  @override
  State<QuestionLevelScreen> createState() => _QuestionLevelScreenState();
}

class _QuestionLevelScreenState extends State<QuestionLevelScreen>
    with SingleTickerProviderStateMixin {
  late final GastroQuestion _question;
  late final GastroWorld _world;
  final AudioService _audio = AudioService();

  int? _selectedOptionIndex;
  bool _hasValidated = false;
  bool _isAnswerCorrect = false;
  bool _triggerConfetti = false;

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _question = allGastroQuestions[widget.level - 1];
    _world = GastroWorld.getWorldForLevel(widget.level);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    // If level was already completed previously, pre-select user's saved choice
    if (widget.progress.isLevelCompleted(widget.level)) {
      _selectedOptionIndex = widget.progress.userAnswers[widget.level];
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onOptionTap(int index) {
    if (_hasValidated) return; // Cannot change after validation
    _audio.playClick();
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _onValidate() {
    if (_selectedOptionIndex == null || _hasValidated) return;

    final isCorrect = _selectedOptionIndex == _question.correctOptionIndex;

    setState(() {
      _hasValidated = true;
      _isAnswerCorrect = isCorrect;
    });

    if (isCorrect) {
      _audio.playCorrect();
      setState(() {
        _triggerConfetti = true;
      });
    } else {
      _audio.playWrong();
    }

    // Save progress
    widget.progress.completeLevel(widget.level, _selectedOptionIndex!, isCorrect);
    StorageService().saveProgress(widget.progress);
  }

  void _onContinue() {
    _audio.playClick();
    if (widget.level >= 30) {
      // Reached end of adventure!
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => VictoryScreen(progress: widget.progress),
        ),
      );
    } else {
      // Next level
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuestionLevelScreen(
            level: widget.level + 1,
            progress: widget.progress,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061121),
      appBar: _buildAppBar(),
      body: ConfettiOverlay(
        isPlaying: _triggerConfetti,
        child: SafeArea(
          child: Column(
            children: [
              // Progress Bar (1 to 30)
              _buildProgressBar(),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  physics: const BouncingScrollPhysics(),
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question Card with Medical Badge
                        _buildQuestionCard(),
                        const SizedBox(height: 16),

                        // Options Cards
                        _buildOptionsList(),
                        const SizedBox(height: 18),

                        // Feedback & Debrief Section (Visible after validation)
                        if (_hasValidated) _buildPedagogicalDebrief(),

                        const SizedBox(height: 80), // Padding for bottom button
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomActionBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF08172D),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _world.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _world.title,
                  style: TextStyle(
                    color: _world.accentColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'NIVEAU ${widget.level} / 30',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Text(
            _world.subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF040D1A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFD166).withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: Color(0xFFFFD166), size: 16),
              const SizedBox(width: 4),
              Text(
                '${widget.progress.totalXp} XP',
                style: const TextStyle(
                  color: Color(0xFFFFD166),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progressVal = (widget.level / 30.0).clamp(0.0, 1.0);
    return Container(
      color: const Color(0xFF08172D),
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: progressVal,
          minHeight: 6,
          backgroundColor: Colors.white.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(_world.primaryColor),
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1E38),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _world.primaryColor.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _world.primaryColor.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _world.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book_rounded, color: _world.primaryColor, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      _question.anatomicalTheme,
                      style: TextStyle(
                        color: _world.accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF040D1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  'PDF Q${_question.originalNumber}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _question.questionText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList() {
    return Column(
      children: List.generate(_question.options.length, (index) {
        final optionText = _question.options[index];
        final isSelected = _selectedOptionIndex == index;
        final isCorrectOption = index == _question.correctOptionIndex;

        Color cardBorderColor = Colors.white.withOpacity(0.15);
        Color cardBgColor = const Color(0xFF0C192E);
        IconData radioIcon = Icons.radio_button_unchecked_rounded;
        Color radioColor = Colors.white38;

        if (_hasValidated) {
          if (isCorrectOption) {
            // Good answer (Green)
            cardBorderColor = const Color(0xFF10B981);
            cardBgColor = const Color(0xFF063A2F);
            radioIcon = Icons.check_circle_rounded;
            radioColor = const Color(0xFF10B981);
          } else if (isSelected && !_isAnswerCorrect) {
            // Wrong selected answer (Red / Amber)
            cardBorderColor = const Color(0xFFEF4444);
            cardBgColor = const Color(0xFF3B1219);
            radioIcon = Icons.cancel_rounded;
            radioColor = const Color(0xFFEF4444);
          } else {
            cardBgColor = const Color(0xFF071220).withOpacity(0.6);
          }
        } else if (isSelected) {
          // Selected before validation (Cyan / Highlight)
          cardBorderColor = _world.primaryColor;
          cardBgColor = _world.primaryColor.withOpacity(0.14);
          radioIcon = Icons.radio_button_checked_rounded;
          radioColor = _world.primaryColor;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => _onOptionTap(index),
              borderRadius: BorderRadius.circular(18),
              splashColor: _world.primaryColor.withOpacity(0.2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cardBorderColor, width: isSelected ? 2.0 : 1.2),
                  boxShadow: [
                    if (isSelected && !_hasValidated)
                      BoxShadow(
                        color: _world.primaryColor.withOpacity(0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(radioIcon, color: radioColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        optionText,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPedagogicalDebrief() {
    final guideMood = _isAnswerCorrect ? GuideMood.happy : GuideMood.teaching;
    final guideMessage = _isAnswerCorrect
        ? 'Excellent diagnostic ! C\'est exactement la bonne réponse médicale.'
        : 'Pas d\'inquiétude ! L\'apprentissage passe par l\'analyse des erreurs : voici l\'explication clé.';

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _isAnswerCorrect
            ? const Color(0xFF042F24)
            : const Color(0xFF1E293B).withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _isAnswerCorrect ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isAnswerCorrect ? const Color(0xFF10B981) : const Color(0xFF38BDF8))
                .withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guide reaction header
          Row(
            children: [
              GastroGuideAvatar(
                size: 56,
                mood: guideMood,
                animate: true,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isAnswerCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                          color: _isAnswerCorrect ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isAnswerCorrect ? 'RÉPONSE CORRECTE (+100 XP)' : 'RETOUR PÉDAGOGIQUE (+30 XP)',
                          style: TextStyle(
                            color: _isAnswerCorrect
                                ? const Color(0xFFA7F3D0)
                                : const Color(0xFFBAE6FD),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      guideMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),

          // Medical explanation text
          const Text(
            'EXPLICATION MÉDICALE VALIDÉE :',
            style: TextStyle(
              color: Color(0xFFFFD166),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _question.explanation,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF08172D),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: _hasValidated
              ? ElevatedButton.icon(
                  onPressed: _onContinue,
                  icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF040D1A)),
                  label: Text(
                    widget.level >= 30 ? 'VOIR MON BILAN FINAL' : 'NIVEAU SUIVANT',
                    style: const TextStyle(
                      color: Color(0xFF040D1A),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: _selectedOptionIndex != null ? _onValidate : null,
                  icon: const Icon(Icons.check_rounded, color: Color(0xFF040D1A)),
                  label: const Text(
                    'VALIDER MA RÉPONSE',
                    style: TextStyle(
                      color: Color(0xFF040D1A),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedOptionIndex != null
                        ? const Color(0xFF10B981)
                        : Colors.white24,
                    elevation: _selectedOptionIndex != null ? 6 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
