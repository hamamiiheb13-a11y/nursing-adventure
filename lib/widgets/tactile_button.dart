import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum TactileButtonStyle {
  primary,
  accent,
  amber,
  secondary,
  ghost,
}

class TactileButton extends StatefulWidget {
  final String label;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onPressed;
  final TactileButtonStyle style;
  final bool fullWidth;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const TactileButton({
    super.key,
    required this.label,
    this.subtitle,
    this.icon,
    required this.onPressed,
    this.style = TactileButtonStyle.primary,
    this.fullWidth = true,
    this.height = 54,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;

    Color topColor;
    Color bottomBorderColor;
    Color textColor;
    Color? iconColor;
    Color? subtitleColor;
    Border? outlineBorder;

    if (!isEnabled) {
      topColor = const Color(0xFFE2E8F0);
      bottomBorderColor = const Color(0xFFCBD5E1);
      textColor = const Color(0xFF94A3B8);
      iconColor = const Color(0xFF94A3B8);
      subtitleColor = const Color(0xFF94A3B8);
    } else {
      switch (widget.style) {
        case TactileButtonStyle.primary:
          topColor = AppColors.primaryTeal;
          bottomBorderColor = AppColors.primaryTealPressed;
          textColor = Colors.white;
          iconColor = Colors.white;
          subtitleColor = const Color(0xFFCCFBF1);
          break;
        case TactileButtonStyle.accent:
          topColor = AppColors.accentCobalt;
          bottomBorderColor = AppColors.accentCobaltPressed;
          textColor = Colors.white;
          iconColor = Colors.white;
          subtitleColor = const Color(0xFFDBEAFE);
          break;
        case TactileButtonStyle.amber:
          topColor = AppColors.rewardAmber;
          bottomBorderColor = AppColors.rewardAmberPressed;
          textColor = Colors.white;
          iconColor = Colors.white;
          subtitleColor = const Color(0xFFFEF3C7);
          break;
        case TactileButtonStyle.secondary:
          topColor = Colors.white;
          bottomBorderColor = const Color(0xFFCBD5E1);
          textColor = AppColors.textPrimary;
          iconColor = AppColors.textPrimary;
          subtitleColor = AppColors.textSecondary;
          outlineBorder = Border.all(color: const Color(0xFFE2E8F0), width: 1.5);
          break;
        case TactileButtonStyle.ghost:
          topColor = Colors.transparent;
          bottomBorderColor = Colors.transparent;
          textColor = AppColors.textSecondary;
          iconColor = AppColors.textSecondary;
          subtitleColor = AppColors.textMuted;
          outlineBorder = Border.all(color: const Color(0xFFE2E8F0), width: 1.0);
          break;
      }
    }

    const double bevelDepth = 4.0;
    final double currentOffset = _isPressed ? bevelDepth : 0.0;

    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.titleSmall(
                  color: textColor,
                  size: 15.0,
                  weight: FontWeight.w700,
                ),
              ),
              if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                const SizedBox(height: 1.5),
                Text(
                  widget.subtitle!,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption(
                    color: subtitleColor,
                    size: 11,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: widget.fullWidth ? double.infinity : null,
          height: widget.height + bevelDepth,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 3D Bottom shadow / bevel layer
              if (widget.style != TactileButtonStyle.ghost)
                Positioned(
                  top: bevelDepth,
                  left: 0,
                  right: 0,
                  height: widget.height,
                  child: Container(
                    decoration: BoxDecoration(
                      color: bottomBorderColor,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                  ),
                ),
              // Main moving face layer
              AnimatedPositioned(
                duration: const Duration(milliseconds: 70),
                curve: Curves.easeOut,
                top: currentOffset,
                left: 0,
                right: 0,
                height: widget.height,
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: topColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: outlineBorder,
                    boxShadow: _isPressed || widget.style == TactileButtonStyle.ghost
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0x0F0F172A),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  child: buttonContent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
