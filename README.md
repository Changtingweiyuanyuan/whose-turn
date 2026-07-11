# 今天換誰？ (Whose Turn?)

> 「今天換誰？」不是一個家事管理 App。
> 它是一個讓家人、情侶、室友透過獎勵發起任務、主動接單，並一起完成生活大小事的任務平台。

**Task Marketplace + Reward System** — 不是排程、不是輪流，而是「今天誰想拿？👀」

## 專案結構

```
app/      Flutter App（目前跑在 in-memory 假後端上，完整可玩）
worker/   Cloudflare Worker：LINE Login → Firebase custom token + 帳號合併
firebase/ Firestore security rules
docs/     PRD、資料模型與任務狀態機
```

## 開發

```bash
# App（假資料模式，開瀏覽器就能玩）
cd app
flutter run -d chrome     # 或 -d ios / -d android
flutter test              # 18 tests
flutter analyze

# Worker
cd worker
npm install && npm test   # 6 tests
```

App 內建「Demo 視角切換」（我的 → Demo 視角切換），可在 媽媽／哥哥／訪客 之間切換，
同時體驗發起人（確認、退回）與接單人（接單、完成、領獎）視角。

## 文件

- [PRD（MVP v1.0）](docs/prd.html) — 產品定位、6 大功能、核心流程、Reward Types、Non-Goals、Roadmap
- [資料模型與任務狀態機](docs/data-model.md)

## 已定案的決策

| 項目 | 決定 |
|---|---|
| 技術選型 | Flutter |
| 後端 | Firebase（Firestore + Auth + FCM，Spark 免費方案）＋ Cloudflare Worker（LINE OAuth → Firebase custom token） |
| 登入方式 | LINE Login + 訪客模式（Firebase Anonymous Auth，之後以帳號升級綁定 LINE） |
| 訪客權限 | 可加入群組、可接任務；「建立群組」與「發起任務」前必須綁定 LINE |
| LINE 綁定衝突 | 若該 LINE 已有既有帳號 → 合併資料（匿名帳號的星星與紀錄併入 LINE 帳號） |
| Domain | whoseturn.app |
| 年齡分級 | 不設限，允許小孩使用 |
| 監測（Sentry / Analytics） | 雛形完成後再導入 |

## 品牌 & 設計

**風格**：MUJI ／ 北歐日系雜貨 ／ Lofi 插畫 ／ Hobonichi 手帳 ／ 日本文具品牌（MIDORI、MARK'S）／ 少量 Studio Ghibli 配色的溫暖感

**配色**：

| 顏色 | Hex | 用途 |
|---|---|---|
| 深藍 🌊 | `#255359` | 文字、重點元件 |
| 粉色 🌸 | `#A75F7B` | 主要按鈕、強調 |
| 黃色 ⭐ | `#FFB21B` | 強調按鈕、星星 |
| 米白 🤍 | `#FFF8ED` | 背景（約 55%） |
| 淺灰 | `#EAECEF` | 輔助（約 25%） |

**字體**：`'Roboto Condensed', sans-serif`（英數）＋ Noto Sans TC（中文 fallback）

## MVP v1.0 — 6 個功能

1. 建立群組 👨‍👩‍👧‍👦
2. 任務牆（首頁）⭐
3. 我的任務
4. 發起任務
5. 任務確認（+1 ⭐，永遠不能扣）
6. 提醒（通知）🔔
