import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

const String backupFileExtension = 'starnyxbak';
const String backupFileFormat = 'starnyx-backup';
const int backupFileVersion = 1;

class BackupFileCodec {
  BackupFileCodec({
    Cipher? cipher,
    Pbkdf2? keyDerivator,
    Random? random,
    int pbkdf2Iterations = 120000,
  }) : _cipher = cipher ?? AesGcm.with256bits(),
       _keyDerivator =
           keyDerivator ??
           Pbkdf2(
             macAlgorithm: Hmac.sha256(),
             iterations: pbkdf2Iterations,
             bits: 256,
           ),
       _random = random ?? Random.secure(),
       _pbkdf2Iterations = pbkdf2Iterations;

  final Cipher _cipher;
  final Pbkdf2 _keyDerivator;
  final Random _random;
  final int _pbkdf2Iterations;

  Future<String> encodeJson(String jsonText, {String? passphrase}) async {
    final normalizedPassphrase = passphrase?.trim();
    if (normalizedPassphrase == null || normalizedPassphrase.isEmpty) {
      return jsonEncode(<String, dynamic>{
        'format': backupFileFormat,
        'version': backupFileVersion,
        'isEncrypted': false,
        'payload': base64Encode(utf8.encode(jsonText)),
      });
    }

    final salt = _nextBytes(16);
    final nonce = _nextBytes(12);
    final secretKey = await _deriveKey(normalizedPassphrase, salt);
    final secretBox = await _cipher.encrypt(
      utf8.encode(jsonText),
      secretKey: secretKey,
      nonce: nonce,
    );

    return jsonEncode(<String, dynamic>{
      'format': backupFileFormat,
      'version': backupFileVersion,
      'isEncrypted': true,
      'payload': base64Encode(secretBox.cipherText),
      'encryption': <String, dynamic>{
        'algorithm': 'aes-256-gcm',
        'kdf': 'pbkdf2-hmac-sha256',
        'iterations': _pbkdf2Iterations,
        'salt': base64Encode(salt),
        'nonce': base64Encode(secretBox.nonce),
        'mac': base64Encode(secretBox.mac.bytes),
      },
    });
  }

  Future<DecodedBackupFile> decodeText(
    String encodedText, {
    String? passphrase,
  }) async {
    final envelope = _decodeEnvelope(encodedText);
    final isEncrypted = envelope['isEncrypted'] as bool? ?? false;
    final payloadBase64 = envelope['payload'] as String?;
    if (payloadBase64 == null || payloadBase64.isEmpty) {
      throw const BackupFileCodecException(
        BackupFileCodecErrorCode.invalidFormat,
        'Backup payload is missing.',
      );
    }

    if (!isEncrypted) {
      final decoded = utf8.decode(base64Decode(payloadBase64));
      return DecodedBackupFile(jsonText: decoded, isEncrypted: false);
    }

    final normalizedPassphrase = passphrase?.trim();
    if (normalizedPassphrase == null || normalizedPassphrase.isEmpty) {
      throw const BackupFileCodecException(
        BackupFileCodecErrorCode.passphraseRequired,
        'A passphrase is required to restore this backup.',
      );
    }

    final encryption = envelope['encryption'] is Map
        ? (envelope['encryption'] as Map).cast<String, dynamic>()
        : null;
    if (encryption == null) {
      throw const BackupFileCodecException(
        BackupFileCodecErrorCode.invalidFormat,
        'Encrypted backup metadata is missing.',
      );
    }

    try {
      final salt = base64Decode(encryption['salt'] as String);
      final nonce = base64Decode(encryption['nonce'] as String);
      final mac = Mac(base64Decode(encryption['mac'] as String));
      final cipherText = base64Decode(payloadBase64);
      final secretKey = await _deriveKey(normalizedPassphrase, salt);
      final clearBytes = await _cipher.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: mac),
        secretKey: secretKey,
      );
      return DecodedBackupFile(
        jsonText: utf8.decode(clearBytes),
        isEncrypted: true,
      );
    } on SecretBoxAuthenticationError {
      throw const BackupFileCodecException(
        BackupFileCodecErrorCode.invalidPassphrase,
        'The passphrase is incorrect.',
      );
    } on FormatException {
      throw const BackupFileCodecException(
        BackupFileCodecErrorCode.invalidFormat,
        'Backup metadata is malformed.',
      );
    }
  }

  Future<Map<String, dynamic>> decodeJsonMap(
    String encodedText, {
    String? passphrase,
  }) async {
    final decoded = await decodeText(encodedText, passphrase: passphrase);
    final dynamic json = jsonDecode(decoded.jsonText);
    if (json is Map<String, dynamic>) {
      return json;
    }
    if (json is Map) {
      return json.cast<String, dynamic>();
    }
    throw const BackupFileCodecException(
      BackupFileCodecErrorCode.invalidFormat,
      'Backup JSON root must be an object.',
    );
  }

  Future<SecretKey> _deriveKey(String passphrase, List<int> salt) {
    return _keyDerivator.deriveKeyFromPassword(
      password: passphrase,
      nonce: salt,
    );
  }

  Map<String, dynamic> _decodeEnvelope(String encodedText) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(encodedText);
    } on FormatException {
      throw const BackupFileCodecException(
        BackupFileCodecErrorCode.invalidFormat,
        'Backup file is not valid JSON.',
      );
    }

    if (decoded is! Map) {
      throw const BackupFileCodecException(
        BackupFileCodecErrorCode.invalidFormat,
        'Backup file root must be an object.',
      );
    }

    final envelope = decoded.cast<String, dynamic>();
    if (envelope['format'] != backupFileFormat) {
      throw const BackupFileCodecException(
        BackupFileCodecErrorCode.invalidFormat,
        'Backup file format is not supported.',
      );
    }
    if (envelope['version'] != backupFileVersion) {
      throw const BackupFileCodecException(
        BackupFileCodecErrorCode.unsupportedVersion,
        'Backup file version is not supported.',
      );
    }
    return envelope;
  }

  List<int> _nextBytes(int length) {
    return List<int>.generate(length, (_) => _random.nextInt(256));
  }
}

class DecodedBackupFile {
  const DecodedBackupFile({required this.jsonText, required this.isEncrypted});

  final String jsonText;
  final bool isEncrypted;
}

enum BackupFileCodecErrorCode {
  invalidFormat,
  unsupportedVersion,
  passphraseRequired,
  invalidPassphrase,
}

class BackupFileCodecException implements Exception {
  const BackupFileCodecException(this.code, this.message);

  final BackupFileCodecErrorCode code;
  final String message;

  @override
  String toString() => 'BackupFileCodecException($code, $message)';
}
