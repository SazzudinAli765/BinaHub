import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_app_bar.dart';
import '../../../core/widgets/cyber_button.dart';
import '../../../core/widgets/cyber_badge.dart';
import '../../pro/screens/pro_scaler_studio_screen.dart';
import '../../pro/screens/dev_mode_screen.dart';
import '../../vault/screens/vault_auth_screen.dart';
import '../../cloud/screens/drive_browser_screen.dart';
import 'directory_manager_screen.dart';

/// Settings & System Configuration Screen
/// Restrained Cyber Precision dark OLED interface aligned with Stitch design.
/// Purged of internal SRS identifiers in compliance with Condition 4.
class SettingsScreen extends StatefulWidget {
  final VoidCallback? onOpenAdmin;
  final VoidCallback? onOpenEarn;

  const SettingsScreen({this.onOpenAdmin, this.onOpenEarn});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _defaultDecoder = 'HW+';
  bool _scanHiddenFiles = false;
  bool _hardwareUpmix = true;
  bool _appLockEnabled = true;

  // Backup Quota State
  final double _usedStorageGb = 2.1;
  final double _totalQuotaGb = 5.0;
  final double _offloadThresholdGb = 3.5; // 70%

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: CyberTopAppBar(
        title: 'Settings',
        customActions: [
          if (widget.onOpenEarn != null)
            IconButton(
              icon: const Icon(Icons.monetization_on, color: CyberColors.warningAmber, size: 20),
              tooltip: 'Earn (Coming Soon)',
              onPressed: widget.onOpenEarn,
            ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined, color: CyberColors.primaryCyan),
            tooltip: 'Administrator Console',
            onPressed: widget.onOpenAdmin,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // 1. Playback & Decoder Default Engine
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'PLAYBACK & DECODER ENGINE',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: CyberColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
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
                    const Text(
                      'Default Decoder Mode',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CyberColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        DecoderBadge(
                          mode: 'HW',
                          isSelected: _defaultDecoder == 'HW',
                          onTap: () => setState(() => _defaultDecoder = 'HW'),
                        ),
                        const SizedBox(width: 6),
                        DecoderBadge(
                          mode: 'HW+',
                          isSelected: _defaultDecoder == 'HW+',
                          onTap: () => setState(() => _defaultDecoder = 'HW+'),
                        ),
                        const SizedBox(width: 6),
                        DecoderBadge(
                          mode: 'SW',
                          isSelected: _defaultDecoder == 'SW',
                          onTap: () => setState(() => _defaultDecoder = 'SW'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'HW+ leverages MediaCodec hardware decoders with Vulkan shader post-processing. Falls back seamlessly to SW on unsupported stream formats.',
                  style: CyberTypography.bodySmall.copyWith(fontSize: 11),
                ),
                const Divider(height: 24, color: CyberColors.borderStructural),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: CyberColors.primaryCyan,
                  title: const Text(
                    'Neural Audio Upmixing',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  subtitle: Text(
                    'Expands 2.0 stereo tracks into spatial binaural soundstages on headphones',
                    style: CyberTypography.bodySmall.copyWith(fontSize: 11),
                  ),
                  value: _hardwareUpmix,
                  onChanged: (val) => setState(() => _hardwareUpmix = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 2. Media Scanning & Directory Indexer
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'MEDIA STORAGE & INDEXING',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: CyberColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Column(
              children: [
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.folder_special_outlined, color: CyberColors.primaryCyan, size: 22),
                  title: const Text('Folder Inclusion & Exclusion Manager', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                  subtitle: const Text('Manage specific directories scanned into the library', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: CyberColors.textSecondary)),
                  trailing: const Icon(Icons.chevron_right, color: CyberColors.textSecondary, size: 18),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DirectoryManagerScreen()));
                  },
                ),
                const Divider(height: 1, color: CyberColors.borderStructural),
                SwitchListTile(
                  dense: true,
                  activeColor: CyberColors.primaryCyan,
                  secondary: const Icon(Icons.visibility_off_outlined, color: CyberColors.textSecondary, size: 22),
                  title: const Text('Scan Hidden Directories (.nomedia)', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                  subtitle: const Text('Traverse dot-prefixed folders and ignore .nomedia exclusion flags', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: CyberColors.textSecondary)),
                  value: _scanHiddenFiles,
                  onChanged: (val) => setState(() => _scanHiddenFiles = val),
                ),
                const Divider(height: 1, color: CyberColors.borderStructural),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.cloud_queue, color: CyberColors.secondaryViolet, size: 22),
                  title: const Text('Google Drive Integration', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                  subtitle: const Text('Connected Google accounts, offline cache, and sync settings', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: CyberColors.textSecondary)),
                  trailing: const Icon(Icons.chevron_right, color: CyberColors.textSecondary, size: 18),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DriveBrowserScreen()));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3. Encrypted Backup & Quota Hub
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'ENCRYPTED BACKUP & REPLICATION',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: CyberColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
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
                    const Text(
                      'Primary Backup Storage',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: CyberColors.textPrimary),
                    ),
                    Text(
                      '${_usedStorageGb.toStringAsFixed(1)} GB / ${_totalQuotaGb.toStringAsFixed(1)} GB',
                      style: CyberTypography.telemetryBadge,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Multi-Segment Quota Bar with 70% threshold marker
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final usedFraction = (_usedStorageGb / _totalQuotaGb).clamp(0.0, 1.0);
                    final thresholdFraction = (_offloadThresholdGb / _totalQuotaGb).clamp(0.0, 1.0);

                    return SizedBox(
                      height: 14,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 6,
                            width: width,
                            decoration: BoxDecoration(
                              color: CyberColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Container(
                            height: 6,
                            width: width * usedFraction,
                            decoration: BoxDecoration(
                              color: CyberColors.primaryCyan,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          // 70% Threshold Pin
                          Positioned(
                            left: width * thresholdFraction - 1,
                            child: Container(
                              width: 2,
                              height: 12,
                              color: CyberColors.warningAmber,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Used: 42%', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: CyberColors.textSecondary)),
                    Text(
                      '70% Cloud Offload Trigger at 3.5 GB',
                      style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: CyberColors.warningAmber.withOpacity(0.9)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Backups are compressed and encrypted with unique per-backup AES-256-GCM keys. At 70% capacity, historical restore points automatically replicate to connected cloud accounts.',
                  style: CyberTypography.bodySmall.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 14),

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
                          icon: const Icon(Icons.file_download_outlined, size: 16),
                          label: const Text('Import', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600)),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CyberColors.primaryCyan,
                            side: BorderSide(color: CyberColors.primaryCyan.withOpacity(0.4)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.file_upload_outlined, size: 16),
                          label: const Text('Export', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600)),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CyberColors.primaryCyan,
                            foregroundColor: const Color(0xFF002022),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.backup, size: 16),
                          label: const Text('Backup Now', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Creating encrypted full restore point...'),
                                backgroundColor: CyberColors.surfaceCarbonRaised,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 4. Advanced Gating: Pro & Dev Mode & Vault
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'ADVANCED WORKSPACES',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: CyberColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.tune, color: CyberColors.secondaryViolet, size: 22),
                  title: const Text('Pro Enhancement Studio', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                  subtitle: const Text('Neural super-resolution, contrast adaptive sharpening, and deblur controls', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: CyberColors.textSecondary)),
                  trailing: const Icon(Icons.chevron_right, color: CyberColors.textSecondary, size: 18),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProScalerStudioScreen()));
                  },
                ),
                const Divider(height: 1, color: CyberColors.borderStructural),
                ListTile(
                  leading: const Icon(Icons.biotech, color: CyberColors.secondaryViolet, size: 22),
                  title: const Text('Development Mode (Experimental)', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                  subtitle: const Text('Device authorization token, mpv.conf injection, and neural engine overdrive', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: CyberColors.textSecondary)),
                  trailing: const Icon(Icons.chevron_right, color: CyberColors.textSecondary, size: 18),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DevModeScreen()));
                  },
                ),
                const Divider(height: 1, color: CyberColors.borderStructural),
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: CyberColors.secondaryViolet, size: 22),
                  title: const Text('Secret Vault Access', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                  subtitle: const Text('Hardware-encrypted media container with screen protection', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: CyberColors.textSecondary)),
                  trailing: const Icon(Icons.chevron_right, color: CyberColors.textSecondary, size: 18),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => VaultAuthScreen()));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
