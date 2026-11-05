import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_button.dart';
import '../../../core/widgets/cyber_badge.dart';

/// Batch Processing & Conversion Queue Screen
/// SRS: TOOL-06 (Queue management, parallel transcoding, pause/resume, error handling)
class BatchQueueScreen extends StatefulWidget {
  @override
  _BatchQueueScreenState createState() => _BatchQueueScreenState();
}

class _BatchQueueScreenState extends State<BatchQueueScreen> {
  final List<Map<String, dynamic>> _jobs = [
    {
      'id': 'job-101',
      'title': 'Cyberpunk_Ep10_Remaster.mkv -> MP3 320k',
      'type': 'AUDIO EXTRACTION',
      'status': 'IN_PROGRESS',
      'progress': 0.68,
      'speed': '14.2x (340 FPS)',
      'eta': '00:18',
    },
    {
      'id': 'job-102',
      'title': 'Interstellar_Docking_Scene_4K.mp4 -> 1080p HEVC',
      'type': 'HARDWARE TRANSCODE',
      'status': 'QUEUED',
      'progress': 0.0,
      'speed': 'Waiting in slot 2',
      'eta': '02:40',
    },
    {
      'id': 'job-103',
      'title': 'Blade_Runner_2049_Sea_Wall.mkv -> MP4 Remux',
      'type': 'ZERO-RECODE MUX',
      'status': 'COMPLETED',
      'progress': 1.0,
      'speed': 'Completed in 1.8s',
      'eta': 'Done',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: AppBar(
        backgroundColor: CyberColors.bgPureBlack,
        title: Text('Batch Conversion Queue', style: CyberTypography.headlineMedium),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: CyberColors.textSecondary),
            tooltip: 'Clear Finished',
            onPressed: () {
              setState(() {
                _jobs.removeWhere((j) => j['status'] == 'COMPLETED');
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Hardware Telemetry Strip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: CyberShapes.roundedMicro,
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('ACTIVE JOBS', style: CyberTypography.telemetryMicro),
                    const SizedBox(height: 4),
                    Text('1 Running', style: CyberTypography.telemetryBadge),
                  ],
                ),
                Container(width: 1, height: 30, color: CyberColors.borderStructural),
                Column(
                  children: [
                    Text('HARDWARE ACCEL', style: CyberTypography.telemetryMicro),
                    const SizedBox(height: 4),
                    const CodecBadge(label: 'VULKAN / NPU', isViolet: true),
                  ],
                ),
                Container(width: 1, height: 30, color: CyberColors.borderStructural),
                Column(
                  children: [
                    Text('THROUGHPUT', style: CyberTypography.telemetryMicro),
                    const SizedBox(height: 4),
                    Text('340 FPS', style: CyberTypography.telemetryBadge.copyWith(color: CyberColors.signalGreen)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('QUEUED MEDIA TASKS', style: CyberTypography.telemetryMicro),
          const SizedBox(height: 8),

          ..._jobs.map((job) {
            final isRunning = job['status'] == 'IN_PROGRESS';
            final isDone = job['status'] == 'COMPLETED';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isRunning ? CyberColors.surfaceCarbonRaised : CyberColors.surfaceCarbon,
                borderRadius: CyberShapes.roundedMicro,
                border: Border.all(
                  color: isRunning ? CyberColors.primaryCyan : CyberColors.borderStructural,
                ),
                boxShadow: isRunning ? const [CyberColors.cyanGlow] : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDone ? const Color(0x3322C55E) : CyberColors.surfaceCarbonRaised,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: isDone ? CyberColors.signalGreen : CyberColors.borderStructural,
                          ),
                        ),
                        child: Text(
                          job['type'],
                          style: CyberTypography.telemetryMicro.copyWith(
                            color: isDone ? CyberColors.signalGreen : CyberColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        job['status'],
                        style: CyberTypography.telemetryBadge.copyWith(
                          color: isRunning
                              ? CyberColors.primaryCyan
                              : (isDone ? CyberColors.signalGreen : CyberColors.textTertiary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['title'],
                    style: CyberTypography.bodyMedium.copyWith(
                      color: CyberColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar
                  LinearProgressIndicator(
                    value: job['progress'],
                    backgroundColor: CyberColors.surfaceElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? CyberColors.signalGreen : CyberColors.primaryCyan,
                    ),
                    minHeight: 3,
                  ),
                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(job['speed'], style: CyberTypography.telemetryMicro),
                      Text('ETA: ${job['eta']}', style: CyberTypography.telemetryMicro),
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
