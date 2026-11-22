import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fullscreen overlay warning when the user holds their device in portrait mode.
/// Automatically appears in portrait mode, and disappears when rotated to landscape.
class RotationWarningWrapper extends StatefulWidget {
  final Widget child;

  const RotationWarningWrapper({
    super.key,
    required this.child,
  });

  @override
  State<RotationWarningWrapper> createState() => _RotationWarningWrapperState();
}

class _RotationWarningWrapperState extends State<RotationWarningWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final Animation<double> _rotationAnim;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _rotationAnim = TweenSequence<double>([
      // Hold portrait
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 20),
      // Rotate 90 degrees to landscape
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: math.pi / 2)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 35,
      ),
      // Hold landscape
      TweenSequenceItem(tween: ConstantTween<double>(math.pi / 2), weight: 25),
      // Rotate back
      TweenSequenceItem(
        tween: Tween<double>(begin: math.pi / 2, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 20,
      ),
    ]).animate(_rotationController);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  bool _isFrench(BuildContext context) {
    try {
      final locale = View.of(context).platformDispatcher.locale;
      return locale.languageCode.toLowerCase() == 'fr';
    } catch (_) {
      return true; // Default to French
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isPortrait = media.orientation == Orientation.portrait ||
        (media.size.width < media.size.height && media.size.width < 600);

    return Stack(
      children: [
        widget.child,
        if (isPortrait)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: _buildWarningOverlay(context),
            ),
          ),
      ],
    );
  }

  Widget _buildWarningOverlay(BuildContext context) {
    final isFr = _isFrench(context);

    return Container(
      color: const Color(0xFF0A0E1A),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Rotating Phone Graphic
              AnimatedBuilder(
                animation: _rotationAnim,
                builder: (context, _) {
                  return Transform.rotate(
                    angle: _rotationAnim.value,
                    child: Container(
                      width: 90,
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00E5FF),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Speaker notch
                          Positioned(
                            top: 10,
                            child: Container(
                              width: 32,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF64748B),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          // Screen content preview (Capsule icon)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.medication_liquid_rounded,
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                                size: 36,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 44,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF2A6D),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                          // Home pill
                          Positioned(
                            bottom: 8,
                            child: Container(
                              width: 28,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFF64748B),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 36),

              // Rotation Curved Arrow Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.screen_rotation_rounded,
                  color: Color(0xFF00E5FF),
                  size: 32,
                ),
              ),

              const SizedBox(height: 20),

              // Main Warning Title
              Text(
                isFr
                    ? 'Tournez votre téléphone pour jouer'
                    : 'Rotate your device to play',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle / Instructions
              Text(
                isFr
                    ? 'CAPSULE WARRIORS se joue exclusivement en mode paysage pour une visibilité et une maniabilité optimales.'
                    : 'CAPSULE WARRIORS is best played in landscape mode for optimal arcade visibility and controls.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 28),

              // Neon Pulse Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.screen_lock_landscape_rounded,
                      color: Color(0xFF00E5FF),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isFr ? 'MODE PAYSAGE REQUIS' : 'LANDSCAPE MODE REQUIRED',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF00E5FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
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
