import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('light theme has correct primary color', () {
      final theme = AppTheme.lightTheme;
      expect(theme.colorScheme.primary, const Color(0xFF1976D2));
    });

    test('dark theme has correct brightness', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
    });

    test('spacing values are correct', () {
      expect(AppTheme.spacing1, 4);
      expect(AppTheme.spacing2, 8);
      expect(AppTheme.spacing4, 16);
    });
  });

  group('Extensions', () {
    test('UserRoleExtension labels', () {
      expect(UserRole.admin.label, 'Admin');
      expect(UserRole.doctor.label, 'Həkim');
      expect(UserRole.receptionist.label, 'Resepşn');
      expect(UserRole.patient.label, 'Pasient');
    });

    test('AppointmentStatusExtension labels', () {
      expect(AppointmentStatus.scheduled.label, 'Planlaşdırılıb');
      expect(AppointmentStatus.completed.label, 'Tamamlanıb');
    });

    test('GenderExtension labels', () {
      expect(Gender.male.label, 'Kişi');
      expect(Gender.female.label, 'Qadın');
    });

    test('BloodTypeExtension labels', () {
      expect(BloodType.aPositive.label, 'A+');
      expect(BloodType.oNegative.label, 'O-');
    });
  });
}
