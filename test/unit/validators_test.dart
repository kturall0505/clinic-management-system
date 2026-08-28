import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_management/core/models/models.dart';

void main() {
  group('Phone Validation', () {
    test('accepts valid +994 format', () {
      expect(() => Patient.create(
        fullName: 'Test',
        birthDate: DateTime(1990, 1, 1),
        phone: '+994501234567',
      ), returnsNormally);
    });

    test('accepts valid 994 format', () {
      expect(() => Patient.create(
        fullName: 'Test',
        birthDate: DateTime(1990, 1, 1),
        phone: '994501234567',
      ), returnsNormally);
    });

    test('accepts valid 0 format', () {
      expect(() => Patient.create(
        fullName: 'Test',
        birthDate: DateTime(1990, 1, 1),
        phone: '0501234567',
      ), returnsNormally);
    });

    test('rejects invalid phone numbers', () {
      expect(() => Patient.create(
        fullName: 'Test',
        birthDate: DateTime(1990, 1, 1),
        phone: '123',
      ), throwsA(isA<ArgumentError>()));

      expect(() => Patient.create(
        fullName: 'Test',
        birthDate: DateTime(1990, 1, 1),
        phone: '12345678901234567890',
      ), throwsA(isA<ArgumentError>()));

      expect(() => Patient.create(
        fullName: 'Test',
        birthDate: DateTime(1990, 1, 1),
        phone: 'abc',
      ), throwsA(isA<ArgumentError>()));
    });

    test('Doctor also validates phone', () {
      expect(() => Doctor.create(
        fullName: 'Dr. Test',
        specialty: 'Test',
        phone: '+994501234567',
        consultationFee: 100,
      ), returnsNormally);

      expect(() => Doctor.create(
        fullName: 'Dr. Test',
        specialty: 'Test',
        phone: '123',
        consultationFee: 100,
      ), throwsA(isA<ArgumentError>()));
    });
  });
}
