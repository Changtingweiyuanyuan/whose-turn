/**
 * Firebase custom token 鑄造與 Google OAuth access token 取得。
 * 用 WebCrypto 以 service account 私鑰簽 RS256 JWT，不依賴 firebase-admin
 * （firebase-admin 無法在 Cloudflare Workers 上執行）。
 */

export interface ServiceAccountEnv {
  FIREBASE_PROJECT_ID: string;
  FIREBASE_CLIENT_EMAIL: string;
  /** PEM 格式私鑰，含 BEGIN/END PRIVATE KEY 標頭 */
  FIREBASE_PRIVATE_KEY: string;
}

const CUSTOM_TOKEN_AUD =
  'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit';
const GOOGLE_TOKEN_URL = 'https://oauth2.googleapis.com/token';
const FIRESTORE_SCOPE = 'https://www.googleapis.com/auth/datastore';

function base64UrlEncode(data: Uint8Array | string): string {
  const bytes =
    typeof data === 'string' ? new TextEncoder().encode(data) : data;
  let binary = '';
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

async function importPrivateKey(pem: string): Promise<CryptoKey> {
  const body = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\\n/g, '')
    .replace(/\s/g, '');
  const der = Uint8Array.from(atob(body), (c) => c.charCodeAt(0));
  return crypto.subtle.importKey(
    'pkcs8',
    der,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
}

export async function signJwt(
  payload: Record<string, unknown>,
  privateKeyPem: string,
): Promise<string> {
  const header = { alg: 'RS256', typ: 'JWT' };
  const signingInput = `${base64UrlEncode(JSON.stringify(header))}.${base64UrlEncode(JSON.stringify(payload))}`;
  const key = await importPrivateKey(privateKeyPem);
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    new TextEncoder().encode(signingInput),
  );
  return `${signingInput}.${base64UrlEncode(new Uint8Array(signature))}`;
}

/** 鑄造 Firebase custom token；Flutter 端以 signInWithCustomToken 換取正式登入。 */
export async function mintCustomToken(
  uid: string,
  claims: Record<string, unknown>,
  env: ServiceAccountEnv,
  now: number = Math.floor(Date.now() / 1000),
): Promise<string> {
  return signJwt(
    {
      iss: env.FIREBASE_CLIENT_EMAIL,
      sub: env.FIREBASE_CLIENT_EMAIL,
      aud: CUSTOM_TOKEN_AUD,
      iat: now,
      exp: now + 3600,
      uid,
      claims,
    },
    env.FIREBASE_PRIVATE_KEY,
  );
}

/** 以 JWT bearer flow 取得可呼叫 Firestore REST API 的 access token。 */
export async function getGoogleAccessToken(
  env: ServiceAccountEnv,
  fetcher: typeof fetch = fetch,
  now: number = Math.floor(Date.now() / 1000),
): Promise<string> {
  const assertion = await signJwt(
    {
      iss: env.FIREBASE_CLIENT_EMAIL,
      scope: FIRESTORE_SCOPE,
      aud: GOOGLE_TOKEN_URL,
      iat: now,
      exp: now + 3600,
    },
    env.FIREBASE_PRIVATE_KEY,
  );
  const res = await fetcher(GOOGLE_TOKEN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });
  if (!res.ok) {
    throw new Error(`Failed to obtain Google access token: ${res.status}`);
  }
  const data = (await res.json()) as { access_token: string };
  return data.access_token;
}

/** LINE userId 對應到 Firebase uid 的固定規則。 */
export function lineUid(lineUserId: string): string {
  return `line:${lineUserId}`;
}
