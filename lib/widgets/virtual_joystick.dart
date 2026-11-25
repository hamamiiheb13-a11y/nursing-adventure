import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full Touch Controls widget combining:
/// - Left: 8-directional virtual analog joystick (80px radius base, 40px radius knob)
/// - Right: Large FIRE button (red glow, 70px radius / 140px diameter)
///          + Smaller SHIELD button (blue glow, 45px radius / 90px diameter)
class VirtualJoystickControls extends StatelessWidget {
  final ValueChanged<Offset>? onMove; // Normalized vector (-1..1, -1..1)
  final Function(bool up, bool down, bool left, bool right)? onDirectionChanged;
  final VoidCallback? onFire;
  final VoidCallback? onFireDown;
  final VoidCallback? onFireUp;
  final VoidCallback? onShield;
  final VoidCallback? onShieldDown;
  final VoidCallback? onShieldUp;

  const VirtualJoystickControls({
    super.key,
    this.onMove,
    this.onDirectionChanged,
    this.onFire,
    this.onFireDown,
    this.onFireUp,
    this.onShield,
    this.onShieldDown,
    this.onShieldUp,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Scale slightly down on very small phone landscape screens
    final double scale = (size.height / 500.0).clamp(0.65, 1.0);

    return Transform.scale(
      scale: scale,
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Left Joystick
            VirtualAnalogJoystick(
              radius: 75.0,
              knobRadius: 36.0,
              onMove: onMove,
              onDirectionChanged: onDirectionChanged,
            ),

            // Right Action Buttons (Fire + Shield)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Shield Button (Cyan/Blue Neon, 45px radius)
                _TouchActionButton(
                  radius: 42.0,
                  icon: Icons.shield_rounded,
                  label: 'BOUCLIER',
                  primaryColor: const Color(0xFF00E5FF),
                  glowColor: const Color(0xFF00B4D8),
                  onTap: onShield,
                  onPointerDown: onShieldDown,
                  onPointerUp: onShieldUp,
                ),
                const SizedBox(width: 20),

                // Fire Button (Red/Orange Neon, 70px radius)
                _TouchActionButton(
                  radius: 65.0,
                  icon: Icons.flash_on_rounded,
                  label: 'TIR',
                  primaryColor: const Color(0xFFFF2A6D),
                  glowColor: const Color(0xFFFF5E7E),
                  onTap: onFire,
                  onPointerDown: onFireDown,
                  onPointerUp: onFireUp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone Virtual Analog Joystick widget
class VirtualAnalogJoystick extends StatefulWidget {
  final double radius;
  final double knobRadius;
  final ValueChanged<Offset>? onMove;
  final Function(bool up, bool down, bool left, bool right)? onDirectionChanged;

  const VirtualAnalogJoystick({
    super.key,
    this.radius = 75.0,
    this.knobRadius = 36.0,
    this.onMove,
    this.onDirectionChanged,
  });

  @override
  State<VirtualAnalogJoystick> createState() => _VirtualAnalogJoystickState();
}

class _VirtualAnalogJoystickState extends State<VirtualAnalogJoystick> {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  int? _activePointer;
  static const double _touchPadding = 16.0;

  void _updatePosition(Offset localPosition) {
    final center = Offset(widget.radius + _touchPadding, widget.radius + _touchPadding);
    final delta = localPosition - center;
    final distance = delta.distance;
    final maxDist = widget.radius - widget.knobRadius * 0.35;

    Offset clampedDelta;
    if (distance <= maxDist) {
      clampedDelta = delta;
    } else {
      clampedDelta = Offset.fromDirection(delta.direction, maxDist);
    }

    setState(() {
      _dragOffset = clampedDelta;
      _isDragging = true;
    });

    final normalized = Offset(
      (clampedDelta.dx / maxDist).clamp(-1.0, 1.0),
      (clampedDelta.dy / maxDist).clamp(-1.0, 1.0),
    );

    widget.onMove?.call(normalized);

    if (widget.onDirectionChanged != null) {
      const deadzone = 0.20;
      widget.onDirectionChanged!(
        normalized.dy < -deadzone,
        normalized.dy > deadzone,
        normalized.dx < -deadzone,
        normalized.dx > deadzone,
      );
    }
  }

  void _resetStick() {
    _activePointer = null;
    setState(() {
      _dragOffset = Offset.zero;
      _isDragging = false;
    });
    widget.onMove?.call(Offset.zero);
    widget.onDirectionChanged?.call(false, false, false, false);
  }

  @override
  Widget build(BuildContext context) {
    final totalSize = (widget.radius + _touchPadding) * 2;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        _activePointer = event.pointer;
        _updatePosition(event.localPosition);
      },
      onPointerMove: (event) {
        if (_activePointer == null || _activePointer == event.pointer) {
          _updatePosition(event.localPosition);
        }
      },
      onPointerUp: (event) {
        if (_activePointer == event.pointer) _resetStick();
      },
      onPointerCancel: (event) {
        if (_activePointer == event.pointer) _resetStick();
      },
      child: SizedBox(
        width: totalSize,
        height: totalSize,
        child: Padding(
          padding: const EdgeInsets.all(_touchPadding),
          child: CustomPaint(
            painter: _JoystickPainter(
              radius: widget.radius,
              knobRadius: widget.knobRadius,
              knobOffset: _dragOffset,
              isDragging: _isDragging,
            ),
          ),
        ),
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  final double radius;
  final double knobRadius;
  final Offset knobOffset;
  final bool isDragging;

  _JoystickPainter({
    required this.radius,
    required this.knobRadius,
    required this.knobOffset,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(radius, radius);

    // 1. Clean Ocean-Glass Base Plate
    final basePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF174266).withValues(alpha: isDragging ? 0.72 : 0.55),
          const Color(0xFF0B253C).withValues(alpha: isDragging ? 0.85 : 0.70),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, basePaint);

    // 2. Crisp Subtle Rim
    final borderPaint = Paint()
      ..color = (isDragging ? const Color(0xFF22D3EE) : const Color(0xFF7DD3FC))
          .withValues(alpha: isDragging ? 0.90 : 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDragging ? 2.4 : 1.6;
    canvas.drawCircle(center, radius - 1, borderPaint);

    // 3. Directional Active Sector Glow when Thumb Moves!
    if (isDragging && knobOffset.distance > 4.0) {
      final dirAngle = knobOffset.direction;
      final sectorPaint = Paint()
        ..color = const Color(0xFF22D3EE).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 3.5),
        dirAngle - 0.45,
        0.90,
        false,
        sectorPaint,
      );
    }

    // 4. Clean Cardinal Crosshair Guides
    final notchPaint = Paint()
      ..color = const Color(0xFF7DD3FC).withValues(alpha: 0.35)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2);
      final p1 = center + Offset(math.cos(angle) * (radius - 12.0), math.sin(angle) * (radius - 12.0));
      final p2 = center + Offset(math.cos(angle) * (radius - 4.0), math.sin(angle) * (radius - 4.0));
      canvas.drawLine(p1, p2, notchPaint);
    }

    // 5. Ergonomic Knob
    final knobCenter = center + knobOffset;

    // Soft Elevation Shadow under Knob
    canvas.drawCircle(
      knobCenter + const Offset(0, 3),
      knobRadius,
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    final knobPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: isDragging
            ? [
                const Color(0xFFA5F3FC),
                const Color(0xFF22D3EE),
                const Color(0xFF0284C7),
              ]
            : [
                const Color(0xFF7DD3FC),
                const Color(0xFF0EA5E9),
                const Color(0xFF0369A1),
              ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: knobCenter, radius: knobRadius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(knobCenter, knobRadius, knobPaint);

    // Knob Border & Inner Dot
    canvas.drawCircle(
      knobCenter,
      knobRadius - 1,
      Paint()
        ..color = Colors.white.withValues(alpha: isDragging ? 0.95 : 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    canvas.drawCircle(
      knobCenter,
      knobRadius * 0.25,
      Paint()..color = Colors.white.withValues(alpha: isDragging ? 0.95 : 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _JoystickPainter oldDelegate) {
    return oldDelegate.knobOffset != knobOffset || oldDelegate.isDragging != isDragging;
  }
}

class _TouchActionButton extends StatefulWidget {
  final double radius;
  final IconData icon;
  final String label;
  final Color primaryColor;
  final Color glowColor;
  final VoidCallback? onTap;
  final VoidCallback? onPointerDown;
  final VoidCallback? onPointerUp;

  const _TouchActionButton({
    required this.radius,
    required this.icon,
    required this.label,
    required this.primaryColor,
    required this.glowColor,
    this.onTap,
    this.onPointerDown,
    this.onPointerUp,
  });

  @override
  State<_TouchActionButton> createState() => _TouchActionButtonState();
}

class _TouchActionButtonState extends State<_TouchActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final diameter = widget.radius * 2;

    return Listener(
      onPointerDown: (_) {
        setState(() => _isPressed = true);
        widget.onPointerDown?.call();
        widget.onTap?.call();
      },
      onPointerUp: (_) {
        setState(() => _isPressed = false);
        widget.onPointerUp?.call();
      },
      onPointerCancel: (_) {
        setState(() => _isPressed = false);
        widget.onPointerUp?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              widget.primaryColor.withValues(alpha: _isPressed ? 0.9 : 0.4),
              const Color(0xFF0F172A).withValues(alpha: 0.8),
            ],
            stops: const [0.3, 1.0],
          ),
          border: Border.all(
            color: _isPressed ? Colors.white : widget.primaryColor.withValues(alpha: 0.85),
            width: _isPressed ? 3.0 : 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.glowColor.withValues(alpha: _isPressed ? 0.75 : 0.35),
              blurRadius: _isPressed ? 24 : 14,
              spreadRadius: _isPressed ? 4 : 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: Colors.white,
              size: widget.radius * 0.72,
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: widget.radius * 0.22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
