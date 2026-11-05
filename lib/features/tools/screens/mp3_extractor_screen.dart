import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../video/models/video_item.dart';
import '../../audio/models/audio_item.dart';

/// Video-to-Audio (MP3 / FLAC) Extractor Screen
/// Replicates the Stitch "bina_hub_media_tools_mp3_redesign" design.
/// Features interactive video selection, tag editing, bitrate selection, and direct library integration.
class Mp3ExtractorScreen extends StatefulWidget {
  final VideoItem? initialVideo;

  const Mp3ExtractorScreen({this.initialVideo});

  @override
  _Mp3ExtractorScreenState createState() => _Mp3ExtractorScreenState();
}

class _Mp3ExtractorScreenState extends State<Mp3ExtractorScreen> {
  late VideoItem _selectedVideo;
  String _selectedFormat = 'MP3';
  String _selectedBitrate = '320 kbps';
  String _selectedChannels = 'Stereo (2.0)';
  bool _addToLibrary = true;

  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _albumController;

  bool _isExtracting = false;
  double _progress = 0.0;
  String _statusText = 'Ready to extract';

  final List<String> _formats = ['MP3', 'AAC', 'FLAC', 'M4A', 'WAV'];
  final List<String> _bitrates = ['128 kbps', '192 kbps', '256 kbps', '320 kbps', 'Lossless (VBR)'];
  final List<String> _channels = ['Stereo (2.0)', 'Mono (1.0)', '5.1 Downmix'];

  @override
  void initState() {
    super.initState();
    _selectedVideo = widget.initialVideo ?? VideoItem.sampleVideos.first;
    _initMetadataControllers();
  }

  void _initMetadataControllers() {
    final cleanTitle = _selectedVideo.title
        .replaceAll(RegExp(r'\.(mp4|mkv|mov|avi|webm)$', caseSensitive: false), '')
        .replaceAll('_', ' ');

    _titleController = TextEditingController(text: cleanTitle);
    _artistController = TextEditingController(text: 'BinaHub Media Audio');
    _albumController = TextEditingController(text: 'Extracted Audio');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  void _showVideoPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CyberColors.surfaceCarbonRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'SELECT SOURCE VIDEO',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: CyberColors.primaryCyan,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: CyberColors.borderStructural, height: 1),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: VideoItem.sampleVideos.length,
                  itemBuilder: (context, idx) {
                    final video = VideoItem.sampleVideos[idx];
                    final isSelected = video.id == _selectedVideo.id;
                    return ListTile(
                      dense: true,
                      leading: Container(
                        width: 44,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF080F17),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected ? CyberColors.primaryCyan : CyberColors.borderStructural,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.movie_outlined, size: 16, color: CyberColors.textSecondary),
                        ),
                      ),
                      title: Text(
                        video.title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? CyberColors.primaryCyan : CyberColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${video.formattedSize} • ${video.formattedDuration} • ${video.resolution}',
                        style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: CyberColors.textSecondary),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: CyberColors.primaryCyan, size: 18)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedVideo = video;
                          _initMetadataControllers();
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startExtraction() {
    setState(() {
      _isExtracting = true;
      _progress = 0.0;
      _statusText = 'Demuxing audio bitstream...';
    });

    // Realistic progress simulation
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return false;

      setState(() {
        _progress += 0.09;
        if (_progress > 0.3 && _progress < 0.7) {
          _statusText = 'Encoding to $_selectedFormat ($_selectedBitrate)...';
        } else if (_progress >= 0.7 && _progress < 1.0) {
          _statusText = 'Writing ID3v2 metadata tags...';
        }
      });

      if (_progress >= 1.0) {
        setState(() {
          _isExtracting = false;
          _progress = 1.0;
          _statusText = 'Extraction complete';
        });

        // Add newly extracted item into sample tracks for immediate playback
        if (_addToLibrary) {
          AudioItem.sampleTracks.insert(
            0,
            AudioItem(
              id: 'extracted-${DateTime.now().millisecondsSinceEpoch}',
              title: _titleController.text.trim().isEmpty ? 'Extracted Audio' : _titleController.text.trim(),
              artist: _artistController.text.trim().isEmpty ? 'Unknown Artist' : _artistController.text.trim(),
              album: _albumController.text.trim().isEmpty ? 'Extracted Audio' : _albumController.text.trim(),
              duration: _selectedVideo.duration,
              format: _selectedFormat,
              quality: _selectedBitrate,
              path: '/storage/emulated/0/Music/Extracted/${_titleController.text.trim()}.${_selectedFormat.toLowerCase()}',
              isFavorite: false,
            ),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Extracted: "${_titleController.text}" saved to Music/Extracted/ and added to Audio Library',
            ),
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
          'MP3 & Audio Extractor',
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
          // SOURCE VIDEO CARD
          const Text(
            'SOURCE VIDEO',
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF070A0F),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberColors.primaryCyan.withOpacity(0.4)),
                  ),
                  child: const Center(
                    child: Icon(Icons.movie_outlined, color: CyberColors.primaryCyan, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedVideo.title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: CyberColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_selectedVideo.formattedSize} • ${_selectedVideo.formattedDuration} • ${_selectedVideo.codec}',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          color: CyberColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CyberColors.primaryCyan,
                      side: BorderSide(color: CyberColors.primaryCyan.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: _showVideoPickerModal,
                    child: const Text(
                      'CHANGE',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // OUTPUT AUDIO FORMAT
          const Text(
            'TARGET AUDIO FORMAT',
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
              children: _formats.map((fmt) {
                final isSelected = _selectedFormat == fmt;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFormat = fmt),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
                    decoration: BoxDecoration(
                      color: isSelected ? CyberColors.primaryCyan : CyberColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: isSelected ? const [CyberColors.cyanGlow] : null,
                    ),
                    child: Text(
                      fmt,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF002022) : CyberColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // TARGET BITRATE
          const Text(
            'TARGET BITRATE & QUALITY',
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
              children: _bitrates.map((br) {
                final isSelected = _selectedBitrate == br;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBitrate = br),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: isSelected ? CyberColors.surfaceCarbonRaised : CyberColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: isSelected ? CyberColors.primaryCyan : CyberColors.borderStructural,
                      ),
                    ),
                    child: Text(
                      br,
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? CyberColors.primaryCyan : CyberColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // CHANNEL MODE
          const Text(
            'CHANNEL MODE',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: CyberColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _channels.map((ch) {
              final isSelected = _selectedChannels == ch;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedChannels = ch),
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? CyberColors.surfaceCarbonRaised : CyberColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: isSelected ? CyberColors.primaryCyan : CyberColors.borderStructural,
                        ),
                      ),
                      child: Text(
                        ch,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? CyberColors.primaryCyan : CyberColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // AUDIO METADATA TAGS (Title, Artist, Album)
          const Text(
            'METADATA TAGS',
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
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Track Title',
                    labelStyle: TextStyle(color: CyberColors.textSecondary, fontSize: 12),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _artistController,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Artist',
                    labelStyle: TextStyle(color: CyberColors.textSecondary, fontSize: 12),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _albumController,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Album',
                    labelStyle: TextStyle(color: CyberColors.textSecondary, fontSize: 12),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ADD TO LIBRARY TOGGLE
          Container(
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: SwitchListTile(
              dense: true,
              activeColor: CyberColors.primaryCyan,
              title: const Text(
                'Add to Audio Library automatically',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              subtitle: const Text(
                'Instantly playable in the Audio tab upon completion',
                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: CyberColors.textSecondary),
              ),
              value: _addToLibrary,
              onChanged: (val) => setState(() => _addToLibrary = val),
            ),
          ),
          const SizedBox(height: 18),

          // EXTRACTION PROGRESS AREA
          if (_isExtracting || _progress > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CyberColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CyberColors.borderStructural),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _statusText,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: CyberColors.primaryCyan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: CyberColors.surfaceCarbonRaised,
                    valueColor: const AlwaysStoppedAnimation<Color>(CyberColors.primaryCyan),
                    minHeight: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // PRIMARY ACTION BUTTON
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
              icon: Icon(_isExtracting ? Icons.sync : Icons.bolt, size: 20),
              label: Text(
                _isExtracting ? 'EXTRACTING AUDIO...' : 'EXTRACT & SAVE AUDIO',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              onPressed: _isExtracting ? null : _startExtraction,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
