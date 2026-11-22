import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EcgMonitorWidget extends StatefulWidget {
  final int bpm;
  final int spo2;
  final String statusText;
  final bool isAlert;
  final double height;

  const EcgMonitorWidget({
    super.key,
    this.bpm = 78,
    this.spo2 = 98,
    this.statusText = 'GARDE ACTIVE • MONITEUR 01',
    this.isAlert = false,
    this.height = 140,
  });

  @override
  State<EcgMonitorWidget> createState() => _EcgMonitorWidgetState();
}

class _EcgMonitorWidgetState extends State<EcgMonitorWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF06111C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isAlert ? const Color(0xFFE11D48) : const Color(0xFF1E293B),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ECG Canvas layer
          AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: _EcgPainter(
                  sweepProgress: _animController.value,
                  isAlert: widget.isAlert,
                ),
              );
            },
          ),

          // Digital HUD readouts overlay
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Status & Patient state
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: widget.isAlert ? const Color(0xFFE11D48) : const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.isAlert
                                      ? const Color(0xFFE11D48).withValues(alpha: 0.6)
                                      : const Color(0xFF10B981).withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.statusText,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                color: widget.isAlert ? const Color(0xFFFDA4AF) : const Color(0xFF6EE7B7),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ECG LEAD II • EN DIRECT',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: Vitals readout (BPM + SpO2)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // BPM
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${widget.bpm}',
                              style: GoogleFonts.plusJakartaSans(
                                color: widget.isAlert ? const Color(0xFFF43F5E) : const Color(0xFF34D399),
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'BPM',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // SpO2
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${widget.spo2}%',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF38BDF8),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'SpO2',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final double sweepProgress; // 0.0 to 1.0
  final bool isAlert;

  _EcgPainter({
    required this.sweepProgress,
    required this.isAlert,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double baselineY = height * 0.62;

    // 1. Medical monitor background grid
    final Paint gridPaint = Paint()
      ..color = const Color(0xFF0F2338).withValues(alpha: 0.5)
      ..strokeWidth = 0.8;

    const double gridSpacing = 18.0;
    for (double x = 0; x < width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }
    for (double y = 0; y < height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // 2. Compute ECG wave points
    // A classic cardiac cycle pattern (P, Q, R, S, T)
    const double cycleWidth = 140.0;
    final int numPoints = (width * 1.5).toInt();
    final List<Offset> points = [];

    for (int i = 0; i <= numPoints; i++) {
      final double x = (i / numPoints) * width;
      final double cycleX = (x % cycleWidth) / cycleWidth; // 0.0 to 1.0 in each heartbeat
      double yOffset = 0.0;

      if (cycleX >= 0.15 && cycleX < 0.25) {
        // P Wave (smooth rounded small hump)
        final double t = (cycleX - 0.15) / 0.10;
        yOffset = -math.sin(t * math.pi) * (isAlert ? 8.0 : 6.0);
      } else if (cycleX >= 0.28 && cycleX < 0.31) {
        // Q Dip (small down)
        final double t = (cycleX - 0.28) / 0.03;
        yOffset = math.sin(t * math.pi) * 5.0;
      } else if (cycleX >= 0.31 && cycleX < 0.37) {
        // R Spike (high sharp peak)
        final double t = (cycleX - 0.31) / 0.06;
        if (t < 0.5) {
          yOffset = - (t / 0.5) * (isAlert ? 48.0 : 38.0);
        } else {
          yOffset = - (1.0 - (t - 0.5) / 0.5) * (isAlert ? 48.0 : 38.0);
        }
      } else if (cycleX >= 0.37 && cycleX < 0.41) {
        // S Dip (negative rebound)
        final double t = (cycleX - 0.37) / 0.04;
        yOffset = math.sin(t * math.pi) * (isAlert ? 14.0 : 10.0);
      } else if (cycleX >= 0.48 && cycleX < 0.65) {
        // T Wave (broad positive dome)
        final double t = (cycleX - 0.48) / 0.17;
        yOffset = -math.sin(t * math.pi) * (isAlert ? 12.0 : 9.0);
      }

      points.add(Offset(x, baselineY + yOffset));
    }

    final double sweepX = sweepProgress * width;
    const double fadeTail = 120.0; // tail length behind the sweep

    // 3. Draw ECG path with fading trail
    final Color mainColor = isAlert ? const Color(0xFFF43F5E) : const Color(0xFF10B981);

    for (int i = 0; i < points.length - 1; i++) {
      final Offset p1 = points[i];
      final Offset p2 = points[i + 1];

      // Distance from sweep head (taking wrapping into account)
      double distBehind = sweepX - p1.dx;
      if (distBehind < 0) {
        distBehind += width;
      }

      double alpha = 0.0;
      if (distBehind < fadeTail) {
        alpha = (1.0 - (distBehind / fadeTail)).clamp(0.05, 1.0);
      } else {
        alpha = 0.08; // subtle ghost line
      }

      final Paint linePaint = Paint()
        ..color = mainColor.withValues(alpha: alpha)
        ..strokeWidth = distBehind < 20 ? 2.5 : 1.8
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, linePaint);
    }

    // 4. Luminous sweep cursor
    final double sweepY = points.firstWhere(
      (p) => (p.dx - sweepX).abs() < 2.0,
      orElse: () => Offset(sweepX, baselineY),
    ).dy;

    final Paint glowPaint = Paint()
      ..color = (isAlert ? const Color(0xFFFDA4AF) : const Color(0xFF6EE7B7)).withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    canvas.drawCircle(Offset(sweepX, sweepY), 4.5, glowPaint);

    final Paint headPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(sweepX, sweepY), 2.2, headPaint);
  }

  @override
  bool shouldRepaint(covariant _EcgPainter oldDelegate) {
    return oldDelegate.sweepProgress != sweepProgress || oldDelegate.isAlert != isAlert;
  }
}
