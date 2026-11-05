import 'package:flutter/material.dart';
import '../theme/cyber_colors.dart';
import '../theme/cyber_typography.dart';

/// Precision Scrubber & Timeline Bar
/// Conforms to the Cyber Precision timeline specification with buffered indicator,
/// 2px technical rail, active playhead line, and high-precision diamond thumb.
class PrecisionScrubber extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final Duration buffered;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<Duration>? onScrubbing;

  const PrecisionScrubber({
    required this.position,
    required this.duration,
    required this.buffered,
    required this.onSeek,
    this.onScrubbing,
  });

  @override
  _PrecisionScrubberState createState() => _PrecisionScrubberState();
}

class _PrecisionScrubberState extends State<PrecisionScrubber> {
  bool _isDragging = false;
  double _dragPositionFraction = 0.0;

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    final ms = (d.inMilliseconds.remainder(1000) ~/ 10);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${ms.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${ms.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = widget.duration.inMilliseconds;
    final currentMs = _isDragging
        ? (_dragPositionFraction * totalMs).toInt()
        : widget.position.inMilliseconds;
    final bufferedMs = widget.buffered.inMilliseconds;

    final double activeFraction = totalMs > 0 ? (currentMs / totalMs).clamp(0.0, 1.0) : 0.0;
    final double bufferedFraction = totalMs > 0 ? (bufferedMs / totalMs).clamp(0.0, 1.0) : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (details) {
            setState(() {
              _isDragging = true;
              _dragPositionFraction = (details.localPosition.dx / width).clamp(0.0, 1.0);
            });
            widget.onScrubbing?.call(Duration(milliseconds: (_dragPositionFraction * totalMs).toInt()));
          },
          onHorizontalDragUpdate: (details) {
            setState(() {
              _dragPositionFraction = (details.localPosition.dx / width).clamp(0.0, 1.0);
            });
            widget.onScrubbing?.call(Duration(milliseconds: (_dragPositionFraction * totalMs).toInt()));
          },
          onHorizontalDragEnd: (details) {
            setState(() {
              _isDragging = false;
            });
            widget.onSeek(Duration(milliseconds: (_dragPositionFraction * totalMs).toInt()));
          },
          onTapDown: (details) {
            final fraction = (details.localPosition.dx / width).clamp(0.0, 1.0);
            widget.onSeek(Duration(milliseconds: (fraction * totalMs).toInt()));
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Floating scrub tooltip when dragging
              if (_isDragging)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceCarbonRaised,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: CyberColors.primaryCyan, width: 1),
                    boxShadow: const [CyberColors.cyanGlow],
                  ),
                  child: Text(
                    _formatDuration(Duration(milliseconds: currentMs)),
                    style: CyberTypography.telemetryTimecodeLarge.copyWith(
                      color: CyberColors.primaryCyan,
                      fontSize: 12,
                    ),
                  ),
                ),

              // Rail and playhead
              SizedBox(
                height: 24,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Background Rail (2px #22222A)
                    Container(
                      height: 2.0,
                      width: width,
                      color: CyberColors.scrubberRail,
                    ),

                    // Buffered bar (2px white 25%)
                    Container(
                      height: 2.0,
                      width: width * bufferedFraction,
                      color: CyberColors.scrubberBuffered,
                    ),

                    // Active playhead (2px solid #00F0FF)
                    Container(
                      height: 2.0,
                      width: width * activeFraction,
                      color: CyberColors.primaryCyan,
                    ),

                    // Diamond/Pill Scrubber Head (2px x 14px in Electric Cyan)
                    Positioned(
                      left: (width * activeFraction - 4).clamp(0.0, width - 8),
                      child: Container(
                        width: 8,
                        height: 16,
                        decoration: BoxDecoration(
                          color: CyberColors.primaryCyan,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: const [CyberColors.cyanGlow],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Timecode readouts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(Duration(milliseconds: currentMs)),
                    style: CyberTypography.telemetryTimecode,
                  ),
                  Text(
                    _formatDuration(widget.duration),
                    style: CyberTypography.telemetryTimecode,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
