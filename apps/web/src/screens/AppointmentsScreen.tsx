import { useEffect, useState, type FormEvent } from 'react';

import { allRecords, deleteRecord, putRecord } from '../core/db';
import {
  APPOINTMENT_STATUS_LABELS,
  type Appointment,
  type AppointmentStatus,
  type Doctor,
  type Patient,
} from '../core/types';

export function AppointmentsScreen() {
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [patients, setPatients] = useState<Patient[]>([]);
  const [doctors, setDoctors] = useState<Doctor[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({
    patientId: '',
    doctorId: '',
    dateTime: '',
    reason: '',
  });

  async function refresh() {
    const [apps, ps, ds] = await Promise.all([
      allRecords<Appointment>('appointments'),
      allRecords<Patient>('patients'),
      allRecords<Doctor>('doctors'),
    ]);
    apps.sort((a, b) => a.dateTime.localeCompare(b.dateTime));
    setAppointments(apps);
    setPatients(ps);
    setDoctors(ds);
  }

  useEffect(() => {
    void refresh();
  }, []);

  const patientName = (id: string) =>
    patients.find((p) => p.id === id)?.fullName ?? '—';
  const doctorName = (id: string) =>
    doctors.find((d) => d.id === id)?.fullName ?? '—';

  function openNew() {
    if (patients.length === 0 || doctors.length === 0) {
      alert('Əvvəlcə ən azı bir pasient və bir həkim əlavə edin');
      return;
    }
    setForm({
      patientId: patients[0].id,
      doctorId: doctors[0].id,
      dateTime: '',
      reason: '',
    });
    setShowForm(true);
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    const appointment: Appointment = {
      id: crypto.randomUUID(),
      patientId: form.patientId,
      doctorId: form.doctorId,
      dateTime: form.dateTime,
      status: 'scheduled',
      reason: form.reason,
    };
    await putRecord('appointments', appointment);
    setShowForm(false);
    await refresh();
  }

  async function setStatus(a: Appointment, status: AppointmentStatus) {
    await putRecord('appointments', { ...a, status });
    await refresh();
  }

  async function handleDelete(id: string) {
    await deleteRecord('appointments', id);
    await refresh();
  }

  return (
    <div>
      <div className="toolbar">
        <button onClick={openNew}>+ Yeni randevu</button>
      </div>
      {appointments.length === 0 && <p>Hələ randevu yoxdur.</p>}
      <ul className="list">
        {appointments.map((a) => (
          <li className="card list-item" key={a.id}>
            <div>
              <strong>
                {patientName(a.patientId)} → {doctorName(a.doctorId)}
              </strong>
              <div className="muted">
                {new Date(a.dateTime).toLocaleString('az-AZ')}
                {a.reason && ` · ${a.reason}`}
              </div>
              <span className={`status status-${a.status}`}>
                {APPOINTMENT_STATUS_LABELS[a.status]}
              </span>
            </div>
            <div className="actions">
              <select
                value={a.status}
                onChange={(e) =>
                  void setStatus(a, e.target.value as AppointmentStatus)
                }
              >
                {Object.entries(APPOINTMENT_STATUS_LABELS).map(([value, label]) => (
                  <option key={value} value={value}>
                    {label}
                  </option>
                ))}
              </select>
              <button className="danger" onClick={() => void handleDelete(a.id)}>
                Sil
              </button>
            </div>
          </li>
        ))}
      </ul>
      {showForm && (
        <div className="modal-backdrop">
          <form className="card modal" onSubmit={handleSubmit}>
            <h2>Yeni randevu</h2>
            <label>
              Pasient
              <select
                value={form.patientId}
                onChange={(e) => setForm({ ...form, patientId: e.target.value })}
              >
                {patients.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.fullName}
                  </option>
                ))}
              </select>
            </label>
            <label>
              Həkim
              <select
                value={form.doctorId}
                onChange={(e) => setForm({ ...form, doctorId: e.target.value })}
              >
                {doctors.map((d) => (
                  <option key={d.id} value={d.id}>
                    {d.fullName} ({d.specialty})
                  </option>
                ))}
              </select>
            </label>
            <label>
              Tarix və vaxt
              <input
                type="datetime-local"
                value={form.dateTime}
                onChange={(e) => setForm({ ...form, dateTime: e.target.value })}
                required
              />
            </label>
            <label>
              Səbəb
              <input
                value={form.reason}
                onChange={(e) => setForm({ ...form, reason: e.target.value })}
              />
            </label>
            <div className="actions">
              <button type="button" onClick={() => setShowForm(false)}>
                Ləğv et
              </button>
              <button type="submit">Yadda saxla</button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}
