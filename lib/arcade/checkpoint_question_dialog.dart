import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/gastro_question.dart';
import '../widgets/tactile_button.dart';

class CheckpointQuestionDialog extends StatefulWidget {
  final GastroQuestion question;
  final int checkpointIndex;
  final Function(int selectedOptionIndex, bool isCorrect) onAnswerValidated;

  const CheckpointQuestionDialog({
    super.key,
    required this.question,
    required this.checkpointIndex,
    required this.onAnswerValidated,
  });

  @override
  State<CheckpointQuestionDialog> createState() => _CheckpointQuestionDialogState();
}

class _CheckpointQuestionDialogState extends State<CheckpointQuestionDialog>
    with TickerProviderStateMixin {
  int? _selectedIndex;
  bool _isValidated = false;

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  late final AnimationController _scanController;
  late final AnimationController _flashController;
  late final Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Slide in from top
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();

    // 2. Holographic scanning beam loop
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // 3. Flash effect on answer
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flashAnimation = CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scanController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  void _onValidate() {
    if (_selectedIndex == null || _isValidated) return;
    setState(() {
      _isValidated = true;
    });
    _flashController.forward(from: 0.0);
  }

  void _onContinue() {
    final bool isCorrect = _selectedIndex == widget.question.correctOptionIndex;
    widget.onAnswerValidated(_selectedIndex!, isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final bool isCorrect = _isValidated && _selectedIndex == q.correctOptionIndex;
    final media = MediaQuery.of(context);
    final isLandscape = media.size.width > media.size.height && media.size.width > 700;

    return SlideTransition(
      position: _slideAnimation,
      child: Stack(
        children: [
          // Semi-transparent backdrop with scanning grid
          Container(
            color: Colors.black.withValues(alpha: 0.75),
          ),

          // Validation Flash Overlay
          if (_isValidated)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _flashAnimation,
                builder: (context, _) {
                  final opacity = ((1.0 - _flashAnimation.value) * 0.35).clamp(0.0, 0.35);
                  return IgnorePointer(
                    child: Container(
                      color: (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                          .withValues(alpha: opacity),
                    ),
                  );
                },
              ),
            ),

          // Main Dialog Card
          Center(
            child: Container(
              width: isLandscape ? math.min(media.size.width * 0.94, 980) : 540,
              height: isLandscape ? math.min(media.size.height * 0.94, 540) : null,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0B132B),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _isValidated
                      ? (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                      : const Color(0xFF00E5FF),
                  width: 2.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isValidated
                            ? (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                            : const Color(0xFF00E5FF))
                        .withValues(alpha: 0.4),
                    blurRadius: 32,
                    spreadRadius: 2,
                  ),
                  const BoxShadow(color: Colors.black, blurRadius: 24),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Holographic Scanning Beam
                    AnimatedBuilder(
                      animation: _scanController,
                      builder: (context, _) {
                        return Positioned(
                          top: _scanController.value * (isLandscape ? 520 : 600),
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF00E5FF).withValues(alpha: 0.7),
                                  Colors.white,
                                  const Color(0xFF00E5FF).withValues(alpha: 0.7),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Content Area
                    isLandscape
                        ? _buildLandscapeContent(q, isCorrect)
                        : _buildPortraitContent(q, isCorrect),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeContent(GastroQuestion q, bool isCorrect) {
    final media = MediaQuery.of(context);
    final bool isCompact = media.size.height < 430;

    return Padding(
      padding: EdgeInsets.all(isCompact ? 12 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left 55%: Question, Theme, Scanning indicator, Result explanation & Summary card
          Expanded(
            flex: 55,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transmission header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 10, vertical: isCompact ? 3 : 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.radar_rounded, color: const Color(0xFF00E5FF), size: isCompact ? 13 : 16),
                            const SizedBox(width: 5),
                            Text(
                              'TRANSMISSION CHECKPOINT #${widget.checkpointIndex}',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF00E5FF),
                                fontSize: isCompact ? 9.5 : 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isCompact ? 6 : 8, vertical: isCompact ? 3 : 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Q${q.originalNumber}',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: isCompact ? 9.5 : 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 6 : 12),

                  // Anatomical Theme
                  Text(
                    q.anatomicalTheme.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF38BDF8),
                      fontSize: isCompact ? 9.5 : 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: isCompact ? 4 : 8),

                  // Question Text
                  Text(
                    q.questionText,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: isCompact ? 13.5 : 16.5,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),

                  // Explanation / Result after answer
                  if (_isValidated) ...[
                    SizedBox(height: isCompact ? 10 : 16),
                    _buildResultBox(q, isCorrect),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(width: isCompact ? 12 : 20),
          const VerticalDivider(color: Color(0xFF1E293B), width: 1),
          SizedBox(width: isCompact ? 12 : 20),

          // Right 45%: Options and Validate / Continue button
          Expanded(
            flex: 45,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(q.options.length, (index) {
                        return _buildOptionTile(q, index);
                      }),
                    ),
                  ),
                ),
                SizedBox(height: isCompact ? 8 : 12),
                if (!_isValidated)
                  TactileButton(
                    label: 'Valider ma réponse',
                    icon: Icons.check_circle_rounded,
                    style: TactileButtonStyle.primary,
                    height: isCompact ? 42 : 48,
                    onPressed: _selectedIndex != null ? _onValidate : null,
                  )
                else
                  TactileButton(
                    label: 'Reprendre la mission',
                    icon: Icons.play_arrow_rounded,
                    style: TactileButtonStyle.primary,
                    height: isCompact ? 42 : 48,
                    onPressed: _onContinue,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitContent(GastroQuestion q, bool isCorrect) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.radar_rounded, color: Color(0xFF00E5FF), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'CHECKPOINT #${widget.checkpointIndex}',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF00E5FF),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Q${q.originalNumber}',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            q.questionText,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(q.options.length, (index) => _buildOptionTile(q, index)),
          if (_isValidated) ...[
            const SizedBox(height: 12),
            _buildResultBox(q, isCorrect),
            const SizedBox(height: 14),
            TactileButton(
              label: 'Reprendre la mission',
              icon: Icons.play_arrow_rounded,
              style: TactileButtonStyle.primary,
              height: 48,
              onPressed: _onContinue,
            ),
          ] else ...[
            const SizedBox(height: 14),
            TactileButton(
              label: 'Valider',
              icon: Icons.check_circle_rounded,
              style: TactileButtonStyle.primary,
              height: 48,
              onPressed: _selectedIndex != null ? _onValidate : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionTile(GastroQuestion q, int index) {
    final option = q.options[index];
    final bool isSelected = _selectedIndex == index;
    final bool isRightOption = index == q.correctOptionIndex;

    Color cardBg = const Color(0xFF1E293B);
    Color borderColor = const Color(0xFF334155);
    Color textColor = Colors.white;

    if (_isValidated) {
      if (isRightOption) {
        cardBg = const Color(0xFF064E3B);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFFA7F3D0);
      } else if (isSelected && !isRightOption) {
        cardBg = const Color(0xFF7F1D1D);
        borderColor = const Color(0xFFEF4444);
        textColor = const Color(0xFFFECACA);
      }
    } else if (isSelected) {
      cardBg = const Color(0xFF0F766E).withValues(alpha: 0.35);
      borderColor = const Color(0xFF00E5FF);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isValidated ? null : () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected || (_isValidated && isRightOption) ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 10, top: 1),
                decoration: BoxDecoration(
                  color: isSelected ? borderColor : const Color(0xFF0F172A),
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  option,
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultBox(GastroQuestion q, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFF064E3B).withValues(alpha: 0.6)
            : const Color(0xFF450A0A).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          width: 1.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect ? const Color(0xFF34D399) : const Color(0xFFF87171),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCorrect ? 'RÉPONSE VALIDÉE ! (+100 XP)' : 'RÉPONSE INCORRECTE (-1 CŒUR)',
                  style: GoogleFonts.plusJakartaSans(
                    color: isCorrect ? const Color(0xFF34D399) : const Color(0xFFF87171),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            q.explanation,
            style: GoogleFonts.inter(
              color: const Color(0xFFF1F5F9),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          if (q.fichePoints.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school_rounded, color: Color(0xFF00E5FF), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          q.ficheTitle.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF00E5FF),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...q.fichePoints.map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              point,
                              style: GoogleFonts.inter(
                                color: const Color(0xFFE2E8F0),
                                fontSize: 11,
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
        ],
      ),
    );
  }
}
