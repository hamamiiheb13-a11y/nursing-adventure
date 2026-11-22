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
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  bool _isValidated = false;
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onValidate() {
    if (_selectedIndex == null || _isValidated) return;
    setState(() {
      _isValidated = true;
    });
  }

  void _onContinue() {
    final bool isCorrect = _selectedIndex == widget.question.correctOptionIndex;
    widget.onAnswerValidated(_selectedIndex!, isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final bool isCorrect = _isValidated && _selectedIndex == q.correctOptionIndex;

    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 520,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
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
                    .withValues(alpha: 0.35),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- HEADER BADGE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emergency_rounded, color: Color(0xFF00E5FF), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'POINT DE CONTRÔLE CLINIQUE #${widget.checkpointIndex}',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF00E5FF),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PDF N°${q.originalNumber}',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Anatomical theme
                  Text(
                    q.anatomicalTheme.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Original Question Text
                  Text(
                    q.questionText,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF1E293B), height: 1),
                  const SizedBox(height: 14),

                  // Answer choices list
                  ...List.generate(q.options.length, (index) {
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
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _isValidated
                            ? null
                            : () {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor, width: isSelected || (_isValidated && isRightOption) ? 1.8 : 1.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
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
                                      fontSize: 12,
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
                                    fontSize: 13.5,
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
                  }),

                  // --- VALIDATION & EXPLANATION PANEL ---
                  if (!_isValidated) ...[
                    const SizedBox(height: 12),
                    TactileButton(
                      label: 'Valider ma décision clinique',
                      icon: Icons.check_circle_rounded,
                      style: TactileButtonStyle.primary,
                      height: 50,
                      onPressed: _selectedIndex != null ? _onValidate : null,
                    ),
                  ] else ...[
                    const SizedBox(height: 14),
                    // Pedagogical Explanation Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? const Color(0xFF064E3B).withValues(alpha: 0.6)
                            : const Color(0xFF450A0A).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isCorrect ? 'DÉCISION CLINIQUE EXACTE ! (+100 XP)' : 'ERREUR CLINIQUE (-1 CŒUR)',
                                style: GoogleFonts.plusJakartaSans(
                                  color: isCorrect ? const Color(0xFF34D399) : const Color(0xFFF87171),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            q.explanation,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFF1F5F9),
                              fontSize: 12.5,
                              height: 1.45,
                            ),
                          ),
                          if (!isCorrect) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7F1D1D),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'ℹ️ Cette question a été ajoutée à votre File de Révision Spacée.',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFFCA5A5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TactileButton(
                      label: 'Reprendre l\'exploration digestive',
                      icon: Icons.play_arrow_rounded,
                      style: TactileButtonStyle.primary,
                      height: 50,
                      onPressed: _onContinue,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
