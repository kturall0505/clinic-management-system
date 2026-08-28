import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_management/core/services/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    test('hashes password with PBKDF2', () {
      final hash = PasswordHasher.hash('testpassword123!');
      expect(hash, startsWith('pbkdf2_sha256$'));
      expect(hash, contains('$600000$'));
    });

    test('verifies correct password', () {
      final hash = PasswordHasher.hash('testpassword123!');
      expect(PasswordHasher.verify('testpassword123!', hash), isTrue);
    });

    test('rejects incorrect password', () {
      final hash = PasswordHasher.hash('testpassword123!');
      expect(PasswordHasher.verify('wrongpassword', hash), isFalse);
    });

    test('rejects malformed hash', () {
      expect(PasswordHasher.verify('password', 'invalid_hash'), isFalse);
    });

    test('different passwords produce different hashes', () {
      final hash1 = PasswordHasher.hash('password1!');
      final hash2 = PasswordHasher.hash('password2!');
      expect(hash1, isNot(hash2));
    });

    test('same password produces same hash', () {
      final hash1 = PasswordHasher.hash('testpassword123!');
      final hash2 = PasswordHasher.hash('testpassword123!');
      expect(hash1, equals(hash2));
    });
  });
}
