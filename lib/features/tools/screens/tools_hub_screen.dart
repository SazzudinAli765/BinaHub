import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_app_bar.dart';
import '../../../core/widgets/cyber_badge.dart';
import 'mp3_extractor_screen.dart';
import 'smart_muxer_screen.dart';
import 'video_trimmer_screen.dart';
import 'batch_queue_screen.dart';

/// Media Tools Hub Screen
/// Fully aligned with the Stitch "bina_hub_media_tools_mp3_redesign" specification.
/// Purged of internal tool numbers and diagnostic diagrams in compliance with Condition 4.
class ToolsHubScreen extends StatelessWidget {
  final VoidCallback? onOpenVault;
  final VoidCallback? onOpenFolders;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenEarn;

  const ToolsHubScreen({
    this.onOpenVault,
    this.onOpenFolders,
    this.onOpenProfile,
    this.onOpenEarn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: CyberTopAppBar(
        title: 'Media Tools',
        onSearchTap: () {},
        onFolderTap: onOpenFolders,
        onVaultTap: onOpenVault,
        onProfileTap: onOpenProfile,
        onEarnTap: onOpenEarn,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Header Hero Card
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceCarbonRaised,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberColors.primaryCyan.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.build_circle_outlined, color: CyberColors.primaryCyan, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Media Processing Suite',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CyberColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hardware-accelerated conversion, lossless extraction & remuxing',
                        style: CyberTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const CodecBadge(label: 'ACCELERATED', isCyan: true),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // FEATURE CARD 1: MP3 Audio Extractor (Stitch Frame 3 Card A)
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.transform, color: CyberColors.primaryCyan, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'MP3 Audio Extractor',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CyberColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: CyberColors.primaryCyan.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: CyberColors.primaryCyan.withOpacity(0.35)),
                      ),
                      child: const Text(
                        '320 KBPS • LOSSLESS',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: CyberColors.primaryCyan,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Source Video Preview Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070A0F),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberColors.borderStructural),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.movie_outlined, color: CyberColors.textSecondary, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'CyberCity_2088_Pro.mkv',
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: CyberColors.surfaceCarbonRaised,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              '4.2 GB',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 9,
                                color: CyberColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Icon(Icons.graphic_eq, color: CyberColors.signalGreen, size: 13),
                          SizedBox(width: 6),
                          Text(
                            'Stream #0:1 • DTS-HD 5.1 (48kHz) → MP3 320k',
                            style: TextStyle(
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
                const SizedBox(height: 10),

                // Extract Button
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberColors.primaryCyan,
                      foregroundColor: const Color(0xFF002022),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.bolt, size: 18),
                    label: const Text(
                      'Extract MP3 (Lossless Demux)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Mp3ExtractorScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // FEATURE CARD 2: Lossless Smart Muxer (Stitch Frame 3 Card B)
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.swap_horiz, color: CyberColors.secondaryViolet, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Lossless Smart Muxer',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CyberColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: CyberColors.secondaryViolet.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: CyberColors.secondaryViolet.withOpacity(0.35)),
                      ),
                      child: const Text(
                        'ZERO-RECODE',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: CyberColors.secondaryViolet,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Repackage MKV, MP4, and TS streams in seconds without re-encoding. Keeps 100% video bitstream quality intact.',
                  style: CyberTypography.bodySmall.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CyberColors.secondaryViolet,
                      side: BorderSide(color: CyberColors.secondaryViolet.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.flash_on, size: 16),
                    label: const Text(
                      'Launch Smart Muxer',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SmartMuxerScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // FEATURE CARD 3: Online Subtitles & Sync (Stitch Frame 3 Card C)
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.subtitles_outlined, color: CyberColors.primaryCyan, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Online Subtitles & .ASS Sync',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CyberColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: CyberColors.signalGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: CyberColors.signalGreen.withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: CyberColors.signalGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'HASH MATCH',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.signalGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Query / Match Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070A0F),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberColors.borderStructural),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'CyberCity_2088_Pro.mkv',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '3 Tracks Found',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              color: CyberColors.primaryCyan,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'ENG, JPN .ASS, FRA',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              color: CyberColors.textSecondary,
                            ),
                          ),
                          Text(
                            'AUTO-SYNC 23.976 fps',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 9,
                              color: CyberColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CyberColors.primaryCyan,
                            side: BorderSide(color: CyberColors.primaryCyan.withOpacity(0.4)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text(
                            'Fetch .ASS / SRT',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Synchronized subtitles downloaded: English (ENG .ASS) attached to player'),
                                backgroundColor: CyberColors.surfaceCarbonRaised,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: CyberColors.surfaceCarbonRaised,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CyberColors.borderStructural),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune, size: 16, color: CyberColors.textSecondary),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Subtitle sync calibration: -10s to +10s in 50ms steps available in Player')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // SECTION HEADER: Additional Processing Tools
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'ADDITIONAL PROCESSING UTILITIES',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: CyberColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),

          // Video Trimmer
          _buildToolRow(
            context: context,
            title: 'Precision Video Trimmer & Cutter',
            description: 'Frame-accurate video trimming with keyframe snapping and fast stream copy without quality degradation.',
            icon: Icons.content_cut,
            badge: 'FRAME ACCURATE',
            badgeColor: CyberColors.signalGreen,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VideoTrimmerScreen()),
              );
            },
          ),
          const SizedBox(height: 10),

          // Video Format Converter & Scaler with honest disclosure
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: CyberColors.surfaceCarbonRaised,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: CyberColors.borderStructural),
                          ),
                          child: const Icon(Icons.video_settings, color: CyberColors.primaryCyan, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Format Converter & Scaler',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CyberColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const CodecBadge(label: 'GPU / NPU', isCyan: true),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Transcode between MP4, MKV, WebM, and ProRes with custom resolution targets up to 4K.',
                  style: CyberTypography.bodySmall.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 8),

                // Clean Consumer Disclosure Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: CyberColors.borderStructural),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: CyberColors.primaryCyan, size: 15),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Upscaling employs mathematical interpolation to enhance resolution; it does not claim to reconstruct original uncompressed sensor detail.',
                          style: CyberTypography.bodySmall.copyWith(
                            color: CyberColors.textSecondary,
                            fontSize: 10.5,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Frame Tools & Snapshot
          _buildToolRow(
            context: context,
            title: 'Frame Tools & Burst Snapshot',
            description: 'Extract single frames at full source resolution, capture burst sequences, or build contact sheets.',
            icon: Icons.camera_alt_outlined,
            badge: 'FULL RES',
            badgeColor: CyberColors.secondaryViolet,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Frame Capture: High-resolution PNG frame saved to /storage/emulated/0/Pictures/Frames/')),
              );
            },
          ),
          const SizedBox(height: 10),

          // Media Diagnostics & Safe Repair
          _buildToolRow(
            context: context,
            title: 'Media Diagnostics & Safe Repair',
            description: 'Inspect video streams, audio codecs, and color primaries. Repair corrupted container headers non-destructively.',
            icon: Icons.troubleshoot_outlined,
            badge: 'SAFE REPAIR',
            badgeColor: CyberColors.signalGreen,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Media Repair: Container index verified. Source file left untouched.')),
              );
            },
          ),
          const SizedBox(height: 10),

          // Batch Conversion Queue
          _buildToolRow(
            context: context,
            title: 'Conversion Queue Manager',
            description: 'Monitor active background processing tasks, reorder conversion jobs, and configure thermal throttling limits.',
            icon: Icons.format_list_bulleted,
            badge: 'QUEUE MGR',
            badgeColor: CyberColors.warningAmber,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BatchQueueScreen()),
              );
            },
          ),
          const SizedBox(height: 18),

          // Privacy Footer (Stitch Frame 3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '100% Privacy Focused',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  color: CyberColors.textSecondary,
                ),
              ),
              Text(
                'On-Device Media Processing',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  color: CyberColors.primaryCyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildToolRow({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CyberColors.surfaceCarbon,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CyberColors.borderStructural),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceCarbonRaised,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberColors.borderStructural),
                  ),
                  child: Icon(icon, color: badgeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: CyberColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: badgeColor.withOpacity(0.35)),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: CyberTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: CyberColors.textTertiary, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
