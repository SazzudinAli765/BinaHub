import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';

/// 10-Band Graphic Equalizer & Audio DSP Processing Sheet
/// Clean, restrained dark OLED aesthetic with responsive sliders and preset chips.
class EqualizerSheet extends StatefulWidget {
  @override
  _EqualizerSheetState createState() => _EqualizerSheetState();
}

class _EqualizerSheetState extends State<EqualizerSheet> {
  bool _eqEnabled = true;
  String _selectedPreset = 'Bass Boost';
  double _bassBoost = 65.0; // 0 - 100%
  double _virtualizer = 40.0; // 0 - 100%

  final List<String> _frequencies = [
    '31Hz', '63Hz', '125Hz', '250Hz', '500Hz', '1kHz', '2kHz', '4kHz', '8kHz', '16kHz'
  ];

  late List<double> _bandLevels; // dB from -12.0 to +12.0

  final Map<String, List<double>> _presets = {
    'Flat': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    'Bass Boost': [6.5, 5.0, 3.5, 1.5, 0, 0, 1.0, 2.0, 3.5, 4.0],
    'Rock': [4.5, 3.0, -1.0, -2.0, -0.5, 2.0, 3.5, 4.5, 4.0, 3.5],
    'Electronic': [5.0, 4.0, 1.5, 0, -1.5, 2.0, 1.0, 3.0, 4.5, 5.0],
    'Vocal': [-2.0, -1.0, 0.5, 3.5, 4.5, 3.5, 2.0, 1.0, 0, -1.0],
  };

  @override
  void initState() {
    super.initState();
    _bandLevels = List.from(_presets['Bass Boost']!);
  }

  void _applyPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      if (_presets.containsKey(preset)) {
        _bandLevels = List.from(_presets[preset]!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: CyberColors.surfaceCarbonRaised,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
          const SizedBox(height: 14),

          // Header with Master EQ Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CyberColors.primaryCyan.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.equalizer, color: CyberColors.primaryCyan, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '10-Band Graphic Equalizer',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _eqEnabled,
                activeColor: CyberColors.primaryCyan,
                activeTrackColor: CyberColors.primaryCyan.withOpacity(0.35),
                inactiveThumbColor: CyberColors.textTertiary,
                inactiveTrackColor: CyberColors.surfaceContainerLow,
                onChanged: (val) => setState(() => _eqEnabled = val),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Presets Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _presets.keys.map((p) {
                final isSelected = _selectedPreset == p;
                return GestureDetector(
                  onTap: _eqEnabled ? () => _applyPreset(p) : null,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? CyberColors.primaryCyan : CyberColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected ? const [CyberColors.cyanGlow] : null,
                    ),
                    child: Text(
                      p,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF002022) : CyberColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // 10 Vertical Slider Slits
          Opacity(
            opacity: _eqEnabled ? 1.0 : 0.4,
            child: SizedBox(
              height: 170,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_frequencies.length, (index) {
                  return Column(
                    children: [
                      Text(
                        '${_bandLevels[index] >= 0 ? '+' : ''}${_bandLevels[index].toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 8.5,
                          color: CyberColors.primaryCyan,
                        ),
                      ),
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: CyberColors.primaryCyan,
                              inactiveTrackColor: CyberColors.scrubberRail,
                              thumbColor: CyberColors.primaryCyan,
                              trackHeight: 2.0,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.5),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                            ),
                            child: Slider(
                              value: _bandLevels[index],
                              min: -12.0,
                              max: 12.0,
                              onChanged: _eqEnabled
                                  ? (val) {
                                      setState(() {
                                        _bandLevels[index] = val;
                                        _selectedPreset = 'Custom';
                                      });
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        _frequencies[index],
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 8.5,
                          color: CyberColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bass Boost & Virtualizer Sliders
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceCarbon,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: CyberColors.borderStructural),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'BASS BOOST',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 9.5,
                              color: CyberColors.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            '${_bassBoost.toInt()}%',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.primaryCyan,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: CyberColors.primaryCyan,
                          inactiveTrackColor: CyberColors.scrubberRail,
                          thumbColor: CyberColors.primaryCyan,
                          trackHeight: 2.0,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                        ),
                        child: Slider(
                          value: _bassBoost,
                          min: 0,
                          max: 100,
                          onChanged: _eqEnabled ? (val) => setState(() => _bassBoost = val) : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceCarbon,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: CyberColors.borderStructural),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '3D VIRTUALIZER',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 9.5,
                              color: CyberColors.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            '${_virtualizer.toInt()}%',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.secondaryViolet,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: CyberColors.secondaryViolet,
                          inactiveTrackColor: CyberColors.scrubberRail,
                          thumbColor: CyberColors.secondaryViolet,
                          trackHeight: 2.0,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                        ),
                        child: Slider(
                          value: _virtualizer,
                          min: 0,
                          max: 100,
                          onChanged: _eqEnabled ? (val) => setState(() => _virtualizer = val) : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
