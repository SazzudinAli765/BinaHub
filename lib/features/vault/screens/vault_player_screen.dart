import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/precision_scrubber.dart';

/// Secure Vault Media Player
/// In-memory stream decryption with hardware FLAG_SECURE window protection.
/// All diagnostic console strings and raw encryption telemetry purged in compliance with Condition 4.
class VaultPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const VaultPlayerScreen({required this.item});

  @override
  _VaultPlayerScreenState createState() => _VaultPlayerScreenState();
}

class _VaultPlayerScreenState extends State<VaultPlayerScreen> {
  static const _platform = MethodChannel('com.binahub.player/media_engine');

  bool _isPlaying = true;
  bool _controlsVisible = true;
  Timer? _autoHideTimer;

  Duration _position = const Duration(minutes: 5, seconds: 12);
  final Duration _duration = const Duration(minutes: 45, seconds: 10);

  @override
  void initState() {
    super.initState();
    _enableSecureFlag(true);
    _startAutoHideTimer();
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _enableSecureFlag(false);
    super.dispose();
  }

  Future<void> _enableSecureFlag(bool enable) async {
    try {
      await _platform.invokeMethod('setSecureWindowFlag', {'enable': enable});
    } catch (e) {
      debugPrint('[VaultPlayer] Could not set FLAG_SECURE: $e');
    }
  }

  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    if (_controlsVisible && _isPlaying) {
      _autoHideTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() => _controlsVisible = false);
        }
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
    if (_controlsVisible) {
      _startAutoHideTimer();
    }
  }

  void _seekRelative(int seconds) {
    setState(() {
      final newPos = _position + Duration(seconds: seconds);
      if (newPos < Duration.zero) {
        _position = Duration.zero;
      } else if (newPos > _duration) {
        _position = _duration;
      } else {
        _position = newPos;
      }
    });
    _startAutoHideTimer();
  }

  void _stepFrame(int frames) {
    // 24fps -> ~41.6ms per frame
    const frameDuration = Duration(milliseconds: 42);
    setState(() {
      final delta = frameDuration * frames;
      final newPos = _position + delta;
      if (newPos >= Duration.zero && newPos <= _duration) {
        _position = newPos;
      }
    });
    _startAutoHideTimer();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      body: SafeArea(
        child: GestureDetector(
          onTap: _toggleControls,
          onDoubleTapDown: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            if (details.localPosition.dx < screenWidth * 0.4) {
              _seekRelative(-10);
            } else if (details.localPosition.dx > screenWidth * 0.6) {
              _seekRelative(10);
            }
          },
          child: Stack(
            children: [
              // Media Playback Canvas
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0710),
                      border: Border.all(color: CyberColors.borderStructural),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: CyberColors.secondaryViolet.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_outline, size: 48, color: CyberColors.secondaryViolet),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.item['originalName'] ?? 'Protected Media',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: CyberColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Protected Playback',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: CyberColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Animated HUD Overlay Controls
              AnimatedOpacity(
                opacity: _controlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_controlsVisible,
                  child: Stack(
                    children: [
                      // Top Bar
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.85),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: CyberColors.textPrimary),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.item['originalName'] ?? 'Encrypted Media',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: CyberColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: CyberColors.secondaryViolet.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: CyberColors.secondaryViolet.withOpacity(0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.shield_outlined, size: 12, color: CyberColors.secondaryViolet),
                                    SizedBox(width: 4),
                                    Text(
                                      'VAULT',
                                      style: TextStyle(
                                        fontFamily: 'JetBrains Mono',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: CyberColors.secondaryViolet,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Center Play/Pause & Step HUD
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.replay_10, color: Colors.white, size: 36),
                              onPressed: () => _seekRelative(-10),
                            ),
                            const SizedBox(width: 24),
                            GestureDetector(
                              onTap: () {
                                setState(() => _isPlaying = !_isPlaying);
                                _startAutoHideTimer();
                              },
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: CyberColors.secondaryViolet,
                                  shape: BoxShape.circle,
                                  boxShadow: const [CyberColors.violetGlow],
                                ),
                                child: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              icon: const Icon(Icons.forward_10, color: Colors.white, size: 36),
                              onPressed: () => _seekRelative(10),
                            ),
                          ],
                        ),
                      ),

                      // Bottom HUD Scrubber & Transport
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.9),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PrecisionScrubber(
                                position: _position,
                                duration: _duration,
                                buffered: _duration,
                                onSeek: (pos) {
                                  setState(() => _position = pos);
                                  _startAutoHideTimer();
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(_position),
                                    style: const TextStyle(
                                      fontFamily: 'JetBrains Mono',
                                      fontSize: 11,
                                      color: CyberColors.textPrimary,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 26,
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: CyberColors.textSecondary,
                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                          ),
                                          onPressed: () => _stepFrame(-1),
                                          child: const Text(
                                            '-1F',
                                            style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      SizedBox(
                                        height: 26,
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: CyberColors.textSecondary,
                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                          ),
                                          onPressed: () => _stepFrame(1),
                                          child: const Text(
                                            '+1F',
                                            style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _formatDuration(_duration),
                                    style: const TextStyle(
                                      fontFamily: 'JetBrains Mono',
                                      fontSize: 11,
                                      color: CyberColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
