/**
 * LINE 登入串接：
 *
 * 1. Web OAuth（主要路徑）：Flutter Web 整頁導向 LINE 授權頁，
 *    回跳帶 authorization code → Worker 以 channel secret 換 access token
 *    （exchangeAuthorizationCode）→ 取 profile → 鑄 Firebase custom token。
 * 2. Native SDK（保留）：App 端用 flutter_line_sdk 取得 access token
 *    直接 POST，Worker 驗證（verifyLineAccessToken）。
 */

export interface LineProfile {
  userId: string;
  displayName: string;
  pictureUrl?: string;
}

const VERIFY_URL = 'https://api.line.me/oauth2/v2.1/verify';
const PROFILE_URL = 'https://api.line.me/v2/profile';
const TOKEN_URL = 'https://api.line.me/oauth2/v2.1/token';

export class LineAuthError extends Error {
  constructor(
    message: string,
    readonly status: number = 401,
  ) {
    super(message);
  }
}

/** 驗證 access token 屬於我們的 channel 且未過期，回傳 LINE profile。 */
export async function verifyLineAccessToken(
  accessToken: string,
  channelId: string,
  fetcher: typeof fetch = fetch,
): Promise<LineProfile> {
  const verifyRes = await fetcher(
    `${VERIFY_URL}?access_token=${encodeURIComponent(accessToken)}`,
  );
  if (!verifyRes.ok) {
    throw new LineAuthError('LINE access token is invalid or expired');
  }
  const verify = (await verifyRes.json()) as {
    client_id: string;
    expires_in: number;
  };
  if (verify.client_id !== channelId) {
    throw new LineAuthError('Access token was issued for another channel');
  }
  if (verify.expires_in <= 0) {
    throw new LineAuthError('LINE access token is expired');
  }

  const profileRes = await fetcher(PROFILE_URL, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  if (!profileRes.ok) {
    throw new LineAuthError('Failed to fetch LINE profile', 502);
  }
  const profile = (await profileRes.json()) as {
    userId: string;
    displayName: string;
    pictureUrl?: string;
  };
  return {
    userId: profile.userId,
    displayName: profile.displayName,
    pictureUrl: profile.pictureUrl,
  };
}

/** Web OAuth：authorization code → access token（需要 channel secret）。 */
export async function exchangeAuthorizationCode(
  code: string,
  redirectUri: string,
  channelId: string,
  channelSecret: string,
  fetcher: typeof fetch = fetch,
): Promise<string> {
  const res = await fetcher(TOKEN_URL, {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      code,
      redirect_uri: redirectUri,
      client_id: channelId,
      client_secret: channelSecret,
    }),
  });
  if (!res.ok) {
    throw new LineAuthError('Failed to exchange authorization code', 401);
  }
  const data = (await res.json()) as { access_token?: string };
  if (!data.access_token) {
    throw new LineAuthError('LINE token response missing access_token', 502);
  }
  return data.access_token;
}
