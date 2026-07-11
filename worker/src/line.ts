/**
 * LINE access token 驗證與取得使用者 profile。
 *
 * App 端流程：Flutter 用 flutter_line_sdk 登入取得 access token，
 * POST 給本 Worker，Worker 向 LINE 驗證後才鑄造 Firebase custom token。
 * 不走 Web OAuth redirect，省去 deep link 複雜度。
 */

export interface LineProfile {
  userId: string;
  displayName: string;
  pictureUrl?: string;
}

const VERIFY_URL = 'https://api.line.me/oauth2/v2.1/verify';
const PROFILE_URL = 'https://api.line.me/v2/profile';

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
