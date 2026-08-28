import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('AppUser', () {
    test('creates with valid data', () {
      final user = AppUser.create(
        username: 'test',
        passwordHash: 'hash',
        salt: 'salt',
        role: UserRole.clinicAdmin,
        fullName: 'Test User',
      );
      expect(user.username, 'test');
      expect(user.role, UserRole.clinicAdmin);
    });

    test('throws on empty username', () {
      expect(
        () => AppUser.create(
          username: '',
          passwordHash: 'hash',
          salt: 'salt',
          role: UserRole.admin,
          fullName: 'Test',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Patient', () {
    test('creates with valid data', () {
      final patient = Patient.create(
        fullName: 'John Doe',
        birthDate: DateTime(1990, 1, 1),
        phone: '+994501234567',
      );
      expect(patient.fullName, 'John Doe');
      expect(patient.age, greaterThan(0));
    });

    test('throws on future birth date', () {
      expect(
        () => Patient.create(
          fullName: 'Test',
          birthDate: DateTime.now().add(const Duration(days: 1)),
          phone: '+994501234567',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on empty name', () {
      expect(
        () => Patient.create(
          fullName: '',
          birthDate: DateTime(1990, 1, 1),
          phone: '+994501234567',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on invalid phone number', () {
      expect(
        () => Patient.create(
          fullName: 'Test',
          birthDate: DateTime(1990, 1, 1),
          phone: '123',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('accepts various Azerbaijan phone formats', () {
      expect(() => Patient.create(fullName: 'Test', birthDate: DateTime(1990, 1, 1), phone: '+994501234567'), returnsNormally);
      expect(() => Patient.create(fullName: 'Test', birthDate: DateTime(1990, 1, 1), phone: '994501234567'), returnsNormally);
      expect(() => Patient.create(fullName: 'Test', birthDate: DateTime(1990, 1, 1), phone: '0501234567'), returnsNormally);
    });
  });        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Doctor', () {
    test('creates with valid data', () {
      final doctor = Doctor.create(
        fullName: 'Dr. Smith',
        specialty: 'Cardiology',
        phone: '+994501234567',
        consultationFee: 100.0,
      );
      expect(doctor.fullName, 'Dr. Smith');
      expect(doctor.consultationFee, 100.0);
    });

    test('throws on negative fee', () {
      expect(
        () => Doctor.create(
          fullName: 'Dr. Smith',
          specialty: 'Cardiology',
          phone: '123',
          consultationFee: -10,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Appointment', () {
    test('creates with valid data', () {
      final appointment = Appointment.create(
        patientId: 'p1',
        doctorId: 'd1',
        dateTime: DateTime.now().add(const Duration(days: 1)),
      );
      expect(appointment.patientId, 'p1');
      expect(appointment.status, AppointmentStatus.scheduled);
    });

    test('throws on past date', () {
      expect(
        () => Appointment.create(
          patientId: 'p1',
          doctorId: 'd1',
          dateTime: DateTime.now().subtract(const Duration(days: 1)),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Payment', () {
    test('creates with valid data', () {
      final payment = Payment.create(
        appointmentId: 'a1',
        patientId: 'p1',
        amount: 50.0,
        method: 'cash',
      );
      expect(payment.amount, 50.0);
      expect(payment.status, 'pending');
    });

    test('throws on negative amount', () {
      expect(
        () => Payment.create(
          appointmentId: 'a1',
          patientId: 'p1',
          amount: -10,
          method: 'cash',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Invoice', () {
    test('creates with valid data', () {
      final invoice = Invoice.create(
        patientId: 'p1',
        appointmentId: 'a1',
        totalAmount: 100.0,
      );
      expect(invoice.totalAmount, 100.0);
      expect(invoice.netAmount, 100.0);
    });

    test('calculates net amount correctly', () {
      final invoice = Invoice.create(
        patientId: 'p1',
        appointmentId: 'a1',
        totalAmount: 100.0,
        discount: 10.0,
        tax: 5.0,
      );
      expect(invoice.netAmount, 95.0);
    });
  });

  group('AuditLog', () {
    test('creates with valid data', () {
      final log = AuditLog.create(
        userId: 'u1',
        userName: 'Admin',
        userRole: UserRole.admin,
        action: AuditAction.create,
        entityType: 'Patient',
      );
      expect(log.userId, 'u1');
      expect(log.action, AuditAction.create);
    });
  });

  group('QueueEntry', () {
    test('creates with valid data', () {
      final entry = QueueEntry.create(
        patientId: 'p1',
        doctorId: 'd1',
        appointmentId: 'a1',
        queueNumber: 1,
      );
      expect(entry.queueNumber, 1);
      expect(entry.status, QueueStatus.waiting);
    });

    test('throws on invalid queue number', () {
      expect(
        () => QueueEntry.create(
          patientId: 'p1',
          doctorId: 'd1',
          appointmentId: 'a1',
          queueNumber: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
