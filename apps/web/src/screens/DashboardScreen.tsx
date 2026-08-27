import { useEffect, useState } from 'react';

import { allRecords } from '../core/db';
import type { Appointment, Doctor, Patient } from '../core/types';

interface Stats {
  patients: number;
  doctors: number;
  today: number;
  total: number;
}

export function DashboardScreen() {
  const [stats, setStats] = useState<Stats | null>(null);

  useEffect(() => {
    void (async () => {
      const [patients, doctors, appointments] = await Promise.all([
        allRecords<Patient>('patients'),
        allRecords<Doctor>('doctors'),
        allRecords<Appointment>('appointments'),
      ]);
      const now = new Date();
      const today = appointments.filter((a) => {
        const d = new Date(a.dateTime);
        return (
          a.status === 'scheduled' &&
          d.getFullYear() === now.getFullYear() &&
          d.getMonth() === now.getMonth() &&
          d.getDate() === now.getDate()
        );
      }).length;
      setStats({
        patients: patients.length,
        doctors: doctors.length,
        today,
        total: appointments.length,
      });
    })();
  }, []);

  if (!stats) return <p>Yüklənir…</p>;

  const cards = [
    { label: 'Pasientlər', value: stats.patients, icon: '🧑‍🦱' },
    { label: 'Həkimlər', value: stats.doctors, icon: '👨‍⚕️' },
    { label: 'Bugünkü randevular', value: stats.today, icon: '📅' },
    { label: 'Bütün randevular', value: stats.total, icon: '🗂️' },
  ];

  return (
    <div className="stat-grid">
      {cards.map((c) => (
        <div className="card stat-card" key={c.label}>
          <span className="stat-icon">{c.icon}</span>
          <span className="stat-value">{c.value}</span>
          <span className="stat-label">{c.label}</span>
        </div>
      ))}
    </div>
  );
}
