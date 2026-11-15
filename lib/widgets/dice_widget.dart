import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../audio/audio_service.dart';

class DiceWidget extends StatefulWidget {
  final int value;
  final bool isRolling;
  final bool enabled;
  final VoidCallback? onRoll;
  final String playerTurnText;
  final Color playerColor;

  const DiceWidget({
    super.key,
    required this.value,
    required this.isRolling,
    required this.enabled,
    this.onRoll,
    required this.playerTurnText,
    required this.playerColor,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final math.Random _random = math.Random();
  int _displayValue = 1;

  @override
  void initState() {
    super.initState();
    _displayValue = widget.value;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animController.addListener(() {
      if (widget.isRolling && _animController.isAnimating) {
        // Flick values rapidly
        if (_random.nextDouble() > 0.4) {
          setState(() {
            _displayValue = 1 + _random.nextInt(6);
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      AudioService().playDice();
      _animController.forward(from: 0.0);
    } else if (!widget.isRolling && oldWidget.isRolling) {
      setState(() {
        _displayValue = widget.value;
      });
      _animController.stop();
    } else if (!widget.isRolling) {
      _displayValue = widget.value;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 3D Animated Die Face
        GestureDetector(
          onTap: (widget.enabled && !widget.isRolling) ? widget.onRoll : null,
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final rotX = widget.isRolling ? (_animController.value * math.pi * 6) : 0.0;
              final rotY = widget.isRolling ? (_animController.value * math.pi * 8) : 0.0;
              final scale = widget.isRolling
                  ? (1.0 + 0.2 * math.sin(_animController.value * math.pi))
                  : 1.0;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002) // Perspective
                  ..rotateX(rotX)
                  ..rotateY(rotY)
                  ..scale(scale, scale, 1.0),
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFE2E8F0),
                        Color(0xFFCBD5E1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.playerColor.withOpacity(0.55),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                      const BoxShadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: widget.playerColor,
                      width: 2.5,
                    ),
                  ),
                  child: Center(
                    child: _buildDicePips(_displayValue, widget.playerColor),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Prominent Animated Roll Button
        ElevatedButton(
          onPressed: (widget.enabled && !widget.isRolling)
              ? () {
                  AudioService().playClick();
                  widget.onRoll?.call();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.enabled ? widget.playerColor : Colors.grey.shade800,
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF1E293B),
            disabledForegroundColor: Colors.white38,
            elevation: widget.enabled ? 8 : 0,
            shadowColor: widget.playerColor.withOpacity(0.6),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                color: widget.enabled ? const Color(0xFFFFD166) : Colors.transparent,
                width: 1.5,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isRolling ? Icons.casino_rounded : Icons.play_arrow_rounded,
                size: 20,
                color: widget.enabled ? const Color(0xFFFFD166) : Colors.white38,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isRolling
                    ? 'ROLLING...'
                    : (widget.enabled ? 'ROLL DICE' : 'WAIT TURN'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Draw authentic dice pips layout (1 to 6)
  Widget _buildDicePips(int val, Color pipColor) {
    const pipSize = 11.0;
    Widget pip() => Container(
          width: pipSize,
          height: pipSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0F172A),
            boxShadow: [
              BoxShadow(
                color: pipColor.withOpacity(0.4),
                blurRadius: 3,
                spreadRadius: 0.5,
              ),
            ],
          ),
        );

    Widget centerPip() => Container(
          width: pipSize * 1.2,
          height: pipSize * 1.2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE63946), // Red center dot for authentic gaming dice
          ),
        );

    switch (val) {
      case 1:
        return Center(child: centerPip());
      case 2:
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(alignment: Alignment.topLeft, child: pip()),
              Align(alignment: Alignment.bottomRight, child: pip()),
            ],
          ),
        );
      case 3:
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(alignment: Alignment.topLeft, child: pip()),
              Center(child: pip()),
              Align(alignment: Alignment.bottomRight, child: pip()),
            ],
          ),
        );
      case 4:
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [pip(), pip()]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [pip(), pip()]),
            ],
          ),
        );
      case 5:
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [pip(), pip()]),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [pip(), pip()]),
                ],
              ),
              Center(child: pip()),
            ],
          ),
        );
      case 6:
      default:
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [pip(), pip(), pip()]),
              Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [pip(), pip(), pip()]),
            ],
          ),
        );
    }
  }
}
