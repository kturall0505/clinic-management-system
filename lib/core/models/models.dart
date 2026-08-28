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
  final DateTime createdAt;

  AppUser({
    String? id,
    required this.username,
    required this.passwordHash,
    required this.salt,
    required this.role,
    required this.fullName,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, Object?> toMap() => {
        'id': id,
        'username': username,
        'passwordHash': passwordHash,
        'salt': salt,
        'role': role.name,
        'fullName': fullName,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
        id: map['id'] as String,
        username: map['username'] as String,
        passwordHash: map['passwordHash'] as String,
        salt: map['salt'] as String,
        role: UserRole.values.byName(map['role'] as String),
        fullName: map['fullName'] as String,
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

class Patient {
  final String id;
  final String fullName;
  final DateTime birthDate;
  final String phone;
  final String? allergies;
  final String? chronicConditions;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    String? id,
    required this.fullName,
    required this.birthDate,
    required this.phone,
    this.allergies,
    this.chronicConditions,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Patient copyWith({
    String? fullName,
    DateTime? birthDate,
    String? phone,
    String? allergies,
    String? chronicConditions,
    String? notes,
  }) =>
      Patient(
        id: id,
        fullName: fullName ?? this.fullName,
        birthDate: birthDate ?? this.birthDate,
        phone: phone ?? this.phone,
        allergies: allergies ?? this.allergies,
        chronicConditions: chronicConditions ?? this.chronicConditions,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'fullName': fullName,
        'birthDate': birthDate.toIso8601String(),
        'phone': phone,
        'allergies': allergies,
        'chronicConditions': chronicConditions,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Patient.fromMap(Map<String, Object?> map) => Patient(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        birthDate: DateTime.parse(map['birthDate'] as String),
        phone: map['phone'] as String,
        allergies: map['allergies'] as String?,
        chronicConditions: map['chronicConditions'] as String?,
        notes: map['notes'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'] as String)
            : null,
        updatedAt: map['updatedAt'] != null
            ? DateTime.tryParse(map['updatedAt'] as String)
            : null,
      );
}

class Doctor {
  final String id;
  final String fullName;
  final String specialty;
  final String phone;
  final double consultationFee;
  final String? schedule;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    String? id,
    required this.fullName,
    required this.specialty,
    required this.phone,
    required this.consultationFee,
    this.schedule,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Doctor copyWith({
    String? fullName,
    String? specialty,
    String? phone,
    double? consultationFee,
    String? schedule,
  }) =>
      Doctor(
        id: id,
        fullName: fullName ?? this.fullName,
        specialty: specialty ?? this.specialty,
        phone: phone ?? this.phone,
        consultationFee: consultationFee ?? this.consultationFee,
        schedule: schedule ?? this.schedule,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'fullName': fullName,
        'specialty': specialty,
        'phone': phone,
        'consultationFee': consultationFee,
        'schedule': schedule,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Doctor.fromMap(Map<String, Object?> map) => Doctor(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        specialty: map['specialty'] as String,
        phone: map['phone'] as String,
        consultationFee: (map['consultationFee'] as num).toDouble(),
        schedule: map['schedule'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'] as String)
            : null,
        updatedAt: map['updatedAt'] != null
            ? DateTime.tryParse(map['updatedAt'] as String)
            : null,
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
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    String? id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    this.status = AppointmentStatus.scheduled,
    this.reason,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Appointment copyWith({
    String? patientId,
    String? doctorId,
    DateTime? dateTime,
    AppointmentStatus? status,
    String? reason,
  }) =>
      Appointment(
        id: id,
        patientId: patientId ?? this.patientId,
        doctorId: doctorId ?? this.doctorId,
        dateTime: dateTime ?? this.dateTime,
        status: status ?? this.status,
        reason: reason ?? this.reason,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'patientId': patientId,
        'doctorId': doctorId,
        'dateTime': dateTime.toIso8601String(),
        'status': status.name,
        'reason': reason,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Appointment.fromMap(Map<String, Object?> map) => Appointment(
        id: map['id'] as String,
        patientId: map['patientId'] as String,
        doctorId: map['doctorId'] as String,
        dateTime: DateTile.parse(map['dateTime'] as String),
        status:
            AppointmentStatus.values.byName(map['status'] as String),
        reason: map['reason'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'] as String)
            : null,
        updatedAt: map['updatedAt'] != null
            ? DateTime.tryParse(map['updatedAt'] as String)
            : null,
      );
}