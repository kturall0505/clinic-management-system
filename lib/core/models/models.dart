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

enum BloodType { aPositive, aNegative, bPositive, bNegative, abPositive, abNegative, oPositive, oNegative }

extension BloodTypeExtension on BloodType {
  String get label {
    switch (this) {
      case BloodType.aPositive:
        return 'A+';
      case BloodType.aNegative:
        return 'A-';
      case BloodType.bPositive:
        return 'B+';
      case BloodType.bNegative:
        return 'B-';
      case BloodType.abPositive:
        return 'AB+';
      case BloodType.abNegative:
        return 'AB-';
      case BloodType.oPositive:
        return 'O+';
      case BloodType.oNegative:
        return 'O-';
    }
  }
}

enum Gender { male, female, other }

extension GenderExtension on Gender {
  String get label {
    switch (this) {
      case Gender.male:
        return 'Kişi';
      case Gender.female:
        return 'Qadın';
      case Gender.other:
        return 'Digər';
    }
  }
}

class PatientMedicalInfo {
  final String id;
  final String patientId;
  final Gender? gender;
  final BloodType? bloodType;
  final double? heightCm;
  final double? weightKg;
  final String? emergencyContact;
  final String? emergencyContactPhone;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final DateTime createdAt;

  const PatientMedicalInfo({
    required this.id,
    required this.patientId,
    this.gender,
    this.bloodType,
    this.heightCm,
    this.weightKg,
    this.emergencyContact,
    this.emergencyContactPhone,
    this.insuranceProvider,
    this.insuranceNumber,
    required this.createdAt,
  });

  factory PatientMedicalInfo.create({
    String? id,
    required String patientId,
    Gender? gender,
    BloodType? bloodType,
    double? heightCm,
    double? weightKg,
    String? emergencyContact,
    String? emergencyContactPhone,
    String? insuranceProvider,
    String? insuranceNumber,
  }) {
    final trimmedPatientId = patientId.trim();
    if (trimmedPatientId.isEmpty) {
      throw ArgumentError('Pasient ID-si boş ola bilməz');
    }
    return PatientMedicalInfo(
      id: id ?? _uuid.v4(),
      patientId: trimmedPatientId,
      gender: gender,
      bloodType: bloodType,
      heightCm: heightCm,
      weightKg: weightKg,
      emergencyContact: emergencyContact?.trim().isEmpty == true ? null : emergencyContact?.trim(),
      emergencyContactPhone: emergencyContactPhone?.trim().isEmpty == true ? null : emergencyContactPhone?.trim(),
      insuranceProvider: insuranceProvider?.trim().isEmpty == true ? null : insuranceProvider?.trim(),
      insuranceNumber: insuranceNumber?.trim().isEmpty == true ? null : insuranceNumber?.trim(),
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'patientId': patientId,
        'gender': gender?.name,
        'bloodType': bloodType?.name,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'emergencyContact': emergencyContact,
        'emergencyContactPhone': emergencyContactPhone,
        'insuranceProvider': insuranceProvider,
        'insuranceNumber': insuranceNumber,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PatientMedicalInfo.fromMap(Map<String, Object?> map) {
    return PatientMedicalInfo(
      id: map['id'] as String,
      patientId: map['patientId'] as String,
      gender: map['gender'] != null ? Gender.values.byName(map['gender'] as String) : null,
      bloodType: map['bloodType'] != null ? BloodType.values.byName(map['bloodType'] as String) : null,
      heightCm: (map['heightCm'] as num?)?.toDouble(),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      emergencyContact: map['emergencyContact'] as String?,
      emergencyContactPhone: map['emergencyContactPhone'] as String?,
      insuranceProvider: map['insuranceProvider'] as String?,
      insuranceNumber: map['insuranceNumber'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  double? get bmi {
    if (heightCm == null || weightKg == null || heightCm! <= 0) return null;
    final heightInMeters = heightCm! / 100;
    return weightKg! / (heightInMeters * heightInMeters);
  }
}

class MedicalVisit {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime visitDate;
  final String? diagnosis;
  final String? symptoms;
  final String? treatment;
  final String? notes;
  final DateTime createdAt;

  const MedicalVisit({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.visitDate,
    this.diagnosis,
    this.symptoms,
    this.treatment,
    this.notes,
    required this.createdAt,
  });

  factory MedicalVisit.create({
    String? id,
    required String patientId,
    required String doctorId,
    required DateTime visitDate,
    String? diagnosis,
    String? symptoms,
    String? treatment,
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
    return MedicalVisit(
      id: id ?? _uuid.v4(),
      patientId: trimmedPatientId,
      doctorId: trimmedDoctorId,
      visitDate: visitDate,
      diagnosis: diagnosis?.trim().isEmpty == true ? null : diagnosis?.trim(),
      symptoms: symptoms?.trim().isEmpty == true ? null : symptoms?.trim(),
      treatment: treatment?.trim().isEmpty == true ? null : treatment?.trim(),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'patientId': patientId,
        'doctorId': doctorId,
        'visitDate': visitDate.toIso8601String(),
        'diagnosis': diagnosis,
        'symptoms': symptoms,
        'treatment': treatment,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MedicalVisit.fromMap(Map<String, Object?> map) {
    return MedicalVisit(
      id: map['id'] as String,
      patientId: map['patientId'] as String,
      doctorId: map['doctorId'] as String,
      visitDate: DateTime.parse(map['visitDate'] as String),
      diagnosis: map['diagnosis'] as String?,
      symptoms: map['symptoms'] as String?,
      treatment: map['treatment'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  MedicalVisit copyWith({
    String? diagnosis,
    String? symptoms,
    String? treatment,
    String? notes,
  }) {
    return MedicalVisit(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      visitDate: visitDate,
      diagnosis: diagnosis ?? this.diagnosis,
      symptoms: symptoms ?? this.symptoms,
      treatment: treatment ?? this.treatment,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

class Medication {
  final String id;
  final String name;
  final String? genericName;
  final String? category;
  final String? dosageForm;
  final String? strength;
  final String? manufacturer;
  final bool requiresPrescription;
  final String? sideEffects;
  final String? contraindications;
  final DateTime createdAt;

  const Medication({
    required this.id,
    required this.name,
    this.genericName,
    this.category,
    this.dosageForm,
    this.strength,
    this.manufacturer,
    this.requiresPrescription = true,
    this.sideEffects,
    this.contraindications,
    required this.createdAt,
  });

  factory Medication.create({
    String? id,
    required String name,
    String? genericName,
    String? category,
    String? dosageForm,
    String? strength,
    String? manufacturer,
    bool requiresPrescription = true,
    String? sideEffects,
    String? contraindications,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Dərman adı boş ola bilməz');
    }
    return Medication(
      id: id ?? _uuid.v4(),
      name: trimmedName,
      genericName: genericName?.trim().isEmpty == true ? null : genericName?.trim(),
      category: category?.trim().isEmpty == true ? null : category?.trim(),
      dosageForm: dosageForm?.trim().isEmpty == true ? null : dosageForm?.trim(),
      strength: strength?.trim().isEmpty == true ? null : strength?.trim(),
      manufacturer: manufacturer?.trim().isEmpty == true ? null : manufacturer?.trim(),
      requiresPrescription: requiresPrescription,
      sideEffects: sideEffects?.trim().isEmpty == true ? null : sideEffects?.trim(),
      contraindications: contraindications?.trim().isEmpty == true ? null : contraindications?.trim(),
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'genericName': genericName,
        'category': category,
        'dosageForm': dosageForm,
        'strength': strength,
        'manufacturer': manufacturer,
        'requiresPrescription': requiresPrescription ? 1 : 0,
        'sideEffects': sideEffects,
        'contraindications': contraindications,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Medication.fromMap(Map<String, Object?> map) {
    return Medication(
      id: map['id'] as String,
      name: map['name'] as String,
      genericName: map['genericName'] as String?,
      category: map['category'] as String?,
      dosageForm: map['dosageForm'] as String?,
      strength: map['strength'] as String?,
      manufacturer: map['manufacturer'] as String?,
      requiresPrescription: (map['requiresPrescription'] as int?) == 1,
      sideEffects: map['sideEffects'] as String?,
      contraindications: map['contraindications'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Medication copyWith({
    String? name,
    String? genericName,
    String? category,
    String? sideEffects,
    String? contraindications,
  }) {
    return Medication(
      id: id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      category: category ?? this.category,
      dosageForm: dosageForm ?? this.dosageForm,
      strength: strength ?? this.strength,
      manufacturer: manufacturer ?? this.manufacturer,
      requiresPrescription: requiresPrescription,
      sideEffects: sideEffects ?? this.sideEffects,
      contraindications: contraindications ?? this.contraindications,
      createdAt: createdAt,
    );
  }
}

class PrescriptionItem {
  final String id;
  final String prescriptionId;
  final String medicationId;
  final String medicationName;
  final String? dosage;
  final String? frequency;
  final String? duration;
  final String? instructions;

  const PrescriptionItem({
    required this.id,
    required this.prescriptionId,
    required this.medicationId,
    required this.medicationName,
    this.dosage,
    this.frequency,
    this.duration,
    this.instructions,
  });

  factory PrescriptionItem.create({
    String? id,
    required String prescriptionId,
    required String medicationId,
    required String medicationName,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
  }) {
    final trimmedPrescriptionId = prescriptionId.trim();
    final trimmedMedicationId = medicationId.trim();
    final trimmedMedicationName = medicationName.trim();
    if (trimmedPrescriptionId.isEmpty) {
      throw ArgumentError('Resept ID-si boş ola bilməz');
    }
    if (trimmedMedicationId.isEmpty) {
      throw ArgumentError('Dərman ID-si boş ola bilməz');
    }
    if (trimmedMedicationName.isEmpty) {
      throw ArgumentError('Dərman adı boş ola bilməz');
    }
    return PrescriptionItem(
      id: id ?? _uuid.v4(),
      prescriptionId: trimmedPrescriptionId,
      medicationId: trimmedMedicationId,
      medicationName: trimmedMedicationName,
      dosage: dosage?.trim().isEmpty == true ? null : dosage?.trim(),
      frequency: frequency?.trim().isEmpty == true ? null : frequency?.trim(),
      duration: duration?.trim().isEmpty == true ? null : duration?.trim(),
      instructions: instructions?.trim().isEmpty == true ? null : instructions?.trim(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'prescriptionId': prescriptionId,
        'medicationId': medicationId,
        'medicationName': medicationName,
        'dosage': dosage,
        'frequency': frequency,
        'duration': duration,
        'instructions': instructions,
      };

  factory PrescriptionItem.fromMap(Map<String, Object?> map) {
    return PrescriptionItem(
      id: map['id'] as String,
      prescriptionId: map['prescriptionId'] as String,
      medicationId: map['medicationId'] as String,
      medicationName: map['medicationName'] as String,
      dosage: map['dosage'] as String?,
      frequency: map['frequency'] as String?,
      duration: map['duration'] as String?,
      instructions: map['instructions'] as String?,
    );
  }

  PrescriptionItem copyWith({
    String? medicationId,
    String? medicationName,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
  }) {
    return PrescriptionItem(
      id: id,
      prescriptionId: prescriptionId,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
    );
  }
}

class Invoice {
  final String id;
  final String patientId;
  final String appointmentId;
  final double totalAmount;
  final double discount;
  final double tax;
  final double netAmount;
  final String status;
  final String? paymentMethod;
  final DateTime? paidAt;
  final DateTime createdAt;

  const Invoice({
    required this.id,
    required this.patientId,
    required this.appointmentId,
    required this.totalAmount,
    this.discount = 0,
    this.tax = 0,
    required this.netAmount,
    this.status = 'pending',
    this.paymentMethod,
    this.paidAt,
    required this.createdAt,
  });

  factory Invoice.create({
    String? id,
    required String patientId,
    required String appointmentId,
    required double totalAmount,
    double discount = 0,
    double tax = 0,
    String status = 'pending',
    String? paymentMethod,
  }) {
    final trimmedPatientId = patientId.trim();
    final trimmedAppointmentId = appointmentId.trim();
    if (trimmedPatientId.isEmpty) {
      throw ArgumentError('Pasient ID-si boş ola bilməz');
    }
    if (trimmedAppointmentId.isEmpty) {
      throw ArgumentError('Randevu ID-si boş ola bilməz');
    }
    if (totalAmount < 0) {
      throw ArgumentError('Məbləğ mənfi ola bilməz');
    }
    if (discount < 0 || tax < 0) {
      throw ArgumentError('Endirim və vergi mənfi ola bilməz');
    }
    final netAmount = totalAmount - discount + tax;
    return Invoice(
      id: id ?? _uuid.v4(),
      patientId: trimmedPatientId,
      appointmentId: trimmedAppointmentId,
      totalAmount: totalAmount,
      discount: discount,
      tax: tax,
      netAmount: netAmount,
      status: status,
      paymentMethod: paymentMethod?.trim().isEmpty == true ? null : paymentMethod?.trim(),
      paidAt: status == 'paid' ? DateTime.now() : null,
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'patientId': patientId,
        'appointmentId': appointmentId,
        'totalAmount': totalAmount,
        'discount': discount,
        'tax': tax,
        'netAmount': netAmount,
        'status': status,
        'paymentMethod': paymentMethod,
        'paidAt': paidAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Invoice.fromMap(Map<String, Object?> map) {
    return Invoice(
      id: map['id'] as String,
      patientId: map['patientId'] as String,
      appointmentId: map['appointmentId'] as String,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      netAmount: (map['netAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'pending',
      paymentMethod: map['paymentMethod'] as String?,
      paidAt: map['paidAt'] != null ? DateTime.tryParse(map['paidAt'] as String) : null,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Invoice copyWith({
    String? status,
    String? paymentMethod,
    DateTime? paidAt,
  }) {
    return Invoice(
      id: id,
      patientId: patientId,
      appointmentId: appointmentId,
      totalAmount: totalAmount,
      discount: discount,
      tax: tax,
      netAmount: netAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt,
    );
  }
}

class InvoiceItem {
  final String id;
  final String invoiceId;
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory InvoiceItem.create({
    String? id,
    required String invoiceId,
    required String description,
    required int quantity,
    required double unitPrice,
  }) {
    final trimmedInvoiceId = invoiceId.trim();
    final trimmedDescription = description.trim();
    if (trimmedInvoiceId.isEmpty) {
      throw ArgumentError('Faktura ID-si boş ola bilməz');
    }
    if (trimmedDescription.isEmpty) {
      throw ArgumentError('Açıqlama boş ola bilməz');
    }
    if (quantity <= 0) {
      throw ArgumentError('Miqdar 0-dan böyük olmalıdır');
    }
    if (unitPrice < 0) {
      throw ArgumentError('Qiymət mənfi ola bilməz');
    }
    return InvoiceItem(
      id: id ?? _uuid.v4(),
      invoiceId: trimmedInvoiceId,
      description: trimmedDescription,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: quantity * unitPrice,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'invoiceId': invoiceId,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
      };

  factory InvoiceItem.fromMap(Map<String, Object?> map) {
    return InvoiceItem(
      id: map['id'] as String,
      invoiceId: map['invoiceId'] as String,
      description: map['description'] as String,
      quantity: (map['quantity'] as int?) ?? 1,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

enum AuditAction { create, update, delete, login, logout, view, export, print }

extension AuditActionExtension on AuditAction {
  String get label {
    switch (this) {
      case AuditAction.create:
        return 'Yaratdı';
      case AuditAction.update:
        return 'Yenilədi';
      case AuditAction.delete:
        return 'Sildi';
      case AuditAction.login:
        return 'Giriş';
      case AuditAction.logout:
        return 'Çıxış';
      case AuditAction.view:
        return 'Baxdı';
      case AuditAction.export:
        return 'Eksport';
      case AuditAction.print:
        return 'Çap';
    }
  }
}

class AuditLog {
  final String id;
  final String userId;
  final String userName;
  final UserRole userRole;
  final AuditAction action;
  final String entityType;
  final String? entityId;
  final String? entityName;
  final Map<String, Object?>? changes;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;

  const AuditLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.entityType,
    this.entityId,
    this.entityName,
    this.changes,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
  });

  factory AuditLog.create({
    String? id,
    required String userId,
    required String userName,
    required UserRole userRole,
    required AuditAction action,
    required String entityType,
    String? entityId,
    String? entityName,
    Map<String, Object?>? changes,
    String? ipAddress,
    String? userAgent,
  }) {
    final trimmedUserId = userId.trim();
    final trimmedUserName = userName.trim();
    final trimmedEntityType = entityType.trim();
    if (trimmedUserId.isEmpty) {
      throw ArgumentError('İstifadəçi ID-si boş ola bilməz');
    }
    if (trimmedUserName.isEmpty) {
      throw ArgumentError('İstifadəçi adı boş ola bilməz');
    }
    if (trimmedEntityType.isEmpty) {
      throw ArgumentError('Entity tipi boş ola bilməz');
    }
    return AuditLog(
      id: id ?? _uuid.v4(),
      userId: trimmedUserId,
      userName: trimmedUserName,
      userRole: userRole,
      action: action,
      entityType: trimmedEntityType,
      entityId: entityId?.trim().isEmpty == true ? null : entityId?.trim(),
      entityName: entityName?.trim().isEmpty == true ? null : entityName?.trim(),
      changes: changes,
      ipAddress: ipAddress?.trim().isEmpty == true ? null : ipAddress?.trim(),
      userAgent: userAgent?.trim().isEmpty == true ? null : userAgent?.trim(),
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'userRole': userRole.name,
        'action': action.name,
        'entityType': entityType,
        'entityId': entityId,
        'entityName': entityName,
        'changes': changes,
        'ipAddress': ipAddress,
        'userAgent': userAgent,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AuditLog.fromMap(Map<String, Object?> map) {
    return AuditLog(
      id: map['id'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userRole: UserRole.values.byName(map['userRole'] as String),
      action: AuditAction.values.byName(map['action'] as String),
      entityType: map['entityType'] as String,
      entityId: map['entityId'] as String?,
      entityName: map['entityName'] as String?,
      changes: map['changes'] as Map<String, Object?>?,
      ipAddress: map['ipAddress'] as String?,
      userAgent: map['userAgent'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

enum QueueStatus { waiting, called, inProgress, completed, skipped }

extension QueueStatusExtension on QueueStatus {
  String get label {
    switch (this) {
      case QueueStatus.waiting:
        return 'Gözləyir';
      case QueueStatus.called:
        return 'Çağırılıb';
      case QueueStatus.inProgress:
        return 'İcra olunur';
      case QueueStatus.completed:
        return 'Tamamlandı';
      case QueueStatus.skipped:
        return 'Keçildi';
    }
  }
}

class QueueEntry {
  final String id;
  final String patientId;
  final String doctorId;
  final String appointmentId;
  final int queueNumber;
  final QueueStatus status;
  final DateTime? calledAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  const QueueEntry({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentId,
    required this.queueNumber,
    this.status = QueueStatus.waiting,
    this.calledAt,
    this.completedAt,
    required this.createdAt,
  });

  factory QueueEntry.create({
    String? id,
    required String patientId,
    required String doctorId,
    required String appointmentId,
    required int queueNumber,
    QueueStatus status = QueueStatus.waiting,
  }) {
    final trimmedPatientId = patientId.trim();
    final trimmedDoctorId = doctorId.trim();
    final trimmedAppointmentId = appointmentId.trim();
    if (trimmedPatientId.isEmpty) {
      throw ArgumentError('Pasient ID-si boş ola bilməz');
    }
    if (trimmedDoctorId.isEmpty) {
      throw ArgumentError('Həkim ID-si boş ola bilməz');
    }
    if (trimmedAppointmentId.isEmpty) {
      throw ArgumentError('Randevu ID-si boş ola bilməz');
    }
    if (queueNumber <= 0) {
      throw ArgumentError('Növbə nömrəsi 0-dan böyük olmalıdır');
    }
    return QueueEntry(
      id: id ?? _uuid.v4(),
      patientId: trimmedPatientId,
      doctorId: trimmedDoctorId,
      appointmentId: trimmedAppointmentId,
      queueNumber: queueNumber,
      status: status,
      calledAt: status == QueueStatus.called || status == QueueStatus.inProgress || status == QueueStatus.completed
          ? DateTime.now()
          : null,
      completedAt: status == QueueStatus.completed ? DateTime.now() : null,
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'patientId': patientId,
        'doctorId': doctorId,
        'appointmentId': appointmentId,
        'queueNumber': queueNumber,
        'status': status.name,
        'calledAt': calledAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory QueueEntry.fromMap(Map<String, Object?> map) {
    return QueueEntry(
      id: map['id'] as String,
      patientId: map['patientId'] as String,
      doctorId: map['doctorId'] as String,
      appointmentId: map['appointmentId'] as String,
      queueNumber: (map['queueNumber'] as int?) ?? 0,
      status: QueueStatus.values.byName(map['status'] as String? ?? 'waiting'),
      calledAt: map['calledAt'] != null ? DateTime.tryParse(map['calledAt'] as String) : null,
      completedAt: map['completedAt'] != null ? DateTime.tryParse(map['completedAt'] as String) : null,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  QueueEntry copyWith({
    QueueStatus? status,
    DateTime? calledAt,
    DateTime? completedAt,
  }) {
    return QueueEntry(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      appointmentId: appointmentId,
      queueNumber: queueNumber,
      status: status ?? this.status,
      calledAt: calledAt ?? this.calledAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
    );
  }
}

enum NotificationType { appointmentReminder, appointmentConfirmation, paymentDue, labResult, general }

extension NotificationTypeExtension on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.appointmentReminder:
        return 'Randevu xatırlatma';
      case NotificationType.appointmentConfirmation:
        return 'Randevu təsdiqi';
      case NotificationType.paymentDue:
        return 'Ödəniş xatırlatma';
      case NotificationType.labResult:
        return 'Laboratoriya nəticəsi';
      case NotificationType.general:
        return 'Ümumi';
    }
  }
}

class AppNotification {
  final String id;
  final String recipientId;
  final NotificationType type;
  final String title;
  final String message;
  final String? channel;
  final bool isRead;
  final DateTime? sentAt;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.message,
    this.channel,
    this.isRead = false,
    this.sentAt,
    this.readAt,
    required this.createdAt,
  });

  factory AppNotification.create({
    String? id,
    required String recipientId,
    required NotificationType type,
    required String title,
    required String message,
    String? channel,
  }) {
    final trimmedRecipientId = recipientId.trim();
    final trimmedTitle = title.trim();
    final trimmedMessage = message.trim();
    if (trimmedRecipientId.isEmpty) {
      throw ArgumentError('Alıcı ID-si boş ola bilməz');
    }
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Başlıq boş ola bilməz');
    }
    if (trimmedMessage.isEmpty) {
      throw ArgumentError('Mesaj boş ola bilməz');
    }
    return AppNotification(
      id: id ?? _uuid.v4(),
      recipientId: trimmedRecipientId,
      type: type,
      title: trimmedTitle,
      message: trimmedMessage,
      channel: channel?.trim().isEmpty == true ? null : channel?.trim(),
      isRead: false,
      sentAt: null,
      readAt: null,
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'recipientId': recipientId,
        'type': type.name,
        'title': title,
        'message': message,
        'channel': channel,
        'isRead': isRead ? 1 : 0,
        'sentAt': sentAt?.toIso8601String(),
        'readAt': readAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppNotification.fromMap(Map<String, Object?> map) {
    return AppNotification(
      id: map['id'] as String,
      recipientId: map['recipientId'] as String,
      type: NotificationType.values.byName(map['type'] as String? ?? 'general'),
      title: map['title'] as String,
      message: map['message'] as String,
      channel: map['channel'] as String?,
      isRead: (map['isRead'] as int?) == 1,
      sentAt: map['sentAt'] != null ? DateTime.tryParse(map['sentAt'] as String) : null,
      readAt: map['readAt'] != null ? DateTime.tryParse(map['readAt'] as String) : null,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  AppNotification copyWith({
    bool? isRead,
    DateTime? sentAt,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id,
      recipientId: recipientId,
      type: type,
      title: title,
      message: message,
      channel: channel,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }
}

enum ReportType { daily, weekly, monthly, custom }

class Report {
  final String id;
  final ReportType type;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> data;
  final String generatedBy;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.data,
    required this.generatedBy,
    required this.createdAt,
  });

  factory Report.create({
    String? id,
    required ReportType type,
    required DateTime startDate,
    required DateTime endDate,
    required Map<String, dynamic> data,
    required String generatedBy,
  }) {
    final trimmedGeneratedBy = generatedBy.trim();
    if (trimmedGeneratedBy.isEmpty) {
      throw ArgumentError('Hesabatı yaradan istifadəçi boş ola bilməz');
    }
    if (startDate.isAfter(endDate)) {
      throw ArgumentError('Başlanğıc tarixi bitiş tarixindən sonra ola bilməz');
    }
    return Report(
      id: id ?? _uuid.v4(),
      type: type,
      startDate: startDate,
      endDate: endDate,
      data: data,
      generatedBy: trimmedGeneratedBy,
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'type': type.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'data': data,
        'generatedBy': generatedBy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Report.fromMap(Map<String, Object?> map) {
    return Report(
      id: map['id'] as String,
      type: ReportType.values.byName(map['type'] as String? ?? 'daily'),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
      generatedBy: map['generatedBy'] as String,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class BackupRecord {
  final String id;
  final String tenantId;
  final int recordsCount;
  final int sizeBytes;
  final String? filePath;
  final bool isSuccessful;
  final String? errorMessage;
  final DateTime createdAt;

  const BackupRecord({
    required this.id,
    required this.tenantId,
    required this.recordsCount,
    required this.sizeBytes,
    this.filePath,
    this.isSuccessful = true,
    this.errorMessage,
    required this.createdAt,
  });

  factory BackupRecord.create({
    String? id,
    required String tenantId,
    required int recordsCount,
    required int sizeBytes,
    String? filePath,
    bool isSuccessful = true,
    String? errorMessage,
  }) {
    final trimmedTenantId = tenantId.trim();
    if (trimmedTenantId.isEmpty) {
      throw ArgumentError('Tenant ID-si boş ola bilməz');
    }
    return BackupRecord(
      id: id ?? _uuid.v4(),
      tenantId: trimmedTenantId,
      recordsCount: recordsCount,
      sizeBytes: sizeBytes,
      filePath: filePath?.trim().isEmpty == true ? null : filePath?.trim(),
      isSuccessful: isSuccessful,
      errorMessage: errorMessage?.trim().isEmpty == true ? null : errorMessage?.trim(),
      createdAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'tenantId': tenantId,
        'recordsCount': recordsCount,
        'sizeBytes': sizeBytes,
        'filePath': filePath,
        'isSuccessful': isSuccessful ? 1 : 0,
        'errorMessage': errorMessage,
        'createdAt': createdAt.toIso8601String(),
      };

  factory BackupRecord.fromMap(Map<String, Object?> map) {
    return BackupRecord(
      id: map['id'] as String,
      tenantId: map['tenantId'] as String,
      recordsCount: (map['recordsCount'] as int?) ?? 0,
      sizeBytes: (map['sizeBytes'] as int?) ?? 0,
      filePath: map['filePath'] as String?,
      isSuccessful: (map['isSuccessful'] as int?) == 1,
      errorMessage: map['errorMessage'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
