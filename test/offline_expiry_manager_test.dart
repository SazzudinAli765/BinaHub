import 'package:flutter_test/flutter_test.dart';
import 'package:binahub/core/services/offline_expiry_manager.dart';
import 'package:binahub/core/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OfflineExpiryManager - 30-Day Expiry & Policy Supervision (EXP-01..12)', () {
    final manager = OfflineExpiryManager.instance;

    setUp(() async {
      await AppDatabase.instance.initialize();
    });

    test('Initializes supervisor and checks expiries', () async {
      await manager.checkAllExpiries();
      expect(manager.managedItems, isA<List<OfflineItemStatus>>());
    });

    test('Enforces EXP-06: strictly single pending extension request constraint', () async {
      final driveId = 'test_drv_sample_video_4k';

      // Seed an offline download item into database
      await AppDatabase.instance.recordOfflineDownload({
        'driveId': driveId,
        'fileName': 'Cyber_Recon_4K.mkv',
        'downloadDate': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        'expiryDate': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        'gracePeriodDays': 5,
        'extensionStatus': 'none',
        'signedToken': 'TOKEN-ORIGINAL-2026',
      });

      // First request succeeds
      final firstRequest = await manager.requestExtension(
        driveId: driveId,
        requestedDays: 30,
        reason: 'Air-gapped research testing in offline bunker',
      );
      expect(firstRequest, isTrue);

      // Duplicate second request while first is still pending MUST be rejected (EXP-06)
      final secondRequest = await manager.requestExtension(
        driveId: driveId,
        requestedDays: 30,
        reason: 'Repeated request before first is resolved',
      );
      expect(secondRequest, isFalse);
    });
  });
}
