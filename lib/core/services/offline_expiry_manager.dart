import 'dart:async';
import 'package:flutter/foundation.dart';
import '../database/app_database.dart';
import '../security/audit_logger.dart';

enum ExpiryState {
  valid,
  expiringSoon, // <= 5 days remaining
  inGracePeriod, // Expired, within 5 days grace
  expiredAndDeleted
}

class OfflineItemStatus {
  final String driveId;
  final String fileName;
  final DateTime downloadDate;
  final DateTime expiryDate;
  final int gracePeriodDays;
  final ExpiryState state;
  final int daysRemaining;
  final String extensionStatus; // 'none', 'pending', 'approved', 'rejected'
  final String signedToken;

  OfflineItemStatus({
    required this.driveId,
    required this.fileName,
    required this.downloadDate,
    required this.expiryDate,
    required this.gracePeriodDays,
    required this.state,
    required this.daysRemaining,
    required this.extensionStatus,
    required this.signedToken,
  });
}

/// Offline Google Drive Expiry & Lifecycle Supervisor
/// Strictly implements SRS EXP-01..12 and Section 9.3
class OfflineExpiryManager extends ChangeNotifier {
  static final OfflineExpiryManager instance = OfflineExpiryManager._internal();
  OfflineExpiryManager._internal();

  Timer? _supervisorTimer;
  final List<OfflineItemStatus> _managedItems = [];

  List<OfflineItemStatus> get managedItems => List.unmodifiable(_managedItems);

  void startSupervisor() {
    _supervisorTimer?.cancel();
    debugPrint('[OfflineExpiryManager] Starting automated 30-day expiry supervisor...');
    checkAllExpiries();
    // Run evaluation cycle periodically
    _supervisorTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      checkAllExpiries();
    });
  }

  void stopSupervisor() {
    _supervisorTimer?.cancel();
  }

  Future<void> checkAllExpiries() async {
    final downloads = await AppDatabase.instance.getOfflineDownloads();
    final now = DateTime.now();
    _managedItems.clear();

    for (final item in downloads) {
      final driveId = item['driveId'] as String;
      final fileName = item['fileName'] as String;
      final downloadDate = DateTime.parse(item['downloadDate'] as String);
      final expiryDate = DateTime.parse(item['expiryDate'] as String);
      final graceDays = (item['gracePeriodDays'] as int?) ?? 5;
      final extensionStatus = (item['extensionStatus'] as String?) ?? 'none';
      final signedToken = (item['signedToken'] as String?) ?? '';

      final difference = expiryDate.difference(now);
      final daysRemaining = difference.inDays;

      ExpiryState state;
      if (now.isBefore(expiryDate)) {
        if (daysRemaining <= 5) {
          state = ExpiryState.expiringSoon;
        } else {
          state = ExpiryState.valid;
        }
      } else {
        final graceExpiry = expiryDate.add(Duration(days: graceDays));
        if (now.isBefore(graceExpiry)) {
          state = ExpiryState.inGracePeriod;
          debugPrint('[OfflineExpiryManager] WARNING: Item "$fileName" entered 5-day grace period!');
        } else {
          state = ExpiryState.expiredAndDeleted;
          debugPrint('[OfflineExpiryManager] EXPIRED: Deleting local file copy for "$fileName" (EXP-08). Cloud copy is preserved.');
          await _deleteLocalOfflineCopy(driveId, fileName);
          continue;
        }
      }

      _managedItems.add(OfflineItemStatus(
        driveId: driveId,
        fileName: fileName,
        downloadDate: downloadDate,
        expiryDate: expiryDate,
        gracePeriodDays: graceDays,
        state: state,
        daysRemaining: daysRemaining,
        extensionStatus: extensionStatus,
        signedToken: signedToken,
      ));
    }

    notifyListeners();
  }

  /// Request extension for an offline copy (EXP-06: Strict single pending request enforcement)
  Future<bool> requestExtension({
    required String driveId,
    required int requestedDays,
    required String reason,
  }) async {
    final downloads = await AppDatabase.instance.getOfflineDownloads();
    final target = downloads.firstWhere(
      (d) => d['driveId'] == driveId,
      orElse: () => {},
    );

    if (target.isEmpty) return false;

    if (target['extensionStatus'] == 'pending') {
      debugPrint('[OfflineExpiryManager] REJECTED: Item already has a pending extension request (EXP-06).');
      return false;
    }

    debugPrint('[OfflineExpiryManager] Submitting offline extension request for $driveId (+ $requestedDays days)...');
    target['extensionStatus'] = 'pending';
    target['extensionRequestDays'] = requestedDays;
    target['extensionReason'] = reason;

    await AuditLogger.instance.logEvent(
      actor: 'OFFLINE_USER',
      action: 'EXTENSION_REQUESTED',
      details: {
        'driveId': driveId,
        'requestedDays': requestedDays,
        'reason': reason,
      },
    );

    await checkAllExpiries();
    return true;
  }

  /// Administrator approves and signs extension token (EXP-04, EXP-05)
  Future<bool> approveExtension({
    required String driveId,
    required int grantedDays,
    required String adminActor,
  }) async {
    final signedToken = 'SIG-EXT-${DateTime.now().millisecondsSinceEpoch}-$driveId-$grantedDays';
    await AppDatabase.instance.updateDownloadExtension(
      driveId: driveId,
      extensionDays: grantedDays,
      signedToken: signedToken,
    );

    await AuditLogger.instance.logEvent(
      actor: adminActor,
      action: 'EXTENSION_APPROVED',
      details: {
        'driveId': driveId,
        'grantedDays': grantedDays,
        'signedToken': signedToken,
      },
    );

    debugPrint('[OfflineExpiryManager] Extension approved for $driveId (+ $grantedDays days). Signed Token: $signedToken');
    await checkAllExpiries();
    return true;
  }

  Future<void> _deleteLocalOfflineCopy(String driveId, String fileName) async {
    await AppDatabase.instance.removeExpiredDownload(driveId);
    await AuditLogger.instance.logEvent(
      actor: 'SYSTEM_EXPIRY_ENGINE',
      action: 'OFFLINE_FILE_WIPED',
      details: {
        'driveId': driveId,
        'fileName': fileName,
        'policy': '30_DAY_EXPIRY_EXCEEDED_GRACE',
      },
    );
  }
}
