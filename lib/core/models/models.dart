import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum UserRole { admin, doctor, receptionist, patient }

class AppUser {
  final String id;
  final String username;
  final String passwordHash;
  final String salt;
  final UserRole role;
  final String fullName;

  AppUser({
    String? id,
    required this.username,
    required this.passwordHash,
    required this.salt,
    required this.role,
    required this.fullName,
  }) : id = id ?? _uuid.v4();

  Map<String, Object?> toMap() => {
        'id': id,
        'username': username,
        'passwordHash': passwordHash,
        'salt': salt,
        'role': role.name,
        'fullName': fullName,
      };

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
        id: map['id'] as String,
        username: map['username'] as String,
        passwordHash: map['passwordHash'] as String,
        salt: map['salt'] as String,
        role: UserRole.values.byName(map['role'] as String),
        fullName: map['fullName'] as String,
      );
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

  Patient({
    String? id,
    required this.fullName,
    required this.birthDate,
    required this.phone,
    this.fin,
    this.allergies,
    this.chronicConditions,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

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

  factory Patient.fromMap(Map<String, Object?> map) => Patient(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        birthDate: DateTime.parse(map['birthDate'] as String),
        phone: map['phone'] as String,
        fin: map['fin'] as String?,
        allergies: map['allergies'] as String?,
        chronicConditions: map['chronicConditions'] as String?,
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
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

  Doctor({
    String? id,
    required this.fullName,
    required this.specialty,
    required this.phone,
    required this.consultationFee,
    this.schedule,
    this.experience,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

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

  factory Doctor.fromMap(Map<String, Object?> map) => Doctor(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        specialty: map['specialty'] as String,
        phone: map['phone'] as String,
        consultationFee: (map['consultationFee'] as num).toDouble(),
        schedule: map['schedule'] as String?,
        experience: map['experience'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

enum AppointmentStatus { scheduled, completed, cancelled, noShow }

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String? reason;
  final String? notes;
  final DateTime createdAt;

  Appointment({
    String? id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    this.status = AppointmentStatus.scheduled,
    this.reason,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  Appointment copyWith({AppointmentStatus? status}) => Appointment(
        id: id,
        patientId: patientId,
        doctorId: doctorId,
        dateTime: dateTime,
        status: status ?? this.status,
        reason: reason,
        notes: notes,
        createdAt: createdAt,
      );

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

  factory Appointment.fromMap(Map<String, Object?> map) => Appointment(
        id: map['id'] as String,
        patientId: map['patientId'] as String,
        doctorId: map['doctorId'] as String,
        dateTime: DateTime.parse(map['dateTime'] as String),
        status: AppointmentStatus.values.byName(map['status'] as String),
        reason: map['reason'] as String?,
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
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

  Prescription({
    String? id,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.medications,
    this.diagnosis,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

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

  factory Prescription.fromMap(Map<String, Object?> map) => Prescription(
        id: map['id'] as String,
        appointmentId: map['appointmentId'] as String,
        patientId: map['patientId'] as String,
        doctorId: map['doctorId'] as String,
        medications: map['medications'] as String,
        diagnosis: map['diagnosis'] as String?,
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

class Payment {
  final String id;
  final String appointmentId;
  final String patientId;
  final double amount;
  final String method;
  final String status;
  final DateTime createdAt;

  Payment({
    String? id,
    required this.appointmentId,
    required this.patientId,
    required this.amount,
    required this.method,
    this.status = 'pending',
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, Object?> toMap() => {
        'id': id,
        'appointmentId': appointmentId,
        'patientId': patientId,
        'amount': amount,
        'method': method,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Payment.fromMap(Map<String, Object?> map) => Payment(
        id: map['id'] as String,
        appointmentId: map['appointmentId'] as String,
        patientId: map['patientId'] as String,
        amount: (map['amount'] as num).toDouble(),
        method: map['method'] as String,
        status: map['status'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
