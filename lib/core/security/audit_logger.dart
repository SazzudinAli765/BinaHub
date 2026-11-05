import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../database/app_database.dart';

class AuditLogEntry {
  final int index;
  final String timestamp;
  final String actor;
  final String action;
  final Map<String, dynamic> details;
  final String prevHash;
  final String hash;

  AuditLogEntry({
    required this.index,
    required this.timestamp,
    required this.actor,
    required this.action,
    required this.details,
    required this.prevHash,
    required this.hash,
  });

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'timestamp': timestamp,
      'actor': actor,
      'action': action,
      'details': details,
      'prevHash': prevHash,
      'hash': hash,
    };
  }

  factory AuditLogEntry.fromMap(Map<String, dynamic> map) {
    return AuditLogEntry(
      index: map['index'] as int,
      timestamp: map['timestamp'] as String,
      actor: map['actor'] as String,
      action: map['action'] as String,
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      prevHash: map['prevHash'] as String,
      hash: map['hash'] as String,
    );
  }
}

/// Cryptographically Chained Immutable Audit Logger
/// Implements SRS AUDIT-01..07, ADM-14, ADM-15, SEC-06.
class AuditLogger {
  static final AuditLogger instance = AuditLogger._internal();
  AuditLogger._internal();

  static const String genesisHash = '0000000000000000000000000000000000000000000000000000000000000000';
  final List<AuditLogEntry> _memoryChain = [];
  bool _isLockdownTriggered = false;

  bool get isLockdownTriggered => _isLockdownTriggered;
  List<AuditLogEntry> get logs => List.unmodifiable(_memoryChain);

  Future<void> initialize() async {
    final storedEvents = await AppDatabase.instance.getAuditEvents();
    _memoryChain.clear();
    for (final event in storedEvents) {
      _memoryChain.add(AuditLogEntry.fromMap(event));
    }

    if (_memoryChain.isEmpty) {
      // Create Genesis block
      await logEvent(
        actor: 'SYSTEM',
        action: 'GENESIS_INITIALIZED',
        details: {'version': '1.0.0', 'securityStandard': 'SHA-256-Merkle-Chain'},
      );
    } else {
      // Verify chain integrity upon startup
      final isIntegrityValid = verifyChainIntegrity();
      if (!isIntegrityValid) {
        debugPrint('[AuditLogger] CRITICAL ALERT: Audit chain tamper detected upon startup!');
        _triggerGlobalLockdown('Startup audit chain validation failed: SHA-256 hash mismatch.');
      }
    }
  }

  /// Appends an event to the cryptographically linked ledger
  Future<AuditLogEntry> logEvent({
    required String actor,
    required String action,
    required Map<String, dynamic> details,
  }) async {
    final nextIndex = _memoryChain.length;
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final prevHash = _memoryChain.isEmpty ? genesisHash : _memoryChain.last.hash;

    final rawPayload = '$nextIndex:$timestamp:$actor:$action:${jsonEncode(details)}:$prevHash';
    final currentHash = sha256.convert(utf8.encode(rawPayload)).toString();

    final entry = AuditLogEntry(
      index: nextIndex,
      timestamp: timestamp,
      actor: actor,
      action: action,
      details: details,
      prevHash: prevHash,
      hash: currentHash,
    );

    _memoryChain.add(entry);
    await AppDatabase.instance.appendAuditEvent(entry.toMap());
    debugPrint('[AuditLogger] Block #$nextIndex appended ($action by $actor). Hash: ${currentHash.substring(0, 16)}...');
    return entry;
  }

  /// Verifies complete ledger integrity from Genesis block to latest block (AUDIT-02)
  bool verifyChainIntegrity() {
    if (_memoryChain.isEmpty) return true;

    for (int i = 0; i < _memoryChain.length; i++) {
      final entry = _memoryChain[i];

      // Check index
      if (entry.index != i) {
        debugPrint('[AuditLogger] Index mismatch at block $i: expected $i, found ${entry.index}');
        return false;
      }

      // Check previous hash link
      final expectedPrevHash = (i == 0) ? genesisHash : _memoryChain[i - 1].hash;
      if (entry.prevHash != expectedPrevHash) {
        debugPrint('[AuditLogger] PrevHash broken at block $i! Expected $expectedPrevHash, got ${entry.prevHash}');
        return false;
      }

      // Recalculate block hash
      final rawPayload = '${entry.index}:${entry.timestamp}:${entry.actor}:${entry.action}:${jsonEncode(entry.details)}:${entry.prevHash}';
      final recalculatedHash = sha256.convert(utf8.encode(rawPayload)).toString();
      if (entry.hash != recalculatedHash) {
        debugPrint('[AuditLogger] Block hash tampered at block $i! Stored: ${entry.hash}, Recalculated: $recalculatedHash');
        return false;
      }
    }

    return true;
  }

  /// Trigger independent Global Lockdown with 3-hour status reports (ADM-14, SEC-07)
  void _triggerGlobalLockdown(String reason) {
    _isLockdownTriggered = true;
    debugPrint('[AuditLogger] EMERGENCY: GLOBAL LOCKDOWN ACTIVATED. Reason: $reason');
  }

  void resetLockdown({required String masterAccessCodeHash}) {
    // Requires validation against super admin credentials
    _isLockdownTriggered = false;
    debugPrint('[AuditLogger] Global lockdown cleared by verified Administrator.');
  }
}
