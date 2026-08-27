import { useState, type FormEvent } from 'react';

import { verifyLogin } from '../core/auth';
import type { AppUser } from '../core/types';

export function LoginScreen({ onLogin }: { onLogin: (user: AppUser) => void }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const user = await verifyLogin(username.trim(), password);
      if (user) {
        onLogin(user);
      } else {
        setError('İstifadəçi adı və ya şifrə yanlışdır');
      }
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="centered-page">
      <form className="card login-card" onSubmit={handleSubmit}>
        <h1>🏥 Klinika Sistemi</h1>
        <label>
          İstifadəçi adı
          <input
            autoComplete="username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            required
          />
        </label>
        <label>
          Şifrə
          <input
            type="password"
            autoComplete="current-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </label>
        {error && <p className="error">{error}</p>}
        <button type="submit" disabled={loading}>
          {loading ? 'Yoxlanılır…' : 'Daxil ol'}
        </button>
      </form>
    </div>
  );
}
