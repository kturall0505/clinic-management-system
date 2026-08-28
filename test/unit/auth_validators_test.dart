import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_management/core/models/models.dart';
import 'package:clinic_management/core/services/password_hasher.dart';

void main() {
  group('UserRole', () {
    test('has correct levels', () {
      expect(UserRole.superAdmin.level, 100);
      expect(UserRole.moderator.level, 90);
      expect(UserRole.auditor.level, 85);
      expect(UserRole.clinicAdmin.level, 80);
      expect(UserRole.doctor.level, 60);
      expect(UserRole.receptionist.level, 40);
      expect(UserRole.patient.level, 20);
    });

    test('has correct labels', () {
      expect(UserRole.superAdmin.label, 'Super Admin');
      expect(UserRole.clinicAdmin.label, 'Klinika Admini');
      expect(UserRole.doctor.label, 'Həkim');
      expect(UserRole.patient.label, 'Pasient');
    });
  });

  group('PasswordHasher', () {
    test('hashes and verifies password', () {
      final hash = PasswordHasher.hash('SecurePass123!');
      expect(PasswordHasher.verify('SecurePass123!', hash), isTrue);
      expect(PasswordHasher.verify('WrongPass', hash), isFalse);
    });

    test('rejects malformed hashes', () {
      expect(PasswordHasher.verify('pass', 'not_a_valid_hash'), isFalse);
    });
  });

  group('AuthService password strength', () {
    test('rejects weak passwords', () {
      expect(AuthService.isPasswordStrong('short'), isFalse);
      expect(AuthService.isPasswordStrong('nouppercase123!'), isFalse);
      expect(AuthService.isPasswordStrong('NOLOWERCASE123!'), isFalse);
      expect(AuthService.isPasswordStrong('NoDigits!'), isFalse);
      expect(AuthService.isPasswordStrong('NoSpecial123'), isFalse);
    });

    test('accepts strong passwords', () {
      expect(AuthService.isPasswordStrong('StrongPass123!'), isTrue);
      expect(AuthService.isPasswordStrong('Abc123!@#'), isTrue);
    });
  });
}
