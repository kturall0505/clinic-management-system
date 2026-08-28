import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:clinic_management/core/models/models.dart';

void main() {
  group('Test Data Sets', () {
    test('seed patients', () {
      final patients = [
        Patient.create(
          fullName: 'Əli Məmmədov',
          birthDate: DateTime(1985, 3, 15),
          phone: '+994501234567',
          fin: 'ABCD1234567890',
          allergies: 'Penisillin',
          chronicConditions: 'Hipertoniya',
        ),
        Patient.create(
          fullName: 'Gülsüm Hüseynova',
          birthDate: DateTime(1990, 7, 22),
          phone: '+994507654321',
          fin: 'EFGH1234567890',
          allergies: null,
          chronicConditions: null,
        ),
      ];

      expect(patients.length, 2);
      expect(patients[0].fullName, 'Əli Məmmədov');
      expect(patients[1].fullName, 'Gülsüm Hüseynova');
    });

    test('seed doctors', () {
      final doctors = [
        Doctor.create(
          fullName: 'Dr. Cəmil Quliyev',
          specialty: 'Kardioloq',
          phone: '+994501111111',
          consultationFee: 150.0,
          experience: '15 il',
        ),
        Doctor.create(
          fullName: 'Dr. Aynur Hüseynova',
          specialty: 'Nevropoloq',
          phone: '+994502222222',
          consultationFee: 120.0,
          experience: '10 il',
        ),
      ];

      expect(doctors.length, 2);
      expect(doctors[0].specialty, 'Kardioloq');
      expect(doctors[1].consultationFee, 120.0);
    });

    test('seed appointments', () {
      final appointment = Appointment.create(
        patientId: 'p1',
        doctorId: 'd1',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        reason: 'Yoxlanış',
      );

      expect(appointment.patientId, 'p1');
      expect(appointment.status, AppointmentStatus.scheduled);
    });

    test('seed prescriptions', () {
      final prescription = Prescription.create(
        appointmentId: 'a1',
        patientId: 'p1',
        doctorId: 'd1',
        medications: 'Aspirin 100mg',
        diagnosis: 'Baş ağrısı',
      );

      expect(prescription.diagnosis, 'Baş ağrısı');
    });

    test('seed invoices', () {
      final invoice = Invoice.create(
        patientId: 'p1',
        appointmentId: 'a1',
        totalAmount: 150.0,
        discount: 10.0,
        tax: 5.0,
        status: 'paid',
        paymentMethod: 'cash',
      );

      expect(invoice.netAmount, 145.0);
      expect(invoice.status, 'paid');
    });

    test('seed audit logs', () {
      final log = AuditLog.create(
        userId: 'u1',
        userName: 'Admin',
        userRole: UserRole.admin,
        action: AuditAction.create,
        entityType: 'Patient',
        entityName: 'Əli Məmmədov',
      );

      expect(log.action, AuditAction.create);
      expect(log.entityType, 'Patient');
    });

    test('seed queue entries', () {
      final queueEntry = QueueEntry.create(
        patientId: 'p1',
        doctorId: 'd1',
        appointmentId: 'a1',
        queueNumber: 1,
      );

      expect(queueEntry.queueNumber, 1);
      expect(queueEntry.status, QueueStatus.waiting);
    });

    test('seed notifications', () {
      final notification = AppNotification.create(
        recipientId: 'p1',
        type: NotificationType.appointmentReminder,
        title: 'Randevu xatırlatma',
        message: 'Sabah saat 10:00-da randevunuz var',
        channel: 'push',
      );

      expect(notification.type, NotificationType.appointmentReminder);
      expect(notification.isRead, false);
    });
  });
}
