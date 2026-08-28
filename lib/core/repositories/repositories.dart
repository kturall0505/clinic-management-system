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

  Future<List<T>> find(Finder finder) async {
    final records = await store.find(db.db, finder: finder);
    return records.map((r) => fromMap(r.value)).toList();
  }
}

class PatientRepository {
  PatientRepository(AppDatabase db)
      : _store = _Store(db, 'patients', Patient.fromMap, (p) => p.toMap());

  final _Store<Patient> _store;

  Future<void> save(Patient patient) => _store.put(patient.id, patient);
  Future<void> delete(String id) => _store.delete(id);

  Future<List<Patient>> all({String? clinicId, int? userLevel}) async {
    if (userLevel != null && userLevel < 100 && clinicId != null) {
      return _store.find(Finder(
        filter: Filter.startsWith('id', clinicId),
      ));
    }
    return _store.all();
  }
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
    final results = await _store.find(Finder(
      filter: Filter.equals('username', username),
      limit: 1,
    ));
    return results.isEmpty ? null : results.first;
  }

  Future<List<AppUser>> findByClinicId(String clinicId) async {
    return _store.find(Finder(
      filter: Filter.equals('clinicId', clinicId),
    ));
  }

  Future<List<AppUser>> findSuperAdmins() async {
    return _store.find(Finder(
      filter: Filter.greaterThanOrEquals('role_level', 100),
    ));
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
    final results = await _store.find(Finder(
      filter: Filter.equals('patientId', patientId),
      limit: 1,
    ));
    return results.isEmpty ? null : results.first;
  }
}

class MedicalVisitRepository {
  MedicalVisitRepository(AppDatabase db)
      : _store = _Store(db, 'medical_visits', MedicalVisit.fromMap, (v) => v.toMap());

  final _Store<MedicalVisit> _store;

  Future<void> save(MedicalVisit visit) => _store.put(visit.id, visit);
  Future<void> delete(String id) => _store.delete(id);

  Future<List<MedicalVisit>> all() async {
    final items = await _store.find(Finder(
      sortOrders: [SortOrder('visitDate', false)],
    ));
    return items;
  }

  Future<List<MedicalVisit>> findByPatientId(String patientId) async {
    return _store.find(Finder(
      filter: Filter.equals('patientId', patientId),
      sortOrders: [SortOrder('visitDate', false)],
    ));
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
    final results = await _store.find(Finder(
      filter: Filter.equals('name', name),
      limit: 1,
    ));
    return results.isEmpty ? null : results.first;
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
    return _store.find(Finder(
      filter: Filter.equals('prescriptionId', prescriptionId),
    ));
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
    return _store.find(Finder(
      filter: Filter.equals('invoiceId', invoiceId),
    ));
  }
}

class AuditLogRepository {
  AuditLogRepository(AppDatabase db)
      : _store = _Store(db, 'audit_logs', AuditLog.fromMap, (a) => a.toMap());

  final _Store<AuditLog> _store;

  Future<void> save(AuditLog log) => _store.put(log.id, log);
  Future<void> delete(String id) => _store.delete(id);

  Future<List<AuditLog>> all() async {
    return _store.find(Finder(
      sortOrders: [SortOrder('createdAt', false)],
    ));
  }

  Future<List<AuditLog>> findByUserId(String userId) async {
    return _store.find(Finder(
      filter: Filter.equals('userId', userId),
      sortOrders: [SortOrder('createdAt', false)],
    ));
  }

  Future<List<AuditLog>> findByEntity(String entityType, String entityId) async {
    return _store.find(Finder(
      filter: Filter.and([
        Filter.equals('entityType', entityType),
        Filter.equals('entityId', entityId),
      ]),
      sortOrders: [SortOrder('createdAt', false)],
    ));
  }
}

class QueueEntryRepository {
  QueueEntryRepository(AppDatabase db)
      : _store = _Store(db, 'queue_entries', QueueEntry.fromMap, (q) => q.toMap());

  final _Store<QueueEntry> _store;

  Future<void> save(QueueEntry entry) => _store.put(entry.id, entry);
  Future<void> delete(String id) => _store.delete(id);

  Future<List<QueueEntry>> all() async {
    return _store.find(Finder(
      sortOrders: [SortOrder('queueNumber', true)],
    ));
  }

  Future<List<QueueEntry>> findByDoctorId(String doctorId) async {
    return _store.find(Finder(
      filter: Filter.equals('doctorId', doctorId),
      sortOrders: [SortOrder('queueNumber', true)],
    ));
  }

  Future<QueueEntry?> findById(String id) async {
    final results = await _store.find(Finder(
      filter: Filter.equals('id', id),
      limit: 1,
    ));
    return results.isEmpty ? null : results.first;
  }

  Future<QueueEntry?> findActiveByPatientId(String patientId) async {
    final results = await _store.find(Finder(
      filter: Filter.and([
        Filter.equals('patientId', patientId),
        Filter.inList('status', ['waiting', 'called', 'inProgress']),
      ]),
      limit: 1,
    ));
    return results.isEmpty ? null : results.first;
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
    return _store.find(Finder(
      filter: Filter.equals('recipientId', recipientId),
      sortOrders: [SortOrder('createdAt', false)],
    ));
  }

  Future<List<AppNotification>> findUnreadByRecipientId(String recipientId) async {
    return _store.find(Finder(
      filter: Filter.and([
        Filter.equals('recipientId', recipientId),
        Filter.equals('isRead', false),
      ]),
      sortOrders: [SortOrder('createdAt', false)],
    ));
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

class ClinicRepository {
  ClinicRepository(AppDatabase db)
      : _store = _Store(db, 'clinics', Clinic.fromMap, (c) => c.toMap());

  final _Store<Clinic> _store;

  Future<void> save(Clinic clinic) => _store.put(clinic.id, clinic);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<Clinic>> all() => _store.all();

  Future<Clinic?> findById(String id) async {
    final results = await _store.find(Finder(
      filter: Filter.equals('id', id),
      limit: 1,
    ));
    return results.isEmpty ? null : results.first;
  }

  Future<List<Clinic>> findPending() async {
    return _store.find(Finder(
      filter: Filter.equals('status', 'pending'),
    ));
  }

  Future<List<Clinic>> findActive() async {
    return _store.find(Finder(
      filter: Filter.equals('status', 'active'),
    ));
  }
}

class ApprovalRepository {
  ApprovalRepository(AppDatabase db)
      : _store = _Store(db, 'approvals', ApprovalRequest.fromMap, (a) => a.toMap());

  final _Store<ApprovalRequest> _store;

  Future<void> save(ApprovalRequest request) => _store.put(request.id, request);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<ApprovalRequest>> all() => _store.all();

  Future<List<ApprovalRequest>> findPending() async {
    return _store.find(Finder(
      filter: Filter.equals('status', 'pending'),
      sortOrders: [SortOrder('createdAt', true)],
    ));
  }

  Future<List<ApprovalRequest>> findByClinicId(String clinicId) async {
    return _store.find(Finder(
      filter: Filter.equals('clinicId', clinicId),
      sortOrders: [SortOrder('createdAt', false)],
    ));
  }
}

enum ApprovalStatus { pending, approved, rejected }

class ApprovalRequest {
  final String id;
  final String clinicId;
  final String requestedBy;
  final ApprovalType type;
  final Map<String, Object?> changes;
  final ApprovalStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNote;
  final DateTime createdAt;

  const ApprovalRequest({
    required this.id,
    required this.clinicId,
    required this.requestedBy,
    required this.type,
    required this.changes,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNote,
    required this.createdAt,
  });

  factory ApprovalRequest.create({
    String? id,
    required String clinicId,
    required String requestedBy,
    required ApprovalType type,
    required Map<String, Object?> changes,
    ApprovalStatus status = ApprovalStatus.pending,
  }) {
    return ApprovalRequest(
      id: id ?? _uuid.v4(),
      clinicId: clinicId,
      requestedBy: requestedBy,
      type: type,
      changes: changes,
      status: status,
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'clinicId': clinicId,
        'requestedBy': requestedBy,
        'type': type.name,
        'changes': changes,
        'status': status.name,
        'reviewedBy': reviewedBy,
        'reviewedAt': reviewedAt?.toIso8601String(),
        'reviewNote': reviewNote,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ApprovalRequest.fromMap(Map<String, Object?> map) {
    final typeStr = map['type'] as String? ?? 'clinic_settings';
    final statusStr = map['status'] as String? ?? 'pending';
    return ApprovalRequest(
      id: map['id'] as String,
      clinicId: map['clinicId'] as String,
      requestedBy: map['requestedBy'] as String,
      type: ApprovalType.values.byName(typeStr),
      changes: Map<String, Object?>.from(map['changes'] as Map? ?? {}),
      status: ApprovalStatus.values.byName(statusStr),
      reviewedBy: map['reviewedBy'] as String?,
      reviewedAt: map['reviewedAt'] == null ? null : DateTime.tryParse(map['reviewedAt'] as String),
      reviewNote: map['reviewNote'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  ApprovalRequest copyWith({
    String? clinicId,
    String? requestedBy,
    ApprovalType? type,
    Map<String, Object?>? changes,
    ApprovalStatus? status,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? reviewNote,
  }) {
    return ApprovalRequest(
      id: id,
      clinicId: clinicId ?? this.clinicId,
      requestedBy: requestedBy ?? this.requestedBy,
      type: type ?? this.type,
      changes: changes ?? this.changes,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNote: reviewNote ?? this.reviewNote,
      createdAt: createdAt,
    );
  }
}

enum ApprovalType { clinicSettings, userRoleChange, subscriptionChange, clinicDeletion }

class TwoFactorRepository {
  TwoFactorRepository(AppDatabase db)
      : _store = _Store(db, 'two_factor', TwoFactorSecret.fromMap, (t) => t.toMap());

  final _Store<TwoFactorSecret> _store;

  Future<void> save(TwoFactorSecret secret) => _store.put(secret.userId, secret);
  Future<void> delete(String userId) => _store.delete(userId);
  Future<TwoFactorSecret?> findByUserId(String userId) async {
    final items = await _store.all();
    return items.where((t) => t.userId == userId).firstOrNull;
  }
}

class TwoFactorSecret {
  final String userId;
  final String secretKey;
  final bool isEnabled;
  final DateTime? createdAt;
  final DateTime? lastUsed;

  const TwoFactorSecret({
    required this.userId,
    required this.secretKey,
    this.isEnabled = true,
    this.createdAt,
    this.lastUsed,
  });

  factory TwoFactorSecret.create({
    required String userId,
    required String secretKey,
    bool isEnabled = true,
  }) {
    return TwoFactorSecret(
      userId: userId,
      secretKey: secretKey,
      isEnabled: isEnabled,
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'userId': userId,
        'secretKey': secretKey,
        'isEnabled': isEnabled ? 1 : 0,
        'createdAt': createdAt?.toIso8601String(),
        'lastUsed': lastUsed?.toIso8601String(),
      };

  factory TwoFactorSecret.fromMap(Map<String, Object?> map) {
    return TwoFactorSecret(
      userId: map['userId'] as String,
      secretKey: map['secretKey'] as String,
      isEnabled: (map['isEnabled'] as int?) ?? 1 == 1,
      createdAt: map['createdAt'] == null ? null : DateTime.tryParse(map['createdAt'] as String),
      lastUsed: map['lastUsed'] == null ? null : DateTime.tryParse(map['lastUsed'] as String),
    );
  }

  TwoFactorSecret copyWith({
    String? secretKey,
    bool? isEnabled,
    DateTime? lastUsed,
  }) {
    return TwoFactorSecret(
      userId: userId,
      secretKey: secretKey ?? this.secretKey,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}

class IpWhitelistRepository {
  IpWhitelistRepository(AppDatabase db)
      : _store = _Store(db, 'ip_whitelist', IpWhitelistEntry.fromMap, (i) => i.toMap());

  final _Store<IpWhitelistEntry> _store;

  Future<void> save(IpWhitelistEntry entry) => _store.put(entry.id, entry);
  Future<void> delete(String id) => _store.delete(id);
  Future<List<IpWhitelistEntry>> all() => _store.all();

  Future<IpWhitelistEntry?> findByIp(String ip) async {
    final items = await _store.all();
    return items.where((i) => i.ipAddress == ip).firstOrNull;
  }

  Future<bool> isAllowed(String ip) async {
    final entries = await _store.all();
    return entries.any((e) => e.ipAddress == ip && e.isActive);
  }
}

class IpWhitelistEntry {
  final String id;
  final String ipAddress;
  final String label;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;

  const IpWhitelistEntry({
    required this.id,
    required this.ipAddress,
    required this.label,
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
  });

  factory IpWhitelistEntry.create({
    String? id,
    required String ipAddress,
    required String label,
    bool isActive = true,
    String? createdBy,
  }) {
    return IpWhitelistEntry(
      id: id ?? _uuid.v4(),
      ipAddress: ipAddress,
      label: label,
      isActive: isActive,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'ipAddress': ipAddress,
        'label': label,
        'isActive': isActive ? 1 : 0,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory IpWhitelistEntry.fromMap(Map<String, Object?> map) {
    return IpWhitelistEntry(
      id: map['id'] as String,
      ipAddress: map['ipAddress'] as String,
      label: map['label'] as String,
      isActive: (map['isActive'] as int?) ?? 1 == 1,
      createdBy: map['createdBy'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  IpWhitelistEntry copyWith({
    String? ipAddress,
    String? label,
    bool? isActive,
    String? createdBy,
  }) {
    return IpWhitelistEntry(
      id: id,
      ipAddress: ipAddress ?? this.ipAddress,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt,
    );
  }
}
