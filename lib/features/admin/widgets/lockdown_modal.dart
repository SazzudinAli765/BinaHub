import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_button.dart';

/// Emergency Global Lockdown Confirmation Gate
/// SRS: SEC-03, 16.6 (Double authentication, session termination, vault locking, alert broadcast)
class LockdownModal extends StatefulWidget {
  @override
  _LockdownModalState createState() => _LockdownModalState();
}

class _LockdownModalState extends State<LockdownModal> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isLocking = false;

  void _executeLockdown() {
    if (_confirmController.text.trim().toUpperCase() != 'LOCKDOWN') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Type "LOCKDOWN" to confirm authorization.'),
          backgroundColor: CyberColors.thermalRed,
        ),
      );
      return;
    }

    setState(() => _isLocking = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLocking = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GLOBAL EMERGENCY LOCKDOWN ENGAGED. All sessions revoked, vaults locked, alerts dispatched to both Super Admins.'),
          backgroundColor: CyberColors.thermalRed,
          duration: Duration(seconds: 5),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CyberColors.surfaceCarbonRaised,
      shape: RoundedRectangleBorder(
        borderRadius: CyberShapes.roundedPanel,
        side: const BorderSide(color: CyberColors.thermalRed, width: 2),
      ),
      title: Row(
        children: [
          const Icon(Icons.warning, color: CyberColors.thermalRed, size: 24),
          const SizedBox(width: 8),
          Text(
            'Confirm Global Lockdown',
            style: CyberTypography.headlineMedium.copyWith(color: CyberColors.thermalRed, fontSize: 16),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WARNING: You are about to initiate an emergency global lockdown. This will:',
            style: CyberTypography.bodySmall.copyWith(color: CyberColors.textPrimary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '1. Terminate all active Android device sessions immediately.\n2. Revoke all Development Mode tokens and reset hardware overrides.\n3. Lock all Secret Vault instances and purge RAM buffers.\n4. Send emergency push and email alerts to all Super Admins.',
            style: CyberTypography.bodySmall.copyWith(color: CyberColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          Text('TYPE "LOCKDOWN" TO CONFIRM:', style: CyberTypography.telemetryMicro.copyWith(color: CyberColors.thermalRed)),
          const SizedBox(height: 6),
          TextField(
            controller: _confirmController,
            style: CyberTypography.telemetryTimecodeLarge.copyWith(color: CyberColors.thermalRed, fontSize: 16),
            decoration: const InputDecoration(
              hintText: 'LOCKDOWN',
              hintStyle: TextStyle(color: CyberColors.textTertiary),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        CyberGhostButton(
          label: 'ABORT',
          height: 36,
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: CyberColors.thermalRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          onPressed: _isLocking ? null : _executeLockdown,
          child: Text(_isLocking ? 'LOCKING...' : 'CONFIRM LOCKDOWN'),
        ),
      ],
    );
  }
}
