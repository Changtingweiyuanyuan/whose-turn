/// 執行模式開關。
///
/// 預設 `false` = Demo 模式（FakeAppRepository，in-memory 假資料，現行公開 demo）。
/// 正式上線改用：
/// ```
/// flutter build web --release --dart-define=USE_FIREBASE=true
/// ```
/// 切換後走 Firebase Auth（匿名 + LINE custom token）與 Firestore 真實讀寫。
const kUseFirebase = bool.fromEnvironment('USE_FIREBASE');

/// LINE Login channel ID（正式上線由 --dart-define 注入，見 docs/backend-setup.md）。
const kLineChannelId = String.fromEnvironment('LINE_CHANNEL_ID');

/// Auth Worker 端點（Cloudflare Worker，POST /auth/line/code）。
const kAuthWorkerUrl = String.fromEnvironment(
  'AUTH_WORKER_URL',
  defaultValue: 'https://whose-turn-auth.workers.dev',
);
