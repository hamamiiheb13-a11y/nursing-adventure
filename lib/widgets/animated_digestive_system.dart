import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedDigestiveSystem extends StatefulWidget {
  final double width;
  final double height;
  final bool interactive;
  final Function(String hotspotName)? onHotspotTapped;

  const AnimatedDigestiveSystem({
    super.key,
    this.width = 320,
    this.height = 360,
    this.interactive = true,
    this.onHotspotTapped,
  });

  @override
  State<AnimatedDigestiveSystem> createState() => _AnimatedDigestiveSystemState();
}

class _AnimatedDigestiveSystemState extends State<AnimatedDigestiveSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _selectedHotspot;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectHotspot(String name) {
    setState(() {
      _selectedHotspot = (_selectedHotspot == name) ? null : name;
    });
    if (widget.onHotspotTapped != null) {
      widget.onHotspotTapped!(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF081426),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF00E5FF).withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.12),
            blurRadius: 28,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Grid and Anatomical HUD
            CustomPaint(
              size: Size(widget.width, widget.height),
              painter: _DigestiveHudPainter(),
            ),

            // Animated Digestive Tract
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: _DigestiveTractPainter(
                    progress: _controller.value,
                    selectedHotspot: _selectedHotspot,
                  ),
                );
              },
            ),

            // Hotspot Buttons (Overlayed for interaction)
            if (widget.interactive) ...[
              _buildHotspot(
                label: 'Estomac',
                color: const Color(0xFF38BDF8),
                leftFraction: 0.40,
                topFraction: 0.28,
              ),
              _buildHotspot(
                label: 'Iléon terminal',
                subtitle: 'Siège Crohn',
                color: const Color(0xFF00E5FF),
                leftFraction: 0.38,
                topFraction: 0.64,
              ),
              _buildHotspot(
                label: 'Côlon',
                subtitle: 'Siège RCH',
                color: const Color(0xFF10B981),
                leftFraction: 0.70,
                topFraction: 0.48,
              ),
              _buildHotspot(
                label: 'Villosités',
                subtitle: 'Surface d\'échange',
                color: const Color(0xFFFFD166),
                leftFraction: 0.16,
                topFraction: 0.52,
              ),
            ],

            // Top Status Header
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withOpacity(0.4),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.biotech_rounded, color: Color(0xFF00E5FF), size: 13),
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'ANATOMIE MICI',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF00E5FF),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: Color(0xFF10B981),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'FLUX ACTIF',
                          style: TextStyle(
                            color: Color(0xFFA7F3D0),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotspot({
    required String label,
    String? subtitle,
    required Color color,
    required double leftFraction,
    required double topFraction,
  }) {
    final isSelected = _selectedHotspot == label;
    return Positioned(
      left: widget.width * leftFraction,
      top: widget.height * topFraction,
      child: GestureDetector(
        onTap: () => _selectHotspot(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.28) : const Color(0xFF0A1F38).withOpacity(0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.55),
              width: isSelected ? 1.6 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isSelected ? 0.35 : 0.15),
                blurRadius: isSelected ? 12 : 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 4,
                backgroundColor: color,
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: color,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DigestiveHudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.04)
      ..strokeWidth = 1.0;

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Concentric medical radar rings in center
    final center = Offset(size.width * 0.5, size.height * 0.52);
    final ringPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, size.width * 0.30, ringPaint);
    canvas.drawCircle(center, size.width * 0.42, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DigestiveTractPainter extends CustomPainter {
  final double progress;
  final String? selectedHotspot;

  _DigestiveTractPainter({
    required this.progress,
    this.selectedHotspot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Esophagus (Œsophage)
    final esophagusPaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.4)
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.50, h * 0.12), Offset(w * 0.50, h * 0.25), esophagusPaint);

    // 2. Stomach (Estomac) - J-shaped organ
    final stomachPath = Path();
    stomachPath.moveTo(w * 0.50, h * 0.24);
    stomachPath.cubicTo(
      w * 0.32, h * 0.23,
      w * 0.28, h * 0.36,
      w * 0.42, h * 0.40,
    );
    stomachPath.cubicTo(
      w * 0.52, h * 0.42,
      w * 0.58, h * 0.37,
      w * 0.55, h * 0.33,
    );
    stomachPath.cubicTo(
      w * 0.52, h * 0.29,
      w * 0.52, h * 0.25,
      w * 0.50, h * 0.24,
    );

    final stomachFill = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0284C7).withOpacity(0.7),
          const Color(0xFF0369A1).withOpacity(0.4),
        ],
      ).createShader(Rect.fromLTWH(w * 0.28, h * 0.23, w * 0.30, h * 0.20));
    canvas.drawPath(stomachPath, stomachFill);

    final stomachBorder = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawPath(stomachPath, stomachBorder);

    // 3. Large Intestine / Colon (Côlon Ascendant, Transverse, Descendant, Sigmoïde, Rectum)
    // Frame around the small intestine
    final colonPath = Path();
    // Start at Caecum (lower right)
    final caecum = Offset(w * 0.30, h * 0.72);
    colonPath.moveTo(caecum.dx, caecum.dy);

    // Ascending colon (right side in anatomical view -> left visually)
    colonPath.lineTo(w * 0.28, h * 0.48);
    // Hepatic flexure
    colonPath.quadraticBezierTo(w * 0.28, h * 0.43, w * 0.36, h * 0.44);
    // Transverse colon
    colonPath.cubicTo(
      w * 0.46, h * 0.46,
      w * 0.60, h * 0.44,
      w * 0.72, h * 0.43,
    );
    // Splenic flexure
    colonPath.quadraticBezierTo(w * 0.76, h * 0.44, w * 0.75, h * 0.50);
    // Descending colon
    colonPath.lineTo(w * 0.75, h * 0.72);
    // Sigmoid colon
    colonPath.cubicTo(
      w * 0.74, h * 0.80,
      w * 0.58, h * 0.82,
      w * 0.52, h * 0.86,
    );
    // Rectum
    colonPath.lineTo(w * 0.52, h * 0.94);

    final colonPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(colonPath, colonPaint);

    final colonOutline = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawPath(colonPath, colonOutline);

    // Colon haustra segments (accent rings along colon)
    final segmentPaint = Paint()
      ..color = const Color(0xFFA7F3D0).withOpacity(0.6)
      ..strokeWidth = 2.0;
    _drawColonHaustra(canvas, colonPath, segmentPaint);

    // 4. Small Intestine (Intestin Grêle & Iléon Terminal)
    final smallIntestinePath = Path();
    smallIntestinePath.moveTo(w * 0.55, h * 0.38); // Duodenum exit
    smallIntestinePath.cubicTo(w * 0.62, h * 0.46, w * 0.42, h * 0.50, w * 0.50, h * 0.54);
    smallIntestinePath.cubicTo(w * 0.60, h * 0.56, w * 0.42, h * 0.60, w * 0.56, h * 0.62);
    smallIntestinePath.cubicTo(w * 0.64, h * 0.64, w * 0.40, h * 0.68, w * 0.48, h * 0.70);
    // End at Iléon terminal connecting into Cæcum
    smallIntestinePath.lineTo(w * 0.32, h * 0.72);

    final smallIntestinePaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(smallIntestinePath, smallIntestinePaint);

    final smallIntestineOutline = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(smallIntestinePath, smallIntestineOutline);

    // Highlight: Iléon terminal (Terminal Ileum) - key Crohn site
    final ileumGlow = Paint()
      ..color = const Color(0xFFFFD166).withOpacity(0.4 + 0.25 * math.sin(progress * 2 * math.pi))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(w * 0.33, h * 0.72), 14, ileumGlow);
    final ileumPoint = Paint()..color = const Color(0xFFFFD166);
    canvas.drawCircle(Offset(w * 0.33, h * 0.72), 5, ileumPoint);

    // 5. Animated Bioluminescent Transit Particles travelling through the system
    _drawAnimatedTransit(canvas, smallIntestinePath, colonPath, progress, size);
  }

  void _drawColonHaustra(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    const totalDashes = 18;
    final length = metric.length;
    for (int i = 1; i < totalDashes; i++) {
      final distance = (length / totalDashes) * i;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent != null) {
        final normal = Offset(-tangent.vector.dy, tangent.vector.dx) * 9.0;
        canvas.drawLine(
          tangent.position - normal,
          tangent.position + normal,
          paint,
        );
      }
    }
  }

  void _drawAnimatedTransit(
    Canvas canvas,
    Path smallPath,
    Path colonPath,
    double t,
    Size size,
  ) {
    final smallMetrics = smallPath.computeMetrics().toList();
    final colonMetrics = colonPath.computeMetrics().toList();
    if (smallMetrics.isEmpty || colonMetrics.isEmpty) return;

    final smallMetric = smallMetrics.first;
    final colonMetric = colonMetrics.first;

    // Small intestine particles (Cyan & Gold)
    const int numParticles = 4;
    for (int i = 0; i < numParticles; i++) {
      final pT = (t + (i / numParticles)) % 1.0;
      final dist = smallMetric.length * pT;
      final tangent = smallMetric.getTangentForOffset(dist);
      if (tangent != null) {
        final particleGlow = Paint()
          ..color = const Color(0xFF00E5FF).withOpacity(0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(tangent.position, 6.0, particleGlow);
        final particleCore = Paint()..color = Colors.white;
        canvas.drawCircle(tangent.position, 2.5, particleCore);
      }
    }

    // Colon particles (Green & Emerald)
    for (int i = 0; i < numParticles; i++) {
      final pT = (t + 0.5 + (i / numParticles)) % 1.0;
      final dist = colonMetric.length * pT;
      final tangent = colonMetric.getTangentForOffset(dist);
      if (tangent != null) {
        final particleGlow = Paint()
          ..color = const Color(0xFF10B981).withOpacity(0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(tangent.position, 6.0, particleGlow);
        final particleCore = Paint()..color = const Color(0xFFA7F3D0);
        canvas.drawCircle(tangent.position, 2.5, particleCore);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DigestiveTractPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.selectedHotspot != selectedHotspot;
  }
}
