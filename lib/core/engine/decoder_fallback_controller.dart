import 'dart:async';
import 'package:flutter/foundation.dart';
import 'media_engine_adapter.dart';

class DecoderFailureRecord {
  final DecoderMode attemptedMode;
  final String errorMessage;
  final DateTime timestamp;

  DecoderFailureRecord({
    required this.attemptedMode,
    required this.errorMessage,
    required this.timestamp,
  });
}

/// Decoder Fallback and Damaged Frame Recovery Controller
/// Strictly implements SRS VID-06, VID-07, VID-08, VID-09.
class DecoderFallbackController {
  final List<DecoderFailureRecord> _failureHistory = [];
  DecoderMode _currentMode = DecoderMode.hwPlus;
  int _damagedFramesSkipped = 0;
  bool _isRecovering = false;

  final _decoderChangeController = StreamController<DecoderMode>.broadcast();
  Stream<DecoderMode> get onDecoderChanged => _decoderChangeController.stream;

  DecoderMode get currentMode => _currentMode;
  int get damagedFramesSkipped => _damagedFramesSkipped;
  List<DecoderFailureRecord> get failureHistory => List.unmodifiable(_failureHistory);

  void setInitialMode(DecoderMode mode) {
    _currentMode = mode;
  }

  /// Evaluates and selects fallback when a decoder crashes or fails to initialize (VID-06, VID-07)
  Future<DecoderMode?> handleDecoderFailure({
    required String errorMessage,
    required Future<bool> Function(DecoderMode fallbackMode) tryInitialize,
  }) async {
    if (_isRecovering) return null;
    _isRecovering = true;

    final failedMode = _currentMode;
    _failureHistory.add(DecoderFailureRecord(
      attemptedMode: failedMode,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    ));

    debugPrint('[DecoderFallback] Decoder failure in $failedMode: $errorMessage. Initiating fallback sequence...');

    // Determine deterministic fallback chain:
    // HW+ -> HW -> Hybrid -> SW
    final List<DecoderMode> candidateModes = _getCandidateFallbacks(failedMode);

    for (final candidate in candidateModes) {
      debugPrint('[DecoderFallback] Attempting candidate fallback mode: $candidate');
      try {
        final success = await tryInitialize(candidate);
        if (success) {
          _currentMode = candidate;
          _decoderChangeController.add(candidate);
          _isRecovering = false;
          debugPrint('[DecoderFallback] Fallback to $candidate succeeded.');
          return candidate;
        }
      } catch (e) {
        debugPrint('[DecoderFallback] Candidate $candidate failed: $e');
      }
    }

    _isRecovering = false;
    debugPrint('[DecoderFallback] All fallback decoder paths exhausted. Unrecoverable playback error.');
    return null;
  }

  List<DecoderMode> _getCandidateFallbacks(DecoderMode current) {
    switch (current) {
      case DecoderMode.hwPlus:
        return [DecoderMode.hw, DecoderMode.hybrid, DecoderMode.sw];
      case DecoderMode.hw:
        return [DecoderMode.hybrid, DecoderMode.sw];
      case DecoderMode.hybrid:
        return [DecoderMode.sw];
      case DecoderMode.sw:
        return []; // No further fallback below software
    }
  }

  /// Damaged frame recovery and skip handler (VID-08)
  bool handleDamagedFrame({required int frameIndex, required String reason}) {
    _damagedFramesSkipped++;
    debugPrint('[DecoderFallback] Damaged frame at index $frameIndex ($reason). Skipping safely (total skipped: $_damagedFramesSkipped).');
    return true; // Continue playback safely
  }

  void resetMetrics() {
    _damagedFramesSkipped = 0;
    _failureHistory.clear();
  }

  void dispose() {
    _decoderChangeController.close();
  }
}
