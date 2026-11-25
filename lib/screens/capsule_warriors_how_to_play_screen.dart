import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../theme/capsule_theme.dart';
import '../widgets/capsule_parallax_background.dart';

class CapsuleWarriorsHowToPlayScreen extends StatefulWidget {
  final VoidCallback? onStart;

  const CapsuleWarriorsHowToPlayScreen({
    super.key,
    this.onStart,
  });

  @override
  State<CapsuleWarriorsHowToPlayScreen> createState() =>
      _CapsuleWarriorsHowToPlayScreenState();
}

class _CapsuleWarriorsHowToPlayScreenState
    extends State<CapsuleWarriorsHowToPlayScreen>
    with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  late final PageController _pageController;
  late final AnimationController _animController;
  Timer? _autoAdvanceTimer;

  int _currentPage = 0;

  final List<Map<String, dynamic>> _tutorialSteps = [
    {
      'title': 'DÉPLACER LA CAPSULE',
      'subtitle': 'Commandes de pilotage 2D',
      'desc':
          'Utilisez [Z,Q,S,D] ou les flèches du clavier (sur PC) ou le joystick et les flèches tactiles (sur mobile) pour mouvoir votre véhicule médical dans la lumière de l\'estomac.',
      'color': CapsuleColors.cyanGlow,
      'badge': 'ÉTAPE 1 / 6',
    },
    {
      'title': 'TIRER SUR LES ENNEMIS',
      'subtitle': 'Laser médical & Arsenal',
      'desc':
          'Appuyez sur [ESPACE] ou touchez le bouton de tir cyan pour neutraliser les bactéries Helicobacter et virions pathogènes avant qu\'ils ne corrodent votre coque.',
      'color': CapsuleColors.electricBlue,
      'badge': 'ÉTAPE 2 / 6',
    },
    {
      'title': 'ÉVITER LES OBSTACLES',
      'subtitle': 'Sucs gastriques & Spores toxiques',
      'desc':
          'Slalomez avec agilité entre les replis de la muqueuse, évitez les jets acides corrosifs et activez votre bouclier [E] ou [Shift] en cas de danger imminent.',
      'color': CapsuleColors.dangerOrange,
      'badge': 'ÉTAPE 3 / 6',
    },
    {
      'title': 'COLLECTER LES BONUS',
      'subtitle': 'Nanocristaux & Réparations',
      'desc':
          'Ramassez les cristaux énergétiques et cœurs de soin flottants pour regagner de la vie, augmenter votre score combo et charger votre tir surpuissant.',
      'color': CapsuleColors.gold,
      'badge': 'ÉTAPE 4 / 6',
    },
    {
      'title': 'VALIDER LES QUESTIONS CLINIQUE',
      'subtitle': 'Checkpoints pédagogiques MICI',
      'desc':
          'Aux nanoportes de diagnostic, répondez aux questions officielles issues du PFE ISSIT. Chaque bonne réponse restaure votre santé et valide vos compétences.',
      'color': CapsuleColors.successGreen,
      'badge': 'ÉTAPE 5 / 6',
    },
    {
      'title': 'TERRASSER LE BOSS DU SECTEUR',
      'subtitle': 'Affrontement décisif de fin de monde',
      'desc':
          'En fin de chaque stage, affrontez le Titan pathogène ! Évitez ses salves de cytokines, visez son noyau et terrassez-le pour débloquer le secteur suivant.',
      'color': CapsuleColors.purple,
      'badge': 'ÉTAPE 6 / 6',
    },
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _pageController = PageController();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _startAutoAdvance();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (_currentPage < _tutorialSteps.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        timer.cancel();
      }
    });
  }

  void _onUserInteraction() {
    _autoAdvanceTimer?.cancel();
  }

  void _nextPage() {
    _onUserInteraction();
    _audio.playClick();
    if (_currentPage < _tutorialSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishTutorial();
    }
  }

  void _prevPage() {
    _onUserInteraction();
    _audio.playClick();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishTutorial() {
    _audio.playClick();
    if (widget.onStart != null) {
      widget.onStart!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _tutorialSteps.length - 1;
    final media = MediaQuery.of(context);
    final isCompact = media.size.height < 520;
    final isNarrow = media.size.width < 620;

    return Scaffold(
      backgroundColor: CapsuleColors.deepOcean,
      body: CapsuleParallaxBackground(
        showHeroCapsule: false,
        showEnemySilhouettes: false,
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar: RETOUR button + Header + Commencer
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 20, vertical: 10),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _audio.playClick();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: CapsuleColors.oceanSurface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CapsuleColors.cyanGlow.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_rounded, color: CapsuleColors.cyanGlow, size: 16),
                            const SizedBox(width: 5),
                            Text(
                              'RETOUR',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isNarrow ? 'COMMENT JOUER' : 'COMMENT JOUER • GUIDE DU PILOTE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isCompact || isNarrow ? 14 : 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: CapsuleColors.cyanGlow.withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Direct "COMMENCER" CTA top-right
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CapsuleColors.cyanGlow,
                        foregroundColor: CapsuleColors.deepOcean,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 16, vertical: 8),
                      ),
                      onPressed: _finishTutorial,
                      child: Text(
                        'COMMENCER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Main PageView of Step-by-Step Cards with Animated Illustrations
              Expanded(
                child: Listener(
                  onPointerDown: (_) => _onUserInteraction(),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: _tutorialSteps.length,
                    itemBuilder: (context, index) {
                      final step = _tutorialSteps[index];
                      final stepColor = step['color'] as Color;
                      final illustrationBox = Container(
                        height: isNarrow ? 145 : (isCompact ? 160 : 210),
                        decoration: BoxDecoration(
                          color: CapsuleColors.deepOcean,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: CapsuleColors.cardBorder),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedBuilder(
                            animation: _animController,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: _TutorialStepPainter(
                                  stepIndex: index,
                                  progress: _animController.value,
                                  color: stepColor,
                                ),
                              );
                            },
                          ),
                        ),
                      );

                      final textCol = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: stepColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              step['badge'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                color: stepColor,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step['title'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: isCompact || isNarrow ? 16 : 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            step['subtitle'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: stepColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            step['desc'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: isCompact ? 12 : 13,
                              color: CapsuleColors.textSubtle,
                              height: 1.4,
                            ),
                          ),
                        ],
                      );

                      return Center(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: isNarrow ? 14 : 24, vertical: 6),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 780),
                            padding: EdgeInsets.all(isCompact || isNarrow ? 16 : 24),
                            decoration: BoxDecoration(
                              color: CapsuleColors.oceanSurface.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: stepColor.withValues(alpha: 0.65),
                                width: 1.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: stepColor.withValues(alpha: 0.18),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                            child: isNarrow
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: double.infinity, child: illustrationBox),
                                      const SizedBox(height: 14),
                                      textCol,
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(flex: 5, child: illustrationBox),
                                      const SizedBox(width: 20),
                                      Expanded(flex: 6, child: textCol),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 3. Bottom Controls: Prev, Dots Indicator, Next / Commencer
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isNarrow ? 14 : 32, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: CapsuleColors.cardBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(horizontal: isNarrow ? 10 : 14, vertical: 8),
                      ),
                      onPressed: _currentPage > 0 ? _prevPage : null,
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 13),
                      label: Text(
                        isNarrow ? 'PRÉC.' : 'PRÉCÉDENT',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),

                    // Dot Indicators
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_tutorialSteps.length, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 20 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isActive ? CapsuleColors.cyanGlow : CapsuleColors.cardBorder,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    // Next / Commencer Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLast ? CapsuleColors.cyanGlow : CapsuleColors.electricBlue,
                        foregroundColor: isLast ? CapsuleColors.deepOcean : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 18, vertical: 10),
                      ),
                      onPressed: _nextPage,
                      icon: Icon(isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_ios_rounded, size: 13),
                      label: Text(
                        isLast ? 'COMMENCER' : 'SUIVANT',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialStepPainter extends CustomPainter {
  final int stepIndex;
  final double progress; // 0..1
  final Color color;

  _TutorialStepPainter({
    required this.stepIndex,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    final center = Offset(size.width / 2, size.height / 2);

    switch (stepIndex) {
      case 0:
        // 1. Move capsule: animated arrows + capsule bobbing/moving
        final capX = size.width * (0.35 + math.sin(t) * 0.15);
        final capY = size.height * (0.5 + math.cos(t * 1.5) * 0.15);

        // Movement directional arrows
        final arrowPaint = Paint()
          ..color = CapsuleColors.cyanGlow.withValues(alpha: 0.4 + 0.3 * math.sin(t * 2))
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(center, 40, arrowPaint);

        // Arrows: up, down, left, right
        _drawArrow(canvas, Offset(center.dx, center.dy - 44), 0, arrowPaint);
        _drawArrow(canvas, Offset(center.dx + 44, center.dy), math.pi / 2, arrowPaint);
        _drawArrow(canvas, Offset(center.dx, center.dy + 44), math.pi, arrowPaint);
        _drawArrow(canvas, Offset(center.dx - 44, center.dy), -math.pi / 2, arrowPaint);

        // Capsule
        _drawMiniCapsule(canvas, Offset(capX, capY), withPropulsion: true, t: t);
        break;

      case 1:
        // 2. Shoot enemies: animated laser beams
        final capPos = Offset(size.width * 0.28, size.height * 0.5);
        final enemyPos = Offset(size.width * 0.72, size.height * 0.5);
        _drawMiniCapsule(canvas, capPos, withPropulsion: true, t: t);

        // Enemy
        canvas.drawCircle(enemyPos, 16, Paint()..color = CapsuleColors.dangerRed);

        // Pulsing laser beam
        final laserCycle = (progress * 3) % 1.0;
        final lx1 = capPos.dx + 22;
        final lx2 = lx1 + (enemyPos.dx - lx1) * laserCycle;
        final beamPaint = Paint()
          ..color = CapsuleColors.cyanGlow
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(lx1, capPos.dy), Offset(lx2, capPos.dy), beamPaint);
        break;

      case 2:
        // 3. Avoid obstacles: capsule dodging up and down
        final capY3 = size.height * (0.5 + math.sin(t * 2) * 0.3);
        _drawMiniCapsule(canvas, Offset(size.width * 0.3, capY3), withPropulsion: true, t: t);

        // Obstacles drifting left
        final obs1X = (size.width * 0.7 - progress * size.width * 0.4) % size.width;
        final obs2X = (size.width * 0.9 - progress * size.width * 0.4) % size.width;
        canvas.drawCircle(Offset(obs1X, size.height * 0.3), 16, Paint()..color = CapsuleColors.dangerOrange);
        canvas.drawCircle(Offset(obs2X, size.height * 0.7), 18, Paint()..color = const Color(0xFF881337));
        break;

      case 3:
        // 4. Collect bonuses: collectibles flying toward capsule
        final capPos4 = Offset(size.width * 0.7, size.height * 0.5);
        _drawMiniCapsule(canvas, capPos4, withPropulsion: false, t: t);

        // Sparkling crystals flying
        for (int i = 0; i < 4; i++) {
          final frac = ((progress + i * 0.25) % 1.0);
          final cx = size.width * 0.15 + (capPos4.dx - size.width * 0.15) * frac;
          final cy = size.height * (0.3 + i * 0.15) + math.sin(t + i) * 10;
          canvas.drawCircle(Offset(cx, cy), 6, Paint()..color = CapsuleColors.gold);
          canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = Colors.white);
        }
        break;

      case 4:
        // 5. Answer questions: mini question panel mockup
        final panelRect = Rect.fromCenter(center: center, width: 140, height: 90);
        canvas.drawRRect(
          RRect.fromRectAndRadius(panelRect, const Radius.circular(10)),
          Paint()..color = CapsuleColors.deepOcean,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(panelRect, const Radius.circular(10)),
          Paint()
            ..color = CapsuleColors.successGreen
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );

        // Question lines
        canvas.drawLine(
          Offset(panelRect.left + 12, panelRect.top + 18),
          Offset(panelRect.right - 12, panelRect.top + 18),
          Paint()..color = Colors.white..strokeWidth = 3,
        );
        // Correct option glow
        final optRect = Rect.fromLTWH(panelRect.left + 10, panelRect.top + 35, 120, 18);
        canvas.drawRRect(
          RRect.fromRectAndRadius(optRect, const Radius.circular(5)),
          Paint()..color = CapsuleColors.successGreen.withValues(alpha: 0.3),
        );
        canvas.drawCircle(Offset(panelRect.left + 20, panelRect.top + 44), 4, Paint()..color = CapsuleColors.successGreen);
        break;

      case 5:
        // 6. Defeat boss: colossal boss exploding
        final bossCenter = Offset(size.width * 0.65, size.height * 0.5);
        canvas.drawCircle(bossCenter, 28, Paint()..color = CapsuleColors.purple);
        canvas.drawCircle(bossCenter, 14, Paint()..color = CapsuleColors.dangerRed);

        // Explosion sparks around boss
        final rand = math.Random(55);
        final expP = (progress * 2) % 1.0;
        for (int i = 0; i < 16; i++) {
          final angle = rand.nextDouble() * math.pi * 2;
          final dist = 28 + expP * 35;
          final px = bossCenter.dx + math.cos(angle) * dist;
          final py = bossCenter.dy + math.sin(angle) * dist;
          canvas.drawCircle(Offset(px, py), 2.5, Paint()..color = CapsuleColors.gold.withValues(alpha: 1.0 - expP));
        }

        // Capsule at left
        _drawMiniCapsule(canvas, Offset(size.width * 0.22, size.height * 0.5), withPropulsion: true, t: t);
        break;
    }
  }

  void _drawArrow(Canvas canvas, Offset tip, double rotation, Paint paint) {
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(rotation);
    final p = Path()
      ..moveTo(0, -6)
      ..lineTo(5, 4)
      ..lineTo(-5, 4)
      ..close();
    canvas.drawPath(p, paint..style = PaintingStyle.fill);
    canvas.restore();
  }

  void _drawMiniCapsule(Canvas canvas, Offset pos, {required bool withPropulsion, required double t}) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    if (withPropulsion) {
      final flame = Path()
        ..moveTo(-16, -5)
        ..lineTo(-32 + math.sin(t * 8) * 4, 0)
        ..lineTo(-16, 5)
        ..close();
      canvas.drawPath(flame, Paint()..color = CapsuleColors.dangerOrange);
    }

    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-16, -10, 32, 20),
      const Radius.circular(10),
    );
    canvas.drawRRect(rrect, Paint()..color = Colors.white);

    // Front cyan
    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(0, -10, 16, 20));
    canvas.drawRRect(rrect, Paint()..color = CapsuleColors.cyanGlow);
    canvas.restore();

    canvas.drawOval(const Rect.fromLTWH(2, -5, 8, 10), Paint()..color = CapsuleColors.electricBlue);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TutorialStepPainter oldDelegate) => true;
}
