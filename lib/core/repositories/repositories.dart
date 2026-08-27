import 'package:sembast/sembast.dart';

import '../db/app_database.dart';
import '../models/models.dart';

class _Store<T> {
  _Store(this.db, String name, this.fromMap, this.toMap)
      : store = stringMapStoreFactory.store(name);

  final AppDatabase db;
  final StoreRef<String, Map<String, Object?>> store;
  final T Function(Map<String, Object?>) fromMap;
  final Map<String, Object?> Function(T) toMap;

  Future<void> put(String id, T value) =>
      store.record(id).put(db.db, toMap(value));

  Future<void> delete(String id) => store.record(id).delete(db.db);

  Future<List<T>> all() async {
    final records = await store.find(db.db);
    return records.map((r) => fromMap(r.value)).toList();
  }
}

class PatientRepository {
  PatientRepository(AppDatabase db)
      : _store = _Store(db, 'patients', Patient.fromMap, (p) => p.toMap());

  final _Store<Patient> _store;

  Future<void> save(Patient patient) => _store.put(patient.id, patient);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<Patient>> all() => _store.all();
}

class DoctorRepository {
  DoctorRepository(AppDatabase db)
      : _store = _Store(db, 'doctors', Doctor.fromMap, (d) => d.toMap());

  final _Store<Doctor> _store;

  Future<void> save(Doctor doctor) => _store.put(doctor.id, doctor);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<Doctor>> all() => _store.all();
}

class AppointmentRepository {
  AppointmentRepository(AppDatabase db)
      : _store =
            _Store(db, 'appointments', Appointment.fromMap, (a) => a.toMap());

  final _Store<Appointment> _store;

  Future<void> save(Appointment appointment) =>
      _store.put(appointment.id, appointment);
  Future<void> delete(String id) => _store.delete(id);

  Future<List<Appointment>> all() async {
    final items = await _store.all();
    items.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return items;
  }
}

class UserRepository {
  UserRepository(AppDatabase db)
      : _store = _Store(db, 'users', AppUser.fromMap, (u) => u.toMap());

  final _Store<AppUser> _store;

  Future<void> save(AppUser user) => _store.put(user.id, user);
  Future<List<AppUser>> all() => _store.all();

  Future<AppUser?> findByUsername(String username) async {
    final users = await _store.all();
    for (final user in users) {
      if (user.username == username) return user;
    }
    return null;
  }
}

class PrescriptionRepository {
  PrescriptionRepository(AppDatabase db)
      : _store =
            _Store(db, 'prescriptions', Prescription.fromMap, (p) => p.toMap());

  final _Store<Prescription> _store;

  Future<void> save(Prescription prescription) =>
      _store.put(prescription.id, prescription);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<Prescription>> all() => _store.all();
}

class PaymentRepository {
  PaymentRepository(AppDatabase db)
      : _store = _Store(db, 'payments', Payment.fromMap, (p) => p.toMap());

  final _Store<Payment> _store;

  Future<void> save(Payment payment) => _store.put(payment.id, payment);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<Payment>> all() => _store.all();
}

class PatientMedicalInfoRepository {
  PatientMedicalInfoRepository(AppDatabase db)
      : _store = _Store(db, 'patient_medical_info', PatientMedicalInfo.fromMap, (p) => p.toMap());

  final _Store<PatientMedicalInfo> _store;

  Future<void> save(PatientMedicalInfo info) => _store.put(info.id, info);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<PatientMedicalInfo>> all() => _store.all();

  Future<PatientMedicalInfo?> findByPatientId(String patientId) async {
    final items = await _store.all();
    for (final item in items) {
      if (item.patientId == patientId) return item;
    }
    return null;
  }
}

class MedicalVisitRepository {
  MedicalVisitRepository(AppDatabase db)
      : _store = _Store(db, 'medical_visits', MedicalVisit.fromMap, (v) => v.toMap());

  final _Store<MedicalVisit> _store;

  Future<void> save(MedicalVisit visit) => _store.put(visit.id, visit);
  Future<void> delete(String id) => _store.delete(id);

  Future<List<MedicalVisit>> all() async {
    final items = await _store.all();
    items.sort((a, b) => b.visitDate.compareTo(a.visitDate));
    return items;
  }

  Future<List<MedicalVisit>> findByPatientId(String patientId) async {
    final items = await _store.all();
    return items.where((v) => v.patientId == patientId).toList();
  }
}

class MedicationRepository {
  MedicationRepository(AppDatabase db)
      : _store = _Store(db, 'medications', Medication.fromMap, (m) => m.toMap());

  final _Store<Medication> _store;

  Future<void> save(Medication medication) => _store.put(medication.id, medication);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<Medication>> all() => _store.all();

  Future<Medication?> findByName(String name) async {
    final items = await _store.all();
    for (final item in items) {
      if (item.name.toLowerCase() == name.toLowerCase()) return item;
    }
    return null;
  }
}

class PrescriptionItemRepository {
  PrescriptionItemRepository(AppDatabase db)
      : _store = _Store(db, 'prescription_items', PrescriptionItem.fromMap, (p) => p.toMap());

  final _Store<PrescriptionItem> _store;

  Future<void> save(PrescriptionItem item) => _store.put(item.id, item);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<PrescriptionItem>> all() => _store.all();

  Future<List<PrescriptionItem>> findByPrescriptionId(String prescriptionId) async {
    final items = await _store.all();
    return items.where((i) => i.prescriptionId == prescriptionId).toList();
  }
}

class InvoiceRepository {
  InvoiceRepository(AppDatabase db)
      : _store = _Store(db, 'invoices', Invoice.fromMap, (i) => i.toMap());

  final _Store<Invoice> _store;

  Future<void> save(Invoice invoice) => _store.put(invoice.id, invoice);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<Invoice>> all() => _store.all();
}

class InvoiceItemRepository {
  InvoiceItemRepository(AppDatabase db)
      : _store = _Store(db, 'invoice_items', InvoiceItem.fromMap, (i) => i.toMap());

  final _Store<InvoiceItem> _store;

  Future<void> save(InvoiceItem item) => _store.put(item.id, item);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<InvoiceItem>> all() => _store.all();

  Future<List<InvoiceItem>> findByInvoiceId(String invoiceId) async {
    final items = await _store.all();
    return items.where((i) => i.invoiceId == invoiceId).toList();
  }
}

class AuditLogRepository {
  AuditLogRepository(AppDatabase db)
      : _store = _Store(db, 'audit_logs', AuditLog.fromMap, (a) => a.toMap());

  final _Store<AuditLog> _store;

  Future<void> save(AuditLog log) => _store.put(log.id, log);
  Future<void> delete(String id) => _store.delete(id);

  Future<List<AuditLog>> all() async {
    final items = await _store.all();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<List<AuditLog>> findByUserId(String userId) async {
    final items = await _store.all();
    return items.where((l) => l.userId == userId).toList();
  }

  Future<List<AuditLog>> findByEntity(String entityType, String entityId) async {
    final items = await _store.all();
    return items.where((l) => l.entityType == entityType && l.entityId == entityId).toList();
  }
}

class QueueEntryRepository {
  QueueEntryRepository(AppDatabase db)
      : _store = _Store(db, 'queue_entries', QueueEntry.fromMap, (q) => q.toMap());

  final _Store<QueueEntry> _store;

  Future<void> save(QueueEntry entry) => _store.put(entry.id, entry);
  Future<void> delete(String id) => _store.delete(id);

  Future<List<QueueEntry>> all() async {
    final items = await _store.all();
    items.sort((a, b) => a.queueNumber.compareTo(b.queueNumber));
    return items;
  }

  Future<List<QueueEntry>> findByDoctorId(String doctorId) async {
    final items = await _store.all();
    return items.where((q) => q.doctorId == doctorId).toList();
  }

  Future<QueueEntry?> findActiveByPatientId(String patientId) async {
    final items = await _store.all();
    for (final item in items) {
      if (item.patientId == patientId &&
          (item.status == QueueStatus.waiting ||
              item.status == QueueStatus.called ||
              item.status == QueueStatus.inProgress)) {
        return item;
      }
    }
    return null;
  }
}

class AppNotificationRepository {
  AppNotificationRepository(AppDatabase db)
      : _store = _Store(db, 'notifications', AppNotification.fromMap, (n) => n.toMap());

  final _Store<AppNotification> _store;

  Future<void> save(AppNotification notification) => _store.put(notification.id, notification);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<AppNotification>> all() => _store.all();

  Future<List<AppNotification>> findByRecipientId(String recipientId) async {
    final items = await _store.all();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items.where((n) => n.recipientId == recipientId).toList();
  }

  Future<List<AppNotification>> findUnreadByRecipientId(String recipientId) async {
    final items = await _store.all();
    return items.where((n) => n.recipientId == recipientId && !n.isRead).toList();
  }
}

class ReportRepository {
  ReportRepository(AppDatabase db)
      : _store = _Store(db, 'reports', Report.fromMap, (r) => r.toMap());

  final _Store<Report> _store;

  Future<void> save(Report report) => _store.put(report.id, report);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<Report>> all() => _store.all();
}

class BackupRecordRepository {
  BackupRecordRepository(AppDatabase db)
      : _store = _Store(db, 'backup_records', BackupRecord.fromMap, (b) => b.toMap());

  final _Store<BackupRecord> _store;

  Future<void> save(BackupRecord record) => _store.put(record.id, record);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<BackupRecord>> all() => _store.all();
}
