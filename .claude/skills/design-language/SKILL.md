---
name: design-language
description: 「今天換誰？」的設計語言規範。任何 UI 修改（畫面、元件、theme）前必須先讀本檔並遵守。風格 = 黑底顆粒雜誌刊物（WHOSE TURN TODAY）× 日系編輯排版 × Streamline Freehand 線稿圖示。
---

# 今天換誰？設計語言（v6 — 黑底顆粒雜誌刊物風・深色主題・Streamline 圖示）

參考基準：黑底顆粒雜誌版面（WHOSE TURN TODAY 刊頭 + 顆粒背景），全站深色化，粉色為主 accent，圖示一律 Streamline Freehand 線稿。

## 核心原則

1. **雜誌刊物感**：像每週出刊的家事週刊，不是 SaaS App。
2. **黑底顆粒為主**：全站底 `ink` #010101 + `NoiseBackground` 顆粒。任務看板/我的任務/通知/個人設定/任務詳情/發起任務**全部深色**。
3. **大字刊頭**：每頁上方是雜誌刊頭，共用 `AppMasthead`。
4. **卡片浮在黑底上**：任務卡 = `main`(藍灰)/`white` 輪替、圓角 8、無框無影。深色資訊塊 = `diluteInk` + `inkSoft` 1px 邊框、圓角 8。淺藍資訊塊 = `main` 底無框（備份提醒、建立/加入群組卡）。
5. **重點色克制**：`pink` 是主 accent 與**主要 CTA 底色**；`ink` 是**次要 CTA 底色**；`main` 淡藍用於次要資訊/時間/未選分頁；`orange` 極少用（僅「自己」的家人 tag 邊框）。

## 色票（唯一來源：`lib/theme/app_colors.dart`，禁止 hardcode，例外見下）

| Token | Hex | 用途 |
|---|---|---|
| ink | #010101 | 全站底、次要 CTA 底、淺卡上的深字/圖示、家人 tag 底 |
| inkHover | #151515 | **次要（ink）CTA 的 hover 底**（ink + 8% 白，非透明） |
| diluteInk | #222222 | 深色資訊塊/彈窗/輸入框/下拉底、深色卡片、圖示格 taken 狀態 |
| main | #C2D1D3 | 藍灰卡片底、未選分頁字、次要時間/日期（淡藍）、淺藍資訊塊底 |
| mainDark | #A5B2B3 | 藍色按鈕（邀請好友）的 hover 底 |
| pink | #CF729B | 主 accent：誰／主要 CTA／選中／NO.xx／粉線／通知未讀邊框／星星 |
| pinkDark | #6E3F54 | 「已領取獎勵」不可再點的實心暗粉底（雜訊底不用半透明 disabled） |
| pinkSoft | #F6E4EC | 圖示選中填色、選中淺色格 |
| white | #FFFFFF | 白卡片底、深底上主要文字 |
| inkSoft | #6F6F6F | 深色塊 1px 邊框、發起人灰字、標籤灰字、圖示 taken 圓底 |
| lightGray | #E7E7E7 | 輸入框/分段控制/圖示格 邊框 |
| orange / orangeSoft | #FF8B04 / #FFE9CD | **僅**「自己」的家人 tag 橘框；orangeSoft 幾乎不用 |
| starEmpty / mainSoft / bg | #D9D9D9 / #E6EDEE / #F7F7F7 | 保留、少用 |

> **允許的 hardcode 例外**：`Colors.white70`/`white54`/`white38`（深底次要文字）、`Color(0x14FFFFFF)`（8% 白 hover 疊層）、`Color(0xFF9F353A)`（卡片「進行中」狀態字）、Streamline SVG 內建色（見圖示章節）。

## 字體

- **英數** = Roboto Condensed，**中文** fallback Noto Sans TC（`app_theme.dart`）。
- **全站字距** `letterSpacing: 0.5`（app 根層 `DefaultTextStyle.merge`）；kicker/刊頭小標例外用 2~3。
- **首頁大標「今天換誰？」** = **預設無襯線 w800、64px、「誰」粉色**。（已移除先前的 HeMouTitle 手寫體，不再使用任何自訂字體。）

## 字級（`lib/theme/app_tokens.dart` AppType）

| Token | px | 用途 |
|---|---|---|
| display | 40 | 保留 |
| heading | 26 | 任務詳情大標 |
| title | 20 | 刊頭標題、星星計數、慶祝副標 |
| cardTitle | 16 | 任務卡標題 |
| body | 16 | 一般字（分頁、清單、欄位標題、內文、頁標題） |
| label | 14 | 次級標籤（發起人、appbar 標題、彈窗內文） |
| kicker | 13 | 刊頭小標、caption、badge、副標 |

> 一般文字一律 **16px**；不得再出現 15/17。次級用 14、caption/badge 用 13。硬編碼字級只保留 12（通知時間、任務詳情完成紀錄時間）。

## 字重

以 **w500 / w600** 為主，**w800** 保留給數字強調（NO.xx、星星數、次數 `3/5` 的完成數、首頁大標）。避免 w400/w700/w900。

- 頁標題、卡片標題、欄位標題、通知標題、個人資料姓名 = **w600 / 16px**（三者一致）
- 內文、分頁、發起人名、狀態字、家人 tag 名 = **w500**
- 完成數字、NO.xx、星星計數、首頁大標 = **w800**

## 間距 / 圓角

- **圓角**：按鈕/輸入框 = 6（theme `radius`）；卡片/資訊塊/彈窗 = 8；膠囊(tag/獎勵) = 999。
- **刊頭 → 內容 gap = 24px**（`AppSpacing.lg`）。
- **刊頭粉色線**：高 2px、`borderRadius: 2`（對齊選中分頁底線的圓角）。
- **分頁 文字↔底線 = 8px**；底線高 **3px**、`borderRadius: 2`。
- **任務卡內三段垂直 gap 一律 8px**：圖↔內容 12（水平）；標題↔發起人、發起人↔獎勵、獎勵↔動作皆 **8**。標題列與右上次數 **底部對齊**（`CrossAxisAlignment.end`）。
- **任務詳情大標↔發起人 = 8**；資訊塊 padding 16/12、label↔value **20px**、列間 8。
- **通知卡**：標題↔body **8**、body↔時間 2。
- **家人 tag**：icon↔名字 8。

## Theme（`lib/theme/shad_theme.dart`）—— 深色化重點

- `colorScheme`：primary=**pink**、secondary=**ink**、accent=**8% 白**（hover）、popover=**diluteInk**、popoverForeground=white、border/input=lightGray。
- `inputTheme`：底 diluteInk、字白、placeholder white54、游標白 **1px**。
- `switchTheme`：開=pink、關=main、把手白。
- `outlineButtonTheme` 前景=**白**；**淺底上的 outline/次要按鈕必須個別指定 `foregroundColor: ink`**。
- `calendarTheme`：日期字白、選中日 pink、今天 ink、hover 8% 白、非本月 white38。
- `primaryToastTheme`：底 diluteInk、inkSoft 邊框、白字；**closeIcon = `AppCloseIcon(white, 22)` @ `ShadPosition(top:20, right:20)`（對齊彈窗的 X）**。
- `dialog / alert` 邊框 = **inkSoft**。

## 圖示系統（重要）

flutter_svg 套件不含 broken/twotone/freehand 樣式，**一律內嵌或以 asset SVG 呈現**，禁止 Material/Iconsax 字型 icon。

- **內嵌字串 SVG**：`AppSvgIcon(svgString, color, size)`（`ColorFilter.srcIn` 整體上色）。用於 UI 線性圖示：返回鍵 `kArrowBackSvg`、卡片前往箭頭 `kArrowNextSvg`、加號 `kAddSvg`、減號 `kMinusSvg`、日曆 `kCalendarSvg`、連結 `kLinkSvg`、星星 `kStarSvg`/`kStarSlashSvg`、禮物斜線 `kGiftSlashSvg`、現金 `kCashSvg`、底部導覽四顆。關閉鈕 `AppCloseIcon`（broken 加號轉 45°）、訊息泡泡 `MessageBubbleIcon`。
- **asset SVG**：`AppAssetIcon(assetPath, {color, fillColor, size})`，讀 `assets/icons/*.svg`。
  - **任務圖示**（27 個 Streamline Freehand duotone）：值存成 `asset:xxx`，由 `TaskIcon` → `AppAssetIcon('assets/icons/xxx.svg')` 渲染，**原色**（#010101 深色線稿，畫在白/淺色圓底上）。
  - **個人圖示 / 頭像**（20 個 Smiley Streamline，`kPersonalIcons`，`lib/constants/personal_icons.dart`）：使用者 avatar 值存成 `asset:smiley_xxx`，由 `PersonAvatar` 渲染。
  - **群組卡**圖示 = `teamwork_clap.svg`、**備份卡** = `cloud_phone_exchange.svg`、**建立群組** = `human_resources_hierarchy.svg`、**加入群組** = `business_agreement.svg`。
- **雙色 Streamline 的上色規則**（Smiley/群組類圖示為 `#f7f7f7` 近白 + `#ff8b04` 橘）：
  - **不可用 `color`(srcIn) 整體上色**（會壓成一坨）。
  - 用 `fillColor`（`ColorMapper` 只替換近白 `#f7f7f7`，橘色永遠不動）：**白/淺底帶 `ink`**（近白主體才看得見）、**深底不帶**（保留近白）。
- **`kMaxGroupMembers`** = `kPersonalIcons.length`（個人圖示數量＝群組最大人數）。

## 元件規範

- **刊頭 `AppMasthead`**：`WHOSE TURN TODAY`（白 w600 字距3）+ `NO.xx`（粉 w800）→ 粉色 2px 圓角線 → 標題（20px w600，靠上）+ 可選星星（粉色 `kStarSvg` 20 + w800 數字，僅我的任務/個人卡）。
- **分頁**：白字選中、`main` 未選、皆 w500；粉色 3px 圓角底線滑動；文字↔底線 8px。等待確認分頁的待確認數 badge：文字後 8px + 粉圓 w800 11。
- **任務卡 `TaskCard`**：`main`/`white` 輪替、圓角 8、無框無影。左側 `TaskIcon` 44。標題 16 w600、發起人 14 灰（冒號 w600）、白底膠囊獎勵（`RewardBadge`）、次數右上（大數字 w800 + 小 /N）。動作右下：**我要接 = ink 底白字 + 白色 broken 箭頭（gap 8、20），hover = inkHover**；狀態字：進行中=**#9F353A**、已完成=ink、已被接走 w500、已領取後帶獎勵 icon（money→cash、其餘→gift，gap 4、16），其餘 w600。
- **CTA 規則**：
  - 主要 CTA = **pink 底白字**（完成一次/我要接(詳情)/領取獎勵/確認/用 LINE 綁定/建立/加入/離開）。
  - 次要 CTA = **ink 底白字，hover = `inkHover`**（放棄任務/取消任務/退回/下次再說/取消）。**hover 絕不可變粉色**。
  - **不得有透明底 CTA**；按鈕不加邊框。淺卡上的按鈕文字用 ink。
  - 不可再點的已完成態（已領取獎勵）= **實心 `pinkDark`**、hover 不變（不用 shadcn disabled 的半透明）。
- **獎勵標籤 `RewardBadge`**：白底膠囊 + `diluteInk` 1.5px 邊框 + 墨黑字（卡片上目前**無 icon**）。任務詳情「獎勵內容」：mystery = `神秘禮物 + gift-slash(16) + 完成才揭曉`（gap 4）；money = `金額 + cash icon(16, ink)`（gap 4）；normal/experience **不帶 icon**。
- **進度 `StarProgress`**：≤8 次 = 星星（完成=**粉色**星、未完成=淡藍帶斜線星，不顯示計數）；>8 次 = 進度條（寬 120、高 8、pink 填 / pinkSoft 底 + `完成數(w800 16)/總數`、gap 8）。
- **任務詳情完成紀錄 / 我的任務「等待確認」= 同一種深色 block**：`Container(diluteInk + inkSoft 1px 邊框, radius 8, padding 16/12)`，頭像 26、白字 w500、時間 `main` 色 12（格式 `MM/dd HH:mm`）；可操作時右側 `退回`(ink CTA2) + `確認`(pink)。
- **卡片時間一律 `MM/dd HH:mm`**。
- **領取獎勵流程**：無獨立慶祝頁。點「領取獎勵」→ **同頁跳 toast**（`🎉 恭喜完成！獎勵已解鎖：<獎勵>`，冒號 w600）→ 按鈕變 disabled「已領取獎勵」（pinkDark）。
- **底部導覽**：`diluteInk` 底、圓弧 notch、`extendBody`；中央粉色 FAB（`kAddSvg`）。四顆 broken svg（任務看板/我的任務/通知/個人設定），選中粉、未選 white54。**通知數 badge = 粉圓 + 1.5px diluteInk 邊框**（自訂 badge，非 Material `Badge`）。
- **通知卡**：diluteInk 底；未讀 = **pink 1px 邊框**、已讀 = inkSoft 1px。標題 16 w600 白、body 13 白70 w500、時間 12 淡藍(main)。
- **個人卡 / 群組卡**：`diluteInk + inkSoft 1px`、radius 8。個人卡：頭像 `PersonAvatar` 44 + 姓名 16 w600 + 帳號狀態 13 inkSoft + 右側星星(粉 20 + w800)。群組卡：`teamwork_clap` 44 + 群名 + 「N 人」→ 虛線 `DashedRule(inkSoft)` → **家人 tag**（`ink` 膠囊 + `PersonAvatar` 16 + 名字 w500，gap 8；**自己的框 orange、其他白**）→ 邀請好友(main 底 ink 字，hover mainDark) + 離開(ink CTA2)。
- **建立/加入群組卡（`_ActionCard`）**：樣式對齊備份卡（`main` 底、無框、ink 圖示 44 + 標題 w600 ink + 副標 13 inkSoft），右側 `kArrowNextSvg`（20、ink）。
- **彈窗（dialog）**：`showShadDialog` 一律加 **`opaque: false` + `barrierColor: Colors.black54`**（否則遮罩會蓋成不透明灰）。深色 dialog = `diluteInk` 底、radius 8、**`removeBorderRadiusWhenTiny: false`**（窄斷點才保留圓角）、白 `AppCloseIcon` 22 @ top20/right20。actions = 橫排靠右、不佔滿寬（`expandActionsWhenTiny:false`）、gap 8、取消(ink CTA2)+主action(pink)；content↔actions gap 24（標題與內文合併進 title 欄自控間距）。
- **建立/加入群組 dialog（`group_dialogs.dart`）**：欄位標題（群組名稱／邀請碼，16 w500 白）→ `ShadInput` → **個人圖示** picker。加入群組：輸入邀請碼後 **debounce 400ms** 查詢，查到才顯示 picker（`findGroupByCode` 預覽、不加入）。
- **個人圖示 picker（`PersonalIconPicker`）**：呈現同發起任務「圖示」；格 44（= 任務卡左側圖示）、圖示 28、`fillColor: ink`。未選 = 白底 + lightGray 1px；選中 = **pinkSoft 底 + pink 2px 邊框**；**已被成員選走 = 暗色（inkSoft 圓底 + Opacity 0.4）、排到最後、不可點**。
- **發起任務表單**：欄位標題 16 w500 白、區塊間 16。數量 stepper = diluteInk + lightGray 框 + 白 svg(20) + hover 8% 白。獎勵類型 = 分段控制（diluteInk + lightGray 框、選項距容器 4/間距 4、選中 pink 填 radius6、hover 8% 白）。日期選擇器 = diluteInk 底白字 + 白日曆 svg leading，placeholder「選擇日期」。指定給 select = 滿版 diluteInk 深色下拉，選項含 `PersonAvatar` 20。
- **背景顆粒**：`NoiseBackground`（opacity 0.2 / density 0.1）。

## 資料 / 命名慣例

- 使用者頭像 = `AppUser.avatarEmoji`（可存 emoji 或 `asset:smiley_xxx`）。`Group` **不含** avatar 欄位（群組卡圖示固定 teamwork_clap）。
- `createGroup(name, {personalIcon})` / `joinGroupByCode(code, {personalIcon})` 會順帶設定當前使用者頭像。

## 修改 UI 檢查清單
- [ ] 顏色來自 `AppColors`（除白名單例外）？
- [ ] 一般字 16px、字重只用 w500/600/800？圓角：按鈕 6、卡片/彈窗 8？
- [ ] 深底頁面文字都是淺色（白 / white70 / white54 / main）？
- [ ] 主要 CTA pink、次要 CTA ink（hover=inkHover，**不可變粉**），**沒有透明底 CTA**？
- [ ] 圖示用 `AppSvgIcon`/`AppAssetIcon`（無 Material/Iconsax 字型 icon）？雙色 Streamline 依底色決定 `fillColor`（白/淺底=ink、深底=不帶）？
- [ ] 彈窗有 `opaque:false + barrierColor: black54`？
- [ ] 新增 asset 後，用**無痕視窗**驗證（Flutter service worker 會快取舊 manifest，Cmd+Shift+R 常清不掉）？
- [ ] 改 shadcn 共用 colorScheme role 前，先評估全站副作用？
- [ ] `flutter analyze` + `flutter build web` **綠燈**才提交/部署？
