import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_app_bar.dart';
import '../../../core/widgets/cyber_badge.dart';
import '../models/audio_item.dart';
import 'full_audio_player_screen.dart';

/// Audio Library Screen
/// Aligns with the Stitch "bina_hub_audio_library" Cyber Precision specification.
class AudioLibraryScreen extends StatefulWidget {
  final VoidCallback? onOpenVault;
  final VoidCallback? onOpenFolders;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenEarn;

  const AudioLibraryScreen({
    this.onOpenVault,
    this.onOpenFolders,
    this.onOpenProfile,
    this.onOpenEarn,
  });

  @override
  _AudioLibraryScreenState createState() => _AudioLibraryScreenState();
}

class _AudioLibraryScreenState extends State<AudioLibraryScreen> {
  String _selectedFilter = 'All';
  String _currentSort = 'Date Added (Newest)';
  String _searchQuery = '';
  String? _currentlyPlayingId = 'aud-1'; // Tracks active playback

  final List<String> _filters = ['All', 'Playlists', 'Favorites', 'MP3', 'Extracted'];
  late List<AudioItem> _tracks;

  @override
  void initState() {
    super.initState();
    _tracks = List.from(AudioItem.sampleTracks);
  }

  List<AudioItem> get _filteredTracks {
    final list = _tracks.where((t) {
      if (_selectedFilter == 'Favorites' && !t.isFavorite) return false;
      if (_selectedFilter == 'MP3' && t.format != 'MP3') return false;
      if (_selectedFilter == 'Extracted' && !t.album.contains('Extracted')) return false;
      if (_searchQuery.isNotEmpty &&
          !t.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !t.artist.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    // Real sorting implementation
    if (_currentSort.contains('Title') || _currentSort.contains('A-Z')) {
      list.sort((a, b) => a.title.compareTo(b.title));
    } else if (_currentSort.contains('Artist')) {
      list.sort((a, b) => a.artist.compareTo(b.artist));
    } else if (_currentSort.contains('Duration')) {
      list.sort((a, b) => b.duration.compareTo(a.duration));
    } else if (_currentSort.contains('Bitrate') || _currentSort.contains('Quality')) {
      list.sort((a, b) => b.quality.compareTo(a.quality));
    } else if (_currentSort.contains('File Size')) {
      list.sort((a, b) => b.duration.compareTo(a.duration));
    } else {
      // Default: Date Added
      list.sort((a, b) => a.id.compareTo(b.id));
    }

    return list;
  }

  void _toggleFavorite(String id) {
    setState(() {
      final index = _tracks.indexWhere((t) => t.id == id);
      if (index != -1) {
        final current = _tracks[index];
        _tracks[index] = AudioItem(
          id: current.id,
          title: current.title,
          artist: current.artist,
          album: current.album,
          duration: current.duration,
          format: current.format,
          quality: current.quality,
          path: current.path,
          isFavorite: !current.isFavorite,
          lyrics: current.lyrics,
        );
      }
    });
  }

  void _shuffleAll() {
    if (_tracks.isNotEmpty) {
      final shuffled = List<AudioItem>.from(_tracks)..shuffle();
      _openFullPlayer(shuffled.first, queue: shuffled);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shuffling all tracks in queue'),
          backgroundColor: CyberColors.surfaceCarbonRaised,
        ),
      );
    }
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CyberColors.surfaceCarbonRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) {
        final options = [
          'Date Added (Newest)',
          'Title (A-Z)',
          'Duration (Longest)',
          'File Size (Largest)',
          'Bitrate / Quality',
        ];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'SORT TRACKS BY',
                      style: CyberTypography.telemetryMicro.copyWith(letterSpacing: 1.0),
                    ),
                  ],
                ),
              ),
              const Divider(color: CyberColors.borderStructural, height: 1),
              ...options.map((opt) {
                final isSelected = _currentSort == opt;
                return ListTile(
                  dense: true,
                  title: Text(
                    opt,
                    style: CyberTypography.bodyMedium.copyWith(
                      color: isSelected ? CyberColors.primaryCyan : CyberColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: CyberColors.primaryCyan, size: 18)
                      : null,
                  onTap: () {
                    setState(() => _currentSort = opt);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _openFullPlayer(AudioItem track, {List<AudioItem>? queue}) {
    setState(() => _currentlyPlayingId = track.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullAudioPlayerScreen(
          track: track,
          playlist: queue ?? _tracks,
        ),
      ),
    );
  }

  void _showTrackOptions(AudioItem track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CyberColors.surfaceCarbonRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: CyberColors.primaryCyan),
              title: Text('Play Track', style: CyberTypography.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                _openFullPlayer(track);
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music, color: CyberColors.textPrimary),
              title: Text('Play Next in Queue', style: CyberTypography.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added to front of queue: ${track.title}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: CyberColors.textPrimary),
              title: Text('Add to Playlist', style: CyberTypography.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added to playlist: ${track.title}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline, color: CyberColors.secondaryViolet),
              title: Text('Move to Secret Vault (Encrypted)', style: CyberTypography.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Moved to Vault: ${track.title}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: CyberColors.textSecondary),
              title: Text('Track Information & Bitstream', style: CyberTypography.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${track.title} • ${track.format} • ${track.quality}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracks = _filteredTracks;

    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: CyberTopAppBar(
        title: 'BinaHub',
        onSearchTap: () {
          // Quick in-library search
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: CyberColors.surfaceCarbonRaised,
                title: Text('Search Audio Library', style: CyberTypography.headlineSmall),
                content: TextField(
                  autofocus: true,
                  style: CyberTypography.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: 'Track title, artist, or album...',
                    prefixIcon: Icon(Icons.search, color: CyberColors.primaryCyan),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() => _searchQuery = '');
                      Navigator.pop(context);
                    },
                    child: const Text('Clear', style: TextStyle(color: CyberColors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done', style: TextStyle(color: CyberColors.primaryCyan)),
                  ),
                ],
              );
            },
          );
        },
        onFolderTap: widget.onOpenFolders,
        onVaultTap: widget.onOpenVault,
        onProfileTap: widget.onOpenProfile,
        onEarnTap: widget.onOpenEarn,
      ),
      body: Column(
        children: [
          // Filter & Sort Toolbar matching Stitch Frame 2
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: CyberColors.bgPureBlack,
            child: Column(
              children: [
                // Filter Pills (Row 1)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: isSelected ? CyberColors.primaryCyan : CyberColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: isSelected ? const [CyberColors.cyanGlow] : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF002022),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Text(
                                filter,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? const Color(0xFF002022) : CyberColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                // Controls & Telemetry Stats (Row 2)
                Row(
                  children: [
                    // Sort by dropdown button
                    GestureDetector(
                      onTap: _showSortMenu,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: CyberColors.surfaceCarbonRaised,
                          borderRadius: CyberShapes.roundedPanel,
                          border: Border.all(color: CyberColors.borderStructural, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sort, color: CyberColors.primaryCyan, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              _currentSort,
                              style: CyberTypography.bodySmall.copyWith(
                                color: CyberColors.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.expand_more, color: CyberColors.textSecondary, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Shuffle All Button (Stitch Frame 2)
                    GestureDetector(
                      onTap: _shuffleAll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: CyberColors.surfaceCarbonRaised,
                          borderRadius: CyberShapes.roundedPanel,
                          border: Border.all(color: CyberColors.borderStructural, width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shuffle, color: CyberColors.primaryCyan, size: 15),
                            SizedBox(width: 6),
                            Text(
                              'Shuffle All',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: CyberColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Telemetry Chip (Stitch Frame 2: 5 TRACKS with pulsing green dot)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color: CyberColors.surfaceCarbonRaised,
                        borderRadius: CyberShapes.roundedMicro,
                        border: Border.all(color: CyberColors.borderStructural, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: CyberColors.signalGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: CyberColors.signalGreen,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${tracks.length}',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'TRACKS',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: CyberColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Track List Container matching Stitch Frame 2
          Expanded(
            child: tracks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.music_off_outlined, size: 48, color: CyberColors.textMuted),
                        const SizedBox(height: 12),
                        Text('No tracks found', style: CyberTypography.headlineSmall),
                        const SizedBox(height: 4),
                        Text('Try selecting a different filter chip', style: CyberTypography.bodySmall),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      final isPlaying = _currentlyPlayingId == track.id;

                      return Container(
                        height: 64,
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isPlaying ? CyberColors.surfaceContainerHigh : CyberColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPlaying ? CyberColors.primaryCyan.withOpacity(0.4) : CyberColors.borderStructural,
                            width: 1.0,
                          ),
                          boxShadow: isPlaying ? const [CyberColors.cyanGlow] : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _openFullPlayer(track),
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              children: [
                                // Album artwork (44x44) with duration pill and now playing halo
                                SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF080F17),
                                          borderRadius: BorderRadius.circular(8),
                                          border: isPlaying
                                              ? Border.all(color: CyberColors.primaryCyan.withOpacity(0.6))
                                              : null,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            isPlaying ? Icons.graphic_eq : Icons.music_note,
                                            size: 20,
                                            color: isPlaying ? CyberColors.primaryCyan : CyberColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 2,
                                        right: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.85),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: Text(
                                            track.formattedDuration,
                                            style: const TextStyle(
                                              fontFamily: 'JetBrains Mono',
                                              fontSize: 8,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Title and Subtitle Metadata
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        track.title,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isPlaying ? CyberColors.primaryCyan : CyberColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Text(
                                            track.format == 'FLAC' ? '38.4 MB' : '8.2 MB',
                                            style: const TextStyle(
                                              fontFamily: 'JetBrains Mono',
                                              fontSize: 10,
                                              color: CyberColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text('•', style: TextStyle(color: CyberColors.textMuted, fontSize: 10)),
                                          const SizedBox(width: 4),
                                          Text(
                                            track.format,
                                            style: TextStyle(
                                              fontFamily: 'JetBrains Mono',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: track.format == 'FLAC'
                                                  ? CyberColors.secondaryViolet
                                                  : CyberColors.primaryCyan,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text('•', style: TextStyle(color: CyberColors.textMuted, fontSize: 10)),
                                          const SizedBox(width: 4),
                                          Text(
                                            track.quality.contains('24-bit') ? '24-BIT' : 'Stereo',
                                            style: TextStyle(
                                              fontFamily: 'JetBrains Mono',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: track.quality.contains('24-bit')
                                                  ? CyberColors.signalGreen
                                                  : CyberColors.textSecondary,
                                            ),
                                          ),
                                          if (isPlaying) ...[
                                            const SizedBox(width: 4),
                                            const Text('•', style: TextStyle(color: CyberColors.textMuted, fontSize: 10)),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'Now Playing',
                                              style: TextStyle(
                                                fontFamily: 'JetBrains Mono',
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color: CyberColors.primaryCyan,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Interactive Favorite Heart Button
                                IconButton(
                                  icon: Icon(
                                    track.isFavorite ? Icons.favorite : Icons.favorite_border,
                                    size: 19,
                                    color: track.isFavorite ? CyberColors.thermalRed : CyberColors.textSecondary,
                                  ),
                                  onPressed: () => _toggleFavorite(track.id),
                                  splashRadius: 18,
                                ),

                                // More Options Button
                                IconButton(
                                  icon: const Icon(Icons.more_vert, size: 19, color: CyberColors.textSecondary),
                                  onPressed: () => _showTrackOptions(track),
                                  splashRadius: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
