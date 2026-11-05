import 'package:flutter/material.dart';
import '../theme/cyber_colors.dart';
import '../theme/cyber_typography.dart';

/// Telemetry Slider with real-time numeric/dB readout in JetBrains Mono
class TelemetrySlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double)? formatValue;
  final ValueChanged<double> onChanged;
  final Color? activeColor;

  const TelemetrySlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.formatValue,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = activeColor ?? CyberColors.primaryCyan;
    final valueText = formatValue != null ? formatValue!(value) : value.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: CyberTypography.bodyMedium.copyWith(color: CyberColors.textPrimary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: CyberColors.surfaceCarbonRaised,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: CyberColors.borderStructural),
              ),
              child: Text(
                valueText,
                style: CyberTypography.telemetryBadge.copyWith(color: displayColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: displayColor,
            inactiveTrackColor: CyberColors.scrubberRail,
            thumbColor: displayColor,
            overlayColor: displayColor.withOpacity(0.2),
            trackHeight: 2.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
