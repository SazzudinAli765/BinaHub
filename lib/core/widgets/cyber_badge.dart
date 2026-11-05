import 'package:flutter/material.dart';
import '../theme/cyber_colors.dart';
import '../theme/cyber_shapes.dart';
import '../theme/cyber_typography.dart';

/// Decoder Telemetry Badge (HW, HW+, SW)
class DecoderBadge extends StatelessWidget {
  final String mode; // "HW", "HW+", "SW"
  final bool isSelected;
  final VoidCallback? onTap;

  const DecoderBadge({
    required this.mode,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isSelected ? CyberColors.primaryCyan : CyberColors.textSecondary;
    final Color borderColor = isSelected ? CyberColors.primaryCyan : CyberColors.borderStructural;
    final Color bgColor = isSelected ? CyberColors.primaryContainer : CyberColors.surfaceCarbonRaised;

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: CyberShapes.roundedMicro,
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: isSelected ? const [CyberColors.cyanGlow] : null,
      ),
      child: Text(
        mode,
        style: CyberTypography.telemetryBadge.copyWith(
          color: textColor,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: badge);
    }
    return badge;
  }
}

/// Resolution Badge (e.g. 4K UHD, 1080p FHD, 720p HD)
class ResolutionBadge extends StatelessWidget {
  final String resolution;
  final bool isUltra;

  const ResolutionBadge({
    required this.resolution,
    this.isUltra = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
      decoration: BoxDecoration(
        color: isUltra ? const Color(0x3300F0FF) : CyberColors.surfaceCarbonRaised,
        borderRadius: CyberShapes.roundedMicro,
        border: Border.all(
          color: isUltra ? CyberColors.primaryCyan : CyberColors.borderStructural,
          width: 0.8,
        ),
      ),
      child: Text(
        resolution.toUpperCase(),
        style: CyberTypography.telemetryBadge.copyWith(
          color: isUltra ? CyberColors.primaryCyan : CyberColors.textPrimary,
          fontSize: 9.5,
        ),
      ),
    );
  }
}

/// Codec & Audio Format Badge (e.g. HEVC 10-bit, FLAC 96kHz, VULKAN-HW)
class CodecBadge extends StatelessWidget {
  final String label;
  final bool isViolet;

  const CodecBadge({
    required this.label,
    this.isViolet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
      decoration: BoxDecoration(
        color: isViolet ? const Color(0x2A8B5CF6) : CyberColors.surfaceCarbon,
        borderRadius: CyberShapes.roundedMicro,
        border: Border.all(
          color: isViolet ? CyberColors.borderViolet : CyberColors.borderStructural,
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: CyberTypography.telemetryMicro.copyWith(
          color: isViolet ? CyberColors.secondaryViolet : CyberColors.textSecondary,
        ),
      ),
    );
  }
}

/// Hardware Telemetry Chip (e.g. "SD 8s Gen 3 • 8GB", "120 FPS", "42°C")
class HardwareTelemetryChip extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;

  const HardwareTelemetryChip({
    required this.text,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? CyberColors.primaryCyan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: CyberColors.surfaceCarbonRaised,
        borderRadius: CyberShapes.roundedMicro,
        border: Border.all(color: CyberColors.borderStructural, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: activeColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: CyberTypography.telemetryBadge.copyWith(
              color: activeColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
