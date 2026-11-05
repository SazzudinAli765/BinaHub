import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_button.dart';
import '../../../core/widgets/cyber_badge.dart';
import 'audit_log_screen.dart';
import 'backup_hub_screen.dart';
import '../widgets/lockdown_modal.dart';

/// Super Admin Governance & Security Dashboard
/// SRS: ADM-05, ROLE-01 to ROLE-08, SEC-01 to SEC-08
class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Inactivity timeout: 30 minutes
  int _secondsRemaining = 1800;
  Timer? _inactivityTimer;

  final List<Map<String, dynamic>> _activeDevices = [
    {
      'name': 'Samsung Galaxy S24 Ultra (This Device)',
      'fingerprint': 'SHA256:8f9a...3c21',
      'ip': '192.168.1.144',
      'lastActive': 'Active Now',
      'isCurrent': true,
    },
    {
      'name': 'Google Pixel 8 Pro (Workstation Testbed)',
      'fingerprint': 'SHA256:1a4e...7d99',
      'ip': '10.0.0.82',
      'lastActive': '12 mins ago',
      'isCurrent': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        Navigator.pop(context); // 30-min auto logout
      }
    });
  }

  String get _formattedTimeout {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _openLockdownModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LockdownModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: AppBar(
        backgroundColor: CyberColors.bgPureBlack,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Super Admin Governance', style: CyberTypography.headlineMedium.copyWith(fontSize: 16)),
            Text('PROTECTED OWNER • LEVEL 3 CLEARANCE', style: CyberTypography.telemetryBadge.copyWith(fontSize: 9)),
          ],
        ),
        elevation: 0,
        actions: [
          // 30-min Inactivity Timer Badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbonRaised,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: CyberColors.warningAmber),
                const SizedBox(width: 4),
                Text(_formattedTimeout, style: CyberTypography.telemetryBadge.copyWith(color: CyberColors.warningAmber)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: CyberColors.textSecondary),
            tooltip: 'Logout Admin',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. High-Level Governance Metric Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'ACTIVE SESSIONS',
                  value: '${_activeDevices.length}/2 MAX',
                  badge: 'DEVICE BOUND',
                  color: CyberColors.primaryCyan,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  title: 'SUPER ADMINS',
                  value: '2/3 SLOTS',
                  badge: 'OWNER PROTECTED',
                  color: CyberColors.secondaryViolet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'BACKUP QUOTA',
                  value: '2.1 / 5.0 GB',
                  badge: '70% OFFLOAD STANDBY',
                  color: CyberColors.signalGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  title: 'LOCKDOWN STATUS',
                  value: 'ARMED',
                  badge: 'STANDBY',
                  color: CyberColors.thermalRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Active Registered Devices (Max 2 Concurrent)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('AUTHORIZED CRYPTOGRAPHIC SESSIONS (MAX 2)', style: CyberTypography.telemetryMicro),
              Text('Strict Keystore EC P-256', style: CyberTypography.telemetryMicro.copyWith(color: CyberColors.primaryCyan)),
            ],
          ),
          const SizedBox(height: 8),

          ..._activeDevices.map((device) {
            final isCurrent = device['isCurrent'] == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrent ? CyberColors.surfaceElevated : CyberColors.surfaceCarbon,
                borderRadius: CyberShapes.roundedMicro,
                border: Border.all(
                  color: isCurrent ? CyberColors.primaryCyan : CyberColors.borderStructural,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCurrent ? Icons.phone_android : Icons.tablet_android,
                    color: isCurrent ? CyberColors.primaryCyan : CyberColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device['name'],
                          style: CyberTypography.bodyMedium.copyWith(
                            color: CyberColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${device['fingerprint']} • ${device['ip']} • ${device['lastActive']}',
                          style: CyberTypography.telemetryMicro,
                        ),
                      ],
                    ),
                  ),
                  if (!isCurrent)
                    CyberGhostButton(
                      label: 'REVOKE',
                      height: 30,
                      onPressed: () {
                        setState(() => _activeDevices.remove(device));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Device session cryptographically revoked and tokens purged.')),
                        );
                      },
                    ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 20),

          // 3. Quick Administrative Tool Navigation
          Text('GOVERNANCE & SECURITY OPERATIONS', style: CyberTypography.telemetryMicro),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: CyberShapes.roundedMicro,
              border: Border.all(color: CyberColors.borderStructural),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.history_edu, color: CyberColors.primaryCyan),
                  title: Text('Immutable Security Audit Log', style: CyberTypography.bodyMedium),
                  subtitle: Text('Tamper-evident append-only ledger with HMAC SHA-256', style: CyberTypography.bodySmall),
                  trailing: const Icon(Icons.chevron_right, color: CyberColors.textSecondary),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AuditLogScreen()));
                  },
                ),
                const Divider(height: 1, color: CyberColors.borderStructural),
                ListTile(
                  leading: const Icon(Icons.cloud_sync_outlined, color: CyberColors.signalGreen),
                  title: Text('Backup Hub & Cloud Replication Engine', style: CyberTypography.bodyMedium),
                  subtitle: Text('5 GB quota monitoring, 70% threshold offloading & sandbox drills', style: CyberTypography.bodySmall),
                  trailing: const Icon(Icons.chevron_right, color: CyberColors.textSecondary),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => BackupHubScreen()));
                  },
                ),
                const Divider(height: 1, color: CyberColors.borderStructural),
                ListTile(
                  leading: const Icon(Icons.vpn_key, color: CyberColors.secondaryViolet),
                  title: Text('Master Access Code & Recovery Secret', style: CyberTypography.bodyMedium),
                  subtitle: Text('Hardware Keystore backed • Rotation verified', style: CyberTypography.bodySmall),
                  trailing: Text('••••••••', style: CyberTypography.telemetryBadge),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recovery secrets are masked per security policy.')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Emergency Global Lockdown Red Switch
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbonRaised,
              borderRadius: CyberShapes.roundedMicro,
              border: Border.all(color: CyberColors.thermalRed, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: CyberColors.thermalRed, size: 22),
                    const SizedBox(width: 8),
                    Text('EMERGENCY GLOBAL LOCKDOWN GATE', style: CyberTypography.headlineSmall.copyWith(fontSize: 14, color: CyberColors.thermalRed)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Immediately invalidates all active sessions, revokes Development Mode tokens, locks Secret Vaults, and broadcasts critical security alerts to both Super Admins.',
                  style: CyberTypography.bodySmall,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberColors.thermalRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    icon: const Icon(Icons.lock, size: 18),
                    label: const Text('INITIATE SYSTEM LOCKDOWN', style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: _openLockdownModal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String badge,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CyberColors.surfaceCarbon,
        borderRadius: CyberShapes.roundedMicro,
        border: Border.all(color: CyberColors.borderStructural),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CyberTypography.telemetryMicro),
          const SizedBox(height: 4),
          Text(
            value,
            style: CyberTypography.headlineMedium.copyWith(color: color, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            badge,
            style: CyberTypography.telemetryMicro.copyWith(fontSize: 8, color: CyberColors.textMuted),
          ),
        ],
      ),
    );
  }
}
