# 後端上線設定（需要你操作的部分）

程式碼已全部就緒：`FirebaseAppRepository`（Firestore 即時讀寫）、LINE Web OAuth（Worker `/auth/line/code`）、安全規則、站內通知。
預設仍跑 **Demo 模式**（FakeAppRepository）；完成下列步驟後改用 `--dart-define=USE_FIREBASE=true` 建置即切換為正式模式。

## 1. Firebase 專案（~15 分鐘）

1. 到 <https://console.firebase.google.com> 建立專案（例：`whose-turn`）。
2. 啟用 **Authentication** → Sign-in method → 開啟 **Anonymous**。
3. 啟用 **Firestore Database**（production mode，地區建議 `asia-east1`）。
4. 部署安全規則：
   - Console → Firestore → Rules → 貼上 `firebase/firestore.rules` 內容 → Publish。
   - （或裝 CLI：`npm i -g firebase-tools && firebase deploy --only firestore:rules`）
5. 在 `app/` 目錄執行 FlutterFire 設定（會覆寫佔位的 `lib/firebase_options.dart`）：
   ```bash
   dart pub global activate flutterfire_cli
   cd app && flutterfire configure   # 選剛建立的專案、平台勾 Web
   ```
6. 建立 **Service Account 金鑰**（Worker 鑄 custom token 用）：
   - Console → 專案設定 → 服務帳戶 → 產生新的私密金鑰（下載 JSON）。

## 2. LINE Developers（~10 分鐘）

1. 到 <https://developers.line.biz> 建立 Provider + **LINE Login channel**（Web app）。
2. 記下 **Channel ID** 與 **Channel Secret**。
3. Callback URL 填正式站首頁（**結尾要有 `/`**）：
   ```
   https://whose-turn-21w.pages.dev/
   ```
   （之後換自訂網域要同步更新。）

## 3. 部署 Auth Worker（~10 分鐘）

```bash
cd worker
npx wrangler secret put LINE_CHANNEL_ID        # LINE Channel ID
npx wrangler secret put LINE_CHANNEL_SECRET    # LINE Channel Secret
npx wrangler secret put FIREBASE_PROJECT_ID    # Firebase 專案 ID
npx wrangler secret put FIREBASE_CLIENT_EMAIL  # service account JSON 的 client_email
npx wrangler secret put FIREBASE_PRIVATE_KEY   # service account JSON 的 private_key（整段 PEM 含換行）
npx wrangler deploy
```
部署完成會得到 Worker URL（例：`https://whose-turn-auth.<subdomain>.workers.dev`），下一步要用。
健康檢查：開 `<worker-url>/healthz` 應回 `{"ok":true}`。

## 4. 正式建置與部署 App

```bash
cd app
flutter build web --release \
  --dart-define=USE_FIREBASE=true \
  --dart-define=LINE_CHANNEL_ID=<你的 LINE Channel ID> \
  --dart-define=AUTH_WORKER_URL=<你的 Worker URL>

npx wrangler pages deploy build/web --project-name whose-turn --branch main
```

> 不帶 `USE_FIREBASE=true` 就是現在的 Demo 模式，兩者可並存
> （例：demo 部署到另一個 Pages project 當展示）。

## 5. 驗證清單

- [ ] 無痕開站 → 自動匿名登入，個人設定顯示「訪客帳號」
- [ ] 建立群組被擋（訪客 gate → LINE 綁定 sheet）
- [ ] 「用 LINE 綁定」→ 導向 LINE 授權 → 回站後顯示 LINE 名稱、`LINE 已綁定`
- [ ] 綁定後建立群組（選個人圖示）→ Firestore console 看得到 groups/members
- [ ] 第二個瀏覽器（另一個匿名帳號）用邀請碼加入 → 已被選走的個人圖示呈現 disabled
- [ ] 發任務 → 另一帳號的通知即時出現（未讀粉框、badge 數字）
- [ ] 接單 → 完成一次 → 發起人確認 → 接單人 ⭐+1（Firestore users doc 檢查 starTotal）
- [ ] 退回、放棄、取消、領取獎勵各流程
- [ ] **個人設定沒有「Demo 視角切換」**（正式模式已隱藏）

## 6. 規則驗證（可選但建議）

Firestore emulator 需要 Java（本機目前未裝）。兩個選項：
- `brew install openjdk && npm i -g firebase-tools && firebase emulators:start --only firestore`，跑 rules 單元測試；或
- 直接用 Console → Rules Playground 手動驗核心情境（訪客建群組應 deny、非發起人 confirm 應 deny、starTotal 遞減應 deny）。

## 7. 之後再說（已文件化、暫不做）

- **FCM push 通知**：MVP 用站內通知（Firestore 即時 listener）已足夠——開著網頁就會即時跳；FCM 需要 service worker + 權限請求 + Cloud Functions 觸發，列入 v1.1。
- **自訂網域**：`whoseturn.app` 買好後：Pages custom domain + Worker route `auth.whoseturn.app` + LINE callback 同步更新。
- **通知改由後端寫入**：目前通知由 client 寫（rules 允許 create），防偽造要搬到 Worker/Cloud Functions，列入 v1.1。
