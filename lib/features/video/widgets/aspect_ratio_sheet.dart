import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';

/// Aspect Ratio & Display Mode Selector Sheet
class AspectRatioSheet extends StatelessWidget {
  final String currentMode;
  final ValueChanged<String> onModeSelected;

  const AspectRatioSheet({
    required this.currentMode,
    required this.onModeSelected,
  });

  static const List<Map<String, String>> modes = [
    {'name': 'Fit to Screen', 'desc': 'Preserves original aspect ratio with black bars'},
    {'name': 'Fill Screen (Crop)', 'desc': 'Fills display completely, crops excess top/bottom'},
    {'name': '16:9 Standard', 'desc': 'Standard HDTV wide aspect ratio'},
    {'name': '4:3 Academy', 'desc': 'Classic TV and vintage format'},
    {'name': '2.35:1 Cinematic', 'desc': 'Ultra-wide anamorphic cinema scale'},
    {'name': 'Custom Stretch', 'desc': 'Stretches video to fill all viewport pixels'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: CyberColors.borderStructural,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Aspect Ratio & Viewport Geometry', style: CyberTypography.headlineSmall),
          const SizedBox(height: 12),
          ...modes.map((mode) {
            final isSelected = currentMode == mode['name'];
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: isSelected ? CyberColors.surfaceElevated : CyberColors.surfaceCarbon,
                borderRadius: CyberShapes.roundedMicro,
                border: Border.all(
                  color: isSelected ? CyberColors.primaryCyan : CyberColors.borderStructural,
                ),
              ),
              child: ListTile(
                dense: true,
                title: Text(mode['name']!, style: CyberTypography.bodyMedium),
                subtitle: Text(mode['desc']!, style: CyberTypography.bodySmall),
                trailing: isSelected
                    ? const Icon(Icons.check, color: CyberColors.primaryCyan, size: 20)
                    : null,
                onTap: () {
                  onModeSelected(mode['name']!);
                  Navigator.pop(context);
                },
              ),
            );
          }).toList(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
