import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_button.dart';

/// A-B Repeat Looping Dialog
class ABLoopDialog extends StatefulWidget {
  final Duration currentPosition;
  final Duration? pointA;
  final Duration? pointB;
  final bool isLooping;
  final Function(Duration? a, Duration? b, bool active) onUpdate;

  const ABLoopDialog({
    required this.currentPosition,
    this.pointA,
    this.pointB,
    this.isLooping = false,
    required this.onUpdate,
  });

  @override
  _ABLoopDialogState createState() => _ABLoopDialogState();
}

class _ABLoopDialogState extends State<ABLoopDialog> {
  Duration? _a;
  Duration? _b;
  late bool _looping;

  @override
  void initState() {
    super.initState();
    _a = widget.pointA;
    _b = widget.pointB;
    _looping = widget.isLooping;
  }

  String _format(Duration? d) {
    if (d == null) return '--:--:--';
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final ms = (d.inMilliseconds.remainder(1000) ~/ 10);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${ms.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.repeat, color: CyberColors.primaryCyan, size: 20),
          const SizedBox(width: 8),
          Text('A-B Precision Loop', style: CyberTypography.headlineSmall),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Current playhead: ${_format(widget.currentPosition)}',
            style: CyberTypography.telemetryTimecode,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('START POINT (A)', style: CyberTypography.telemetryMicro),
                  const SizedBox(height: 4),
                  Text(_format(_a), style: CyberTypography.telemetryTimecodeLarge),
                  const SizedBox(height: 6),
                  CyberGhostButton(
                    label: 'SET A',
                    height: 32,
                    onPressed: () => setState(() => _a = widget.currentPosition),
                  ),
                ],
              ),
              Container(width: 1, height: 50, color: CyberColors.borderStructural),
              Column(
                children: [
                  Text('END POINT (B)', style: CyberTypography.telemetryMicro),
                  const SizedBox(height: 4),
                  Text(_format(_b), style: CyberTypography.telemetryTimecodeLarge),
                  const SizedBox(height: 6),
                  CyberGhostButton(
                    label: 'SET B',
                    height: 32,
                    onPressed: () => setState(() => _b = widget.currentPosition),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            dense: true,
            title: Text('Engage Loop', style: CyberTypography.bodyMedium),
            value: _looping && _a != null && _b != null,
            onChanged: (_a != null && _b != null)
                ? (val) => setState(() => _looping = val)
                : null,
          ),
        ],
      ),
      actions: [
        CyberGhostButton(
          label: 'CLEAR',
          height: 36,
          onPressed: () {
            setState(() {
              _a = null;
              _b = null;
              _looping = false;
            });
            widget.onUpdate(null, null, false);
            Navigator.pop(context);
          },
        ),
        CyberPrimaryButton(
          label: 'APPLY',
          height: 36,
          onPressed: () {
            widget.onUpdate(_a, _b, _looping && _a != null && _b != null);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
