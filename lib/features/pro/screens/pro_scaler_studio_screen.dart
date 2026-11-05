import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_button.dart';
import '../../../core/widgets/cyber_badge.dart';
import '../../../core/widgets/telemetry_slider.dart';

/// Pro Scaler Studio Screen
/// Replicates the Stitch "bina_hub_pro_scaler_studio" design.
class ProScalerStudioScreen extends StatefulWidget {
  @override
  _ProScalerStudioScreenState createState() => _ProScalerStudioScreenState();
}

class _ProScalerStudioScreenState extends State<ProScalerStudioScreen> {
  // Real-time enhancement sliders
  double _superResolution = 75.0; // 0 - 100%
  double _casSharpening = 85.0; // 0 - 100%
  double _deblurRadius = 1.8; // 0.0 - 5.0
  double _denoiseStrength = 40.0; // 0 - 100%

  // Split-screen comparison divider (0.0 to 1.0)
  double _splitDivider = 0.5;

  // Active Scalers (Tier limits: Max 3 for High-End Snapdragon 8s Gen 3)
  final List<Map<String, dynamic>> _scalerSlots = [
    {'name': 'Neural_CAS_SuperRes_v4', 'active': true, 'tier': 'Tier 1'},
    {'name': 'Inverse_Deblur_Kernel_SNPE', 'active': true, 'tier': 'Tier 1'},
    {'name': 'Adaptive_Denoise_Vulkan', 'active': false, 'tier': 'Tier 2'},
  ];

  // Hardware Telemetry
  double _socTemp = 42.0; // °C
  double _fps = 119.8;
  int _battery = 78;

  void _verifyAndImportScaler() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.security, color: CyberColors.primaryCyan, size: 20),
              const SizedBox(width: 8),
              Text('Verify & Import Scaler', style: CyberTypography.headlineSmall),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Custom scaler files must be signed and validated by the internal authenticity parser.',
                style: CyberTypography.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Verification Token / Key',
                  hintText: 'Enter authentication passcode (e.g. Zuniya)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            CyberGhostButton(label: 'CANCEL', height: 36, onPressed: () => Navigator.pop(context)),
            CyberPrimaryButton(
              label: 'VALIDATE',
              height: 36,
              onPressed: () {
                Navigator.pop(context);
                if (controller.text.trim().toLowerCase() == 'zuniya') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Signature Verified ("Zuniya"). Custom Scaler imported successfully!'),
                      backgroundColor: CyberColors.surfaceCarbonRaised,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification Failed: Trailing signature mismatch. Rejected.'),
                      backgroundColor: CyberColors.thermalRed,
                    ),
                  );
                }
              },
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
        title: Row(
          children: [
            Text('Pro Scaler Studio', style: CyberTypography.headlineMedium),
            const SizedBox(width: 8),
            const HardwareTelemetryChip(text: 'SD 8s Gen 3 • 8GB'),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: CyberColors.primaryCyan),
            tooltip: 'Verify & Import Scaler',
            onPressed: _verifyAndImportScaler,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Interactive Split-Screen Before/After Comparison Preview
          Text('REAL-TIME MULTI-STAGE COMPARISON PREVIEW', style: CyberTypography.telemetryMicro),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Stack(
                  children: [
                    // Base Unprocessed (Left side background)
                    Container(
                      width: width,
                      color: const Color(0xFF0A0F17),
                      child: const Center(
                        child: Text(
                          'ORIGINAL 360p / BILINEAR',
                          style: TextStyle(color: CyberColors.textTertiary, fontSize: 11),
                        ),
                      ),
                    ),

                    // Processed Enhanced (Right side reveal via clip)
                    ClipRect(
                      clipper: _SplitClipper(_splitDivider),
                      child: Container(
                        width: width,
                        color: const Color(0xFF131D2A),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_awesome, color: CyberColors.primaryCyan, size: 36),
                              const SizedBox(height: 6),
                              Text(
                                'NPU TENSOR + CAS SHARPEN (1080p)',
                                style: CyberTypography.telemetryBadge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Interactive Split Drag Handle Line
                    Positioned(
                      left: (width * _splitDivider - 2).clamp(0.0, width - 4),
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _splitDivider = (details.localPosition.dx / width).clamp(0.05, 0.95);
                          });
                        },
                        child: Container(
                          width: 4,
                          color: CyberColors.primaryCyan,
                          child: Center(
                            child: Container(
                              width: 16,
                              height: 32,
                              decoration: BoxDecoration(
                                color: CyberColors.primaryCyan,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [CyberColors.cyanGlow],
                              ),
                              child: const Icon(Icons.compare_arrows, size: 14, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Top Indicators
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: Colors.black.withOpacity(0.7),
                        child: Text('BEFORE (RAW)', style: CyberTypography.telemetryMicro),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: Colors.black.withOpacity(0.7),
                        child: Text('AFTER (ENHANCED)', style: CyberTypography.telemetryBadge),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 2. Hardware Thermal & Compute Telemetry Card
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
                    Text('SoC THERMAL', style: CyberTypography.telemetryMicro),
                    const SizedBox(height: 4),
                    Text(
                      '${_socTemp.toStringAsFixed(1)}°C',
                      style: CyberTypography.telemetryBadge.copyWith(
                        color: _socTemp > 45 ? CyberColors.warningAmber : CyberColors.signalGreen,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 30, color: CyberColors.borderStructural),
                Column(
                  children: [
                    Text('DISPLAY RENDER', style: CyberTypography.telemetryMicro),
                    const SizedBox(height: 4),
                    Text(
                      '${_fps.toStringAsFixed(1)} FPS',
                      style: CyberTypography.telemetryBadge.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                Container(width: 1, height: 30, color: CyberColors.borderStructural),
                Column(
                  children: [
                    Text('BATTERY', style: CyberTypography.telemetryMicro),
                    const SizedBox(height: 4),
                    Text(
                      '$_battery%',
                      style: CyberTypography.telemetryBadge.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Multi-Stage Pipeline Tuning Sliders
          Text('PIPELINE STAGE PARAMETERS', style: CyberTypography.telemetryMicro),
          const SizedBox(height: 10),

          // Super Resolution Slider
          TelemetrySlider(
            label: 'NPU Super-Resolution Tensor Weight',
            value: _superResolution,
            min: 0,
            max: 100,
            formatValue: (v) => '${v.toInt()}%',
            onChanged: (val) => setState(() => _superResolution = val),
          ),
          const SizedBox(height: 12),

          // CAS Sharpening Slider
          TelemetrySlider(
            label: 'Contrast Adaptive Sharpening (CAS)',
            value: _casSharpening,
            min: 0,
            max: 100,
            formatValue: (v) => '${v.toInt()}%',
            onChanged: (val) => setState(() => _casSharpening = val),
          ),
          const SizedBox(height: 12),

          // Inverse Deblur Kernel Radius Slider
          TelemetrySlider(
            label: 'Inverse Deblur Kernel Radius',
            value: _deblurRadius,
            min: 0.0,
            max: 5.0,
            activeColor: CyberColors.secondaryViolet,
            formatValue: (v) => '${v.toStringAsFixed(2)} px',
            onChanged: (val) => setState(() => _deblurRadius = val),
          ),
          const SizedBox(height: 12),

          // Compression Artifact Reduction / Denoise
          TelemetrySlider(
            label: 'Compression Artifact & Noise Reduction',
            value: _denoiseStrength,
            min: 0,
            max: 100,
            formatValue: (v) => '${v.toInt()}%',
            onChanged: (val) => setState(() => _denoiseStrength = val),
          ),
          const SizedBox(height: 24),

          // 4. Active Scalers Slot Manager
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ACTIVE SCALER SLOTS (MAX 3)', style: CyberTypography.telemetryMicro),
              Text('Constraint: enabledoneonly;', style: CyberTypography.telemetryMicro.copyWith(color: CyberColors.secondaryViolet)),
            ],
          ),
          const SizedBox(height: 8),

          ...List.generate(_scalerSlots.length, (idx) {
            final slot = _scalerSlots[idx];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: slot['active'] ? CyberColors.surfaceElevated : CyberColors.surfaceCarbon,
                borderRadius: CyberShapes.roundedMicro,
                border: Border.all(
                  color: slot['active'] ? CyberColors.primaryCyan : CyberColors.borderStructural,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    slot['active'] ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                    color: slot['active'] ? CyberColors.primaryCyan : CyberColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(slot['name'], style: CyberTypography.bodyMedium),
                  ),
                  CodecBadge(label: slot['tier'], isViolet: slot['active']),
                  const SizedBox(width: 8),
                  Switch(
                    value: slot['active'],
                    onChanged: (val) {
                      setState(() => slot['active'] = val);
                    },
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Action Buttons: Save Custom Profile
          CyberPrimaryButton(
            label: 'SAVE CURRENT PROFILE',
            icon: Icons.save,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Custom Video Profile saved to SQLite storage.'),
                  backgroundColor: CyberColors.surfaceCarbonRaised,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SplitClipper extends CustomClipper<Rect> {
  final double fraction;

  _SplitClipper(this.fraction);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(size.width * fraction, 0, size.width, size.height);
  }

  @override
  bool shouldReclip(_SplitClipper oldClipper) => oldClipper.fraction != fraction;
}
