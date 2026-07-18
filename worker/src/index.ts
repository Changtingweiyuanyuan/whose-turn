/**
 * 今天換誰？ Auth Worker
 *
 * POST /auth/line/code（Web OAuth，主要路徑）
 *   body: { code: string, redirectUri: string, anonymousUid?: string }
 *   1. 用 channel secret 把 authorization code 換成 access token
 *   2. 之後與 /auth/line 相同（驗證、鑄 token、合併匿名帳號）
 *
 * POST /auth/line（Native SDK，保留）
 *   body: { accessToken: string, anonymousUid?: string }
 *   1. 向 LINE 驗證 access token 並取得 profile
 *   2. uid = line:{LINE userId}
 *   3. 若帶 anonymousUid：把匿名帳號資料併入 LINE 帳號（已定案：合併資料）
 *   4. 回傳 Firebase custom token，Flutter 端 signInWithCustomToken
 *
 * GET /healthz — 部署健康檢查
 */

import { Hono, type Context } from 'hono';
import { cors } from 'hono/cors';
import {
  verifyLineAccessToken,
  exchangeAuthorizationCode,
  LineAuthError,
} from './line';
import { mintCustomToken, lineUid, type ServiceAccountEnv } from './firebase';
import { mergeAnonymousInto } from './merge';

export interface Env extends ServiceAccountEnv {
  LINE_CHANNEL_ID: string;
  LINE_CHANNEL_SECRET: string;
}

const app = new Hono<{ Bindings: Env }>();

// Flutter Web 從瀏覽器直接 POST，需要 CORS（MVP 全開；正式可鎖 domain）
app.use('/auth/*', cors());

app.get('/healthz', (c) => c.json({ ok: true, service: 'whose-turn-auth' }));

/** 共同流程：access token → profile → merge → custom token。 */
async function issueCustomToken(
  accessToken: string,
  anonymousUid: string | undefined,
  env: Env,
) {
  const profile = await verifyLineAccessToken(accessToken, env.LINE_CHANNEL_ID);
  const uid = lineUid(profile.userId);

  let merge = { merged: false, movedStars: 0, repointedDocs: 0 };
  if (anonymousUid && anonymousUid !== uid) {
    merge = await mergeAnonymousInto(anonymousUid, uid, env);
  }

  const customToken = await mintCustomToken(
    uid,
    {
      provider: 'line',
      displayName: profile.displayName,
      pictureUrl: profile.pictureUrl ?? null,
    },
    env,
  );

  return { customToken, uid, profile, merge };
}

function handleError(c: Context<{ Bindings: Env }>, err: unknown) {
  if (err instanceof LineAuthError) {
    return c.json({ error: err.message }, err.status as 401 | 502);
  }
  console.error(err);
  return c.json({ error: 'internal error' }, 500);
}

app.post('/auth/line/code', async (c) => {
  const body = await c.req
    .json<{ code?: string; redirectUri?: string; anonymousUid?: string }>()
    .catch(() => null);
  if (!body?.code || !body.redirectUri) {
    return c.json({ error: 'code and redirectUri are required' }, 400);
  }

  try {
    const accessToken = await exchangeAuthorizationCode(
      body.code,
      body.redirectUri,
      c.env.LINE_CHANNEL_ID,
      c.env.LINE_CHANNEL_SECRET,
    );
    return c.json(await issueCustomToken(accessToken, body.anonymousUid, c.env));
  } catch (err) {
    return handleError(c, err);
  }
});

app.post('/auth/line', async (c) => {
  const body = await c.req
    .json<{ accessToken?: string; anonymousUid?: string }>()
    .catch(() => null);
  if (!body?.accessToken) {
    return c.json({ error: 'accessToken is required' }, 400);
  }

  try {
    return c.json(
      await issueCustomToken(body.accessToken, body.anonymousUid, c.env),
    );
  } catch (err) {
    return handleError(c, err);
  }
});

export default app;
