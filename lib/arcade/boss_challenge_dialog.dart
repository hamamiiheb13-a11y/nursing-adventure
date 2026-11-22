import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/gastro_question.dart';
import '../widgets/tactile_button.dart';
import 'arcade_models.dart';

class BossChallengeDialog extends StatefulWidget {
  final ArcadeBoss boss;
  final Function(int questionId, int selectedOptionIndex, bool isCorrect) onAnswerValidated;
  final VoidCallback onVictoryClaimed;

  const BossChallengeDialog({
    super.key,
    required this.boss,
    required this.onAnswerValidated,
    required this.onVictoryClaimed,
  });

  @override
  State<BossChallengeDialog> createState() => _BossChallengeDialogState();
}

class _BossChallengeDialogState extends State<BossChallengeDialog>
    with SingleTickerProviderStateMixin {
  int _questionIndex = 0;
  int? _selectedIndex;
  bool _isValidated = false;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  GastroQuestion get _currentQuestion {
    final questions = widget.boss.challengeQuestions;
    return questions[_questionIndex % questions.length];
  }

  void _onValidate() {
    if (_selectedIndex == null || _isValidated) return;
    final isCorrect = _selectedIndex == _currentQuestion.correctOptionIndex;

    setState(() {
      _isValidated = true;
    });

    widget.onAnswerValidated(_currentQuestion.id, _selectedIndex!, isCorrect);
  }

  void _onNext() {
    if (widget.boss.isDefeated) {
      widget.onVictoryClaimed();
    } else {
      setState(() {
        _isValidated = false;
        _selectedIndex = null;
        _questionIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final boss = widget.boss;
    final q = _currentQuestion;
    final bool isCorrect = _isValidated && _selectedIndex == q.correctOptionIndex;

    return Center(
      child: Container(
        width: 540,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF090D16),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: boss.isDefeated
                ? const Color(0xFFFFD166)
                : (boss.auraColor),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: boss.auraColor.withValues(alpha: 0.4),
              blurRadius: 32,
              spreadRadius: 3,
            ),
            const BoxShadow(color: Colors.black87, blurRadius: 24),
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
                // --- BOSS HEADER BAR ---
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: boss.auraColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: boss.auraColor, width: 2),
                      ),
                      child: Icon(boss.icon, color: boss.auraColor, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'DÉFI DU BOSS : ',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFEF4444),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                boss.name.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            boss.title,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // --- BOSS HP SEGMENTS ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'POINTS DE VIE DU BOSS :',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFE2E8F0),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      ...List.generate(boss.maxHp, (i) {
                        final bool isActive = i < boss.currentHp;
                        return Container(
                          width: 24,
                          height: 14,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFFEF4444) : const Color(0xFF475569),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFEF4444).withValues(alpha: 0.6),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF1E293B), height: 1),
                const SizedBox(height: 14),

                // If boss defeated!
                if (boss.isDefeated) ...[
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.stars_rounded, color: Color(0xFFFFD166), size: 68),
                        const SizedBox(height: 10),
                        Text(
                          'VICTOIRE TOTALE SUR LE BOSS !',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFFFD166),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${boss.name} a été neutralisé avec succès grâce à votre précision clinique.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: const Color(0xFFE2E8F0),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TactileButton(
                          label: 'Débloquer le Monde Suivant !',
                          icon: Icons.check_circle_rounded,
                          style: TactileButtonStyle.primary,
                          height: 52,
                          onPressed: widget.onVictoryClaimed,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Question Header
                  Text(
                    'DÉCISION THÉRAPEUTIQUE DE NEUTRALISATION',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    q.questionText,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Option cards
                  ...List.generate(q.options.length, (index) {
                    final opt = q.options[index];
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
                      padding: const EdgeInsets.only(bottom: 9),
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
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
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  opt,
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
                  }),

                  // Action Button
                  if (!_isValidated) ...[
                    const SizedBox(height: 12),
                    TactileButton(
                      label: 'Tirer le Rayon Laser Médical',
                      icon: Icons.bolt_rounded,
                      style: TactileButtonStyle.primary,
                      height: 50,
                      onPressed: _selectedIndex != null ? _onValidate : null,
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? const Color(0xFF064E3B).withValues(alpha: 0.6)
                            : const Color(0xFF450A0A).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCorrect ? 'IMPACT CRITIQUE ! LE BOSS PERD 1 PV' : 'TIR DÉVIÉ ! LE BOSS RÉPLIQUE (-1 CŒUR)',
                            style: GoogleFonts.plusJakartaSans(
                              color: isCorrect ? const Color(0xFF34D399) : const Color(0xFFF87171),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            q.explanation,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFF1F5F9),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TactileButton(
                      label: widget.boss.isDefeated ? 'Célébrer la Victoire !' : 'Poursuivre l\'assaut médical',
                      icon: Icons.arrow_forward_rounded,
                      style: TactileButtonStyle.primary,
                      height: 50,
                      onPressed: _onNext,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
