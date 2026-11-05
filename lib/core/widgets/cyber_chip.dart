import 'package:flutter/material.dart';
import '../theme/cyber_colors.dart';
import '../theme/cyber_shapes.dart';
import '../theme/cyber_typography.dart';

/// Cyber Precision Filter Chip
class CyberFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const CyberFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected ? CyberColors.primaryCyan : CyberColors.surfaceCarbonRaised,
          borderRadius: CyberShapes.roundedMicro,
          border: Border.all(
            color: isSelected ? CyberColors.primaryCyan : CyberColors.borderStructural,
            width: 1.0,
          ),
          boxShadow: isSelected ? const [CyberColors.cyanGlow] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? CyberColors.bgPureBlack : CyberColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: isSelected
                  ? CyberTypography.buttonAction.copyWith(fontSize: 12)
                  : CyberTypography.bodySmall.copyWith(
                      color: CyberColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
