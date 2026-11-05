import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_badge.dart';

/// Audio Stream & Channel Selector Sheet
class AudioTrackSheet extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTrackSelected;

  const AudioTrackSheet({
    required this.selectedIndex,
    required this.onTrackSelected,
  });

  @override
  _AudioTrackSheetState createState() => _AudioTrackSheetState();
}

class _AudioTrackSheetState extends State<AudioTrackSheet> {
  late int _selected;

  final List<Map<String, dynamic>> _audioStreams = [
    {
      'title': 'English [Original DTS-HD MA]',
      'channels': '7.1.4 Atmos',
      'codec': 'DTS-HD',
      'bitrate': '4800 kbps',
      'isDefault': true,
    },
    {
      'title': 'English [Dolby Digital 5.1]',
      'channels': '5.1 Surround',
      'codec': 'AC3',
      'bitrate': '640 kbps',
      'isDefault': false,
    },
    {
      'title': 'Commentary by Director [Stereo]',
      'channels': '2.0 Stereo',
      'codec': 'AAC',
      'bitrate': '192 kbps',
      'isDefault': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedIndex;
  }

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
          Text('Audio Tracks & Multi-Stream Output', style: CyberTypography.headlineSmall),
          const SizedBox(height: 12),
          ...List.generate(_audioStreams.length, (index) {
            final stream = _audioStreams[index];
            final isChosen = _selected == index;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isChosen ? CyberColors.surfaceElevated : CyberColors.surfaceCarbon,
                borderRadius: CyberShapes.roundedMicro,
                border: Border.all(
                  color: isChosen ? CyberColors.primaryCyan : CyberColors.borderStructural,
                ),
              ),
              child: ListTile(
                dense: true,
                leading: Icon(
                  isChosen ? Icons.volume_up : Icons.volume_down_outlined,
                  color: isChosen ? CyberColors.primaryCyan : CyberColors.textSecondary,
                  size: 20,
                ),
                title: Text(stream['title'], style: CyberTypography.bodyMedium),
                subtitle: Text(
                  '${stream['channels']} • ${stream['bitrate']}',
                  style: CyberTypography.bodySmall,
                ),
                trailing: CodecBadge(label: stream['codec'], isViolet: true),
                onTap: () {
                  setState(() => _selected = index);
                  widget.onTrackSelected(index);
                },
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
