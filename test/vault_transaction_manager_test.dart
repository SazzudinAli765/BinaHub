import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:binahub/core/security/vault_transaction_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VaultTransactionManager - 6-Step Transactional Movement (VLT-02, Sec 10.2)', () {
    final manager = VaultTransactionManager.instance;

    test('Full 6-step movement succeeds without data corruption', () async {
      final dummyData = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      bool sourceDeleted = false;

      // Step 1: Begin transaction
      final txId = await manager.beginTransaction(
        sourcePath: '/storage/emulated/0/DCIM/TestVideo.mp4',
        originalFilename: 'TestVideo.mp4',
        sourceSizeBytes: dummyData.length,
      );
      expect(txId, startsWith('TX-'));

      // Step 2 & 3: Encrypt & verify staged ciphertext
      final staged = await manager.stageAndVerify(
        transactionId: txId,
        sourceBytes: dummyData,
      );
      expect(staged, isTrue);

      // Step 4: Commit vault entry into database
      final committed = await manager.commit(transactionId: txId);
      expect(committed, isTrue);

      // Step 5: Secure deletion callback only executed after commit
      final completed = await manager.completeMove(
        transactionId: txId,
        deleteSourceCallback: (path) async {
          expect(path, equals('/storage/emulated/0/DCIM/TestVideo.mp4'));
          sourceDeleted = true;
          return true;
        },
      );

      expect(completed, isTrue);
      expect(sourceDeleted, isTrue);
    });

    test('Staging with corrupted byteLength triggers rollback and preserves source', () async {
      final dummyData = Uint8List.fromList([10, 20, 30, 40]);

      final txId = await manager.beginTransaction(
        sourcePath: '/storage/emulated/0/DCIM/CorruptVideo.mp4',
        originalFilename: 'CorruptVideo.mp4',
        sourceSizeBytes: 999, // Mismatched size
      );

      // Corrupted verification throws state error or fails gracefully
      final staged = await manager.stageAndVerify(
        transactionId: txId,
        sourceBytes: dummyData,
      );

      // Returns false and rolls back safely
      expect(staged, isFalse);
    });

    test('Cannot completeMove before transaction is committed', () async {
      final dummyData = Uint8List.fromList([1, 2, 3]);

      final txId = await manager.beginTransaction(
        sourcePath: '/storage/emulated/0/DCIM/EarlyDelete.mp4',
        originalFilename: 'EarlyDelete.mp4',
        sourceSizeBytes: dummyData.length,
      );

      // Attempting to delete source before stage/commit throws StateError
      expect(
        () async => await manager.completeMove(
          transactionId: txId,
          deleteSourceCallback: (path) async => true,
        ),
        throwsStateError,
      );
    });
  });
}
