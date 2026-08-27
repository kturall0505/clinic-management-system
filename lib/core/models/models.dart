import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum UserRole { admin, doctor, receptionist, patient }

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.doctor:
        return 'Həkim';
      case UserRole.receptionist:
        return 'Resepşn';
      case UserRole.patient:
        return 'Pasient';
    }
  }
}

class AppUser {
  final String id;
  final String username;
  final String passwordHash;
  final String salt;
  final UserRole role;
  final String fullName;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.salt,
    required this.role,
    required this.fullName,
    required this.createdAt,
  });

  factory AppUser.create({
    String? id,
    required String username,
    required String passwordHash,
    required String salt,
    required UserRole role,
    required String fullName,
  }) {
    final trimmedUsername = username.trim();
    final trimmedFullName = fullName.trim();
    if (trimmedUsername.isEmpty) {
      throw ArgumentError('İstifadəçi adı boş ola bilməz');
    }
    if (trimmedFullName.isEmpty) {
      throw ArgumentError('Ad Soyad boş ola bilməz');
    }
    return AppUser(
      id: id ?? _uuid.v4(),
      username: trimmedUsername,
      passwordHash: passwordHash,
      salt: salt,
      role: role,
      fullName: trimmedFullName,
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'username': username,
        'passwordHash': passwordHash,
        'salt': salt,
        'role': role.name,
        'fullName': fullName,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromMap(Map<String, Object?> map) {
    final roleStr = map['role'] as String? ?? 'patient';
    return AppUser(
      id: map['id'] as String,
      username: map['username'] as String,
      passwordHash: map['passwordHash'] as String,
      salt: map['salt'] as String,
      role: UserRole.values.byName(roleStr),
      fullName: map['fullName'] as String,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  AppUser copyWith({
    String? username,
    String? passwordHash,
    String? salt,
    UserRole? role,
    String? fullName,
  }) {
    return AppUser(
      id: id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt,
    );
  }
}

class Patient {
  final String id;
  final String fullName;
  final DateTime birthDate;
  final String phone;
  final String? fin;
  final String? allergies;
  final String? chronicConditions;
  final String? notes;
  final DateTime createdAt;

  const Patient({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.phone,
    this.fin,
    this.allergies,
    this.chronicConditions,
    this.notes,
    required this.createdAt,
  });

  factory Patient.create({
    String? id,
    required String fullName,
    required DateTime birthDate,
    required String phone,
    String? fin,
    String? allergies,
    String? chronicConditions,
    String? notes,
  }) {
    final trimmedName = fullName.trim();
    final trimmedPhone = phone.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Pasientin adı boş ola bilməz');
    }
    if (trimmedPhone.isEmpty) {
      throw ArgumentError('Telefon nömrəsi boş ola bilməz');
    }
    if (birthDate.isAfter(DateTime.now())) {
      throw ArgumentError('Doğum tarixi gələcəkdə ola bilməz');
    }
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    if (age > 120) {
      throw ArgumentError('Doğum tarixi çox köhnədir');
    }
    return Patient(
      id: id ?? _uuid.v4(),
      fullName: trimmedName,
      birthDate: birthDate,
      phone: trimmedPhone,
      fin: fin?.trim().isEmpty == true ? null : fin?.trim(),
      allergies: allergies?.trim().isEmpty == true ? null : allergies?.trim(),
      chronicConditions: chronicConditions?.trim().isEmpty == true ? null : chronicConditions?.trim(),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      createdAt: now,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'fullName': fullName,
        'birthDate': birthDate.toIso8601String(),
        'phone': phone,
        'fin': fin,
        'allergies': allergies,
        'chronicConditions': chronicConditions,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Patient.fromMap(Map<String, Object?> map) {
    return Patient(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      birthDate: DateTime.parse(map['birthDate'] as String),
      phone: map['phone'] as String,
      fin: map['fin'] as String?,
      allergies: map['allergies'] as String?,
      chronicConditions: map['chronicConditions'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Patient copyWith({
    String? fullName,
    DateTime? birthDate,
    String? phone,
    String? fin,
    String? allergies,
    String? chronicConditions,
    String? notes,
  }) {
    return Patient(
      id: id,
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      fin: fin ?? this.fin,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  int get age {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

class Doctor {
  final String id;
  final String fullName;
  final String specialty;
  final String phone;
  final double consultationFee;
  final String? schedule;
  final String? experience;
  final DateTime createdAt;

  const Doctor({
    required this.id,
    required this.fullName,
    required this.specialty,
    required this.phone,
    required this.consultationFee,
    this.schedule,
    this.experience,
    required this.createdAt,
  });

  factory Doctor.create({
    String? id,
    required String fullName,
    required String specialty,
    required String phone,
    required double consultationFee,
    String? schedule,
    String? experience,
  }) {
    final trimmedName = fullName.trim();
    final trimmedSpecialty = specialty.trim();
    final trimmedPhone = phone.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Həkimin adı boş ola bilməz');
    }
    if (trimmedSpecialty.isEmpty) {
      throw ArgumentError('İxtisas boş ola bilməz');
    }
    if (trimmedPhone.isEmpty) {
      throw ArgumentError('Telefon nömrəsi boş ola bilməz');
    }
    if (consultationFee < 0) {
      throw ArgumentError('Konsultasiya haqqı mənfi ola bilməz');
    }
    return Doctor(
      id: id ?? _uuid.v4(),
      fullName: trimmedName,
      specialty: trimmedSpecialty,
      phone: trimmedPhone,
      consultationFee: consultationFee,
      schedule: schedule?.trim().isEmpty == true ? null : schedule?.trim(),
      experience: experience?.trim().isEmpty == true ? null : experience?.trim(),
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'fullName': fullName,
        'specialty': specialty,
        'phone': phone,
        'consultationFee': consultationFee,
        'schedule': schedule,
        'experience': experience,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Doctor.fromMap(Map<String, Object?> map) {
    return Doctor(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      specialty: map['specialty'] as String,
      phone: map['phone'] as String,
      consultationFee: (map['consultationFee'] as num?)?.toDouble() ?? 0.0,
      schedule: map['schedule'] as String?,
      experience: map['experience'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Doctor copyWith({
    String? fullName,
    String? specialty,
    String? phone,
    double? consultationFee,
    String? schedule,
    String? experience,
  }) {
    return Doctor(
      id: id,
      fullName: fullName ?? this.fullName,
      specialty: specialty ?? this.specialty,
      phone: phone ?? this.phone,
      consultationFee: consultationFee ?? this.consultationFee,
      schedule: schedule ?? this.schedule,
      experience: experience ?? this.experience,
      createdAt: createdAt,
    );
  }
}

enum AppointmentStatus { scheduled, completed, cancelled, noShow }

extension AppointmentStatusExtension on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'Planlaşdırılıb';
      case AppointmentStatus.completed:
        return 'Tamamlanıb';
      case AppointmentStatus.cancelled:
        return 'Ləğv edilib';
      case AppointmentStatus.noShow:
        return 'Gəlməyib';
    }
  }
}

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String? reason;
  final String? notes;
  final DateTime createdAt;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    this.status = AppointmentStatus.scheduled,
    this.reason,
    this.notes,
    required this.createdAt,
  });

  factory Appointment.create({
    String? id,
    required String patientId,
    required String doctorId,
    required DateTime dateTime,
    AppointmentStatus status = AppointmentStatus.scheduled,
    String? reason,
    String? notes,
  }) {
    final trimmedPatientId = patientId.trim();
    final trimmedDoctorId = doctorId.trim();
    if (trimmedPatientId.isEmpty) {
      throw ArgumentError('Pasient ID-si boş ola bilməz');
    }
    if (trimmedDoctorId.isEmpty) {
      throw ArgumentError('Həkim ID-si boş ola bilməz');
    }
    if (dateTime.isBefore(DateTime.now().subtract(const Duration(minutes: 5)))) {
      throw ArgumentError('Randevu vaxtı keçmişdə ola bilməz');
    }
    return Appointment(
      id: id ?? _uuid.v4(),
      patientId: trimmedPatientId,
      doctorId: trimmedDoctorId,
      dateTime: dateTime,
      status: status,
      reason: reason?.trim().isEmpty == true ? null : reason?.trim(),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'patientId': patientId,
        'doctorId': doctorId,
        'dateTime': dateTime.toIso8601String(),
        'status': status.name,
        'reason': reason,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Appointment.fromMap(Map<String, Object?> map) {
    final statusStr = map['status'] as String? ?? 'scheduled';
    return Appointment(
      id: map['id'] as String,
      patientId: map['patientId'] as String,
      doctorId: map['doctorId'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      status: AppointmentStatus.values.byName(statusStr),
      reason: map['reason'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Appointment copyWith({
    String? patientId,
    String? doctorId,
    DateTime? dateTime,
    AppointmentStatus? status,
    String? reason,
    String? notes,
  }) {
    return Appointment(
      id: id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

class Prescription {
  final String id;
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final String medications;
  final String? diagnosis;
  final String? notes;
  final DateTime createdAt;

  const Prescription({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.medications,
    this.diagnosis,
    this.notes,
    required this.createdAt,
  });

  factory Prescription.create({
    String? id,
    required String appointmentId,
    required String patientId,
    required String doctorId,
    required String medications,
    String? diagnosis,
    String? notes,
  }) {
    final trimmedAppointmentId = appointmentId.trim();
    final trimmedPatientId = patientId.trim();
    final trimmedDoctorId = doctorId.trim();
    final trimmedMeds = medications.trim();
    if (trimmedAppointmentId.isEmpty) {
      throw ArgumentError('Randevu ID-si boş ola bilməz');
    }
    if (trimmedPatientId.isEmpty) {
      throw ArgumentError('Pasient ID-si boş ola bilməz');
    }
    if (trimmedDoctorId.isEmpty) {
      throw ArgumentError('Həkim ID-si boş ola bilməz');
    }
    if (trimmedMeds.isEmpty) {
      throw ArgumentError('Dərmanlar siyahısı boş ola bilməz');
    }
    return Prescription(
      id: id ?? _uuid.v4(),
      appointmentId: trimmedAppointmentId,
      patientId: trimmedPatientId,
      doctorId: trimmedDoctorId,
      medications: trimmedMeds,
      diagnosis: diagnosis?.trim().isEmpty == true ? null : diagnosis?.trim(),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'appointmentId': appointmentId,
        'patientId': patientId,
        'doctorId': doctorId,
        'medications': medications,
        'diagnosis': diagnosis,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Prescription.fromMap(Map<String, Object?> map) {
    return Prescription(
      id: map['id'] as String,
      appointmentId: map['appointmentId'] as String,
      patientId: map['patientId'] as String,
      doctorId: map['doctorId'] as String,
      medications: map['medications'] as String,
      diagnosis: map['diagnosis'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Prescription copyWith({
    String? medications,
    String? diagnosis,
    String? notes,
  }) {
    return Prescription(
      id: id,
      appointmentId: appointmentId,
      patientId: patientId,
      doctorId: doctorId,
      medications: medications ?? this.medications,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

class Payment {
  final String id;
  final String appointmentId;
  final String patientId;
  final double amount;
  final String method;
  final String status;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  factory Payment.create({
    String? id,
    required String appointmentId,
    required String patientId,
    required double amount,
    required String method,
    String status = 'pending',
  }) {
    final trimmedAppointmentId = appointmentId.trim();
    final trimmedPatientId = patientId.trim();
    final trimmedMethod = method.trim();
    if (trimmedAppointmentId.isEmpty) {
      throw ArgumentError('Randevu ID-si boş ola bilməz');
    }
    if (trimmedPatientId.isEmpty) {
      throw ArgumentError('Pasient ID-si boş ola bilməz');
    }
    if (trimmedMethod.isEmpty) {
      throw ArgumentError('Ödəniş üsulu boş ola bilməz');
    }
    if (amount < 0) {
      throw ArgumentError('Məbləğ mənfi ola bilməz');
    }
    final validStatuses = {'pending', 'completed', 'failed', 'refunded'};
    if (!validStatuses.contains(status)) {
      throw ArgumentError('Yanlış ödəniş statusu: $status');
    }
    return Payment(
      id: id ?? _uuid.v4(),
      appointmentId: trimmedAppointmentId,
      patientId: trimmedPatientId,
      amount: amount,
      method: trimmedMethod,
      status: status,
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'appointmentId': appointmentId,
        'patientId': patientId,
        'amount': amount,
        'method': method,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Payment.fromMap(Map<String, Object?> map) {
    return Payment(
      id: map['id'] as String,
      appointmentId: map['appointmentId'] as String,
      patientId: map['patientId'] as String,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      method: map['method'] as String,
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Payment copyWith({
    double? amount,
    String? method,
    String? status,
  }) {
    return Payment(
      id: id,
      appointmentId: appointmentId,
      patientId: patientId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
