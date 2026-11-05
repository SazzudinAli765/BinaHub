class VideoItem {
  final String id;
  final String title;
  final String path;
  final Duration duration;
  final String resolution; // 4K UHD, 1080p, 720p
  final String codec; // HEVC 10-bit, AV1, H.264
  final int fileSizeMb;
  final String dateAdded;
  final String? thumbnailAsset;
  final bool isFavorite;
  final Duration lastPosition;

  const VideoItem({
    required this.id,
    required this.title,
    required this.path,
    required this.duration,
    required this.resolution,
    required this.codec,
    required this.fileSizeMb,
    required this.dateAdded,
    this.thumbnailAsset,
    this.isFavorite = false,
    this.lastPosition = Duration.zero,
  });

  String get formattedDuration {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get formattedSize {
    if (fileSizeMb > 1024) {
      return '${(fileSizeMb / 1024).toStringAsFixed(1)} GB';
    }
    return '$fileSizeMb MB';
  }

  static List<VideoItem> get sampleVideos => [
    const VideoItem(
      id: 'vid-1',
      title: 'Cyberpunk_Edgerunners_Ep10_Remastered_HDR.mkv',
      path: '/storage/emulated/0/Movies/Cyberpunk_Edgerunners_Ep10.mkv',
      duration: Duration(hours: 2, minutes: 14, seconds: 5),
      resolution: '4K UHD',
      codec: 'HEVC / 10-bit',
      fileSizeMb: 4280,
      dateAdded: '2026-11-01',
      isFavorite: true,
      lastPosition: Duration(hours: 1, minutes: 14, seconds: 22),
    ),
    const VideoItem(
      id: 'vid-2',
      title: 'Interstellar_Docking_Scene_4K_IMAX.mp4',
      path: '/storage/emulated/0/Movies/Interstellar_Docking.mp4',
      duration: Duration(minutes: 8, seconds: 45),
      resolution: '4K UHD',
      codec: 'AV1 / 10-bit',
      fileSizeMb: 1120,
      dateAdded: '2026-10-28',
      isFavorite: true,
      lastPosition: Duration(minutes: 4, seconds: 12),
    ),
    const VideoItem(
      id: 'vid-3',
      title: 'Blade_Runner_2049_Sea_Wall_Final_Battle.mkv',
      path: '/storage/emulated/0/Movies/Blade_Runner_2049.mkv',
      duration: Duration(minutes: 14, seconds: 30),
      resolution: '1440p',
      codec: 'HEVC / HDR10',
      fileSizeMb: 1850,
      dateAdded: '2026-10-22',
      isFavorite: false,
    ),
    const VideoItem(
      id: 'vid-4',
      title: 'Formula1_Monaco_GP_2026_Highlights_60FPS.ts',
      path: '/storage/emulated/0/Download/F1_Monaco_2026.ts',
      duration: Duration(minutes: 45, seconds: 10),
      resolution: '1080p',
      codec: 'AVC / 60 FPS',
      fileSizeMb: 2400,
      dateAdded: '2026-10-15',
      isFavorite: false,
    ),
    const VideoItem(
      id: 'vid-5',
      title: 'Oppenheimer_Trinity_Test_Sequence.mkv',
      path: '/storage/emulated/0/Movies/Oppenheimer_Trinity.mkv',
      duration: Duration(minutes: 12, seconds: 18),
      resolution: '1080p',
      codec: 'HEVC / DTS-HD',
      fileSizeMb: 950,
      dateAdded: '2026-10-10',
      isFavorite: true,
    ),
    const VideoItem(
      id: 'vid-6',
      title: 'Anime_Opening_Compilation_SuperResolution.mp4',
      path: '/storage/emulated/0/Anime/Openings.mp4',
      duration: Duration(minutes: 24, seconds: 40),
      resolution: '720p',
      codec: 'AVC / Stereo',
      fileSizeMb: 620,
      dateAdded: '2026-10-05',
      isFavorite: false,
    ),
  ];
}
