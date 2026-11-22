import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EndoscopyCanvasWidget extends StatefulWidget {
  final int step; // 1 to 4
  final int inflammationPercentage; // 100% down to 0%
  final int bpm;
  final bool isTargetLocked;
  final bool? isAnswerCorrect; // null before answer, true if correct, false if wrong
  final VoidCallback onTargetLocked;
  final double height;

  const EndoscopyCanvasWidget({
    super.key,
    required this.step,
    required this.inflammationPercentage,
    this.bpm = 82,
    required this.isTargetLocked,
    this.isAnswerCorrect,
    required this.onTargetLocked,
    this.height = 320,
  });

  @override
  State<EndoscopyCanvasWidget> createState() => _EndoscopyCanvasWidgetState();
}

class _EndoscopyCanvasWidgetState extends State<EndoscopyCanvasWidget> with SingleTickerProviderStateMixin {
  late AnimationController _peristalticController;

  // Reticle relative position (-1.0 to 1.0 from center)
  Offset _reticlePos = const Offset(0.0, 0.25);
  // Target position for each step
  late Offset _targetPos;

  double _lockProgress = 0.0;
  bool _isLocking = false;

  @override
  void initState() {
    super.initState();
    _peristalticController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _updateTargetForStep();
  }

  @override
  void didUpdateWidget(covariant EndoscopyCanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      _updateTargetForStep();
      _lockProgress = 0.0;
      _isLocking = false;
      _reticlePos = const Offset(0.0, 0.25); // reset reticle offset
    }
  }

  void _updateTargetForStep() {
    // Unique distinct target location in the mucosal field for each step
    switch (widget.step) {
      case 1:
        _targetPos = const Offset(-0.25, -0.22); // Fistula lesion
        break;
      case 2:
        _targetPos = const Offset(0.28, -0.15); // Ileal junction
        break;
      case 3:
        _targetPos = const Offset(-0.20, 0.22); // Colonic fold
        break;
      case 4:
      default:
        _targetPos = const Offset(0.22, 0.18); // Mucosal villi cluster
        break;
    }
  }

  @override
  void dispose() {
    _peristalticController.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details, Size viewSize) {
    if (widget.isTargetLocked) return;

    final double radius = viewSize.shortestSide / 2.0;
    if (radius <= 0) return;

    setState(() {
      final double dx = _reticlePos.dx + (details.delta.dx / radius);
      final double dy = _reticlePos.dy + (details.delta.dy / radius);

      // Clamp within circular field of view
      final double dist = math.sqrt(dx * dx + dy * dy);
      if (dist <= 0.75) {
        _reticlePos = Offset(dx, dy);
      } else {
        _reticlePos = Offset(dx / dist * 0.75, dy / dist * 0.75);
      }

      _checkTargetProximity();
    });
  }

  void _checkTargetProximity() {
    if (widget.isTargetLocked) return;

    final double distToTarget = (_reticlePos - _targetPos).distance;
    // If within ~0.22 normalized distance threshold
    if (distToTarget < 0.22) {
      _lockProgress = (_lockProgress + 0.25).clamp(0.0, 1.0);
      if (_lockProgress >= 1.0 && !_isLocking) {
        _isLocking = true;
        widget.onTargetLocked();
      }
    } else {
      _lockProgress = math.max(0.0, _lockProgress - 0.15);
    }
  }

  void _autoTarget() {
    if (widget.isTargetLocked) return;
    setState(() {
      _reticlePos = _targetPos;
      _lockProgress = 1.0;
      _isLocking = true;
    });
    widget.onTargetLocked();
  }

  String _getZoneLabel() {
    switch (widget.step) {
      case 1:
        return 'ZONE 1 • LÉSION TRANSMURALE & PERTUIS';
      case 2:
        return 'ZONE 2 • JONCTION ILÉO-CÆCALE & ILÉON';
      case 3:
        return 'ZONE 3 • CADRE COLIQUE & HAUSTRASTIONS';
      case 4:
      default:
        return 'ZONE 4 • VILLOSITÉS DU GRÊLE (HD ZOOM)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAlert = widget.isAnswerCorrect == false;
    final bool isHealed = widget.isAnswerCorrect == true;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF030A12), // Deep endoscope monitor black
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAlert
              ? const Color(0xFFE11D48)
              : (isHealed ? const Color(0xFF10B981) : const Color(0xFF1E293B)),
          width: isAlert || isHealed ? 2.5 : 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final Size viewSize = Size(constraints.maxWidth, constraints.maxHeight);

          return Stack(
            children: [
              // 1. Organic Endoscopic Canvas
              GestureDetector(
                onPanUpdate: (d) => _handlePanUpdate(d, viewSize),
                behavior: HitTestBehavior.opaque,
                child: AnimatedBuilder(
                  animation: _peristalticController,
                  builder: (context, _) {
                    return CustomPaint(
                      size: viewSize,
                      painter: _EndoscopyPainter(
                        animationValue: _peristalticController.value,
                        step: widget.step,
                        reticlePos: widget.isTargetLocked ? _targetPos : _reticlePos,
                        targetPos: _targetPos,
                        lockProgress: widget.isTargetLocked ? 1.0 : _lockProgress,
                        isTargetLocked: widget.isTargetLocked,
                        isAnswerCorrect: widget.isAnswerCorrect,
                        inflammationRate: widget.inflammationPercentage / 100.0,
                      ),
                    );
                  },
                ),
              ),

              // 2. Medical HUD Overlay (Top & Bottom bars)
              Positioned(
                top: 12,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Zone badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.6),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2DD4BF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getZoneLabel(),
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFCCFBF1),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Optics info
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'HD 4K • 3.2x',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom HUD: Patient Sami Inflammation + Guidance / Lock state
              Positioned(
                bottom: 12,
                left: 14,
                right: 14,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Locked or Target guidance banner
                    if (widget.isTargetLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF10B981), width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'CIBLE VERROUILLÉE — ANALYSE CLINIQUE EN COURS',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.touch_app_rounded, color: Color(0xFF38BDF8), size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Glissez pour cibler l\'anomalie',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFE2E8F0),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Discrete auto-target button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: _autoTarget,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF475569), width: 0.8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.my_location_rounded, color: Color(0xFF2DD4BF), size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Ciblage auto',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFCCFBF1),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),

                    // Sami Inflammation Level Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A131F).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Sami • Inflammation :',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: widget.inflammationPercentage / 100.0,
                                minHeight: 6,
                                backgroundColor: const Color(0xFF1E293B),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.inflammationPercentage > 50
                                      ? const Color(0xFFE11D48)
                                      : (widget.inflammationPercentage > 0
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFF10B981)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.inflammationPercentage}%',
                            style: GoogleFonts.plusJakartaSans(
                              color: widget.inflammationPercentage > 0
                                  ? const Color(0xFFFDA4AF)
                                  : const Color(0xFF6EE7B7),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EndoscopyPainter extends CustomPainter {
  final double animationValue; // 0.0 to 1.0
  final int step;
  final Offset reticlePos;
  final Offset targetPos;
  final double lockProgress;
  final bool isTargetLocked;
  final bool? isAnswerCorrect;
  final double inflammationRate;

  _EndoscopyPainter({
    required this.animationValue,
    required this.step,
    required this.reticlePos,
    required this.targetPos,
    required this.lockProgress,
    required this.isTargetLocked,
    required this.isAnswerCorrect,
    required this.inflammationRate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final Offset center = Offset(width / 2.0, height / 2.0);
    final double radius = math.min(width, height) * 0.44;

    // 1. Clip to circular / rounded optical lens
    final Path clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.save();
    canvas.clipPath(clipPath);

    // 2. Draw Intestinal Mucosal background with organic folds
    _drawMucosa(canvas, center, radius);

    // 3. Draw Target Lesion
    _drawLesion(canvas, center, radius);

    // 4. Optical Vignetting (dark edges typical of endoscopic lenses)
    _drawVignette(canvas, center, radius);

    // 5. Draw Endoscopic Reticle & Lock Ring
    _drawReticle(canvas, center, radius);

    canvas.restore();

    // 6. Outer circular metallic scope bezel
    final Paint bezelPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, bezelPaint);

    // Inner optical bezel ring
    final Paint innerBezel = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 2, innerBezel);
  }

  void _drawMucosa(Canvas canvas, Offset center, double radius) {
    // Breathing peristalsis
    final double wave = math.sin(animationValue * 2 * math.pi);
    final double breathingRadius = radius + wave * 3.5;

    // Intestinal background gradient (pinkish-red mucosa)
    final Color mucosalBase = Color.lerp(
      const Color(0xFF6B2129), // Deep intestinal pink/crimson
      const Color(0xFF881337), // Inflamed active
      inflammationRate,
    )!;

    final Paint bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [
          mucosalBase,
          const Color(0xFF3B0713),
          const Color(0xFF180308),
        ],
        stops: const [0.35, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: breathingRadius));

    canvas.drawCircle(center, breathingRadius, bgPaint);

    // Organic circular folds (haustrations & peristaltic rings)
    final Paint foldPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int ring = 1; ring <= 4; ring++) {
      final double r = radius * (ring * 0.22);
      final double pulse = math.sin(animationValue * 2 * math.pi + ring * 0.8) * 4.0;
      final Rect ovalRect = Rect.fromCenter(
        center: center,
        width: (r + pulse) * 2.1,
        height: (r + pulse) * 1.85,
      );

      foldPaint.color = const Color(0xFF9F1239).withValues(alpha: 0.35);
      foldPaint.strokeWidth = 4.0 + ring;
      canvas.drawOval(ovalRect, foldPaint);

      foldPaint.color = const Color(0xFFFDA4AF).withValues(alpha: 0.15);
      foldPaint.strokeWidth = 1.5;
      canvas.drawOval(ovalRect, foldPaint);
    }
  }

  void _drawLesion(Canvas canvas, Offset center, double radius) {
    final Offset lesionCenter = Offset(
      center.dx + targetPos.dx * radius,
      center.dy + targetPos.dy * radius,
    );

    final bool isHealed = isAnswerCorrect == true;
    final double pulse = math.sin(animationValue * 4 * math.pi) * 2.0;

    // Outer erythema halo
    final Paint erythemaPaint = Paint()
      ..shader = RadialGradient(
        colors: isHealed
            ? [
                const Color(0xFF10B981).withValues(alpha: 0.6),
                const Color(0xFF047857).withValues(alpha: 0.0),
              ]
            : [
                const Color(0xFFE11D48).withValues(alpha: 0.75),
                const Color(0xFF9F1239).withValues(alpha: 0.0),
              ],
      ).createShader(Rect.fromCircle(center: lesionCenter, radius: 28.0 + pulse));

    canvas.drawCircle(lesionCenter, 28.0 + pulse, erythemaPaint);

    // Core lesion based on step
    if (step == 1) {
      // Step 1: Fistula tract / abnormal ulcerated orifice
      final Paint ulcerPaint = Paint()
        ..color = isHealed ? const Color(0xFF065F46) : const Color(0xFF200308)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(center: lesionCenter, width: 14, height: 8),
        ulcerPaint,
      );

      final Paint ringPaint = Paint()
        ..color = isHealed ? const Color(0xFF34D399) : const Color(0xFFF43F5E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawOval(
        Rect.fromCenter(center: lesionCenter, width: 18, height: 11),
        ringPaint,
      );
    } else if (step == 2) {
      // Step 2: Terminal ileum mucosal cobblestone ulcer
      for (int i = 0; i < 4; i++) {
        final double angle = i * math.pi / 2;
        final Offset sub = Offset(
          lesionCenter.dx + math.cos(angle) * 7,
          lesionCenter.dy + math.sin(angle) * 7,
        );
        final Paint cobblePaint = Paint()
          ..color = isHealed ? const Color(0xFF10B981) : const Color(0xFFBE123C);
        canvas.drawCircle(sub, 4.5, cobblePaint);
      }
    } else if (step == 3) {
      // Step 3: Colonic absorption zone
      final Paint haustraPaint = Paint()
        ..color = isHealed ? const Color(0xFF34D399) : const Color(0xFFFB7185)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawArc(
        Rect.fromCircle(center: lesionCenter, radius: 12),
        0.2,
        math.pi * 1.6,
        false,
        haustraPaint,
      );
    } else {
      // Step 4: Small bowel micro-villi carpet
      for (int i = 0; i < 7; i++) {
        final double angle = i * 2 * math.pi / 7;
        final Offset v = Offset(
          lesionCenter.dx + math.cos(angle) * 9,
          lesionCenter.dy + math.sin(angle) * 9,
        );
        final Paint villiPaint = Paint()
          ..color = isHealed ? const Color(0xFF6EE7B7) : const Color(0xFFFDA4AF);
        canvas.drawCircle(v, 2.8, villiPaint);
      }
    }
  }

  void _drawVignette(Canvas canvas, Offset center, double radius) {
    final Paint vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.transparent,
          Colors.transparent,
          const Color(0x99000000),
          const Color(0xE6000000),
        ],
        stops: const [0.0, 0.65, 0.88, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, vignettePaint);
  }

  void _drawReticle(Canvas canvas, Offset center, double radius) {
    final Offset reticleCenter = Offset(
      center.dx + reticlePos.dx * radius,
      center.dy + reticlePos.dy * radius,
    );

    final bool isLocked = isTargetLocked;
    final Color reticleColor = isLocked
        ? const Color(0xFF10B981)
        : (lockProgress > 0 ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0));

    // 1. Crosshair lines
    final Paint linePaint = Paint()
      ..color = reticleColor.withValues(alpha: 0.7)
      ..strokeWidth = 1.2;

    const double crossLen = 14.0;
    const double gap = 7.0;

    canvas.drawLine(
      Offset(reticleCenter.dx - crossLen, reticleCenter.dy),
      Offset(reticleCenter.dx - gap, reticleCenter.dy),
      linePaint,
    );
    canvas.drawLine(
      Offset(reticleCenter.dx + gap, reticleCenter.dy),
      Offset(reticleCenter.dx + crossLen, reticleCenter.dy),
      linePaint,
    );
    canvas.drawLine(
      Offset(reticleCenter.dx, reticleCenter.dy - crossLen),
      Offset(reticleCenter.dx, reticleCenter.dy - gap),
      linePaint,
    );
    canvas.drawLine(
      Offset(reticleCenter.dx, reticleCenter.dy + gap),
      Offset(reticleCenter.dx, reticleCenter.dy + crossLen),
      linePaint,
    );

    // 2. Optical Reticle Corners / Brackets
    final Paint bracketPaint = Paint()
      ..color = reticleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isLocked ? 2.2 : 1.5;

    const double bSize = 22.0;
    const double bCorner = 6.0;

    // Top-Left
    canvas.drawLine(
      Offset(reticleCenter.dx - bSize, reticleCenter.dy - bSize),
      Offset(reticleCenter.dx - bSize + bCorner, reticleCenter.dy - bSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(reticleCenter.dx - bSize, reticleCenter.dy - bSize),
      Offset(reticleCenter.dx - bSize, reticleCenter.dy - bSize + bCorner),
      bracketPaint,
    );

    // Top-Right
    canvas.drawLine(
      Offset(reticleCenter.dx + bSize, reticleCenter.dy - bSize),
      Offset(reticleCenter.dx + bSize - bCorner, reticleCenter.dy - bSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(reticleCenter.dx + bSize, reticleCenter.dy - bSize),
      Offset(reticleCenter.dx + bSize, reticleCenter.dy - bSize + bCorner),
      bracketPaint,
    );

    // Bottom-Left
    canvas.drawLine(
      Offset(reticleCenter.dx - bSize, reticleCenter.dy + bSize),
      Offset(reticleCenter.dx - bSize + bCorner, reticleCenter.dy + bSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(reticleCenter.dx - bSize, reticleCenter.dy + bSize),
      Offset(reticleCenter.dx - bSize, reticleCenter.dy + bSize - bCorner),
      bracketPaint,
    );

    // Bottom-Right
    canvas.drawLine(
      Offset(reticleCenter.dx + bSize, reticleCenter.dy + bSize),
      Offset(reticleCenter.dx + bSize - bCorner, reticleCenter.dy + bSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(reticleCenter.dx + bSize, reticleCenter.dy + bSize),
      Offset(reticleCenter.dx + bSize, reticleCenter.dy + bSize - bCorner),
      bracketPaint,
    );

    // 3. Progress Lock Ring
    if (lockProgress > 0) {
      final Paint ringPaint = Paint()
        ..color = (isLocked ? const Color(0xFF10B981) : const Color(0xFF38BDF8))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: reticleCenter, radius: bSize + 5),
        -math.pi / 2,
        2 * math.pi * lockProgress,
        false,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EndoscopyPainter oldDelegate) {
    return true; // Peristalsis animation 60 FPS
  }
}
