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
  final String? allergies;
  final String? chronicConditions;
  final String? notes;

  Patient({
    String? id,
    required this.fullName,
    required this.birthDate,
    required this.phone,
    this.allergies,
    this.chronicConditions,
    this.notes,
  }) : id = id ?? _uuid.v4();

  Map<String, Object?> toMap() => {
        'id': id,
        'fullName': fullName,
        'birthDate': birthDate.toIso8601String(),
        'phone': phone,
        'allergies': allergies,
        'chronicConditions': chronicConditions,
        'notes': notes,
      };

  factory Patient.fromMap(Map<String, Object?> map) => Patient(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        birthDate: DateTime.parse(map['birthDate'] as String),
        phone: map['phone'] as String,
        allergies: map['allergies'] as String?,
        chronicConditions: map['chronicConditions'] as String?,
        notes: map['notes'] as String?,
      );
}

class Doctor {
  final String id;
  final String fullName;
  final String specialty;
  final String phone;
  final double consultationFee;
  final String? schedule;

  Doctor({
    String? id,
    required this.fullName,
    required this.specialty,
    required this.phone,
    required this.consultationFee,
    this.schedule,
  }) : id = id ?? _uuid.v4();

  Map<String, Object?> toMap() => {
        'id': id,
        'fullName': fullName,
        'specialty': specialty,
        'phone': phone,
        'consultationFee': consultationFee,
        'schedule': schedule,
      };

  factory Doctor.fromMap(Map<String, Object?> map) => Doctor(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        specialty: map['specialty'] as String,
        phone: map['phone'] as String,
        consultationFee: (map['consultationFee'] as num).toDouble(),
        schedule: map['schedule'] as String?,
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

  Appointment({
    String? id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    this.status = AppointmentStatus.scheduled,
    this.reason,
  }) : id = id ?? _uuid.v4();

  Appointment copyWith({AppointmentStatus? status}) => Appointment(
        id: id,
        patientId: patientId,
        doctorId: doctorId,
        dateTime: dateTime,
        status: status ?? this.status,
        reason: reason,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'patientId': patientId,
        'doctorId': doctorId,
        'dateTime': dateTime.toIso8601String(),
        'status': status.name,
        'reason': reason,
      };

  factory Appointment.fromMap(Map<String, Object?> map) => Appointment(
        id: map['id'] as String,
        patientId: map['patientId'] as String,
        doctorId: map['doctorId'] as String,
        dateTime: DateTime.parse(map['dateTime'] as String),
        status: AppointmentStatus.values.byName(map['status'] as String),
        reason: map['reason'] as String?,
      );
}
