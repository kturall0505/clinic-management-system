import { useEffect, useState, type FormEvent } from 'react';

import { allRecords, deleteRecord, putRecord } from '../core/db';
import type { Doctor } from '../core/types';

const EMPTY = {
  fullName: '',
  specialty: '',
  phone: '',
  fee: '',
  schedule: '',
};

export function DoctorsScreen() {
  const [doctors, setDoctors] = useState<Doctor[]>([]);
  const [editing, setEditing] = useState<Doctor | null>(null);
  const [form, setForm] = useState(EMPTY);
  const [showForm, setShowForm] = useState(false);
  const [feeError, setFeeError] = useState('');

  async function refresh() {
    const all = await allRecords<Doctor>('doctors');
    all.sort((a, b) => a.fullName.localeCompare(b.fullName));
    setDoctors(all);
  }

  useEffect(() => {
    void refresh();
  }, []);

  function openNew() {
    setEditing(null);
    setForm(EMPTY);
    setFeeError('');
    setShowForm(true);
  }

  function openEdit(d: Doctor) {
    setEditing(d);
    setForm({
      fullName: d.fullName,
      specialty: d.specialty,
      phone: d.phone,
      fee: String(d.consultationFee),
      schedule: d.schedule,
    });
    setFeeError('');
    setShowForm(true);
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    const fee = Number(form.fee);
    if (!Number.isFinite(fee) || fee < 0) {
      setFeeError('Düzgün məbləğ daxil edin');
      return;
    }
    const doctor: Doctor = {
      id: editing?.id ?? crypto.randomUUID(),
      fullName: form.fullName,
      specialty: form.specialty,
      phone: form.phone,
      consultationFee: fee,
      schedule: form.schedule,
    };
    await putRecord('doctors', doctor);
    setShowForm(false);
    await refresh();
  }

  async function handleDelete(id: string) {
    await deleteRecord('doctors', id);
    await refresh();
  }

  return (
    <div>
      <div className="toolbar">
        <button onClick={openNew}>+ Yeni həkim</button>
      </div>
      {doctors.length === 0 && <p>Hələ həkim yoxdur.</p>}
      <ul className="list">
        {doctors.map((d) => (
          <li className="card list-item" key={d.id}>
            <div>
              <strong>{d.fullName}</strong>
              <div className="muted">
                {d.specialty} · {d.phone} · {d.consultationFee.toFixed(2)} AZN
              </div>
              {d.schedule && <div className="muted">Qrafik: {d.schedule}</div>}
            </div>
            <div className="actions">
              <button onClick={() => openEdit(d)}>Düzəliş</button>
              <button className="danger" onClick={() => void handleDelete(d.id)}>
                Sil
              </button>
            </div>
          </li>
        ))}
      </ul>
      {showForm && (
        <div className="modal-backdrop">
          <form className="card modal" onSubmit={handleSubmit}>
            <h2>{editing ? 'Həkimə düzəliş' : 'Yeni həkim'}</h2>
            <label>
              Ad Soyad
              <input
                value={form.fullName}
                onChange={(e) => setForm({ ...form, fullName: e.target.value })}
                required
              />
            </label>
            <label>
              İxtisas
              <input
                value={form.specialty}
                onChange={(e) => setForm({ ...form, specialty: e.target.value })}
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
              Qəbul haqqı (AZN)
              <input
                value={form.fee}
                onChange={(e) => setForm({ ...form, fee: e.target.value })}
                required
              />
            </label>
            {feeError && <p className="error">{feeError}</p>}
            <label>
              İş qrafiki
              <input
                value={form.schedule}
                onChange={(e) => setForm({ ...form, schedule: e.target.value })}
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
