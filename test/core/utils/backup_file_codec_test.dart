import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/utils/backup_file_codec.dart';

void main() {
  const backupJson =
      '{"schemaVersion":1,"starnyxs":[{"id":"habit-1","title":"Hydrate"}]}';

  group('BackupFileCodec', () {
    test('wraps plaintext json in a starnyxbak envelope', () async {
      final codec = BackupFileCodec();

      final encoded = await codec.encodeJson(backupJson);
      final envelope = jsonDecode(encoded) as Map<String, dynamic>;
      final decoded = await codec.decodeText(encoded);

      expect(envelope['format'], backupFileFormat);
      expect(envelope['version'], backupFileVersion);
      expect(envelope['isEncrypted'], isFalse);
      expect(envelope['payload'], isNot(backupJson));
      expect(decoded.jsonText, backupJson);
      expect(decoded.isEncrypted, isFalse);
    });

    test('encrypts payload when a passphrase is provided', () async {
      final codec = BackupFileCodec();

      final encoded = await codec.encodeJson(
        backupJson,
        passphrase: 'moonlight',
      );
      final envelope = jsonDecode(encoded) as Map<String, dynamic>;
      final decoded = await codec.decodeText(encoded, passphrase: 'moonlight');

      expect(envelope['isEncrypted'], isTrue);
      expect(encoded, isNot(contains('Hydrate')));
      expect(decoded.jsonText, backupJson);
      expect(decoded.isEncrypted, isTrue);
    });

    test('requires a passphrase for encrypted backups', () async {
      final codec = BackupFileCodec();
      final encoded = await codec.encodeJson(
        backupJson,
        passphrase: 'moonlight',
      );

      await expectLater(
        () => codec.decodeText(encoded),
        throwsA(
          isA<BackupFileCodecException>().having(
            (error) => error.code,
            'code',
            BackupFileCodecErrorCode.passphraseRequired,
          ),
        ),
      );
    });

    test('rejects an invalid passphrase for encrypted backups', () async {
      final codec = BackupFileCodec();
      final encoded = await codec.encodeJson(
        backupJson,
        passphrase: 'moonlight',
      );

      await expectLater(
        () => codec.decodeText(encoded, passphrase: 'sunrise'),
        throwsA(
          isA<BackupFileCodecException>().having(
            (error) => error.code,
            'code',
            BackupFileCodecErrorCode.invalidPassphrase,
          ),
        ),
      );
    });
  });
}
