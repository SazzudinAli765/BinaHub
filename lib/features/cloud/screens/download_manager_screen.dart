import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_button.dart';
import '../../../core/widgets/cyber_badge.dart';
import '../../../core/services/drive_service.dart';
import '../../../core/services/offline_expiry_manager.dart';

/// Download Manager Screen
/// SRS: DLD-01 to DLD-08, EXP-01 to EXP-12 (Queue, Wi-Fi only, Storage select, Expiry timestamps)
class DownloadManagerScreen extends StatefulWidget {
  @override
  _DownloadManagerScreenState createState() => _DownloadManagerScreenState();
}

class _DownloadManagerScreenState extends State<DownloadManagerScreen> {
  bool _wifiOnly = true;
  String _storageDestination = 'Internal Storage (/emulated/0/Download/)';

  @override
  void initState() {
    super.initState();
    DriveService.instance.addListener(_onServiceUpdate);
    OfflineExpiryManager.instance.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    DriveService.instance.removeListener(_onServiceUpdate);
    OfflineExpiryManager.instance.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  final List<Map<String, dynamic>> _downloads = [
    {
      'id': 'dld-1',
      'title': 'Dune_Part_Two_IMAX_DirectStream.mkv',
      'size': '8.4 GB',
      'downloaded': '5.2 GB',
      'progress': 0.62,
      'speed': '18.4 MB/s',
      'status': 'DOWNLOADING',
      'expiry': 'Expires in 29 days (2026-12-02)',
    },
    {
      'id': 'dld-2',
      'title': 'Hans_Zimmer_Live_Prague_Lossless.flac',
      'size': '920 MB',
      'downloaded': '920 MB',
      'progress': 1.0,
      'speed': 'Completed',
      'status': 'COMPLETED',
      'expiry': 'Expires in 14 days (2026-11-17)',
    },
  ];

  Future<void> _handleExtensionRequest(String title) async {
    Navigator.pop(context);
    final driveId = 'drv_${title.hashCode.abs()}';

    final success = await OfflineExpiryManager.instance.requestExtension(
      driveId: driveId,
      requestedDays: 30,
      reason: 'Offline research playback in isolated air-gapped lab',
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offline extension requested: Pending Super Admin digital signature (EXP-06).'),
            backgroundColor: CyberColors.surfaceCarbonRaised,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request Denied: A pending extension request is already awaiting review (EXP-06).'),
            backgroundColor: CyberColors.warningAmber,
          ),
        );
      }
    }
  }

  void _showExpiryInfo(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.timer_outlined, color: CyberColors.warningAmber, size: 20),
              const SizedBox(width: 8),
              Text('Offline License Expiry', style: CyberTypography.headlineSmall),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Downloaded media files carry signed offline license timestamps per Google Drive security policies (EXP-01..12).',
                style: CyberTypography.bodySmall,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CyberColors.surfaceCarbon,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: CyberColors.borderStructural),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TARGET: ${item['title']}', style: CyberTypography.telemetryMicro),
                    const SizedBox(height: 4),
                    Text('STATUS: ${item['expiry']}', style: CyberTypography.telemetryBadge.copyWith(color: CyberColors.warningAmber)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            CyberGhostButton(label: 'DISMISS', height: 36, onPressed: () => Navigator.pop(context)),
            CyberPrimaryButton(
              label: 'REQUEST 30-DAY EXTENSION',
              height: 36,
              onPressed: () => _handleExtensionRequest(item['title'] as String),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: AppBar(
        backgroundColor: CyberColors.bgPureBlack,
        title: Text('Download Manager', style: CyberTypography.headlineMedium),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Network & Storage Preferences Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: CyberShapes.roundedMicro,
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('Wi-Fi Only Downloads', style: CyberTypography.bodyMedium),
                  subtitle: Text('Prevents high cellular data consumption on 4K files', style: CyberTypography.bodySmall),
                  value: _wifiOnly,
                  onChanged: (val) => setState(() => _wifiOnly = val),
                ),
                const Divider(height: 1, color: CyberColors.borderStructural),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('Storage Destination', style: CyberTypography.bodyMedium),
                  subtitle: Text(_storageDestination, style: CyberTypography.bodySmall),
                  trailing: const Icon(Icons.chevron_right, color: CyberColors.textSecondary),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text('DOWNLOAD QUEUE (${_downloads.length})', style: CyberTypography.telemetryMicro),
          const SizedBox(height: 8),

          ..._downloads.map((item) {
            final isDownloading = item['status'] == 'DOWNLOADING';
            final isDone = item['status'] == 'COMPLETED';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CyberColors.surfaceCarbon,
                borderRadius: CyberShapes.roundedMicro,
                border: Border.all(
                  color: isDownloading ? CyberColors.primaryCyan : CyberColors.borderStructural,
                ),
                boxShadow: isDownloading ? const [CyberColors.cyanGlow] : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['title'],
                          style: CyberTypography.bodyMedium.copyWith(
                            color: CyberColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        item['status'],
                        style: CyberTypography.telemetryBadge.copyWith(
                          color: isDownloading
                              ? CyberColors.primaryCyan
                              : (isDone ? CyberColors.signalGreen : CyberColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item['downloaded']} of ${item['size']} • ${item['speed']}',
                    style: CyberTypography.telemetryMicro,
                  ),
                  const SizedBox(height: 8),

                  LinearProgressIndicator(
                    value: item['progress'],
                    backgroundColor: CyberColors.surfaceElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? CyberColors.signalGreen : CyberColors.primaryCyan,
                    ),
                    minHeight: 3,
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showExpiryInfo(item),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: CyberColors.warningAmber),
                            const SizedBox(width: 4),
                            Text(
                              item['expiry'],
                              style: CyberTypography.telemetryMicro.copyWith(color: CyberColors.warningAmber),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (isDownloading)
                        IconButton(
                          icon: const Icon(Icons.pause_circle_outline, color: CyberColors.primaryCyan, size: 22),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: CyberColors.thermalRed, size: 20),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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
