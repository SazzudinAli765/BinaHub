import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_button.dart';
import '../../../core/widgets/cyber_chip.dart';

/// Lossless Smart Muxer Screen (Zero-Recode Container Remuxing)
/// Modernized Cyber Precision interface with container selection and stream filtering.
class SmartMuxerScreen extends StatefulWidget {
  @override
  _SmartMuxerScreenState createState() => _SmartMuxerScreenState();
}

class _SmartMuxerScreenState extends State<SmartMuxerScreen> {
  String _sourceFile = 'CyberCity_2088_Pro.mkv';
  String _targetContainer = 'MP4';
  bool _includeAudio1 = true;
  bool _includeAudio2 = false;
  bool _includeSubtitles = true;

  bool _isMuxing = false;
  double _muxProgress = 0.0;

  final List<String> _containers = ['MP4', 'MKV', 'TS', 'WebM', 'MOV'];

  void _runMuxer() {
    setState(() {
      _isMuxing = true;
      _muxProgress = 0.0;
    });

    // Zero-recode is fast (~1-2 seconds)
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;
      setState(() => _muxProgress += 0.2);
      if (_muxProgress >= 1.0) {
        setState(() {
          _isMuxing = false;
          _muxProgress = 1.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lossless Remux Finished: 4.2 GB repackaged in 1.4 seconds (No quality loss).'),
            backgroundColor: CyberColors.surfaceCarbonRaised,
          ),
        );
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          'Lossless Smart Muxer',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CyberColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberColors.secondaryViolet.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: CyberColors.secondaryViolet, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Zero-Recode Direct Bitstream Copy',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Copies raw H.264/HEVC/AV1 packets into a new container without re-encoding. 100% original quality preserved.',
                        style: CyberTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'SOURCE MEDIA FILE',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: CyberColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Row(
              children: [
                const Icon(Icons.video_file_outlined, color: CyberColors.textPrimary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _sourceFile,
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      color: CyberColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CyberColors.primaryCyan,
                      side: BorderSide(color: CyberColors.primaryCyan.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {},
                    child: const Text('BROWSE', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'TARGET OUTPUT CONTAINER',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: CyberColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _containers.map((c) {
                final isSelected = _targetContainer == c;
                return GestureDetector(
                  onTap: () => setState(() => _targetContainer = c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
                    decoration: BoxDecoration(
                      color: isSelected ? CyberColors.secondaryViolet : CyberColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      c,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : CyberColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'STREAM SELECTION & MAPPING',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: CyberColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Column(
              children: [
                const CheckboxListTile(
                  dense: true,
                  activeColor: CyberColors.primaryCyan,
                  title: Text('Stream #0:0 Video [HEVC 10-bit 3840x2160]', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: Colors.white)),
                  value: true,
                  onChanged: null,
                ),
                const Divider(height: 1, color: CyberColors.borderStructural),
                CheckboxListTile(
                  dense: true,
                  activeColor: CyberColors.primaryCyan,
                  title: const Text('Stream #0:1 Audio [English DTS-HD MA 7.1]', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: Colors.white)),
                  value: _includeAudio1,
                  onChanged: (val) => setState(() => _includeAudio1 = val ?? true),
                ),
                const Divider(height: 1, color: CyberColors.borderStructural),
                CheckboxListTile(
                  dense: true,
                  activeColor: CyberColors.primaryCyan,
                  title: const Text('Stream #0:2 Audio [Director Commentary Stereo]', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: Colors.white)),
                  value: _includeAudio2,
                  onChanged: (val) => setState(() => _includeAudio2 = val ?? false),
                ),
                const Divider(height: 1, color: CyberColors.borderStructural),
                CheckboxListTile(
                  dense: true,
                  activeColor: CyberColors.primaryCyan,
                  title: const Text('Stream #0:3 Subtitle [English SDH .ass]', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: Colors.white)),
                  value: _includeSubtitles,
                  onChanged: (val) => setState(() => _includeSubtitles = val ?? true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Progress indicator if muxing
          if (_isMuxing || _muxProgress > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CyberColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CyberColors.borderStructural),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('REMUXING CONTAINER', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: Colors.white)),
                      Text('${(_muxProgress * 100).toInt()}%', style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: CyberColors.secondaryViolet, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _muxProgress,
                    backgroundColor: CyberColors.surfaceCarbonRaised,
                    valueColor: const AlwaysStoppedAnimation<Color>(CyberColors.secondaryViolet),
                    minHeight: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberColors.secondaryViolet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: Icon(_isMuxing ? Icons.sync : Icons.transform, size: 20),
              label: Text(
                _isMuxing ? 'REMUXING...' : 'START LOSSLESS MUX',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              onPressed: _isMuxing ? null : _runMuxer,
            ),
          ),
        ],
      ),
    );
  }
}
