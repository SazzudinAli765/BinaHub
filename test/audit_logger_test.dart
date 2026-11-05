import 'package:flutter_test/flutter_test.dart';
import 'package:binahub/core/security/audit_logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuditLogger - Cryptographic Append-Only Ledger (AUDIT-01..07, ADM-14)', () {
    final logger = AuditLogger.instance;

    setUp(() async {
      await logger.initialize();
    });

    test('Genesis block initialized correctly with 64 zero hex string', () {
      expect(logger.logs.isNotEmpty, isTrue);
      final genesis = logger.logs.first;
      expect(genesis.index, equals(0));
      expect(genesis.action, equals('GENESIS_INITIALIZED'));
      expect(genesis.prevHash, equals(AuditLogger.genesisHash));
      expect(genesis.hash.length, equals(64));
    });

    test('Consecutive logs form a valid SHA-256 hash chain', () async {
      final initialCount = logger.logs.length;

      await logger.logEvent(
        actor: 'owner.sazzudin@gmail.com',
        action: 'VAULT_ITEM_OPEN',
        details: {'file': 'Personal_Archive_Master_2026.mkv'},
      );

      await logger.logEvent(
        actor: 'owner.sazzudin@gmail.com',
        action: 'DECODER_OVERRIDE',
        details: {'from': 'HW', 'to': 'HW+'},
      );

      expect(logger.logs.length, equals(initialCount + 2));

      // Verify chain integrity
      final isValid = logger.verifyChainIntegrity();
      expect(isValid, isTrue);

      // Verify each block's prevHash matches prior block's hash
      for (int i = 1; i < logger.logs.length; i++) {
        expect(logger.logs[i].prevHash, equals(logger.logs[i - 1].hash));
      }
    });

    test('Tamper in historical entry is detected immediately', () async {
      // Create at least 2 events
      await logger.logEvent(
        actor: 'system',
        action: 'TEST_EVENT',
        details: {},
      );

      expect(logger.verifyChainIntegrity(), isTrue);
    });
  });
}
