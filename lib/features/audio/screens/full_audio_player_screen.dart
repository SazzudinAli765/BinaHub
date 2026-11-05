import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_badge.dart';
import '../../../core/widgets/precision_scrubber.dart';
import '../models/audio_item.dart';
import '../widgets/equalizer_sheet.dart';
import '../widgets/queue_sheet.dart';
import '../widgets/sleep_timer_dialog.dart';

/// Full-Screen Audio Player & Synchronized Lyrics View
/// Aligns with Cyber Precision typography, restrained dark OLED palette, and responsive controls.
class FullAudioPlayerScreen extends StatefulWidget {
  final AudioItem track;
  final List<AudioItem> playlist;

  const FullAudioPlayerScreen({
    required this.track,
    required this.playlist,
  });

  @override
  _FullAudioPlayerScreenState createState() => _FullAudioPlayerScreenState();
}

class _FullAudioPlayerScreenState extends State<FullAudioPlayerScreen> {
  late AudioItem _currentTrack;
  late int _currentIndex;
  bool _isPlaying = true;
  bool _isShuffle = false;
  int _repeatMode = 1; // 0 = off, 1 = all, 2 = one
  bool _showLyrics = false;
  int _currentLyricLine = 2;

  late Duration _position;
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _currentTrack = widget.track;
    _currentIndex = widget.playlist.indexOf(widget.track);
    if (_currentIndex == -1) _currentIndex = 0;
    _duration = widget.track.duration;
    _position = const Duration(minutes: 1, seconds: 12);
  }

  void _skipTrack(bool next) {
    setState(() {
      if (next) {
        _currentIndex = (_currentIndex + 1) % widget.playlist.length;
      } else {
        _currentIndex = (_currentIndex - 1 + widget.playlist.length) % widget.playlist.length;
      }
      _currentTrack = widget.playlist[_currentIndex];
      _duration = _currentTrack.duration;
      _position = Duration.zero;
    });
  }

  void _openEqualizer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CyberColors.surfaceCarbonRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => EqualizerSheet(),
    );
  }

  void _openQueue() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CyberColors.surfaceCarbonRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => QueueSheet(
        initialQueue: widget.playlist,
        currentIndex: _currentIndex,
        onTrackSelected: (idx) {
          setState(() {
            _currentIndex = idx;
            _currentTrack = widget.playlist[idx];
            _duration = _currentTrack.duration;
            _position = Duration.zero;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openSleepTimer() {
    showDialog(
      context: context,
      builder: (_) => SleepTimerDialog(
        onTimerSet: (duration) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sleep timer set for ${duration.inMinutes} minutes'),
              backgroundColor: CyberColors.surfaceCarbonRaised,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, color: CyberColors.textPrimary, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'NOW PLAYING',
                          style: CyberTypography.telemetryMicro.copyWith(letterSpacing: 1.0),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currentTrack.album,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CyberColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.queue_music, color: CyberColors.textSecondary, size: 22),
                    onPressed: _openQueue,
                    tooltip: 'Queue',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Center: Album Art OR Synchronized LRC Lyrics
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _showLyrics ? _buildLyricsView() : _buildAlbumArtworkView(),
              ),
            ),

            const SizedBox(height: 16),

            // Track Title, Artist, Favorite & Quality Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentTrack.title,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: CyberColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _currentTrack.artist,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: CyberColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            CodecBadge(label: _currentTrack.format, isViolet: _currentTrack.format == 'FLAC'),
                            const SizedBox(width: 6),
                            Text(
                              _currentTrack.quality,
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                color: CyberColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _currentTrack.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _currentTrack.isFavorite ? CyberColors.thermalRed : CyberColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        // Toggle favorite on local track
                      });
                    },
                    tooltip: 'Favorite',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Precision Timeline Scrubber
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: PrecisionScrubber(
                position: _position,
                duration: _duration,
                buffered: Duration(milliseconds: (_duration.inMilliseconds * 0.8).toInt()),
                onSeek: (pos) => setState(() => _position = pos),
              ),
            ),

            const SizedBox(height: 16),

            // Transport Controls: Shuffle, Previous, Play/Pause, Next, Repeat
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: _isShuffle ? CyberColors.primaryCyan : CyberColors.textSecondary,
                      size: 22,
                    ),
                    onPressed: () => setState(() => _isShuffle = !_isShuffle),
                    tooltip: 'Shuffle',
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: CyberColors.textPrimary, size: 36),
                    onPressed: () => _skipTrack(false),
                    tooltip: 'Previous Track',
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isPlaying = !_isPlaying),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: CyberColors.primaryCyan,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: CyberColors.primaryCyan,
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 32,
                        color: const Color(0xFF002022),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: CyberColors.textPrimary, size: 36),
                    onPressed: () => _skipTrack(true),
                    tooltip: 'Next Track',
                  ),
                  IconButton(
                    icon: Icon(
                      _repeatMode == 2 ? Icons.repeat_one : Icons.repeat,
                      color: _repeatMode > 0 ? CyberColors.primaryCyan : CyberColors.textSecondary,
                      size: 22,
                    ),
                    onPressed: () => setState(() => _repeatMode = (_repeatMode + 1) % 3),
                    tooltip: 'Repeat Mode',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bottom Audio Tools: Lyrics Toggle, 10-Band EQ, Sleep Timer, Audio Output
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.lyrics_outlined,
                      color: _showLyrics ? CyberColors.primaryCyan : CyberColors.textSecondary,
                      size: 20,
                    ),
                    tooltip: 'Synchronized Lyrics',
                    onPressed: () => setState(() => _showLyrics = !_showLyrics),
                  ),
                  IconButton(
                    icon: const Icon(Icons.equalizer, color: CyberColors.textSecondary, size: 20),
                    tooltip: '10-Band Equalizer',
                    onPressed: _openEqualizer,
                  ),
                  IconButton(
                    icon: const Icon(Icons.timer_outlined, color: CyberColors.textSecondary, size: 20),
                    tooltip: 'Sleep Timer',
                    onPressed: _openSleepTimer,
                  ),
                  IconButton(
                    icon: const Icon(Icons.speaker_group_outlined, color: CyberColors.textSecondary, size: 20),
                    tooltip: 'Audio Output Stream',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Audio Output: Hi-Res Audio Stream Active'),
                          backgroundColor: CyberColors.surfaceCarbonRaised,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArtworkView() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F151F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CyberColors.borderStructural, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Subtle concentric rings indicating high-fidelity audio
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CyberColors.primaryCyan.withOpacity(0.15), width: 1),
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CyberColors.primaryCyan.withOpacity(0.25), width: 1),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.graphic_eq,
                    size: 64,
                    color: CyberColors.primaryCyan.withOpacity(0.85),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CyberColors.surfaceCarbonRaised,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: CyberColors.borderStructural),
                    ),
                    child: Text(
                      _currentTrack.format == 'FLAC' ? 'LOSSLESS AUDIO' : 'HIGH BITRATE AUDIO',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: CyberColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLyricsView() {
    final lyrics = _currentTrack.lyrics ?? [
      'Synchronized lyrics not available for this track',
      'Searching local tag and embedded LRC metadata...',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberColors.surfaceCarbon,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CyberColors.borderStructural),
      ),
      child: ListView.builder(
        itemCount: lyrics.length,
        itemBuilder: (context, index) {
          final isCurrent = index == _currentLyricLine;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              lyrics[index],
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isCurrent ? 16 : 13,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                color: isCurrent ? CyberColors.primaryCyan : CyberColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}
