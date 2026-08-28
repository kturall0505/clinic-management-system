import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

import '../lib/core/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    late PasswordHasher hasher;

    setUp(() {
      hasher = const PasswordHasher();
    });

    test('generateSalt returns base64-encoded 16 bytes', () {
      final salt = hasher.generateSalt();
      expect(salt, isNotEmpty);
      // Base64 decoded should be 16 bytes
      final decoded = base64Decode(salt);
      expect(decoded.length, equals(16));
    });

    test('hash and verify with same password returns true', () {
      final salt = hasher.generateSalt();
      final hash = hasher.hash('testPassword123!', salt);
      expect(hasher.verify('testPassword123!', hash, salt), isTrue);
    });

    test('verify with wrong password returns false', () {
      final salt = hasher.generateSalt();
      final hash = hasher.hash('correctPassword', salt);
      expect(hasher.verify('wrongPassword', hash, salt), isFalse);
    });

    test('verify with empty password returns false', () {
      final salt = hasher.generateSalt();
      final hash = hasher.hash('somePassword', salt);
      expect(hasher.verify('', hash, salt), isFalse);
    });

    test('different salts produce different hashes for same password', () {
      final salt1 = hasher.generateSalt();
      final salt2 = hasher.generateSalt();
      final hash1 = hasher.hash('samePassword', salt1);
      final hash2 = hasher.hash('samePassword', salt2);
      expect(hash1, isNot(equals(hash2)));
      expect(base64Decode(hash1).length, equals(32));
      expect(base64Decode(hash2).length, equals(32));
    });

    test('hashAndEncode produces correct format', () {
      final encoded = hasher.hashAndEncode('testPassword');
      final parts = encoded.split('\$');
      expect(parts.length, equals(4));
      expect(parts[0], equals('PBKDF2'));
      expect(int.parse(parts[1]), equals(100000));
      expect(base64Decode(parts[2]).length, equals(16));
      expect(base64Decode(parts[3]).length, equals(32));
    });

    test('verifyFromStoredHash round-trip', () {
      final encoded = hasher.hashAndEncode('mySecurePassword');
      expect(hasher.verifyFromStoredHash('mySecurePassword', encoded), isTrue);
      expect(hasher.verifyFromStoredHash('wrongPassword', encoded), isFalse);
    });

    test('verifyFromStoredHash throws on invalid format', () {
      expect(
        () => hasher.verifyFromStoredHash('pwd', 'invalid-format'),
        throwsArgumentError,
      );
    });

    test('same input produces different hashes each time (salt uniqueness)', () {
      final hash1 = hasher.hashAndEncode('samePassword');
      final hash2 = hasher.hashAndEncode('samePassword');
      expect(hash1, isNot(equals(hash2)));
    });

    test('verify with empty salt returns false', () {
      expect(hasher.verify('password', 'someHash', ''), isFalse);
    });
  });
}
