import 'package:flutter/material.dart';
import '../theme/cyber_colors.dart';
import '../theme/cyber_shapes.dart';
import '../theme/cyber_typography.dart';
import 'cyber_badge.dart';

/// Docked Mini-Player Widget
/// Docked directly above the bottom navigation bar during active playback.
class DockedMiniPlayer extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? formatBadge;
  final bool isPlaying;
  final double progress; // 0.0 to 1.0
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onTap;
  final VoidCallback? onClose;

  const DockedMiniPlayer({
    required this.title,
    required this.subtitle,
    required this.isPlaying,
    required this.progress,
    required this.onPlayPause,
    required this.onNext,
    required this.onTap,
    this.formatBadge = 'FLAC 96k',
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: CyberColors.surfaceCarbonRaised,
        border: const Border(
          top: BorderSide(color: CyberColors.borderStructural, width: 1.0),
        ),
      ),
      child: Stack(
        children: [
          // Top 1.5px progress indicator
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(CyberColors.primaryCyan),
              minHeight: 1.5,
            ),
          ),

          // Player contents
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    // Album art / thumbnail box
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: CyberColors.surfaceCarbon,
                        borderRadius: CyberShapes.roundedMicro,
                        border: Border.all(color: CyberColors.borderStructural, width: 1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.graphic_eq,
                          size: 20,
                          color: CyberColors.primaryCyan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Title, subtitle and format tag
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: CyberTypography.bodyMedium.copyWith(
                                    color: CyberColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (formatBadge != null) ...[
                                const SizedBox(width: 6),
                                CodecBadge(label: formatBadge!, isViolet: true),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: CyberTypography.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Controls
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: CyberColors.primaryCyan,
                        size: 24,
                      ),
                      onPressed: onPlayPause,
                      splashRadius: 20,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.skip_next,
                        color: CyberColors.textPrimary,
                        size: 22,
                      ),
                      onPressed: onNext,
                      splashRadius: 20,
                    ),
                    if (onClose != null)
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: CyberColors.textTertiary,
                          size: 18,
                        ),
                        onPressed: onClose,
                        splashRadius: 18,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
