import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import 'package:clinic_management/core/db/app_database.dart';
import 'package:clinic_management/core/models/models.dart';
import 'package:clinic_management/core/repositories/repositories.dart';
import 'package:clinic_management/core/services/ai_service.dart';
import 'package:clinic_management/core/services/auth_service.dart';

int _dbCounter = 0;

Future<AppDatabase> _memoryDb() async => AppDatabase.forTesting(
    await databaseFactoryMemory.openDatabase('test_${_dbCounter++}.db'));

void main() {
  group('AuthService', () {
    test('seeds default admin and logs in', () async {
      final db = await _memoryDb();
      final auth = AuthService(UserRepository(db));
      await auth.ensureSeedAdmin();
      expect(await auth.login('admin', 'wrong'), isFalse);
      expect(await auth.login('admin', 'admin123'), isTrue);
      expect(auth.currentUser?.role, UserRole.admin);
    });

    test('rejects duplicate usernames', () async {
      final db = await _memoryDb();
      final auth = AuthService(UserRepository(db));
      await auth.register(
          username: 'dr1',
          password: 'secret',
          role: UserRole.doctor,
          fullName: 'Dr One');
      expect(
        () => auth.register(
            username: 'dr1',
            password: 'other',
            role: UserRole.doctor,
            fullName: 'Dr Two'),
        throwsStateError,
      );
    });
  });

  group('Repositories', () {
    test('patient CRUD round-trips', () async {
      final db = await _memoryDb();
      final repo = PatientRepository(db);
      final patient = Patient(
          fullName: 'Test Pasient',
          birthDate: DateTime(1985, 5, 20),
          phone: '+994501112233',
          allergies: 'Penisilin');
      await repo.save(patient);
      final all = await repo.all();
      expect(all, hasLength(1));
      expect(all.first.fullName, 'Test Pasient');
      expect(all.first.allergies, 'Penisilin');
      await repo.delete(patient.id);
      expect(await repo.all(), isEmpty);
    });

    test('appointments are sorted by time', () async {
      final db = await _memoryDb();
      final repo = AppointmentRepository(db);
      final later = Appointment(
          patientId: 'p1',
          doctorId: 'd1',
          dateTime: DateTime(2026, 1, 2, 10));
      final earlier = Appointment(
          patientId: 'p2',
          doctorId: 'd1',
          dateTime: DateTime(2026, 1, 1, 9));
      await repo.save(later);
      await repo.save(earlier);
      final all = await repo.all();
      expect(all.first.id, earlier.id);
    });
  });

  group('AiService', () {
    test('offline fallback answers appointment questions', () async {
      final ai = AiService(endpoint: null);
      final answer = await ai.ask('Randevu necə yaradım?');
      expect(answer, contains('Randevu'));
    });
  });
}
