import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimeBackground extends StatefulWidget {
  final Widget child;
  final bool showFloatingElements;

  const AnimeBackground({
    super.key,
    required this.child,
    this.showFloatingElements = true,
  });

  @override
  State<AnimeBackground> createState() => _AnimeBackgroundState();
}

class _AnimeBackgroundState extends State<AnimeBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_FloatingParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Generate background ambient particles
    for (int i = 0; i < 28; i++) {
      _particles.add(_FloatingParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.15 + _random.nextDouble() * 0.35,
        size: 4 + _random.nextDouble() * 12,
        type: _ParticleType.values[_random.nextInt(_ParticleType.values.length)],
        opacity: 0.15 + _random.nextDouble() * 0.35,
        rotationSpeed: (_random.nextDouble() - 0.5) * 2,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF040D1A), // Deep navy abyss
            Color(0xFF0A1F38), // Oceanic medical blue
            Color(0xFF082D4F), // Coastal cyan navy
            Color(0xFF031628), // Shadow navy
          ],
          stops: [0.0, 0.35, 0.75, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated floating ambient particles & medical ocean shimmer
          if (widget.showFloatingElements)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                );
              },
            ),

          // Main child content
          widget.child,
        ],
      ),
    );
  }
}

enum _ParticleType { cross, star, circle, diamond, pulse }

class _FloatingParticle {
  double x;
  double y;
  final double speed;
  final double size;
  final _ParticleType type;
  final double opacity;
  final double rotationSpeed;

  _FloatingParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.type,
    required this.opacity,
    required this.rotationSpeed,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_FloatingParticle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Subtle sunburst / adventure rays from top center
    final rayPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.6),
        radius: 1.2,
        colors: [
          const Color(0xFF00E5FF).withOpacity(0.08),
          const Color(0xFFFFD166).withOpacity(0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), rayPaint);

    for (final p in particles) {
      // Animate upward drift like sea bubbles / medical sparkles
      final currentY = ((p.y - progress * p.speed) % 1.0) * h;
      final currentX = ((p.x + math.sin(progress * math.pi * 2 + p.y * 10) * 0.05) % 1.0) * w;
      final rot = progress * p.rotationSpeed * math.pi * 2;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(rot);

      final paint = Paint()
        ..color = (p.type == _ParticleType.cross
                ? const Color(0xFF00E5FF)
                : p.type == _ParticleType.star
                    ? const Color(0xFFFFD166)
                    : const Color(0xFF90E0EF))
            .withOpacity(p.opacity)
        ..style = PaintingStyle.fill;

      switch (p.type) {
        case _ParticleType.cross:
          final s = p.size;
          canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: s, height: s * 0.3), paint);
          canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: s * 0.3, height: s), paint);
          break;
        case _ParticleType.star:
          final s = p.size * 0.8;
          final starPath = Path()
            ..moveTo(0, -s)
            ..lineTo(s * 0.3, -s * 0.3)
            ..lineTo(s, 0)
            ..lineTo(s * 0.3, s * 0.3)
            ..lineTo(0, s)
            ..lineTo(-s * 0.3, s * 0.3)
            ..lineTo(-s, 0)
            ..lineTo(-s * 0.3, -s * 0.3)
            ..close();
          canvas.drawPath(starPath, paint);
          break;
        case _ParticleType.circle:
          canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
          break;
        case _ParticleType.diamond:
          final s = p.size * 0.6;
          final dPath = Path()
            ..moveTo(0, -s)
            ..lineTo(s, 0)
            ..lineTo(0, s)
            ..lineTo(-s, 0)
            ..close();
          canvas.drawPath(dPath, paint);
          break;
        case _ParticleType.pulse:
          final pPaint = Paint()
            ..color = const Color(0xFF00F5D4).withOpacity(p.opacity * 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
          canvas.drawCircle(Offset.zero, p.size * 0.6, pPaint);
          break;
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
