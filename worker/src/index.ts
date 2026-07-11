/**
 * 今天換誰？ Auth Worker
 *
 * POST /auth/line
 *   body: { accessToken: string, anonymousUid?: string }
 *   1. 向 LINE 驗證 access token 並取得 profile
 *   2. uid = line:{LINE userId}
 *   3. 若帶 anonymousUid：把匿名帳號資料併入 LINE 帳號（已定案：合併資料）
 *   4. 回傳 Firebase custom token，Flutter 端 signInWithCustomToken
 *
 * GET /healthz — 部署健康檢查
 */

import { Hono } from 'hono';
import { verifyLineAccessToken, LineAuthError } from './line';
import { mintCustomToken, lineUid, type ServiceAccountEnv } from './firebase';
import { mergeAnonymousInto } from './merge';

export interface Env extends ServiceAccountEnv {
  LINE_CHANNEL_ID: string;
}

const app = new Hono<{ Bindings: Env }>();

app.get('/healthz', (c) => c.json({ ok: true, service: 'whose-turn-auth' }));

app.post('/auth/line', async (c) => {
  const body = await c.req.json<{ accessToken?: string; anonymousUid?: string }>()
    .catch(() => null);
  if (!body?.accessToken) {
    return c.json({ error: 'accessToken is required' }, 400);
  }

  try {
    const profile = await verifyLineAccessToken(
      body.accessToken,
      c.env.LINE_CHANNEL_ID,
    );
    const uid = lineUid(profile.userId);

    let merge = { merged: false, movedStars: 0, repointedDocs: 0 };
    if (body.anonymousUid && body.anonymousUid !== uid) {
      merge = await mergeAnonymousInto(body.anonymousUid, uid, c.env);
    }

    const customToken = await mintCustomToken(
      uid,
      {
        provider: 'line',
        displayName: profile.displayName,
        pictureUrl: profile.pictureUrl ?? null,
      },
      c.env,
    );

    return c.json({ customToken, uid, profile, merge });
  } catch (err) {
    if (err instanceof LineAuthError) {
      return c.json({ error: err.message }, err.status as 401 | 502);
    }
    console.error(err);
    return c.json({ error: 'internal error' }, 500);
  }
});

export default app;
