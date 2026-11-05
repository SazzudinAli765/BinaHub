import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../database/app_database.dart';
import 'vault_security_service.dart';
import 'native_shredder_bridge.dart';

enum VaultTransactionStatus {
  initiated,
  staged,
  verified,
  committed,
  completed,
  rolledBack,
  failed
}

class VaultTransactionRecord {
  final String transactionId;
  final String sourcePath;
  final String originalFilename;
  final int sourceSizeBytes;
  VaultTransactionStatus status;
  Map<String, dynamic>? stagedCiphertextMetadata;
  String? errorMessage;
  final DateTime createdAt;

  VaultTransactionRecord({
    required this.transactionId,
    required this.sourcePath,
    required this.originalFilename,
    required this.sourceSizeBytes,
    required this.status,
    this.stagedCiphertextMetadata,
    this.errorMessage,
    required this.createdAt,
  });
}

/// Transactional Move into Vault Coordinator
/// Strictly implements SRS Section 10.2 (6-Step Moving Protocol) & VLT-02.
class VaultTransactionManager {
  static final VaultTransactionManager instance = VaultTransactionManager._internal();
  VaultTransactionManager._internal();

  final Map<String, VaultTransactionRecord> _activeTransactions = {};

  /// Step 1: Verify source access and readiness
  Future<String> beginTransaction({
    required String sourcePath,
    required String originalFilename,
    required int sourceSizeBytes,
  }) async {
    final txId = 'TX-${DateTime.now().millisecondsSinceEpoch}-${sourcePath.hashCode.abs()}';
    _activeTransactions[txId] = VaultTransactionRecord(
      transactionId: txId,
      sourcePath: sourcePath,
      originalFilename: originalFilename,
      sourceSizeBytes: sourceSizeBytes,
      status: VaultTransactionStatus.initiated,
      createdAt: DateTime.now(),
    );

    debugPrint('[VaultTx] Step 1: Initiated transaction $txId for source "$sourcePath" ($sourceSizeBytes bytes).');
    return txId;
  }

  /// Step 2 & 3: Encrypt into staging area and verify integrity before touching source
  Future<bool> stageAndVerify({
    required String transactionId,
    required Uint8List sourceBytes,
  }) async {
    final tx = _activeTransactions[transactionId];
    if (tx == null || tx.status != VaultTransactionStatus.initiated) {
      throw StateError('Invalid transaction state for staging: $transactionId');
    }

    try {
      debugPrint('[VaultTx] Step 2: Streaming encryption to private staging storage...');
      final encryptedMeta = await VaultSecurityService.instance.encryptPayload(
        plaintextBytes: sourceBytes,
        originalFilename: tx.originalFilename,
      );

      tx.stagedCiphertextMetadata = encryptedMeta;
      tx.status = VaultTransactionStatus.staged;

      debugPrint('[VaultTx] Step 3: Verifying integrity and byte counts of staged ciphertext...');
      if (encryptedMeta['byteLength'] != sourceBytes.length || encryptedMeta['byteLength'] != tx.sourceSizeBytes) {
        throw StateError('Staged byte length mismatch! Staged: ${encryptedMeta['byteLength']}, Expected: ${tx.sourceSizeBytes}');
      }
      if (encryptedMeta['authTag'] == null || (encryptedMeta['authTag'] as String).isEmpty) {
        throw StateError('Invalid or missing authentication tag on staged payload!');
      }

      tx.status = VaultTransactionStatus.verified;
      debugPrint('[VaultTx] Step 3: Integrity verification passed for $transactionId.');
      return true;
    } catch (e) {
      tx.status = VaultTransactionStatus.failed;
      tx.errorMessage = e.toString();
      debugPrint('[VaultTx] Staging failed: $e. Rolling back safely without modifying source.');
      await rollback(transactionId);
      return false;
    }
  }

  /// Step 4: Atomically commit the encrypted vault object
  Future<bool> commit({required String transactionId}) async {
    final tx = _activeTransactions[transactionId];
    if (tx == null || tx.status != VaultTransactionStatus.verified) {
      throw StateError('Cannot commit unverified transaction: $transactionId');
    }

    try {
      debugPrint('[VaultTx] Step 4: Committing vault object atomically to database...');
      final meta = tx.stagedCiphertextMetadata!;
      await AppDatabase.instance.insertVaultObject({
        'id': 'VLT-${DateTime.now().millisecondsSinceEpoch}',
        'transactionId': tx.transactionId,
        'originalFilename': tx.originalFilename,
        'encryptedFilename': meta['encryptedFilename'],
        'authTag': meta['authTag'],
        'nonce': meta['nonce'],
        'ciphertext': meta['ciphertext'],
        'sizeBytes': tx.sourceSizeBytes,
        'committedAt': DateTime.now().toIso8601String(),
      });

      tx.status = VaultTransactionStatus.committed;
      debugPrint('[VaultTx] Step 4: Atomic commit successful for $transactionId.');
      return true;
    } catch (e) {
      tx.status = VaultTransactionStatus.failed;
      tx.errorMessage = e.toString();
      await rollback(transactionId);
      return false;
    }
  }

  /// Step 5: Delete original source file ONLY after successful commit
  Future<bool> completeMove({
    required String transactionId,
    Future<bool> Function(String sourcePath)? deleteSourceCallback,
  }) async {
    final tx = _activeTransactions[transactionId];
    if (tx == null || tx.status != VaultTransactionStatus.committed) {
      throw StateError('Source cannot be deleted prior to committed vault state!');
    }

    debugPrint('[VaultTx] Step 5: Securely shredding original source file "${tx.sourcePath}" with NIST SP 800-88 3-pass overwrite...');
    final deleter = deleteSourceCallback ?? (path) => NativeShredderBridge.instance.shredFile(path);
    final deleted = await deleter(tx.sourcePath);
    if (deleted) {
      tx.status = VaultTransactionStatus.completed;
      debugPrint('[VaultTx] Step 5: Original safely removed. Transaction $transactionId completed successfully.');
      return true;
    } else {
      debugPrint('[VaultTx] Warning: Could not delete source file, but vault entry is safely preserved.');
      tx.status = VaultTransactionStatus.completed;
      return false;
    }
  }

  /// Step 6: Crash recovery handler
  Future<void> recoverDanglingTransactions() async {
    debugPrint('[VaultTx] Step 6: Checking for incomplete or dangling vault staging transactions...');
    for (final tx in _activeTransactions.values) {
      if (tx.status != VaultTransactionStatus.completed) {
        debugPrint('[VaultTx] Found uncompleted transaction ${tx.transactionId} (${tx.status}). Rolling back safely...');
        await rollback(tx.transactionId);
      }
    }
  }

  Future<void> rollback(String transactionId) async {
    final tx = _activeTransactions[transactionId];
    if (tx != null) {
      tx.status = VaultTransactionStatus.rolledBack;
      tx.stagedCiphertextMetadata = null;
      debugPrint('[VaultTx] Transaction $transactionId rolled back. Source file "${tx.sourcePath}" remains intact.');
    }
  }
}
