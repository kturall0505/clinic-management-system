import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/core/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    late PasswordHasher hasher;
    setUp(() { hasher = const PasswordHasher(); });

    test('generateSalt returns base64-encoded 16 bytes', () {
      final salt = hasher.generateSalt();
      expect(salt, isNotEmpty);
      expect(base64Decode(salt).length, equals(16));
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
    test('different salts produce different hashes', () {
      final salt1 = hasher.generateSalt();
      final salt2 = hasher.generateSalt();
      final hash1 = hasher.hash('samePassword', salt1);
      final hash2 = hasher.hash('samePassword', salt2);
      expect(hash1, isNot(equals(hash2)));
    });
    test('hashAndEncode round-trip', () {
      final encoded = hasher.hashAndEncode('mySecurePassword');
      expect(hasher.verifyFromStoredHash('mySecurePassword', encoded), isTrue);
      expect(hasher.verifyFromStoredHash('wrongPassword', encoded), isFalse);
    });
    test('same input produces different hashes', () {
      expect(hasher.hashAndEncode('samePassword'), isNot(equals(hasher.hashAndEncode('samePassword'))));
    });
  });
}