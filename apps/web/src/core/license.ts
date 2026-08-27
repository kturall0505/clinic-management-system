import { LICENSE_SERVER_URL, TENANT_ID } from './config';

export type LicenseState = 'valid' | 'graceExpired' | 'unknown';

const LAST_SUCCESS_KEY = `license_last_success_${TENANT_ID}`;
const FIRST_RUN_KEY = `license_first_run_${TENANT_ID}`;
const GRACE_MS = 24 * 60 * 60 * 1000;

export function getLastSuccess(): Date | null {
  const stored = localStorage.getItem(LAST_SUCCESS_KEY);
  if (stored) return new Date(stored);
  // First installation: one grace period from install time so the clinic
  // can finish setup before the first online check.
  let firstRun = localStorage.getItem(FIRST_RUN_KEY);
  if (!firstRun) {
    firstRun = new Date().toISOString();
    localStorage.setItem(FIRST_RUN_KEY, firstRun);
  }
  return new Date(firstRun);
}

/** Sends only the tenant id and a timestamp — never any clinical data. */
async function sendHeartbeat(): Promise<boolean> {
  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 10_000);
    const res = await fetch(`${LICENSE_SERVER_URL}/heartbeat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        tenantId: TENANT_ID,
        timestamp: new Date().toISOString(),
      }),
      signal: controller.signal,
    });
    clearTimeout(timer);
    return res.ok;
  } catch {
    return false;
  }
}

export async function checkLicense(): Promise<{
  state: LicenseState;
  lastSuccess: Date | null;
}> {
  const succeeded = await sendHeartbeat();
  if (succeeded) {
    localStorage.setItem(LAST_SUCCESS_KEY, new Date().toISOString());
    return { state: 'valid', lastSuccess: new Date() };
  }
  const last = getLastSuccess();
  if (last && Date.now() - last.getTime() <= GRACE_MS) {
    return { state: 'valid', lastSuccess: last };
  }
  return { state: 'graceExpired', lastSuccess: last };
}
