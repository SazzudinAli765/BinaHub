import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_app_bar.dart';
import '../../../core/widgets/cyber_badge.dart';
import '../../../core/widgets/cyber_chip.dart';
import '../models/video_item.dart';
import '../widgets/search_filter_modal.dart';
import 'video_player_screen.dart';

/// Video Library Screen
/// Replicates the Stitch "bina_hub_video_library" Cyber Precision specification.
class VideoLibraryScreen extends StatefulWidget {
  final VoidCallback? onOpenVault;
  final VoidCallback? onOpenFolders;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenEarn;

  const VideoLibraryScreen({
    this.onOpenVault,
    this.onOpenFolders,
    this.onOpenProfile,
    this.onOpenEarn,
  });

  @override
  _VideoLibraryScreenState createState() => _VideoLibraryScreenState();
}

class _VideoLibraryScreenState extends State<VideoLibraryScreen> {
  String _selectedFilter = 'All';
  String _currentSort = 'Date Added (Newest)';
  bool _isGridView = true;
  String _searchQuery = '';

  final List<String> _filters = ['All', '4K', '1440p', '1080p', '720p', '480p'];
  late List<VideoItem> _allVideos;

  @override
  void initState() {
    super.initState();
    _allVideos = List.from(VideoItem.sampleVideos);
  }

  List<VideoItem> get _filteredVideos {
    final list = _allVideos.where((v) {
      if (_selectedFilter != 'All' && !v.resolution.contains(_selectedFilter)) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !v.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    // Apply sorting
    if (_currentSort.contains('Title') || _currentSort.contains('A-Z') || _currentSort.contains('A – Z')) {
      list.sort((a, b) => a.title.compareTo(b.title));
    } else if (_currentSort.contains('Resolution') || _currentSort.contains('Quality')) {
      list.sort((a, b) => b.resolution.compareTo(a.resolution));
    } else if (_currentSort.contains('File Size')) {
      list.sort((a, b) => b.fileSizeMb.compareTo(a.fileSizeMb));
    } else if (_currentSort.contains('Duration')) {
      list.sort((a, b) => b.duration.compareTo(a.duration));
    } else if (_currentSort.contains('Oldest')) {
      list.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
    } else {
      // Newest first default
      list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    }

    return list;
  }

  void _toggleFavorite(String id) {
    setState(() {
      final index = _allVideos.indexWhere((v) => v.id == id);
      if (index != -1) {
        final current = _allVideos[index];
        _allVideos[index] = VideoItem(
          id: current.id,
          title: current.title,
          path: current.path,
          duration: current.duration,
          resolution: current.resolution,
          codec: current.codec,
          fileSizeMb: current.fileSizeMb,
          dateAdded: current.dateAdded,
          thumbnailAsset: current.thumbnailAsset,
          isFavorite: !current.isFavorite,
          lastPosition: current.lastPosition,
        );
      }
    });
  }

  void _quickResume() {
    if (_allVideos.isNotEmpty) {
      final resumeVideo = _allVideos.firstWhere(
        (v) => v.lastPosition > Duration.zero,
        orElse: () => _allVideos.first,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: resumeVideo)),
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
          'Date Added (Oldest)',
          'Resolution (Highest)',
          'File Size (Largest)',
          'Duration (Longest)',
          'Title (A-Z)',
        ];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              return ListTile(
                dense: true,
                title: Text(opt, style: CyberTypography.bodyMedium),
                trailing: _currentSort == opt
                    ? const Icon(Icons.check, color: CyberColors.primaryCyan, size: 18)
                    : null,
                onTap: () {
                  setState(() => _currentSort = opt);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _openSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CyberColors.surfaceCarbonRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => SearchFilterModal(
        onApply: (query, res, sort) {
          setState(() {
            _searchQuery = query;
            if (res != 'All') _selectedFilter = res;
            _currentSort = sort;
          });
        },
      ),
    );
  }

  void _showVideoOptions(VideoItem video) {
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
              leading: const Icon(Icons.play_circle_outline, color: CyberColors.primaryCyan),
              title: Text('Play Video', style: CyberTypography.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.graphic_eq, color: CyberColors.secondaryViolet),
              title: Text('Play as Background Audio', style: CyberTypography.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Playing audio in background: ${video.title}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.audio_file_outlined, color: CyberColors.textPrimary),
              title: Text('Extract to MP3 / AAC', style: CyberTypography.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sent to MP3 Extractor: ${video.title}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline, color: CyberColors.secondaryViolet),
              title: Text('Move to Secret Vault (Encrypted)', style: CyberTypography.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Transactional move to Vault: ${video.title}')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: CyberColors.textSecondary),
              title: Text('Media Information & Codecs', style: CyberTypography.bodyMedium),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videos = _filteredVideos;

    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: CyberTopAppBar(
        title: 'BinaHub',
        onSearchTap: _openSearch,
        onFolderTap: widget.onOpenFolders,
        onVaultTap: widget.onOpenVault,
        onProfileTap: widget.onOpenProfile,
        onEarnTap: widget.onOpenEarn,
      ),
      body: Column(
        children: [
          // Filter Chips Bar (Horizontal Scroll)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: CyberColors.bgPureBlack,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  return CyberFilterChip(
                    label: filter,
                    isSelected: _selectedFilter == filter,
                    onTap: () => setState(() => _selectedFilter = filter),
                  );
                }).toList(),
              ),
            ),
          ),

          // Sub-bar: Sort & Layout Switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
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
                const Spacer(),
                // Telemetry Chip (Stitch Frame 1: 142 Clips with green dot)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${videos.length}',
                        style: CyberTypography.telemetryMicro.copyWith(
                          color: CyberColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'CLIPS',
                        style: CyberTypography.telemetryMicro.copyWith(
                          color: CyberColors.textSecondary,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceCarbonRaised,
                    borderRadius: CyberShapes.roundedPanel,
                    border: Border.all(color: CyberColors.borderStructural, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.grid_view,
                          color: _isGridView ? CyberColors.primaryCyan : CyberColors.textSecondary,
                          size: 17,
                        ),
                        onPressed: () => setState(() => _isGridView = true),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                        splashRadius: 16,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.view_agenda_outlined,
                          color: !_isGridView ? CyberColors.primaryCyan : CyberColors.textSecondary,
                          size: 17,
                        ),
                        onPressed: () => setState(() => _isGridView = false),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                        splashRadius: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Video Grid / List
          Expanded(
            child: videos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.video_library_outlined, size: 48, color: CyberColors.textMuted),
                        const SizedBox(height: 12),
                        Text('No videos found', style: CyberTypography.headlineSmall),
                        const SizedBox(height: 4),
                        Text('Try selecting a different filter chip', style: CyberTypography.bodySmall),
                      ],
                    ),
                  )
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: videos.length,
                        itemBuilder: (context, index) {
                          return _buildGridCard(videos[index]);
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: videos.length,
                        itemBuilder: (context, index) {
                          return _buildListTile(videos[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton.extended(
          onPressed: _quickResume,
          backgroundColor: CyberColors.primaryCyan,
          foregroundColor: const Color(0xFF002022),
          elevation: 6,
          icon: const Icon(Icons.play_circle_filled, size: 20),
          label: Text(
            'Quick Resume',
            style: CyberTypography.buttonAction.copyWith(
              color: const Color(0xFF002022),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(VideoItem video) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: CyberColors.surfaceCarbon,
          borderRadius: CyberShapes.roundedMicro,
          border: Border.all(color: CyberColors.borderStructural, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Area (16:9 ratio)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: CyberColors.surfaceContainerLow,
                    child: const Center(
                      child: Icon(Icons.movie_outlined, size: 28, color: CyberColors.borderStructural),
                    ),
                  ),

                  // Duration Pill (Bottom Right)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        video.formattedDuration,
                        style: CyberTypography.telemetryTimecode.copyWith(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),

                  // Top Left Resolution Badge
                  Positioned(
                    top: 4,
                    left: 4,
                    child: ResolutionBadge(
                      resolution: video.resolution,
                      isUltra: video.resolution.contains('4K'),
                    ),
                  ),

                  // Top Right Favorite Button (Interactive micro-interaction)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(video.id),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          shape: BoxShape.circle,
                          border: Border.all(color: CyberColors.borderStructural, width: 0.8),
                        ),
                        child: Icon(
                          video.isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 15,
                          color: video.isFavorite ? CyberColors.thermalRed : CyberColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  // Bottom Progress Bar (Stitch Frame 1: Cyber Precision Cyan Progress Line)
                  if (video.lastPosition > Duration.zero)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2.5,
                        color: CyberColors.surfaceCarbonRaised,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (video.lastPosition.inSeconds / video.duration.inSeconds).clamp(0.0, 1.0),
                          child: Container(color: CyberColors.primaryCyan),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Card Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      video.title,
                      style: CyberTypography.bodyMedium.copyWith(
                        color: CyberColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Codec & Options Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CodecBadge(label: video.codec, isViolet: true),
                        GestureDetector(
                          onTap: () => _showVideoOptions(video),
                          child: const Icon(Icons.more_vert, size: 16, color: CyberColors.textSecondary),
                        ),
                      ],
                    ),

                    // File size & date
                    Text(
                      '${video.formattedSize} • ${video.dateAdded}',
                      style: CyberTypography.telemetryMicro,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(VideoItem video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: CyberColors.surfaceCarbon,
        borderRadius: CyberShapes.roundedMicro,
        border: Border.all(color: CyberColors.borderStructural, width: 1.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        leading: SizedBox(
          width: 72,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: CyberColors.surfaceContainerLow,
                  child: const Center(
                    child: Icon(Icons.movie_outlined, size: 18, color: CyberColors.borderStructural),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Text(
                    video.formattedDuration,
                    style: CyberTypography.telemetryMicro.copyWith(fontSize: 8, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          video.title,
          style: CyberTypography.bodyMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            ResolutionBadge(resolution: video.resolution),
            const SizedBox(width: 6),
            CodecBadge(label: video.codec, isViolet: true),
            const SizedBox(width: 6),
            Text(video.formattedSize, style: CyberTypography.telemetryMicro),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, size: 18, color: CyberColors.textSecondary),
          onPressed: () => _showVideoOptions(video),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
          );
        },
      ),
    );
  }
}
