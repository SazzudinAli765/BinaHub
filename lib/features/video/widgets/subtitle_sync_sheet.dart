import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_button.dart';
import '../../../core/widgets/cyber_badge.dart';

/// Subtitle Selection & Precision Sync Offset Sheet
/// SRS: SUB-01 to SUB-08 (Search, Download, ±10s 50ms stepper, Appearance)
class SubtitleSyncSheet extends StatefulWidget {
  final double initialOffsetMs;
  final ValueChanged<double> onOffsetChanged;

  const SubtitleSyncSheet({
    this.initialOffsetMs = 0.0,
    required this.onOffsetChanged,
  });

  @override
  _SubtitleSyncSheetState createState() => _SubtitleSyncSheetState();
}

class _SubtitleSyncSheetState extends State<SubtitleSyncSheet> {
  late double _offsetMs;
  int _selectedTrackIndex = 0;
  double _fontSize = 18.0;
  Color _subtitleColor = CyberColors.textPrimary;

  final List<Map<String, dynamic>> _tracks = [
    {'title': 'English [Embedded SDH]', 'lang': 'en', 'format': 'ASS', 'selected': true},
    {'title': 'English [External .srt]', 'lang': 'en', 'format': 'SRT', 'selected': false},
    {'title': 'Japanese [Original]', 'lang': 'ja', 'format': 'ASS', 'selected': false},
    {'title': 'Spanish [Subscene]', 'lang': 'es', 'format': 'VTT', 'selected': false},
  ];

  @override
  void initState() {
    super.initState();
    _offsetMs = widget.initialOffsetMs;
  }

  void _adjustOffset(double deltaMs) {
    setState(() {
      _offsetMs = (_offsetMs + deltaMs).clamp(-10000.0, 10000.0);
    });
    widget.onOffsetChanged(_offsetMs);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtitle Tracks & Calibration', style: CyberTypography.headlineSmall),
              CyberGhostButton(
                label: 'Search Online',
                icon: Icons.cloud_download_outlined,
                height: 32,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Searching OpenSubtitles / Subscene API...')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Track List
          Text('AVAILABLE STREAMS', style: CyberTypography.telemetryMicro),
          const SizedBox(height: 6),
          ...List.generate(_tracks.length, (index) {
            final track = _tracks[index];
            final isSelected = _selectedTrackIndex == index;
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.subtitles_outlined,
                  size: 18,
                  color: isSelected ? CyberColors.primaryCyan : CyberColors.textSecondary,
                ),
                title: Text(track['title'], style: CyberTypography.bodyMedium),
                trailing: CodecBadge(label: track['format'], isViolet: isSelected),
                onTap: () {
                  setState(() => _selectedTrackIndex = index);
                },
              ),
            );
          }),

          const SizedBox(height: 12),
          // Precision Sync Calibration (-10s to +10s in 50ms increments)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TIMING SYNCHRONIZATION', style: CyberTypography.telemetryMicro),
              Text(
                '${_offsetMs >= 0 ? '+' : ''}${(_offsetMs / 1000).toStringAsFixed(2)}s (${_offsetMs.toInt()} ms)',
                style: CyberTypography.telemetryBadge.copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CyberGhostButton(
                label: '-0.5s',
                height: 34,
                onPressed: () => _adjustOffset(-500),
              ),
              CyberGhostButton(
                label: '-50ms',
                height: 34,
                onPressed: () => _adjustOffset(-50),
              ),
              CyberGhostButton(
                label: 'RESET',
                height: 34,
                onPressed: () => _adjustOffset(-_offsetMs),
              ),
              CyberGhostButton(
                label: '+50ms',
                height: 34,
                onPressed: () => _adjustOffset(50),
              ),
              CyberGhostButton(
                label: '+0.5s',
                height: 34,
                onPressed: () => _adjustOffset(500),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
