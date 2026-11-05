import 'dart:async';

enum DecoderMode { hw, hwPlus, sw, hybrid }
enum PlaybackState { idle, buffering, playing, paused, completed, error }

class MediaTrack {
  final int id;
  final String title;
  final String language;
  final String codec;
  final int? channels;
  final int? sampleRate;

  const MediaTrack({
    required this.id,
    required this.title,
    required this.language,
    required this.codec,
    this.channels,
    this.sampleRate,
  });
}

class SubtitleTrack {
  final int id;
  final String title;
  final String language;
  final String format; // srt, ass, vtt
  final bool isExternal;

  const SubtitleTrack({
    required this.id,
    required this.title,
    required this.language,
    required this.format,
    this.isExternal = false,
  });
}

/// Abstract Media Engine Adapter (ARCH-01)
/// Standardizes interface for mpv, FFmpeg, and Android MediaCodec backends.
abstract class MediaEngineAdapter {
  Future<void> initialize();
  Future<void> loadSource(String uri, {DecoderMode decoder = DecoderMode.hwPlus});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setSpeed(double speed);
  Future<void> stepFrame(int direction); // -1 for previous, +1 for next (VID-12)
  Future<void> setDecoderMode(DecoderMode mode);
  Future<void> setAudioTrack(int trackId);
  Future<void> setSubtitleTrack(int trackId);
  Future<void> setSubtitleOffset(Duration offset);
  Future<void> dispose();

  Stream<Duration> get onPositionChanged;
  Stream<Duration> get onDurationChanged;
  Stream<PlaybackState> get onStateChanged;
  Stream<DecoderMode> get onDecoderChanged;
  Stream<String> get onErrorOccurred;
}
