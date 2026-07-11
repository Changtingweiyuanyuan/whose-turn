/**
 * 匿名帳號 → LINE 帳號的資料合併。
 *
 * 政策（已定案）：若該 LINE 已有既有帳號，合併資料——
 * 匿名帳號的星星總數併入 LINE 帳號、任務接單紀錄 re-point 到 LINE uid、
 * 群組成員資格轉移，最後在匿名 user doc 標記 mergedInto。
 *
 * 透過 Firestore REST API 操作（firebase-admin 不能跑在 Workers）。
 */

import { getGoogleAccessToken, type ServiceAccountEnv } from './firebase';

const FIRESTORE_BASE = 'https://firestore.googleapis.com/v1';

interface FirestoreDoc {
  name: string;
  fields?: Record<string, FirestoreValue>;
}
type FirestoreValue = {
  stringValue?: string;
  integerValue?: string;
  booleanValue?: boolean;
  timestampValue?: string;
};

function docPath(env: ServiceAccountEnv, path: string): string {
  return `projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/${path}`;
}

async function firestoreGet(
  env: ServiceAccountEnv,
  token: string,
  path: string,
  fetcher: typeof fetch,
): Promise<FirestoreDoc | null> {
  const res = await fetcher(`${FIRESTORE_BASE}/${docPath(env, path)}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (res.status === 404) return null;
  if (!res.ok) throw new Error(`Firestore GET ${path} failed: ${res.status}`);
  return (await res.json()) as FirestoreDoc;
}

/** runQuery：找出某 collection 中 userId == uid 的文件路徑。 */
async function findDocsByUserId(
  env: ServiceAccountEnv,
  token: string,
  collectionId: string,
  uid: string,
  fetcher: typeof fetch,
): Promise<string[]> {
  const res = await fetcher(
    `${FIRESTORE_BASE}/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        structuredQuery: {
          from: [{ collectionId, allDescendants: true }],
          where: {
            fieldFilter: {
              field: { fieldPath: 'userId' },
              op: 'EQUAL',
              value: { stringValue: uid },
            },
          },
        },
      }),
    },
  );
  if (!res.ok) throw new Error(`Firestore runQuery failed: ${res.status}`);
  const rows = (await res.json()) as Array<{ document?: { name: string } }>;
  return rows.filter((r) => r.document).map((r) => r.document!.name);
}

/** commit：批次寫入（更新 userId 欄位、累加星星、標記 merged）。 */
async function firestoreCommit(
  env: ServiceAccountEnv,
  token: string,
  writes: unknown[],
  fetcher: typeof fetch,
): Promise<void> {
  const res = await fetcher(
    `${FIRESTORE_BASE}/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents:commit`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ writes }),
    },
  );
  if (!res.ok) throw new Error(`Firestore commit failed: ${res.status}`);
}

export interface MergeResult {
  merged: boolean;
  movedStars: number;
  repointedDocs: number;
}

/**
 * 把 anonymousUid 的資料併入 targetUid（LINE 帳號）。
 * 匿名帳號不存在或沒有資料時回傳 merged: false（無事可做）。
 */
export async function mergeAnonymousInto(
  anonymousUid: string,
  targetUid: string,
  env: ServiceAccountEnv,
  fetcher: typeof fetch = fetch,
): Promise<MergeResult> {
  const token = await getGoogleAccessToken(env, fetcher);

  const anonDoc = await firestoreGet(env, token, `users/${anonymousUid}`, fetcher);
  if (!anonDoc) return { merged: false, movedStars: 0, repointedDocs: 0 };

  const anonStars = Number(anonDoc.fields?.starTotal?.integerValue ?? 0);
  const targetDoc = await firestoreGet(env, token, `users/${targetUid}`, fetcher);
  const targetStars = Number(targetDoc?.fields?.starTotal?.integerValue ?? 0);

  // 接單紀錄與群組成員資格 re-point 到 LINE uid
  const [completionDocs, memberDocs] = await Promise.all([
    findDocsByUserId(env, token, 'completions', anonymousUid, fetcher),
    findDocsByUserId(env, token, 'members', anonymousUid, fetcher),
  ]);
  const repointWrites = [...completionDocs, ...memberDocs].map((name) => ({
    update: {
      name,
      fields: { userId: { stringValue: targetUid } },
    },
    updateMask: { fieldPaths: ['userId'] },
  }));

  const writes = [
    ...repointWrites,
    {
      update: {
        name: docPath(env, `users/${targetUid}`),
        fields: {
          starTotal: { integerValue: String(targetStars + anonStars) },
        },
      },
      updateMask: { fieldPaths: ['starTotal'] },
    },
    {
      update: {
        name: docPath(env, `users/${anonymousUid}`),
        fields: {
          mergedInto: { stringValue: targetUid },
          starTotal: { integerValue: '0' },
        },
      },
      updateMask: { fieldPaths: ['mergedInto', 'starTotal'] },
    },
  ];
  await firestoreCommit(env, token, writes, fetcher);

  return {
    merged: true,
    movedStars: anonStars,
    repointedDocs: repointWrites.length,
  };
}
