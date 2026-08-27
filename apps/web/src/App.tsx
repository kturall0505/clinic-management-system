import { useCallback, useEffect, useState } from 'react';

import './App.css';
import { ensureSeedAdmin } from './core/auth';
import { checkLicense, type LicenseState } from './core/license';
import type { AppUser } from './core/types';
import { AppointmentsScreen } from './screens/AppointmentsScreen';
import { AssistantScreen } from './screens/AssistantScreen';
import { DashboardScreen } from './screens/DashboardScreen';
import { DoctorsScreen } from './screens/DoctorsScreen';
import { LicenseLockScreen } from './screens/LicenseLockScreen';
import { LoginScreen } from './screens/LoginScreen';
import { PatientsScreen } from './screens/PatientsScreen';

type Tab = 'dashboard' | 'patients' | 'doctors' | 'appointments' | 'assistant';

const TABS: Array<{ id: Tab; label: string; icon: string }> = [
  { id: 'dashboard', label: 'Panel', icon: '📊' },
  { id: 'patients', label: 'Pasientlər', icon: '🧑‍🦱' },
  { id: 'doctors', label: 'Həkimlər', icon: '👨‍⚕️' },
  { id: 'appointments', label: 'Randevular', icon: '📅' },
  { id: 'assistant', label: 'AI Köməkçi', icon: '🤖' },
];

const TITLES: Record<Tab, string> = {
  dashboard: 'İdarə paneli',
  patients: 'Pasientlər',
  doctors: 'Həkimlər',
  appointments: 'Randevular',
  assistant: 'AI Köməkçi',
};

export default function App() {
  const [ready, setReady] = useState(false);
  const [license, setLicense] = useState<{
    state: LicenseState;
    lastSuccess: Date | null;
  }>({ state: 'unknown', lastSuccess: null });
  const [checking, setChecking] = useState(false);
  const [user, setUser] = useState<AppUser | null>(null);
  const [tab, setTab] = useState<Tab>('dashboard');

  const runLicenseCheck = useCallback(async () => {
    setChecking(true);
    try {
      setLicense(await checkLicense());
    } finally {
      setChecking(false);
    }
  }, []);

  useEffect(() => {
    void (async () => {
      await ensureSeedAdmin();
      await runLicenseCheck();
      setReady(true);
    })();
  }, [runLicenseCheck]);

  if (!ready) {
    return (
      <div className="centered-page">
        <p>Yüklənir…</p>
      </div>
    );
  }

  if (license.state === 'graceExpired') {
    return (
      <LicenseLockScreen
        lastSuccess={license.lastSuccess}
        onRetry={() => void runLicenseCheck()}
        checking={checking}
      />
    );
  }

  if (!user) {
    return <LoginScreen onLogin={setUser} />;
  }

  return (
    <div className="shell">
      <nav className="sidebar">
        {TABS.map((t) => (
          <button
            key={t.id}
            className={tab === t.id ? 'nav-item active' : 'nav-item'}
            onClick={() => setTab(t.id)}
          >
            <span>{t.icon}</span>
            {t.label}
          </button>
        ))}
      </nav>
      <div className="main">
        <header className="topbar">
          <h1>{TITLES[tab]}</h1>
          <div className="topbar-right">
            <span
              title={
                license.state === 'valid'
                  ? 'Lisenziya aktivdir'
                  : 'Lisenziya yoxlaması gözlənilir'
              }
            >
              {license.state === 'valid' ? '🟢' : '🟠'}
            </span>
            <span>{user.fullName}</span>
            <button onClick={() => setUser(null)}>Çıxış</button>
          </div>
        </header>
        <main className="content">
          {tab === 'dashboard' && <DashboardScreen />}
          {tab === 'patients' && <PatientsScreen />}
          {tab === 'doctors' && <DoctorsScreen />}
          {tab === 'appointments' && <AppointmentsScreen />}
          {tab === 'assistant' && <AssistantScreen />}
        </main>
      </div>
    </div>
  );
}
