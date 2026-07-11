# whose-turn-auth（Cloudflare Worker）

LINE Login → Firebase custom token 的橋接服務，含匿名帳號資料合併。

## API

### `POST /auth/line`

```json
{ "accessToken": "<LINE SDK 取得的 access token>", "anonymousUid": "<選填：目前匿名帳號的 Firebase uid>" }
```

回傳：

```json
{ "customToken": "...", "uid": "line:U1234", "profile": { ... }, "merge": { "merged": true, "movedStars": 3, "repointedDocs": 5 } }
```

Flutter 端拿 `customToken` 呼叫 `signInWithCustomToken` 完成登入。
帶 `anonymousUid` 時會把匿名帳號的星星、接單紀錄、群組成員資格併入 LINE 帳號（政策：LINE 已有帳號 → 合併資料）。

## 部署（需要 Cloudflare / Firebase / LINE 帳號，尚未執行）

```bash
cd worker
npm install
npm test                          # vitest
npx wrangler login                # Cloudflare 帳號
npx wrangler secret put LINE_CHANNEL_ID
npx wrangler secret put FIREBASE_PROJECT_ID
npx wrangler secret put FIREBASE_CLIENT_EMAIL
npx wrangler secret put FIREBASE_PRIVATE_KEY   # service account JSON 裡的 private_key
npm run deploy
```

之後把 custom domain 設為 `auth.whoseturn.app`。

## 事前準備

1. **LINE Developers**：建立 LINE Login channel，取得 Channel ID
2. **Firebase Console**：專案設定 → 服務帳戶 → 產生新的私密金鑰（JSON），取 `client_email` 與 `private_key`
3. service account 需有 `Service Account Token Creator` 與 Firestore 存取權限
