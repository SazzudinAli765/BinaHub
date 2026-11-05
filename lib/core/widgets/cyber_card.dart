import 'package:flutter/material.dart';
import '../theme/cyber_colors.dart';
import '../theme/cyber_shapes.dart';

/// Cyber Card container with technical borders and optional elevation
class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isElevated;
  final bool isActive;
  final Color? borderColor;

  const CyberCard({
    required this.child,
    this.padding = CyberShapes.paddingCard,
    this.onTap,
    this.isElevated = false,
    this.isActive = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isElevated ? CyberColors.surfaceCarbonRaised : CyberColors.surfaceCarbon,
        borderRadius: CyberShapes.roundedMicro,
        border: Border.all(
          color: isActive
              ? CyberColors.primaryCyan
              : (borderColor ?? CyberColors.borderStructural),
          width: 1.0,
        ),
        boxShadow: isActive ? const [CyberColors.cyanGlow] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: CyberShapes.roundedMicro,
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
