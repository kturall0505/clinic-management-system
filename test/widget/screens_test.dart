import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clinic_management/core/app_config.dart';
import 'package:clinic_management/core/db/app_database.dart';
import 'package:clinic_management/core/models/models.dart';
import 'package:clinic_management/core/repositories/repositories.dart';
import 'package:clinic_management/core/services/auth_service.dart';
import 'package:clinic_management/ui/screens/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('shows login form', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthService(UserRepository(AppDatabase.forTesting(MemoryDatabase()))),
            child: const LoginScreen(),
          ),
        ),
      );

      expect(find.text('Tibb Klinika'), findsOneWidget);
      expect(find.text('Giriş'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('validates empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthService(UserRepository(AppDatabase.forTesting(MemoryDatabase()))),
            child: const LoginScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Giriş'));
      await tester.pump();

      expect(find.text('İstifadəçi adı tələb olunur'), findsOneWidget);
    });
  });

  group('DashboardScreen Widget Tests', () {
    testWidgets('shows loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider.value(value: PatientRepository(AppDatabase.forTesting(MemoryDatabase()))),
              Provider.value(value: DoctorRepository(AppDatabase.forTesting(MemoryDatabase()))),
              Provider.value(value: AppointmentRepository(AppDatabase.forTesting(MemoryDatabase()))),
            ],
            child: const DashboardScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no data', (WidgetTester tester) async {
      final db = AppDatabase.forTesting(MemoryDatabase());
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider.value(value: PatientRepository(db)),
              Provider.value(value: DoctorRepository(db)),
              Provider.value(value: AppointmentRepository(db)),
            ],
            child: const DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Panel boşdur'), findsOneWidget);
    });
  });

  group('AuthService Tests', () {
    test('password hashing is consistent', () {
      final salt = AuthService._generateSalt();
      final hash1 = AuthService.hashPassword('password', salt);
      final hash2 = AuthService.hashPassword('password', salt);
      expect(hash1, hash2);
    });

    test('password strength validation', () {
      expect(AuthService.isPasswordStrong('pass'), false);
      expect(AuthService.isPasswordStrong('password1'), true);
      expect(AuthService.isPasswordStrong('PASSWORD'), false);
      expect(AuthService.isPasswordStrong('Pass1!'), true);
    });
  });
}
