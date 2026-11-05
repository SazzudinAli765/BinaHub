import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_button.dart';

/// Intelligent Sleep Timer Dialog
/// SRS: AUD-09 (Countdown, Finish current track, Audio fade-out)
class SleepTimerDialog extends StatefulWidget {
  final ValueChanged<Duration> onTimerSet;

  const SleepTimerDialog({required this.onTimerSet});

  @override
  _SleepTimerDialogState createState() => _SleepTimerDialogState();
}

class _SleepTimerDialogState extends State<SleepTimerDialog> {
  int _selectedMinutes = 30;
  bool _finishCurrentTrack = true;
  bool _fadeout = true;

  final List<int> _durations = [15, 30, 45, 60, 90, 120];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.timer_outlined, color: CyberColors.primaryCyan, size: 22),
          const SizedBox(width: 8),
          Text('Intelligent Sleep Timer', style: CyberTypography.headlineSmall),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COUNTDOWN DURATION', style: CyberTypography.telemetryMicro),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _durations.map((mins) {
              final isSelected = _selectedMinutes == mins;
              return GestureDetector(
                onTap: () => setState(() => _selectedMinutes = mins),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? CyberColors.primaryCyan : CyberColors.surfaceCarbon,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? CyberColors.primaryCyan : CyberColors.borderStructural,
                    ),
                  ),
                  child: Text(
                    '$mins min',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? CyberColors.bgPureBlack : CyberColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text('Finish Current Track First', style: CyberTypography.bodyMedium),
            subtitle: Text('Prevents abrupt stops mid-song', style: CyberTypography.bodySmall),
            value: _finishCurrentTrack,
            onChanged: (val) => setState(() => _finishCurrentTrack = val),
          ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text('Smooth Audio Fade-Out', style: CyberTypography.bodyMedium),
            subtitle: Text('Gradual 30s decibel attenuation', style: CyberTypography.bodySmall),
            value: _fadeout,
            onChanged: (val) => setState(() => _fadeout = val),
          ),
        ],
      ),
      actions: [
        CyberGhostButton(
          label: 'CANCEL',
          height: 36,
          onPressed: () => Navigator.pop(context),
        ),
        CyberPrimaryButton(
          label: 'SET TIMER',
          height: 36,
          onPressed: () {
            widget.onTimerSet(Duration(minutes: _selectedMinutes));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sleep timer engaged for $_selectedMinutes minutes')),
            );
          },
        ),
      ],
    );
  }
}
