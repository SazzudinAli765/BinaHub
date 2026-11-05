import 'package:flutter/material.dart';
import '../theme/cyber_colors.dart';
import '../theme/cyber_shapes.dart';
import '../theme/cyber_typography.dart';

/// Primary Cyber Action Button
/// High-contrast Electric Cyan with 4px corner radius and glowing active state.
class CyberPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  const CyberPrimaryButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 42.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: onPressed != null ? CyberColors.primaryCyan : CyberColors.surfaceElevated,
        borderRadius: CyberShapes.roundedMicro,
        boxShadow: onPressed != null ? const [CyberColors.cyanGlow] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: CyberShapes.roundedMicro,
          onTap: isLoading ? null : onPressed,
          splashColor: CyberColors.primaryPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(CyberColors.bgPureBlack),
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: CyberColors.bgPureBlack),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: CyberTypography.buttonAction),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Instrument Ghost Action Button
/// Dark substrate background with technical border; shifts to cyan outline on focus/active.
class CyberGhostButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isActive;
  final double? width;
  final double height;

  const CyberGhostButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.isActive = false,
    this.width,
    this.height = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: CyberColors.surfaceCarbon,
        borderRadius: CyberShapes.roundedMicro,
        border: Border.all(
          color: isActive ? CyberColors.primaryCyan : CyberColors.borderStructural,
          width: 1.0,
        ),
        boxShadow: isActive ? const [CyberColors.cyanGlow] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: CyberShapes.roundedMicro,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: isActive ? CyberColors.primaryCyan : CyberColors.textPrimary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: CyberTypography.buttonGhost.copyWith(
                    color: isActive ? CyberColors.primaryCyan : CyberColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Micro-radii Icon Action Button
class CyberIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double size;
  final bool isGlowing;

  const CyberIconButton({
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size = 20.0,
    this.isGlowing = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: CyberColors.surfaceCarbon,
        borderRadius: CyberShapes.roundedMicro,
        border: Border.all(
          color: isGlowing ? CyberColors.primaryCyan : CyberColors.borderStructural,
          width: 1.0,
        ),
        boxShadow: isGlowing ? const [CyberColors.cyanGlow] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: CyberShapes.roundedMicro,
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              size: size,
              color: color ?? (isGlowing ? CyberColors.primaryCyan : CyberColors.textPrimary),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
