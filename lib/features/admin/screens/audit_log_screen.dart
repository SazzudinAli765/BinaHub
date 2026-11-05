import 'package:flutter/material.dart';
import '../../../core/theme/cyber_colors.dart';
import '../../../core/theme/cyber_shapes.dart';
import '../../../core/theme/cyber_typography.dart';
import '../../../core/widgets/cyber_badge.dart';
import '../../../core/security/audit_logger.dart';

/// Immutable Security Audit Log Screen
/// SRS: AUDIT-01 to AUDIT-07 (Append-only, tamper-evident ledger, HMAC SHA-256 verification)
class AuditLogScreen extends StatefulWidget {
  @override
  _AuditLogScreenState createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  late bool _isChainValid;

  @override
  void initState() {
    super.initState();
    _isChainValid = AuditLogger.instance.verifyChainIntegrity();
  }

  void _verifyChainNow() {
    final valid = AuditLogger.instance.verifyChainIntegrity();
    setState(() {
      _isChainValid = valid;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          valid
              ? 'Cryptographic Verification Passed: All ${AuditLogger.instance.logs.length} blocks adhere to strict SHA-256 hash chaining.'
              : 'CRITICAL ALERT: Tamper detected in audit ledger!',
        ),
        backgroundColor: valid ? CyberColors.surfaceCarbonRaised : CyberColors.thermalRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logs = AuditLogger.instance.logs;

    return Scaffold(
      backgroundColor: CyberColors.bgPureBlack,
      appBar: AppBar(
        backgroundColor: CyberColors.bgPureBlack,
        title: Text('Security Audit Ledger', style: CyberTypography.headlineMedium),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.verified,
              color: _isChainValid ? CyberColors.signalGreen : CyberColors.thermalRed,
            ),
            tooltip: _isChainValid ? 'SHA-256 Chain Integrity Valid' : 'Tamper Detected',
            onPressed: _verifyChainNow,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CyberColors.surfaceCarbon,
              borderRadius: CyberShapes.roundedMicro,
              border: Border.all(
                color: _isChainValid ? CyberColors.signalGreen : CyberColors.thermalRed,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_clock,
                  color: _isChainValid ? CyberColors.signalGreen : CyberColors.thermalRed,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Append-Only Tamper-Evident Ledger',
                        style: CyberTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Audit records cannot be edited, rolled back, or deleted. Any unauthorized SQLite modification invalidates the cryptographic hash chain.',
                        style: CyberTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('HISTORICAL AUDIT BLOCKS (${logs.length})', style: CyberTypography.telemetryMicro),
          const SizedBox(height: 8),

          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text('No audit blocks in ledger.', style: CyberTypography.bodySmall),
              ),
            )
          else
            ...logs.reversed.map((entry) {
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: CyberColors.surfaceCarbonRaised,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text('BLK-#${entry.index}', style: CyberTypography.telemetryMicro),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.action,
                            style: CyberTypography.telemetryBadge.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const CodecBadge(label: 'SHA-256 LINKED', isViolet: false),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Actor: ${entry.actor}', style: CyberTypography.bodySmall.copyWith(color: CyberColors.textPrimary)),
                    Text('Details: ${entry.details}', style: CyberTypography.bodySmall),
                    const SizedBox(height: 4),
                    Text('Timestamp: ${entry.timestamp}', style: CyberTypography.telemetryMicro),
                    const SizedBox(height: 4),
                    Text(
                      'Hash: ${entry.hash.substring(0, 32)}...',
                      style: CyberTypography.telemetryMicro.copyWith(color: CyberColors.textTertiary),
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
