import { describe, it, expect } from 'vitest';
import { verifyLineAccessToken, LineAuthError } from '../src/line';
import { signJwt, mintCustomToken, lineUid } from '../src/firebase';

const CHANNEL_ID = '1234567890';

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

function makeFetcher(routes: Record<string, (req: Request) => Response>) {
  return (async (input: RequestInfo | URL, init?: RequestInit) => {
    const req = new Request(input, init);
    const url = new URL(req.url);
    const handler = routes[url.origin + url.pathname];
    if (!handler) throw new Error(`Unexpected fetch: ${req.url}`);
    return handler(req);
  }) as typeof fetch;
}

describe('verifyLineAccessToken', () => {
  const routes = {
    'https://api.line.me/oauth2/v2.1/verify': () =>
      jsonResponse({ client_id: CHANNEL_ID, expires_in: 2591659 }),
    'https://api.line.me/v2/profile': () =>
      jsonResponse({
        userId: 'U1234',
        displayName: 'Chelsea',
        pictureUrl: 'https://example.com/p.jpg',
      }),
  };

  it('returns profile for a valid token', async () => {
    const profile = await verifyLineAccessToken(
      'token',
      CHANNEL_ID,
      makeFetcher(routes),
    );
    expect(profile).toEqual({
      userId: 'U1234',
      displayName: 'Chelsea',
      pictureUrl: 'https://example.com/p.jpg',
    });
  });

  it('rejects a token issued for another channel', async () => {
    const fetcher = makeFetcher({
      ...routes,
      'https://api.line.me/oauth2/v2.1/verify': () =>
        jsonResponse({ client_id: 'other-channel', expires_in: 100 }),
    });
    await expect(
      verifyLineAccessToken('token', CHANNEL_ID, fetcher),
    ).rejects.toBeInstanceOf(LineAuthError);
  });

  it('rejects an expired token', async () => {
    const fetcher = makeFetcher({
      ...routes,
      'https://api.line.me/oauth2/v2.1/verify': () =>
        jsonResponse({ error: 'invalid_token' }, 400),
    });
    await expect(
      verifyLineAccessToken('token', CHANNEL_ID, fetcher),
    ).rejects.toBeInstanceOf(LineAuthError);
  });
});

async function generateTestKeyPem(): Promise<{ pem: string; publicKey: CryptoKey }> {
  const pair = await crypto.subtle.generateKey(
    {
      name: 'RSASSA-PKCS1-v1_5',
      modulusLength: 2048,
      publicExponent: new Uint8Array([1, 0, 1]),
      hash: 'SHA-256',
    },
    true,
    ['sign', 'verify'],
  );
  const pkcs8 = await crypto.subtle.exportKey('pkcs8', pair.privateKey);
  const b64 = btoa(String.fromCharCode(...new Uint8Array(pkcs8)));
  const pem = `-----BEGIN PRIVATE KEY-----\n${b64}\n-----END PRIVATE KEY-----`;
  return { pem, publicKey: pair.publicKey };
}

function decodeSegment(segment: string): Record<string, unknown> {
  const padded = segment.replace(/-/g, '+').replace(/_/g, '/');
  return JSON.parse(atob(padded));
}

describe('firebase custom token', () => {
  it('signs a verifiable RS256 JWT with the expected payload', async () => {
    const { pem, publicKey } = await generateTestKeyPem();
    const env = {
      FIREBASE_PROJECT_ID: 'whose-turn-test',
      FIREBASE_CLIENT_EMAIL: 'sa@whose-turn-test.iam.gserviceaccount.com',
      FIREBASE_PRIVATE_KEY: pem,
    };
    const now = 1_800_000_000;
    const token = await mintCustomToken(
      'line:U1234',
      { provider: 'line', displayName: 'Chelsea' },
      env,
      now,
    );

    const [headerB64, payloadB64, sigB64] = token.split('.');
    expect(decodeSegment(headerB64)).toEqual({ alg: 'RS256', typ: 'JWT' });

    const payload = decodeSegment(payloadB64);
    expect(payload.uid).toBe('line:U1234');
    expect(payload.iss).toBe(env.FIREBASE_CLIENT_EMAIL);
    expect(payload.iat).toBe(now);
    expect(payload.exp).toBe(now + 3600);

    const signature = Uint8Array.from(
      atob(sigB64.replace(/-/g, '+').replace(/_/g, '/')),
      (c) => c.charCodeAt(0),
    );
    const valid = await crypto.subtle.verify(
      'RSASSA-PKCS1-v1_5',
      publicKey,
      signature,
      new TextEncoder().encode(`${headerB64}.${payloadB64}`),
    );
    expect(valid).toBe(true);
  });

  it('signJwt produces three dot-separated segments', async () => {
    const { pem } = await generateTestKeyPem();
    const jwt = await signJwt({ hello: 'world' }, pem);
    expect(jwt.split('.')).toHaveLength(3);
  });
});

describe('lineUid', () => {
  it('prefixes LINE userId', () => {
    expect(lineUid('U99')).toBe('line:U99');
  });
});
