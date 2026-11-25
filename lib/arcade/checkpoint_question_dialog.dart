import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final ScrollController _leftScroll = ScrollController();
  final ScrollController _rightScroll = ScrollController();

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(parent: _enterController, curve: Curves.easeOut);
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    _leftScroll.dispose();
    _rightScroll.dispose();
    super.dispose();
  }

  void _onValidate() {
    if (_selectedIndex == null || _isValidated) return;
    setState(() {
      _isValidated = true;
    });
    // Gently scroll left column down on compact screens so student sees explanation immediately
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_leftScroll.hasClients && _leftScroll.position.maxScrollExtent > 0) {
        _leftScroll.animateTo(
          _leftScroll.position.maxScrollExtent * 0.65,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onContinue() {
    if (_selectedIndex == null) return;
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

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          color: CapsuleColors.deepOcean.withValues(alpha: 0.78),
          child: SafeArea(
            child: Center(
              child: Container(
                width: isLandscape ? math.min(media.size.width * 0.96, 980) : math.min(media.size.width * 0.94, 540),
                constraints: BoxConstraints(
                  maxHeight: isLandscape ? math.min(media.size.height * 0.95, 540) : media.size.height * 0.90,
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
                      CapsuleColors.oceanSurface,
                      CapsuleColors.deepOcean,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isValidated
                        ? (isCorrect ? CapsuleColors.mintGreen : CapsuleColors.dangerOrange)
                        : CapsuleColors.cyanGlow.withValues(alpha: 0.65),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.40),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: isLandscape
                      ? _buildLandscapeContent(q, isCorrect, isCompact)
                      : _buildPortraitContent(q, isCorrect),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeContent(GastroQuestion q, bool isCorrect, bool isCompact) {
    return Padding(
      padding: EdgeInsets.all(isCompact ? 12 : 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left 50%: Question Header, Question Text, and Rich Pedagogical Card on validation
          Expanded(
            flex: 50,
            child: Scrollbar(
              controller: _leftScroll,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _leftScroll,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(right: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionHeader(q, isCompact),
                    SizedBox(height: isCompact ? 6 : 10),
                    Text(
                      q.questionText,
                      style: GoogleFonts.plusJakartaSans(
                        color: CapsuleColors.textWhite,
                        fontSize: isCompact ? 13.5 : 16.0,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    if (_isValidated) ...[
                      SizedBox(height: isCompact ? 8 : 14),
                      _buildPedagogicalResultCard(q, isCorrect, isCompact),
                    ],
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: isCompact ? 10 : 18),
          Container(width: 1, color: CapsuleColors.cardBorder),
          SizedBox(width: isCompact ? 10 : 18),

          // Right 50%: Interactive Option Cards + Clear Action Button
          Expanded(
            flex: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Scrollbar(
                    controller: _rightScroll,
                    thumbVisibility: q.options.length > 4,
                    child: SingleChildScrollView(
                      controller: _rightScroll,
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
                SizedBox(height: isCompact ? 6 : 10),
                if (!_isValidated)
                  TactileButton(
                    label: 'Valider ma réponse',
                    icon: Icons.check_circle_rounded,
                    style: TactileButtonStyle.primary,
                    height: isCompact ? 40 : 48,
                    onPressed: _selectedIndex != null ? _onValidate : null,
                  )
                else
                  TactileButton(
                    label: 'Poursuivre la mission',
                    icon: Icons.play_arrow_rounded,
                    style: TactileButtonStyle.primary,
                    height: isCompact ? 40 : 48,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuestionHeader(q, true),
          const SizedBox(height: 10),
          Text(
            q.questionText,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(q.options.length, (index) => _buildOptionTile(q, index, true)),
          if (_isValidated) ...[
            const SizedBox(height: 10),
            _buildPedagogicalResultCard(q, isCorrect, true),
            const SizedBox(height: 12),
            TactileButton(
              label: 'Poursuivre la mission',
              icon: Icons.play_arrow_rounded,
              style: TactileButtonStyle.primary,
              height: 46,
              onPressed: _onContinue,
            ),
          ] else ...[
            const SizedBox(height: 12),
            TactileButton(
              label: 'Valider ma réponse',
              icon: Icons.check_circle_rounded,
              style: TactileButtonStyle.primary,
              height: 46,
              onPressed: _selectedIndex != null ? _onValidate : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(GastroQuestion q, bool isCompact) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 10, vertical: isCompact ? 3 : 4),
          decoration: BoxDecoration(
            color: (widget.isRevisionMode ? CapsuleColors.gold : CapsuleColors.cyanGlow).withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (widget.isRevisionMode ? CapsuleColors.gold : CapsuleColors.cyanGlow).withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isRevisionMode ? Icons.replay_rounded : Icons.radar_rounded,
                color: widget.isRevisionMode ? CapsuleColors.gold : CapsuleColors.cyanGlow,
                size: isCompact ? 13 : 15,
              ),
              const SizedBox(width: 5),
              Text(
                widget.isRevisionMode
                    ? 'RÉVISION #${widget.checkpointIndex}'
                    : 'CHECKPOINT #${widget.checkpointIndex}',
                style: GoogleFonts.plusJakartaSans(
                  color: widget.isRevisionMode ? CapsuleColors.gold : CapsuleColors.cyanGlow,
                  fontSize: isCompact ? 10 : 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: CapsuleColors.cardOcean,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Q${q.originalNumber}',
            style: GoogleFonts.orbitron(
              color: CapsuleColors.textSubtle,
              fontSize: isCompact ? 9.5 : 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          q.anatomicalTheme,
          style: GoogleFonts.inter(
            color: CapsuleColors.turquoise,
            fontSize: isCompact ? 10.5 : 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(GastroQuestion q, int index, bool isCompact) {
    final option = q.options[index];
    final bool isSelected = _selectedIndex == index;
    final bool isRightOption = index == q.correctOptionIndex;

    Color cardBg = CapsuleColors.cardOcean.withValues(alpha: 0.78);
    Color borderColor = CapsuleColors.cardBorder;
    Color textColor = CapsuleColors.textWhite;
    Color badgeBg = CapsuleColors.deepOcean;

    if (_isValidated) {
      if (isRightOption) {
        cardBg = const Color(0xFF065F46).withValues(alpha: 0.75);
        borderColor = CapsuleColors.mintGreen;
        textColor = const Color(0xFFD1FAE5);
        badgeBg = CapsuleColors.mintGreen;
      } else if (isSelected && !isRightOption) {
        cardBg = const Color(0xFF881337).withValues(alpha: 0.55);
        borderColor = CapsuleColors.dangerOrange;
        textColor = const Color(0xFFFED7AA);
        badgeBg = CapsuleColors.dangerOrange;
      }
    } else if (isSelected) {
      cardBg = CapsuleColors.turquoise.withValues(alpha: 0.28);
      borderColor = CapsuleColors.cyanGlow;
      badgeBg = CapsuleColors.cyanGlow;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: isCompact ? 5 : 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isValidated ? null : () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 10 : 12,
            vertical: isCompact ? 6.5 : 10,
          ),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected || (_isValidated && isRightOption) ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: isCompact ? 21 : 24,
                height: isCompact ? 21 : 24,
                margin: const EdgeInsets.only(right: 9),
                decoration: BoxDecoration(
                  color: badgeBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: GoogleFonts.inter(
                      color: (isSelected || (_isValidated && isRightOption))
                          ? CapsuleColors.deepOcean
                          : CapsuleColors.textWhite,
                      fontSize: isCompact ? 10 : 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  option,
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: isCompact ? 12.0 : 13.0,
                    fontWeight: isSelected || (_isValidated && isRightOption)
                        ? FontWeight.w700
                        : FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ),
              if (_isValidated && isRightOption)
                const Icon(Icons.check_circle_rounded, color: CapsuleColors.mintGreen, size: 18)
              else if (_isValidated && isSelected && !isRightOption)
                const Icon(Icons.info_outline_rounded, color: CapsuleColors.dangerOrange, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPedagogicalResultCard(GastroQuestion q, bool isCorrect, bool isCompact) {
    final Color accent = isCorrect ? CapsuleColors.mintGreen : CapsuleColors.dangerOrange;
    final Color bgTint = isCorrect
        ? const Color(0xFF064E3B).withValues(alpha: 0.55)
        : const Color(0xFF431407).withValues(alpha: 0.55);

    return Container(
      padding: EdgeInsets.all(isCompact ? 10 : 12),
      decoration: BoxDecoration(
        color: bgTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.lightbulb_rounded,
                color: accent,
                size: 19,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  isCorrect
                      ? 'EXACT ! +100 XP • +30% PUISSANCE D\'ARME'
                      : 'CORRECTION CLINIQUE (+35 XP)',
                  style: GoogleFonts.plusJakartaSans(
                    color: accent,
                    fontSize: isCompact ? 11.0 : 12.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          // If wrong, explicitly highlight why & show the exact right answer!
          if (!isCorrect) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF065F46).withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CapsuleColors.mintGreen.withValues(alpha: 0.6)),
              ),
              child: Text(
                'Bonne réponse : ${q.correctOptionText}',
                style: GoogleFonts.inter(
                  color: const Color(0xFFA7F3D0),
                  fontSize: isCompact ? 11.0 : 12.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],

          const SizedBox(height: 7),
          Text(
            q.explanation,
            style: GoogleFonts.inter(
              color: CapsuleColors.textWhite,
              fontSize: isCompact ? 11.2 : 12.0,
              height: 1.38,
            ),
          ),

          if (q.fichePoints.isNotEmpty) ...[
            const SizedBox(height: 9),
            Container(
              padding: EdgeInsets.all(isCompact ? 8 : 10),
              decoration: BoxDecoration(
                color: CapsuleColors.deepOcean.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school_rounded, color: CapsuleColors.cyanGlow, size: 14),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'À RETENIR : ${q.ficheTitle.toUpperCase()}',
                          style: GoogleFonts.plusJakartaSans(
                            color: CapsuleColors.cyanGlow,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ...q.fichePoints.take(isCompact ? 2 : 3).map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 2.5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: CapsuleColors.mintGreen, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              point,
                              style: GoogleFonts.inter(
                                color: CapsuleColors.textSubtle,
                                fontSize: isCompact ? 10.5 : 11.2,
                                height: 1.3,
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
