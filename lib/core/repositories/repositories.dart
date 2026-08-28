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

  Future<List<T>> query({required Filter filter}) async {
    final records = await store.find(db.db, filter: filter);
    return records.map((r) => fromMap(r.value)).toList();
  }

  Future<T?> findById(String id) async {
    final record = await store.record(id).get(db.db);
    if (record == null) return null;
    return fromMap(record);
  }
}

class PatientRepository {
  PatientRepository(AppDatabase db)
      : _store = _Store(db, 'patients', Patient.fromMap, (p) => p.toMap());

  final _Store<Patient> _store;

  Future<void> save(Patient patient) =>
      _store.put(patient.id, patient.copyWith());
  Future<void> delete(String id) => _store.delete(id);
  Future<List<Patient>> all() => _store.all();
  Future<Patient?> findById(String id) => _store.findById(id);
}

class DoctorRepository {
  DoctorRepository(AppDatabase db)
      : _store = _Store(db, 'doctors', Doctor.fromMap, (d) => d.toMap());

  final _Store<Doctor> _store;

  Future<void> save(Doctor doctor) =>
      _store.put(doctor.id, doctor.copyWith());
  Future<void> delete(String id) => _store.delete(id);
  Future<List<Doctor>> all() => _store.all();
  Future<Doctor?> findById(String id) => _store.findById(id);
}

class AppointmentRepository {
  AppointmentRepository(AppDatabase db)
      : _store =
            _Store(db, 'appointments', Appointment.fromMap, (a) => a.toMap());

  final _Store<Appointment> _store;

  Future<void> save(Appointment appointment) =>
      _store.put(appointment.id, appointment.copyWith());
  Future<void> delete(String id) => _store.delete(id);

  Future<List<Appointment>> all() async {
    final items = await _store.all();
    items.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return items;
  }

  Future<bool> hasCollision(Appointment appointment,
      {String? excludeId}) async {
    final all = await _store.query(
      filter: Filter.and([
        Filter.equals('doctorId', appointment.doctorId),
        Filter.equals('dateTime', appointment.dateTime.toIso8601String()),
        Filter.equals('status', AppointmentStatus.scheduled.name),
      ]),
    );
    if (excludeId != null) {
      return all.any((a) => a.id != excludeId);
    }
    return all.isNotEmpty;
  }

  Future<Appointment?> findById(String id) => _store.findById(id);
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