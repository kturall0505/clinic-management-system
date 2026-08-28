import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// PBKDF2 password hashing utility.
///
/// Uses PBKDF2-HMAC-SHA256 with 100,000 iterations (OWASP 2023 minimum).
/// Only depends on the `crypto` package (already in pubspec.yaml).
class PasswordHasher {
  static const int _defaultIterations = 100000;
  static const int _keyLengthBytes = 32; // 256 bits
  static const int _saltLength = 16;
  static const int _hashLength = 32; // SHA-256 output length

  final int iterations;

  const PasswordHasher({this.iterations = _defaultIterations});

  /// Generates cryptographically random salt bytes (base64-encoded).
  String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// PBKDF2 key derivation using HMAC-SHA256 (RFC 2898 Section 5.2).
  Uint8List _pbkdf2(List<int> passwordBytes, List<int> salt, int keyLength) {
    final hmac = Hmac(sha256, passwordBytes);
    final blocks = (keyLength + _hashLength - 1) ~/ _hashLength;
    final result = BytesBuilder();

    for (int block = 1; block <= blocks; block++) {
      final blockBytes = ByteData(4)..setUint32(0, block, Endian.big);
      final uBytes = Uint8List.fromList([
        ...salt,
        ...blockBytes.buffer.asUint8List(),
      ]);

      var u = hmac.convert(uBytes).bytes;
      var f = Uint8List.fromList(u);

      for (int j = 2; j <= iterations; j++) {
        u = hmac.convert(u).bytes;
        for (int k = 0; k < _hashLength; k++) {
          f[k] ^= u[k];
        }
      }

      result.add(f);
    }

    return result.toBytes().sublist(0, keyLength);
  }

  /// Hashes [password] with the given [salt] and returns a base64-encoded hash.
  String hash(String password, String salt) {
    final passwordBytes = utf8.encode(password);
    final saltBytes = base64Decode(salt);
    final key = _pbkdf2(passwordBytes, saltBytes, _keyLengthBytes);
    return base64Encode(key.toList());
  }

  /// Verifies [password] against the stored [hash] and [salt].
  bool verify(String password, String hash, String salt) {
    final actualHash = this.hash(password, salt);
    final actualBytes = utf8.encode(actualHash);
    final expectedBytes = utf8.encode(hash);
    if (actualBytes.length != expectedBytes.length) return false;
    int result = 0;
    for (int i = 0; i < actualBytes.length; i++) {
      result |= actualBytes[i] ^ expectedBytes[i];
    }
    return result == 0;
  }

  /// Hashes password into a combined storable string format:
  /// `PBKDF2$iterations$saltBase64$hashBase64`
  String hashAndEncode(String password) {
    final salt = generateSalt();
    final hash = this.hash(password, salt);
    return 'PBKDF2\$$iterations\$$salt\$$hash';
  }

  /// Verifies password against a combined hash string.
  bool verifyFromStoredHash(String password, String storedHash) {
    final parts = storedHash.split('\$');
    if (parts.length != 4 || parts[0] != 'PBKDF2') {
      throw ArgumentError('Invalid hash format');
    }
    return verify(password, parts[3], parts[2]);
  }
}
