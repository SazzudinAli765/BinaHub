import 'package:flutter_test/flutter_test.dart';
import 'package:binahub/core/engine/decoder_fallback_controller.dart';
import 'package:binahub/core/engine/media_engine_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DecoderFallbackController - 4-Stage Fallback Sequence (VID-06..09)', () {
    test('Defaults to HW+ and follows fallback chain HW+ -> HW -> Hybrid -> SW', () async {
      final controller = DecoderFallbackController();
      controller.setInitialMode(DecoderMode.hwPlus);
      expect(controller.currentMode, equals(DecoderMode.hwPlus));

      // 1. First failure on HW+ falls back to HW
      final nextMode1 = await controller.handleDecoderFailure(
        errorMessage: 'MediaCodec HW+ surface initialization failed',
        tryInitialize: (mode) async {
          return mode == DecoderMode.hw; // HW succeeds
        },
      );

      expect(nextMode1, equals(DecoderMode.hw));
      expect(controller.currentMode, equals(DecoderMode.hw));
      expect(controller.failureHistory.length, equals(1));

      // 2. Failure on HW falls back through chain to SW
      final nextMode2 = await controller.handleDecoderFailure(
        errorMessage: 'MediaCodec hardware decoder crashed mid-playback',
        tryInitialize: (mode) async {
          return mode == DecoderMode.sw; // Only SW succeeds
        },
      );

      expect(nextMode2, equals(DecoderMode.sw));
      expect(controller.currentMode, equals(DecoderMode.sw));
      expect(controller.failureHistory.length, equals(2));
    });

    test('Damaged frame skip counter increments correctly without desync (VID-08)', () {
      final controller = DecoderFallbackController();
      expect(controller.damagedFramesSkipped, equals(0));

      controller.recordDamagedFrameSkipped(ptsMs: 1420);
      controller.recordDamagedFrameSkipped(ptsMs: 1462);

      expect(controller.damagedFramesSkipped, equals(2));
    });
  });
}
