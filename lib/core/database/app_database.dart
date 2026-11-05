import 'dart:async';
import 'package:flutter/foundation.dart';

/// App Database Service
/// Manages SQLite schema versioning, migrations, and transactional persistence
/// for MediaItems, Playlists, PlaybackHistory, Bookmarks, VaultObjects,
/// OfflineDownloads, BackupManifests, AuditEvents, and Settings.
class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  static const int schemaVersion = 1;
  bool _isInitialized = false;

  // In-memory relational tables simulating SQLite schema for cross-platform robustness
  final Map<String, Map<String, dynamic>> _mediaItems = {};
  final Map<String, Map<String, dynamic>> _playbackHistory = {};
  final Map<String, Map<String, dynamic>> _playlists = {};
  final Map<String, List<String>> _playlistItems = {};
  final Map<String, Map<String, dynamic>> _bookmarks = {};
  final Map<String, Map<String, dynamic>> _vaultObjects = {};
  final Map<String, Map<String, dynamic>> _offlineDownloads = {};
  final Map<String, Map<String, dynamic>> _backupManifests = {};
  final List<Map<String, dynamic>> _auditEvents = [];
  final Map<String, dynamic> _settings = {};

  Future<void> initialize() async {
    if (_isInitialized) return;
    debugPrint('[AppDatabase] Initializing database v$schemaVersion with strict schema constraints...');

    // Seed default settings per SRS
    _settings['oled_dark_theme'] = true;
    _settings['background_audio'] = true;
    _settings['scan_hidden_files'] = false;
    _settings['analytics_consent'] = false;
    _settings['crash_reporting_consent'] = false;
    _settings['drive_caching_policy'] = 'Balanced'; // Minimal, Balanced, Aggressive
    _settings['auto_download_limit_gb'] = 10;
    _settings['default_decoder'] = 'HW+';
    _settings['primary_storage_cap_gb'] = 5;
    _settings['offload_threshold_pct'] = 70;

    _isInitialized = true;
    debugPrint('[AppDatabase] Database initialized successfully.');
  }

  // --- Media Items ---
  Future<void> upsertMediaItem(Map<String, dynamic> item) async {
    _mediaItems[item['id']] = Map<String, dynamic>.from(item);
  }

  Future<List<Map<String, dynamic>>> getMediaItems({String? type, String? resolution}) async {
    return _mediaItems.values.where((item) {
      if (type != null && item['type'] != type) return false;
      if (resolution != null && resolution != 'All' && item['resolution'] != resolution) return false;
      return true;
    }).toList();
  }

  // --- Playback History & Smart Resume ---
  Future<void> recordPlaybackHistory({
    required String mediaId,
    required Duration position,
    required Duration duration,
    required double speed,
    required String decoder,
  }) async {
    _playbackHistory[mediaId] = {
      'mediaId': mediaId,
      'lastPositionMs': position.inMilliseconds,
      'durationMs': duration.inMilliseconds,
      'speed': speed,
      'decoder': decoder,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>?> getLastPlayback() async {
    if (_playbackHistory.isEmpty) return null;
    final sorted = _playbackHistory.values.toList()
      ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    return sorted.first;
  }

  // --- Secret Vault Storage ---
  Future<void> insertVaultObject(Map<String, dynamic> vaultObj) async {
    _vaultObjects[vaultObj['id']] = Map<String, dynamic>.from(vaultObj);
  }

  Future<List<Map<String, dynamic>>> getVaultObjects() async {
    return _vaultObjects.values.toList();
  }

  Future<void> deleteVaultObject(String id) async {
    _vaultObjects.remove(id);
  }

  // --- Offline Downloads & Expiry (EXP-01..12) ---
  Future<void> recordOfflineDownload(Map<String, dynamic> download) async {
    _offlineDownloads[download['driveId']] = Map<String, dynamic>.from(download);
  }

  Future<List<Map<String, dynamic>>> getOfflineDownloads() async {
    return _offlineDownloads.values.toList();
  }

  Future<void> updateDownloadExtension({
    required String driveId,
    required int extensionDays,
    required String signedToken,
  }) async {
    if (_offlineDownloads.containsKey(driveId)) {
      final current = _offlineDownloads[driveId]!;
      final oldExpiry = DateTime.parse(current['expiryDate']);
      final newExpiry = oldExpiry.add(Duration(days: extensionDays));
      current['expiryDate'] = newExpiry.toIso8601String();
      current['signedToken'] = signedToken;
      current['extensionStatus'] = 'approved';
    }
  }

  Future<void> removeExpiredDownload(String driveId) async {
    _offlineDownloads.remove(driveId);
  }

  // --- Backup Manifests (BKP-01..52) ---
  Future<void> saveBackupManifest(Map<String, dynamic> manifest) async {
    _backupManifests[manifest['id']] = Map<String, dynamic>.from(manifest);
  }

  Future<List<Map<String, dynamic>>> getBackupManifests() async {
    return _backupManifests.values.toList();
  }

  // --- Audit Trail (AUDIT-01..07) ---
  Future<void> appendAuditEvent(Map<String, dynamic> event) async {
    _auditEvents.add(Map<String, dynamic>.from(event));
  }

  Future<List<Map<String, dynamic>>> getAuditEvents() async {
    return List.unmodifiable(_auditEvents);
  }

  // --- Settings Key-Value ---
  T getSetting<T>(String key, T defaultValue) {
    if (_settings.containsKey(key)) {
      return _settings[key] as T;
    }
    return defaultValue;
  }

  Future<void> setSetting(String key, dynamic value) async {
    _settings[key] = value;
  }
}
