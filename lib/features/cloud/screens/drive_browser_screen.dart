import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_button.dart';
import '../../../core/widgets/cyber_badge.dart';
import 'download_manager_screen.dart';

/// Google Drive Cloud Media Browser
/// SRS: DRV-01 to DRV-10 (OAuth, Directory navigation, Direct range streaming, Offline download)
class DriveBrowserScreen extends StatefulWidget {
  @override
  _DriveBrowserScreenState createState() => _DriveBrowserScreenState();
}

class _DriveBrowserScreenState extends State<DriveBrowserScreen> {
  bool _isConnected = true;
  String _userEmail = 'admin.sazzudin@gmail.com';
  String _currentPath = 'My Drive / MediaVault / 4K Movies';

  final List<Map<String, dynamic>> _cloudFiles = [
    {
      'name': 'Dune_Part_Two_IMAX_DirectStream.mkv',
      'size': '8.4 GB',
      'type': 'video',
      'format': '4K HDR',
      'duration': '02:46:12',
    },
    {
      'name': 'Hans_Zimmer_Live_Prague_Lossless.flac',
      'size': '920 MB',
      'type': 'audio',
      'format': 'FLAC 96k',
      'duration': '01:38:40',
    },
    {
      'name': 'Documentary_The_Deep_Ocean.mp4',
      'size': '2.1 GB',
      'type': 'video',
      'format': '1080p',
      'duration': '00:52:10',
    },
  ];

  void _streamCloudFile(Map<String, dynamic> file) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Direct HTTP Range Streaming: ${file['name']} (Zero download required).'),
        backgroundColor: CyberColors.surfaceCarbonRaised,
      ),
    );
  }

  void _downloadOffline(Map<String, dynamic> file) {
    DriveService.instance.startDownload(
      driveId: 'drv_${file['name'].hashCode.abs()}',
      fileName: file['name'],
      totalBytes: 1024 * 1024 * 450, // 450 MB original quality
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting Original-Quality Download: ${file['name']} (30-Day Offline Policy).'),
        backgroundColor: CyberColors.surfaceCarbonRaised,
        action: SnackBarAction(
          label: 'VIEW QUEUE',
          textColor: CyberColors.primaryCyan,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadManagerScreen()));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: AppBar(
        backgroundColor: CyberColors.bgPureBlack,
        title: Text('Google Drive Media', style: CyberTypography.headlineMedium),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined, color: CyberColors.primaryCyan),
            tooltip: 'Download Manager',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DownloadManagerScreen()));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Google Account Connection Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: CyberShapes.roundedMicro,
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_done, color: CyberColors.primaryCyan, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Google Drive Connected', style: CyberTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      Text(_userEmail, style: CyberTypography.telemetryMicro),
                    ],
                  ),
                ),
                CyberGhostButton(
                  label: 'DISCONNECT',
                  height: 30,
                  onPressed: () {
                    setState(() => _isConnected = !_isConnected);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Current Path Breadcrumb
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbonRaised,
              borderRadius: CyberShapes.roundedMicro,
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_open, color: CyberColors.secondaryViolet, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentPath,
                    style: CyberTypography.telemetryMicro.copyWith(color: CyberColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('CLOUD MEDIA FILES (${_cloudFiles.length})', style: CyberTypography.telemetryMicro),
          const SizedBox(height: 8),

          ..._cloudFiles.map((file) {
            final isVideo = file['type'] == 'video';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CyberColors.surfaceCarbon,
                borderRadius: CyberShapes.roundedMicro,
                border: Border.all(color: CyberColors.borderStructural),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isVideo ? Icons.movie_outlined : Icons.graphic_eq,
                        color: isVideo ? CyberColors.primaryCyan : CyberColors.secondaryViolet,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          file['name'],
                          style: CyberTypography.bodyMedium.copyWith(
                            color: CyberColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CodecBadge(label: file['format'], isViolet: !isVideo),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Size: ${file['size']} • Duration: ${file['duration']}',
                    style: CyberTypography.telemetryMicro,
                  ),
                  const SizedBox(height: 12),

                  // Actions: Stream vs Download
                  Row(
                    children: [
                      Expanded(
                        child: CyberPrimaryButton(
                          label: 'DIRECT STREAM',
                          icon: Icons.play_arrow,
                          height: 34,
                          onPressed: () => _streamCloudFile(file),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CyberGhostButton(
                          label: 'DOWNLOAD',
                          icon: Icons.download,
                          height: 34,
                          onPressed: () => _downloadOffline(file),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
