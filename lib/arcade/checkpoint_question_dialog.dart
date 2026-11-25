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
        cardBg = const Color(0xFF1F3859).withValues(alpha: 0.72);
        borderColor = CapsuleColors.amberGold;
        textColor = const Color(0xFFFEF3C7);
        badgeBg = CapsuleColors.amberGold;
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
                const Icon(Icons.info_outline_rounded, color: CapsuleColors.amberGold, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPedagogicalResultCard(GastroQuestion q, bool isCorrect, bool isCompact) {
    final Color accent = isCorrect ? CapsuleColors.mintGreen : CapsuleColors.amberGold;
    final Color bgTint = isCorrect
        ? const Color(0xFF064E3B).withValues(alpha: 0.55)
        : CapsuleColors.oceanSurface.withValues(alpha: 0.90);

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

          const SizedBox(height: 8),
          _ClinicalMiniDiagram(
            diagramType: q.diagramType,
            accent: accent,
            isCompact: isCompact,
          ),

          const SizedBox(height: 8),
          Text(
            q.explanation,
            style: GoogleFonts.inter(
              color: CapsuleColors.textWhite,
              fontSize: isCompact ? 11.2 : 12.0,
              height: 1.38,
            ),
          ),

          if (q.whyOthersWrong.isNotEmpty) ...[
            const SizedBox(height: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: CapsuleColors.amberGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: CapsuleColors.amberGold.withValues(alpha: 0.42)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'POURQUOI LES AUTRES CHOIX NE CONVIENNENT PAS',
                    style: GoogleFonts.plusJakartaSans(
                      color: CapsuleColors.amberGold,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    q.whyOthersWrong,
                    style: GoogleFonts.inter(
                      color: CapsuleColors.textWhite,
                      fontSize: isCompact ? 10.6 : 11.3,
                      height: 1.32,
                    ),
                  ),
                ],
              ),
            ),
          ],

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

class _ClinicalMiniDiagram extends StatefulWidget {
  final String diagramType;
  final Color accent;
  final bool isCompact;

  const _ClinicalMiniDiagram({
    required this.diagramType,
    required this.accent,
    required this.isCompact,
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
      'villi_absorption' => 'SCHÉMA • VILLOSITÉS & ABSORPTION',
      'colon_water' => 'SCHÉMA • RÉABSORPTION COLIQUE (H₂O)',
      'ileum_valve' => 'SCHÉMA • ILÉON TERMINAL & VALVULE',
      'systemic_mici' => 'SCHÉMA • ATTEINTE SYSTÉMIQUE',
      'biotherapy_tnf' => 'SCHÉMA • BIOTHÉRAPIE ANTI-TNF',
      'biomarker_labs' => 'SCHÉMA • SUIVI BIOLOGIQUE & ENDOSCOPIE',
      'pregnancy_genetics' => 'SCHÉMA • HÉRÉDITÉ & MATERNITÉ',
      'emergency_nursing' => 'SCHÉMA • SURVEILLANCE INFIRMIÈRE',
      _ => 'SCHÉMA • REPÈRE ANATOMIQUE',
    };

    return Container(
      height: widget.isCompact ? 58 : 70,
      decoration: BoxDecoration(
        color: CapsuleColors.deepOcean.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.35)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, _) => CustomPaint(
                  painter: _ClinicalDiagramPainter(
                    diagramType: widget.diagramType,
                    t: _pulseCtrl.value,
                    accent: widget.accent,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            left: 8,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: CapsuleColors.cyanGlow,
                fontSize: 8.8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
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

  const _ClinicalDiagramPainter({
    required this.diagramType,
    required this.t,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h * 0.58;
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);

    final gridPaint = Paint()
      ..color = CapsuleColors.cyanGlow.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (double x = 24; x < w; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }

    final linePaint = Paint()
      ..color = CapsuleColors.cyanGlow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    switch (diagramType) {
      case 'fistula_stenosis':
        // Left: two parallel walls bridged by a pulsing fistula duct
        canvas.drawLine(Offset(w * 0.10, cy - 12), Offset(w * 0.42, cy - 12), linePaint);
        canvas.drawLine(Offset(w * 0.10, cy + 12), Offset(w * 0.42, cy + 12), linePaint);
        fillPaint.color = accent.withValues(alpha: 0.45 + 0.35 * pulse);
        canvas.drawRect(Rect.fromLTWH(w * 0.23, cy - 12, 10, 24), fillPaint);
        // Right: stenosis narrowing pinch
        final pinch = 4.0 + pulse * 2.0;
        final topPath = Path()
          ..moveTo(w * 0.55, cy - 14)
          ..quadraticBezierTo(w * 0.72, cy - pinch, w * 0.90, cy - 14);
        final botPath = Path()
          ..moveTo(w * 0.55, cy + 14)
          ..quadraticBezierTo(w * 0.72, cy + pinch, w * 0.90, cy + 14);
        canvas.drawPath(topPath, linePaint);
        canvas.drawPath(botPath, linePaint);
        break;
      case 'villi_absorption':
        final villi = Path()..moveTo(w * 0.08, cy + 14);
        for (int i = 0; i < 6; i++) {
          final bx = w * (0.14 + i * 0.13);
          final tipY = cy - 10 - 3 * math.sin(t * math.pi * 2 + i);
          villi.quadraticBezierTo(bx, tipY, bx + w * 0.065, cy + 14);
        }
        canvas.drawPath(villi, linePaint..color = CapsuleColors.mintGreen);
        fillPaint.color = CapsuleColors.cyanGlow;
        for (int i = 0; i < 4; i++) {
          final dx = w * (0.20 + i * 0.18);
          final dy = cy - 12 - ((t * 14 + i * 4) % 14);
          canvas.drawCircle(Offset(dx, dy), 2.5, fillPaint);
        }
        break;
      case 'colon_water':
        final colon = Path()
          ..moveTo(w * 0.15, cy + 14)
          ..lineTo(w * 0.15, cy - 8)
          ..quadraticBezierTo(w * 0.5, cy - 16, w * 0.85, cy - 8)
          ..lineTo(w * 0.85, cy + 14);
        canvas.drawPath(colon, linePaint..strokeWidth = 3.2);
        fillPaint.color = CapsuleColors.cyanGlow.withValues(alpha: 0.85);
        for (int i = 0; i < 4; i++) {
          final hx = w * (0.28 + i * 0.15);
          final hy = cy - 4 + pulse * 10;
          canvas.drawCircle(Offset(hx, hy), 3.0, fillPaint);
        }
        break;
      case 'ileum_valve':
        canvas.drawLine(Offset(w * 0.10, cy), Offset(w * 0.48, cy), linePaint..strokeWidth = 3);
        canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.68, cy), width: w * 0.30, height: 28), linePaint);
        fillPaint.color = CapsuleColors.gold.withValues(alpha: 0.7 + 0.3 * pulse);
        canvas.drawCircle(Offset(w * (0.15 + 0.33 * t), cy), 4, fillPaint);
        break;
      case 'biotherapy_tnf':
        final abPaint = Paint()
          ..color = CapsuleColors.cyanGlow
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;
        for (int i = 0; i < 3; i++) {
          final ax = w * (0.22 + i * 0.28);
          final ay = cy + 6 - pulse * 5;
          canvas.drawLine(Offset(ax, ay + 8), Offset(ax, ay), abPaint);
          canvas.drawLine(Offset(ax, ay), Offset(ax - 7, ay - 7), abPaint);
          canvas.drawLine(Offset(ax, ay), Offset(ax + 7, ay - 7), abPaint);
          fillPaint.color = accent.withValues(alpha: 0.85);
          canvas.drawCircle(Offset(ax, ay - 10), 3.5, fillPaint);
        }
        break;
      case 'biomarker_labs':
      case 'emergency_nursing':
        final wave = Path()..moveTo(w * 0.08, cy);
        for (double x = w * 0.08; x <= w * 0.92; x += 4) {
          final norm = (x - w * 0.08) / (w * 0.84);
          final spike = (norm - t).abs() < 0.06
              ? -14 * math.sin(((norm - t) / 0.06) * math.pi)
              : 0.0;
          wave.lineTo(x, cy + spike);
        }
        canvas.drawPath(wave, linePaint..color = accent);
        break;
      case 'pregnancy_genetics':
      default:
        final p1 = Path();
        final p2 = Path();
        for (double x = w * 0.12; x <= w * 0.88; x += 6) {
          final phase = (x / w) * math.pi * 4 + t * math.pi * 2;
          final y1 = cy + math.sin(phase) * 9;
          final y2 = cy - math.sin(phase) * 9;
          if (x == w * 0.12) {
            p1.moveTo(x, y1);
            p2.moveTo(x, y2);
          } else {
            p1.lineTo(x, y1);
            p2.lineTo(x, y2);
          }
        }
        canvas.drawPath(p1, linePaint..color = CapsuleColors.cyanGlow);
        canvas.drawPath(p2, linePaint..color = CapsuleColors.mintGreen);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ClinicalDiagramPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.diagramType != diagramType;
}
