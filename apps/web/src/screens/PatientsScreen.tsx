import { useEffect, useState, type FormEvent } from 'react';

import { allRecords, deleteRecord, putRecord } from '../core/db';
import type { Patient } from '../core/types';

const EMPTY: Omit<Patient, 'id'> = {
  fullName: '',
  birthDate: '',
  phone: '',
  allergies: '',
  chronicConditions: '',
  notes: '',
};

export function PatientsScreen() {
  const [patients, setPatients] = useState<Patient[]>([]);
  const [editing, setEditing] = useState<Patient | null>(null);
  const [form, setForm] = useState(EMPTY);
  const [showForm, setShowForm] = useState(false);

  async function refresh() {
    const all = await allRecords<Patient>('patients');
    all.sort((a, b) => a.fullName.localeCompare(b.fullName));
    setPatients(all);
  }

  useEffect(() => {
    void refresh();
  }, []);

  function openNew() {
    setEditing(null);
    setForm(EMPTY);
    setShowForm(true);
  }

  function openEdit(p: Patient) {
    setEditing(p);
    setForm({ ...p });
    setShowForm(true);
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    const patient: Patient = {
      id: editing?.id ?? crypto.randomUUID(),
      ...form,
    };
    await putRecord('patients', patient);
    setShowForm(false);
    await refresh();
  }

  async function handleDelete(id: string) {
    await deleteRecord('patients', id);
    await refresh();
  }

  return (
    <div>
      <div className="toolbar">
        <button onClick={openNew}>+ Yeni pasient</button>
      </div>
      {patients.length === 0 && <p>Hələ pasient yoxdur.</p>}
      <ul className="list">
        {patients.map((p) => (
          <li className="card list-item" key={p.id}>
            <div>
              <strong>{p.fullName}</strong>
              <div className="muted">
                {p.phone}
                {p.birthDate && ` · ${p.birthDate}`}
                {p.allergies && ` · Allergiya: ${p.allergies}`}
              </div>
            </div>
            <div className="actions">
              <button onClick={() => openEdit(p)}>Düzəliş</button>
              <button className="danger" onClick={() => void handleDelete(p.id)}>
                Sil
              </button>
            </div>
          </li>
        ))}
      </ul>
      {showForm && (
        <div className="modal-backdrop">
          <form className="card modal" onSubmit={handleSubmit}>
            <h2>{editing ? 'Pasientə düzəliş' : 'Yeni pasient'}</h2>
            <label>
              Ad Soyad
              <input
                value={form.fullName}
                onChange={(e) => setForm({ ...form, fullName: e.target.value })}
                required
              />
            </label>
            <label>
              Telefon
              <input
                value={form.phone}
                onChange={(e) => setForm({ ...form, phone: e.target.value })}
              />
            </label>
            <label>
              Doğum tarixi
              <input
                type="date"
                value={form.birthDate}
                onChange={(e) => setForm({ ...form, birthDate: e.target.value })}
              />
            </label>
            <label>
              Allergiyalar
              <input
                value={form.allergies}
                onChange={(e) => setForm({ ...form, allergies: e.target.value })}
              />
            </label>
            <label>
              Xroniki xəstəliklər
              <input
                value={form.chronicConditions}
                onChange={(e) =>
                  setForm({ ...form, chronicConditions: e.target.value })
                }
              />
            </label>
            <label>
              Qeydlər
              <textarea
                value={form.notes}
                onChange={(e) => setForm({ ...form, notes: e.target.value })}
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
