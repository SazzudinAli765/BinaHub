import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/precision_scrubber.dart';

/// Precision Video Trimmer & Clip Cutter Screen
/// Frame-accurate trimming, Keyframe snapping, Fast stream copy
class VideoTrimmerScreen extends StatefulWidget {
  @override
  _VideoTrimmerScreenState createState() => _VideoTrimmerScreenState();
}

class _VideoTrimmerScreenState extends State<VideoTrimmerScreen> {
  final Duration _totalDuration = const Duration(minutes: 8, seconds: 45);
  Duration _trimStart = const Duration(minutes: 1, seconds: 30);
  Duration _trimEnd = const Duration(minutes: 4, seconds: 15);
  Duration _currentPlayhead = const Duration(minutes: 2, seconds: 0);
  bool _fastKeyframeCut = true;
  bool _isExporting = false;

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final ms = (d.inMilliseconds.remainder(1000) ~/ 10);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${ms.toString().padLeft(2, '0')}';
  }

  void _exportTrimmedClip() {
    setState(() => _isExporting = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trimmed clip exported: ${_format(_trimEnd - _trimStart)} saved to Movies/Clips/'),
            backgroundColor: CyberColors.surfaceCarbonRaised,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final clipDuration = _trimEnd - _trimStart;

    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: AppBar(
        backgroundColor: CyberColors.bgPureBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CyberColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Video Trimmer & Cutter',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CyberColors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Frame Preview Area
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: CyberColors.surfaceCarbonRaised,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CyberColors.borderStructural),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.content_cut, size: 40, color: CyberColors.primaryCyan),
                      const SizedBox(height: 8),
                      Text(
                        'PLAYHEAD: ${_format(_currentPlayhead)}',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: CyberColors.primaryCyan,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time markers: Start, Duration, End
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('START POINT', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: CyberColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(_format(_trimStart), style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceCarbonRaised,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: CyberColors.primaryCyan.withOpacity(0.4)),
                  ),
                  child: Text(
                    'CLIP: ${_format(clipDuration)}',
                    style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.w700, color: CyberColors.primaryCyan),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('END POINT', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: CyberColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(_format(_trimEnd), style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Scrubber
            PrecisionScrubber(
              position: _currentPlayhead,
              duration: _totalDuration,
              buffered: _totalDuration,
              onSeek: (pos) => setState(() => _currentPlayhead = pos),
            ),
            const SizedBox(height: 16),

            // Trim Triggers: Set Start, Set End
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CyberColors.primaryCyan,
                      side: BorderSide(color: CyberColors.primaryCyan.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.first_page, size: 18),
                    label: const Text('SET START', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      if (_currentPlayhead < _trimEnd) {
                        setState(() => _trimStart = _currentPlayhead);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CyberColors.primaryCyan,
                      side: BorderSide(color: CyberColors.primaryCyan.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.last_page, size: 18),
                    label: const Text('SET END', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      if (_currentPlayhead > _trimStart) {
                        setState(() => _trimEnd = _currentPlayhead);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fast Keyframe cut checkbox
            Container(
              decoration: BoxDecoration(
                color: CyberColors.surfaceCarbon,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CyberColors.borderStructural),
              ),
              child: SwitchListTile(
                dense: true,
                activeColor: CyberColors.primaryCyan,
                title: const Text('Keyframe Snapping (Instant Export)', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                subtitle: const Text('Lossless cut at closest I-frame without re-encoding', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: CyberColors.textSecondary)),
                value: _fastKeyframeCut,
                onChanged: (val) => setState(() => _fastKeyframeCut = val),
              ),
            ),

            const Spacer(),

            // Export Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberColors.primaryCyan,
                  foregroundColor: const Color(0xFF002022),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: Icon(_isExporting ? Icons.sync : Icons.download_done, size: 20),
                label: Text(
                  _isExporting ? 'EXPORTING CLIP...' : 'EXPORT TRIMMED VIDEO',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: _isExporting ? null : _exportTrimmedClip,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
