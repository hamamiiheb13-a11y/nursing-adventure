import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_progress.dart';
import '../widgets/tactile_button.dart';

class CapsuleWarriorsIntroScreen extends StatefulWidget {
  final GameProgress progress;
  final VoidCallback onContinue;

  const CapsuleWarriorsIntroScreen({
    super.key,
    required this.progress,
    required this.onContinue,
  });

  @override
  State<CapsuleWarriorsIntroScreen> createState() => _CapsuleWarriorsIntroScreenState();
}

class _CapsuleWarriorsIntroScreenState extends State<CapsuleWarriorsIntroScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _anim;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _scenes = [
    {
      'badge': 'PHASE 1 : INJECTION DE LA NANO-CAPSULE',
      'title': 'Descente dans l\'Estomac',
      'desc':
          'Une capsule médicale de nanorobotique avancée est ingérée par le patient. '
          'Sa mission : cartographier le tractus digestif et prodiguer des soins ciblés.',
      'icon': Icons.medication_liquid_rounded,
      'color': Color(0xFF00E5FF),
    },
    {
      'badge': 'PHASE 2 : ALERTE PATHOLOGIQUE (MICI)',
      'title': 'Muqueuse Gastrique Menacée',
      'desc':
          'Les parois de l\'estomac et du duodénum subissent de violentes poussées inflammatoires : '
          'bactéries pathogènes (Helicobacter), cytokines pro-inflammatoires et ulcérations tissulaires sévères.',
      'icon': Icons.coronavirus_rounded,
      'color': Color(0xFFEF4444),
    },
    {
      'badge': 'PHASE 3 : PROTOCOLE CLINIQUE DU PFE',
      'title': '33 Défis Médicaux Validés',
      'desc':
          'Pour restaurer l\'intégrité de la muqueuse et débloquer vos armes de pointe, '
          'vous devez diagnostiquer chaque lésion en validant les 33 questions cliniques officielles de l\'ISSIT Tunis.',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'badge': 'PHASE 4 : ARSENAL & COMBAT DES 7 BOSS',
      'title': 'Neutralisez les Menaces !',
      'desc':
          'Pilotez la capsule avec les flèches du clavier ou les boutons tactiles, '
          'tirez au laser (Espace), activez votre bouclier énergétique et terrassez les 7 Boss pour obtenir votre diplôme !',
      'icon': Icons.military_tech_rounded,
      'color': Color(0xFFFFD166),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _scenes.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 750;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Stack(
        children: [
          // 2D animated stomach background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                return CustomPaint(
                  painter: _IntroBgPainter(progress: _anim.value),
                );
              },
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar with Skip Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BRIEFING NARRATIF',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF00E5FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.fast_forward_rounded, color: Color(0xFF94A3B8), size: 18),
                        label: Text(
                          'Passer l\'intro',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: widget.onContinue,
                      ),
                    ],
                  ),
                ),

                // PageView with Narrative Slides
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: _scenes.length,
                    itemBuilder: (context, index) {
                      final scene = _scenes[index];
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 620),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              padding: EdgeInsets.all(isMobile ? 22 : 36),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: (scene['color'] as Color).withValues(alpha: 0.6),
                                  width: 1.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (scene['color'] as Color).withValues(alpha: 0.2),
                                    blurRadius: 28,
                                  ),
                                  const BoxShadow(color: Colors.black, blurRadius: 20),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: (scene['color'] as Color).withValues(alpha: 0.18),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: (scene['color'] as Color),
                                        width: 2.2,
                                      ),
                                    ),
                                    child: Icon(
                                      scene['icon'] as IconData,
                                      color: (scene['color'] as Color),
                                      size: 38,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (scene['color'] as Color).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      scene['badge'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: (scene['color'] as Color),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    scene['title'] as String,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: isMobile ? 20 : 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    scene['desc'] as String,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: isMobile ? 13 : 15,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Navigation Dots & Next Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(_scenes.length, (i) {
                            final isActive = i == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isActive ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFF00E5FF) : const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                        TactileButton(
                          label: _currentPage == _scenes.length - 1 ? 'Commencer l\'Aventure' : 'Suivant',
                          icon: Icons.arrow_forward_rounded,
                          style: TactileButtonStyle.primary,
                          height: 48,
                          onPressed: _nextPage,
                        ),
                      ],
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

class _IntroBgPainter extends CustomPainter {
  final double progress;

  _IntroBgPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF030712), Color(0xFF3B0764), Color(0xFF030712)],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF881337).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 5; i++) {
      final y = size.height * (0.2 + i * 0.15) + math.sin(t + i) * 20.0;
      final path = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(size.width * 0.5, y + math.cos(t + i) * 30.0, size.width, y);
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _IntroBgPainter oldDelegate) => true;
}
