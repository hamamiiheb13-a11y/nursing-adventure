import 'dart:math' as math;
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
    with TickerProviderStateMixin {
  int _questionIndex = 0;
  int? _selectedIndex;
  bool _isValidated = false;
  bool _showSuperShot = false;
  bool _showBossAttack = false;

  late final AnimationController _slideInController;
  late final Animation<Offset> _slideInAnimation;

  late final AnimationController _shakeController;
  late final AnimationController _pulseController;
  late final AnimationController _victoryParticlesController;

  @override
  void initState() {
    super.initState();

    // 1. Boss slide in from right edge
    _slideInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _slideInAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideInController,
      curve: Curves.easeOutBack,
    ));
    _slideInController.forward();

    // 2. Dramatic screen shake
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeController.forward();

    // 3. Aura pulsing
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // 4. Victory explosion particles
    _victoryParticlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _slideInController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    _victoryParticlesController.dispose();
    super.dispose();
  }

  GastroQuestion get _currentQuestion {
    final questions = widget.boss.challengeQuestions;
    if (questions.isEmpty) {
      return allGastroQuestions.first;
    }
    return questions[_questionIndex % questions.length];
  }

  void _onValidate() {
    if (_selectedIndex == null || _isValidated) return;
    final isCorrect = _selectedIndex == _currentQuestion.correctOptionIndex;

    setState(() {
      _isValidated = true;
      if (isCorrect) {
        _showSuperShot = true;
      } else {
        _showBossAttack = true;
      }
    });

    widget.onAnswerValidated(_currentQuestion.id, _selectedIndex!, isCorrect);

    if (widget.boss.isDefeated) {
      _victoryParticlesController.repeat();
    }
  }

  void _onNext() {
    if (widget.boss.isDefeated) {
      widget.onVictoryClaimed();
    } else {
      setState(() {
        _isValidated = false;
        _selectedIndex = null;
        _showSuperShot = false;
        _showBossAttack = false;
        _questionIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final boss = widget.boss;
    final q = _currentQuestion;
    final bool isCorrect = _isValidated && _selectedIndex == q.correctOptionIndex;
    final media = MediaQuery.of(context);
    final isLandscape = media.size.width > media.size.height && media.size.width > 700;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        // Dramatic entrance shake
        final double shakeOffset = (1.0 - _shakeController.value) *
            math.sin(_shakeController.value * math.pi * 8) *
            10.0;
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: SlideTransition(
        position: _slideInAnimation,
        child: Stack(
          children: [
            // Dark vignette backdrop
            Container(
              color: Colors.black.withValues(alpha: 0.8),
            ),

            // Attack flash effects
            if (_showSuperShot)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                  ),
                ),
              ),
            if (_showBossAttack)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  ),
                ),
              ),

            // Victory particle canvas
            if (boss.isDefeated)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _victoryParticlesController,
                    builder: (context, _) => CustomPaint(
                      painter: _BossVictoryParticlesPainter(
                        progress: _victoryParticlesController.value,
                      ),
                    ),
                  ),
                ),
              ),

            // Main Boss Combat Dialog Box
            Center(
              child: Container(
                width: isLandscape ? math.min(media.size.width * 0.92, 980) : 540,
                height: isLandscape ? math.min(media.size.height * 0.92, 530) : null,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      color: (boss.isDefeated ? const Color(0xFFFFD166) : boss.auraColor)
                          .withValues(alpha: 0.45),
                      blurRadius: 36,
                      spreadRadius: 3,
                    ),
                    const BoxShadow(color: Colors.black, blurRadius: 28),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: isLandscape
                      ? _buildLandscapeBossLayout(boss, q, isCorrect)
                      : _buildPortraitBossLayout(boss, q, isCorrect),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeBossLayout(ArcadeBoss boss, GastroQuestion q, bool isCorrect) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left 45%: Boss Avatar, Boss HP bar, Combat Feedback
          Expanded(
            flex: 45,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Boss Identification Row
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          final glow = 6.0 + _pulseController.value * 8.0;
                          return Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: boss.auraColor.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                              border: Border.all(color: boss.auraColor, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: boss.auraColor.withValues(alpha: 0.5),
                                  blurRadius: glow,
                                ),
                              ],
                            ),
                            child: Icon(boss.icon, color: boss.auraColor, size: 30),
                          );
                        },
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AFFRONTEMENT DU BOSS',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFEF4444),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              boss.name.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              boss.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Boss Health Bar (Top Segmented Bar)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'JAUGE VITALE DU BOSS',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFE2E8F0),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${boss.currentHp} / ${boss.maxHp} HP',
                              style: GoogleFonts.plusJakartaSans(
                                color: boss.isDefeated
                                    ? const Color(0xFFFFD166)
                                    : const Color(0xFFEF4444),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (boss.currentHp / boss.maxHp).clamp(0.0, 1.0),
                            minHeight: 12,
                            backgroundColor: const Color(0xFF334155),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              boss.isDefeated ? const Color(0xFFFFD166) : const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Defeated Fanfare OR Combat Feedback
                  if (boss.isDefeated)
                    _buildBossDefeatedBox(boss)
                  else if (_isValidated)
                    _buildCombatFeedbackBox(isCorrect, q),
                ],
              ),
            ),
          ),

          const SizedBox(width: 20),
          const VerticalDivider(color: Color(0xFF1E293B), width: 1),
          const SizedBox(width: 20),

          // Right 55%: Tactical Question or Victory Final Action
          Expanded(
            flex: 55,
            child: boss.isDefeated
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD166), size: 72),
                        const SizedBox(height: 14),
                        Text(
                          'STAGE VALIDÉ AVEC SUCCÈS !',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toutes les menaces biologiques de cette zone sont éradiquées.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        TactileButton(
                          label: 'DÉBLOQUER L\'ÉTAPE SUIVANTE',
                          icon: Icons.arrow_forward_rounded,
                          style: TactileButtonStyle.primary,
                          height: 52,
                          onPressed: widget.onVictoryClaimed,
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question prompt
                      Text(
                        'RIPOSTE THÉRAPEUTIQUE - SUPER TIR',
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
                      const SizedBox(height: 12),

                      // Option choices
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(q.options.length, (index) {
                              return _buildBossOptionTile(q, index);
                            }),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      if (!_isValidated)
                        TactileButton(
                          label: 'TIRER LE SUPER-LASER',
                          icon: Icons.flash_on_rounded,
                          style: TactileButtonStyle.primary,
                          height: 48,
                          onPressed: _selectedIndex != null ? _onValidate : null,
                        )
                      else
                        TactileButton(
                          label: widget.boss.isDefeated ? 'Célébrer la Victoire' : 'Tour Suivant',
                          icon: Icons.navigate_next_rounded,
                          style: TactileButtonStyle.primary,
                          height: 48,
                          onPressed: _onNext,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitBossLayout(ArcadeBoss boss, GastroQuestion q, bool isCorrect) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(boss.icon, color: boss.auraColor, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  boss.name.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${boss.currentHp}/${boss.maxHp} HP',
                style: GoogleFonts.inter(color: const Color(0xFFEF4444), fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (boss.currentHp / boss.maxHp).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFF334155),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
            ),
          ),
          const SizedBox(height: 14),
          if (boss.isDefeated) ...[
            _buildBossDefeatedBox(boss),
            const SizedBox(height: 16),
            TactileButton(
              label: 'DÉBLOQUER L\'ÉTAPE SUIVANTE',
              icon: Icons.check_circle_rounded,
              style: TactileButtonStyle.primary,
              height: 50,
              onPressed: widget.onVictoryClaimed,
            ),
          ] else ...[
            Text(
              q.questionText,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(q.options.length, (index) => _buildBossOptionTile(q, index)),
            if (_isValidated) ...[
              const SizedBox(height: 10),
              _buildCombatFeedbackBox(isCorrect, q),
              const SizedBox(height: 12),
              TactileButton(
                label: 'Continuer',
                icon: Icons.navigate_next_rounded,
                style: TactileButtonStyle.primary,
                height: 48,
                onPressed: _onNext,
              ),
            ] else ...[
              const SizedBox(height: 12),
              TactileButton(
                label: 'TIRER LE SUPER-LASER',
                icon: Icons.flash_on_rounded,
                style: TactileButtonStyle.primary,
                height: 48,
                onPressed: _selectedIndex != null ? _onValidate : null,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildBossOptionTile(GastroQuestion q, int index) {
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
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isValidated ? null : () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
                  opt,
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: 12.5,
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

  Widget _buildCombatFeedbackBox(bool isCorrect, GastroQuestion q) {
    return Container(
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
          Row(
            children: [
              Icon(
                isCorrect ? Icons.flash_on_rounded : Icons.shield_outlined,
                color: isCorrect ? const Color(0xFF34D399) : const Color(0xFFF87171),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect
                    ? 'SUPER TIR TOUCHÉ ! (-1 HP AU BOSS)'
                    : 'RIPOSTE DU BOSS ! (-0.5 CŒUR)',
                style: GoogleFonts.plusJakartaSans(
                  color: isCorrect ? const Color(0xFF34D399) : const Color(0xFFF87171),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            q.explanation,
            style: GoogleFonts.inter(color: const Color(0xFFF1F5F9), fontSize: 11.5, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildBossDefeatedBox(ArcadeBoss boss) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD166).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD166)),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars_rounded, color: Color(0xFFFFD166), size: 48),
          const SizedBox(height: 6),
          Text(
            'BOSS NEUTRALISÉ !',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFFFD166),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${boss.name} a été détruit par vos super-lasers cliniques.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BossVictoryParticlesPainter extends CustomPainter {
  final double progress;

  _BossVictoryParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);
    final center = Offset(size.width * 0.5, size.height * 0.4);

    for (int i = 0; i < 60; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 80.0 + rand.nextDouble() * 260.0;
      final dist = (progress * speed) % 350.0;
      final p = center + Offset(math.cos(angle) * dist, math.sin(angle) * dist);

      final radius = (4.0 * (1.0 - progress)).clamp(1.0, 5.0);
      final alpha = ((1.0 - (dist / 350.0)) * 0.8).clamp(0.0, 0.8);

      final paint = Paint()
        ..color = (i % 2 == 0 ? const Color(0xFFFFD166) : const Color(0xFF00E5FF))
            .withValues(alpha: alpha);
      canvas.drawCircle(p, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BossVictoryParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
