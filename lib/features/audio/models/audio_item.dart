class AudioItem {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String format; // FLAC, MP3, AAC, WAV
  final String quality; // 96kHz / 24-bit, 320 kbps
  final String path;
  final bool isFavorite;
  final List<String>? lyrics;

  const AudioItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.format,
    required this.quality,
    required this.path,
    this.isFavorite = false,
    this.lyrics,
  });

  String get formattedDuration {
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static List<AudioItem> get sampleTracks => [
    const AudioItem(
      id: 'aud-1',
      title: 'Synthwave_Overdrive_2026_Remaster',
      artist: 'Cyberpunk Soundscapes',
      album: 'Neon Grid Symphony',
      duration: Duration(minutes: 4, seconds: 28),
      format: 'FLAC',
      quality: '96kHz / 24-bit',
      path: '/storage/emulated/0/Music/Synthwave_Overdrive.flac',
      isFavorite: true,
      lyrics: [
        'Neon lights cutting through the acid rain',
        'Digital pulse running through my veins',
        'Vulkan cores overclocked to maximum speed',
        'In the matrix of glass and steel we bleed',
        'Zero frame drop, pure bitstream flight',
        'Lost in the glow of the cyber night',
      ],
    ),
    const AudioItem(
      id: 'aud-2',
      title: 'Quantum_Decay_Atmospheric_Mix',
      artist: 'Acoustic Nexus',
      album: 'Sub-Bass Dimensions',
      duration: Duration(minutes: 6, seconds: 12),
      format: 'FLAC',
      quality: '192kHz / 24-bit',
      path: '/storage/emulated/0/Music/Quantum_Decay.flac',
      isFavorite: true,
    ),
    const AudioItem(
      id: 'aud-3',
      title: 'Solaris_Solar_Winds_Ambient',
      artist: 'Drift Protocol',
      album: 'Exosphere Vol. 4',
      duration: Duration(minutes: 5, seconds: 45),
      format: 'WAV',
      quality: 'Lossless PCM',
      path: '/storage/emulated/0/Music/Solaris.wav',
      isFavorite: false,
    ),
    const AudioItem(
      id: 'aud-4',
      title: 'Tokyo_Midnight_Monorail',
      artist: 'Binaural Beats Studio',
      album: 'Urban Field Recordings',
      duration: Duration(minutes: 3, seconds: 50),
      format: 'MP3',
      quality: '320 kbps',
      path: '/storage/emulated/0/Music/Tokyo_Midnight.mp3',
      isFavorite: false,
    ),
    const AudioItem(
      id: 'aud-5',
      title: 'Video_Extracted_Soundtrack_01',
      artist: 'BinaHub Muxer Engine',
      album: 'Extracted Audio',
      duration: Duration(minutes: 2, seconds: 40),
      format: 'MP3',
      quality: '320 kbps',
      path: '/storage/emulated/0/Music/Extracted/Soundtrack_01.mp3',
      isFavorite: false,
    ),
  ];
}
