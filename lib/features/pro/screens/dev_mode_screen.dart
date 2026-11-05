import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_button.dart';
import '../../../core/widgets/cyber_badge.dart';

/// Experimental Development Mode Screen
/// SRS: DEV-01 to DEV-11 (Privileged access, time-limited token, mpv.conf injection, hardware overrides)
class DevModeScreen extends StatefulWidget {
  @override
  _DevModeScreenState createState() => _DevModeScreenState();
}

class _DevModeScreenState extends State<DevModeScreen> {
  bool _isActivated = true;
  Duration _remainingTime = const Duration(hours: 47, minutes: 22);
  bool _forceGpuOverdrive = false;
  bool _bypassThermalThrottle = false;
  final TextEditingController _mpvConfController = TextEditingController(
    text: '# BinaHub Experimental mpv config\nvo=gpu-next\ngpu-api=vulkan\nhwdec=mediacodec\nglsl-shaders="~~/shaders/ravu-r4.hook;~~/shaders/cas.glsl"\nscale=ewa_lanczos\ndscale=mitchell\n',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: AppBar(
        backgroundColor: CyberColors.bgPureBlack,
        title: Row(
          children: [
            const Icon(Icons.biotech, color: CyberColors.secondaryViolet, size: 22),
            const SizedBox(width: 8),
            Text('Development Mode', style: CyberTypography.headlineMedium),
          ],
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Expiry & Access Status Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbonRaised,
              borderRadius: CyberShapes.roundedMicro,
              border: Border.all(color: CyberColors.secondaryViolet),
              boxShadow: const [CyberColors.violetGlow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('EXPERIMENTAL ACCESS ACTIVE', style: CyberTypography.telemetryVioletBadge),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: CyberColors.surfaceCarbon,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: CyberColors.borderStructural),
                      ),
                      child: Text(
                        'EXPIRY: 47h 22m',
                        style: CyberTypography.telemetryBadge.copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Device bound cryptographically to Android Keystore EC P-256 keypair. Overrides will automatically revert to default safe state upon token expiration or remote revocation.',
                  style: CyberTypography.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('EXPERIMENTAL HARDWARE OVERRIDES', style: CyberTypography.telemetryMicro),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: CyberShapes.roundedMicro,
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  dense: true,
                  title: Text('Force GPU / NPU Overdrive Clock', style: CyberTypography.bodyMedium),
                  subtitle: Text('Overrides Adreno power governor for raw zero-latency rendering', style: CyberTypography.bodySmall),
                  value: _forceGpuOverdrive,
                  onChanged: (val) => setState(() => _forceGpuOverdrive = val),
                ),
                const Divider(height: 1, color: CyberColors.borderStructural),
                SwitchListTile(
                  dense: true,
                  title: Text('Bypass Soft Thermal Throttling (45°C)', style: CyberTypography.bodyMedium),
                  subtitle: Text('Allows compute up to hard hardware safety shutdown (65°C)', style: CyberTypography.bodySmall),
                  value: _bypassThermalThrottle,
                  onChanged: (val) => setState(() => _bypassThermalThrottle = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Custom mpv.conf & GLSL Shader Injection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DIRECT MPV.CONF & GLSL SHADER INJECTION', style: CyberTypography.telemetryMicro),
              CyberGhostButton(
                label: 'RESET CONFIG',
                height: 28,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: CyberShapes.roundedMicro,
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: TextField(
              controller: _mpvConfController,
              maxLines: 7,
              style: CyberTypography.telemetryMicro.copyWith(
                fontSize: 11,
                color: CyberColors.textPrimary,
                fontFamily: 'monospace',
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Apply and Revoke Triggers
          Row(
            children: [
              Expanded(
                child: CyberGhostButton(
                  label: 'REVOKE ACCESS',
                  icon: Icons.lock_clock,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Development Mode deactivated and reset to stock defaults.')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CyberPrimaryButton(
                  label: 'APPLY OVERRIDES',
                  icon: Icons.check,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('mpv.conf and hardware parameters injected into C++ core.'),
                        backgroundColor: CyberColors.surfaceCarbonRaised,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
