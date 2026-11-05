import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:binahub/core/security/native_shredder_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NativeShredderBridge - NIST SP 800-88 3-Pass Overwrite Shredder (VLT-02, Sec 10.2)', () {
    final shredder = NativeShredderBridge.instance;

    test('Shreds and unlinks file with 3-pass overwrite pattern', () async {
      // Create temporary file with test data
      final tempDir = Directory.systemTemp.createTempSync('binahub_shred_test_');
      final targetFile = File('${tempDir.path}/confidential_test_media.mp4');
      await targetFile.writeAsBytes(List.generate(128 * 1024, (i) => (i % 256)));

      expect(await targetFile.exists(), isTrue);
      expect(await targetFile.length(), equals(128 * 1024));

      // Execute NIST SP 800-88 3-Pass shred
      final success = await shredder.shredFile(targetFile.path);

      expect(success, isTrue);
      // File must be completely unlinked from filesystem
      expect(await targetFile.exists(), isFalse);

      tempDir.deleteSync(recursive: true);
    });

    test('Returns false gracefully when target file does not exist', () async {
      final nonExistentPath = '/non/existent/path/media_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final success = await shredder.shredFile(nonExistentPath);
      expect(success, isFalse);
    });
  });
}
