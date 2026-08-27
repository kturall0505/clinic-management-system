import { allRecords, putRecord } from './db';
import type { AppUser, UserRole } from './types';

async function sha256Hex(text: string): Promise<string> {
  const data = new TextEncoder().encode(text);
  const digest = await crypto.subtle.digest('SHA-256', data);
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

function randomSalt(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(16));
  return Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

export async function findUser(username: string): Promise<AppUser | null> {
  const users = await allRecords<AppUser>('users');
  return users.find((u) => u.username === username) ?? null;
}

export async function registerUser(params: {
  username: string;
  password: string;
  role: UserRole;
  fullName: string;
}): Promise<AppUser> {
  const existing = await findUser(params.username);
  if (existing) {
    throw new Error('Bu istifadəçi adı artıq mövcuddur');
  }
  const salt = randomSalt();
  const user: AppUser = {
    id: crypto.randomUUID(),
    username: params.username,
    passwordHash: await sha256Hex(`${salt}:${params.password}`),
    salt,
    role: params.role,
    fullName: params.fullName,
  };
  await putRecord('users', user);
  return user;
}

/** Development seed only — must be changed before production use. */
export async function ensureSeedAdmin(): Promise<void> {
  const users = await allRecords<AppUser>('users');
  if (users.length === 0) {
    await registerUser({
      username: 'admin',
      password: 'admin123',
      role: 'admin',
      fullName: 'Administrator',
    });
  }
}

export async function verifyLogin(
  username: string,
  password: string,
): Promise<AppUser | null> {
  const user = await findUser(username);
  if (!user) return null;
  const hash = await sha256Hex(`${user.salt}:${password}`);
  return hash === user.passwordHash ? user : null;
}
