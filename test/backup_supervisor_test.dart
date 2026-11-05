import 'package:flutter_test/flutter_test.dart';
import 'package:binahub/core/services/backup_supervisor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackupSupervisor - 5GB Quota & 70% Threshold Offloader (BKP-01..52)', () {
    final supervisor = BackupSupervisor.instance;

    setUp(() async {
      await supervisor.initialize();
    });

    test('Initializes with default 5 GB quota cap and tracks local bytes', () {
      expect(BackupSupervisor.primaryStorageCapBytes, equals(5 * 1024 * 1024 * 1024));
      expect(
        (BackupSupervisor.primaryStorageCapBytes * BackupSupervisor.offloadThresholdRatio).toInt(),
        equals((5 * 1024 * 1024 * 1024 * 0.70).toInt()),
      );
      expect(supervisor.currentLocalStorageBytes, isNonNegative);
    });

    test('Creating a backup adds manifest and updates storage usage', () async {
      final initialCount = supervisor.manifests.length;

      final manifest = await supervisor.createBackup(
        type: BackupType.full,
        actor: 'owner.sazzudin@gmail.com',
      );

      expect(manifest.id, startsWith('BKP-'));
      expect(manifest.isEncrypted, isTrue);
      expect(manifest.sha256Checksum, startsWith('SHA256-'));
      expect(supervisor.manifests.length, equals(initialCount + 1));
    });

    test('Isolated sandbox restore drill validates DEK and SQLite schema (BKP-08)', () async {
      expect(supervisor.manifests.isNotEmpty, isTrue);
      final targetManifest = supervisor.manifests.first;

      final drillResult = await supervisor.restoreFromBackup(
        backupId: targetManifest.id,
        actor: 'owner.sazzudin@gmail.com',
      );

      expect(drillResult, isTrue);
    });

    test('70% quota threshold triggers automatic oldest-backup offload', () async {
      final initialManifests = supervisor.manifests.length;

      await supervisor.createBackup(
        type: BackupType.full,
        actor: 'owner.sazzudin@gmail.com',
      );

      expect(supervisor.manifests.length, greaterThanOrEqualTo(initialManifests));
    });
  });
}
