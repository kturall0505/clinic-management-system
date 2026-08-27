import { openDB, type IDBPDatabase } from 'idb';

import { TENANT_ID } from './config';

export type StoreName = 'users' | 'patients' | 'doctors' | 'appointments';

const STORES: StoreName[] = ['users', 'patients', 'doctors', 'appointments'];

let dbPromise: Promise<IDBPDatabase> | null = null;

/** Each clinic installation keeps its own database, keyed by tenant id,
 *  so data from different clinics is never mixed. */
export function getDb(): Promise<IDBPDatabase> {
  dbPromise ??= openDB(`clinic_${TENANT_ID}`, 1, {
    upgrade(db) {
      for (const name of STORES) {
        if (!db.objectStoreNames.contains(name)) {
          db.createObjectStore(name, { keyPath: 'id' });
        }
      }
    },
  });
  return dbPromise;
}

export async function putRecord<T extends { id: string }>(
  store: StoreName,
  value: T,
): Promise<void> {
  const db = await getDb();
  await db.put(store, value);
}

export async function deleteRecord(
  store: StoreName,
  id: string,
): Promise<void> {
  const db = await getDb();
  await db.delete(store, id);
}

export async function allRecords<T>(store: StoreName): Promise<T[]> {
  const db = await getDb();
  return (await db.getAll(store)) as T[];
}
