import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TactileCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool animateHover;

  const TactileCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.isSelected = false,
    this.backgroundColor = AppColors.surface,
    this.borderColor,
    this.borderRadius = 18,
    this.animateHover = true,
  });

  @override
  State<TactileCard> createState() => _TactileCardState();
}

class _TactileCardState extends State<TactileCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isClickable = widget.onTap != null;

    final Color effectiveBorderColor = widget.isSelected
        ? AppColors.primaryTeal
        : (widget.borderColor ?? (_isHovered && isClickable ? const Color(0xFFCBD5E1) : AppColors.border));

    final double effectiveBorderWidth = widget.isSelected ? 2.0 : 1.0;

    return MouseRegion(
      cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (isClickable && widget.animateHover) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (isClickable && widget.animateHover) {
          setState(() => _isHovered = false);
        }
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (isClickable) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (isClickable) {
            setState(() => _isPressed = false);
            widget.onTap?.call();
          }
        },
        onTapCancel: () {
          if (isClickable) setState(() => _isPressed = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
            0,
            _isPressed ? 2.0 : (_isHovered && isClickable ? -2.0 : 0.0),
            0,
          ),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.surfaceSubtle : widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: effectiveBorderColor,
              width: effectiveBorderWidth,
            ),
            boxShadow: _isPressed
                ? [
                    const BoxShadow(
                      color: Color(0x080F172A),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    )
                  ]
                : (_isHovered && isClickable
                    ? AppShadows.modal
                    : AppShadows.card),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
