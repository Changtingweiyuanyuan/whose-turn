---
name: design-language
description: 「今天換誰？」的設計語言規範。任何 UI 修改（畫面、元件、theme）前必須先讀本檔並遵守。風格 = 黑底顆粒雜誌刊物（WHOSE TURN TODAY）× 日系編輯排版。
---

# 今天換誰？設計語言（v5 — 黑底顆粒雜誌刊物風・深色主題）

參考基準：黑底顆粒雜誌版面（WHOSE TURN TODAY 刊頭 + 顆粒背景），全站深色化，粉色為主 accent。

## 核心原則

1. **雜誌刊物感**：像每週出刊的家事週刊，不是 SaaS App。
2. **黑底顆粒為主**：全站底 `ink` #010101 + `NoiseBackground` 顆粒。任務看板/我的任務/通知/個人設定/任務詳情/發起任務**全部深色**。
3. **大字刊頭**：每頁上方是雜誌刊頭（見下），共用 `AppMasthead`。
4. **卡片浮在黑底上**：任務卡 = `main`(藍灰)/`white` 輪替、圓角 8、無框無影。深色資訊塊 = `diluteInk` + `inkSoft` 1px 邊框、圓角 8。
5. **重點色克制**：`pink` 是主 accent 與**主要 CTA 底色**；`ink` 是**次要 CTA 底色**；`main` 淡藍用於次要資訊/時間/未選分頁。

## 色票（唯一來源：`lib/theme/app_colors.dart`，禁止 hardcode，例外見下）

| Token | Hex | 用途 |
|---|---|---|
| ink | #010101 | 全站底、次要 CTA 底、日曆「今天」底、淺卡上的深字 |
| diluteInk | #222222 | 深色資訊塊/彈窗/輸入框/下拉底、深色卡片 |
| main | #C2D1D3 | 藍灰卡片底、未選分頁字、次要時間/日期（淡藍） |
| pink | #CF729B | 主 accent：誰／主要 CTA／選中／NO.xx／粉線／未讀邊框 |
| pinkSoft | #F6E4EC | 進度條底、圖示選中填色、選中淺色格 |
| white | #FFFFFF | 白卡片底、深底上主要文字 |
| inkSoft | #6F6F6F | 深色塊 1px 邊框、發起人灰字、標籤灰字 |
| lightGray | #E7E7E7 | 輸入框/分段控制邊框 |
| orange / orangeSoft | #FF8B04 / #FFE9CD | 訪客備份提醒（保留，少用） |

> **允許的 hardcode 例外**：`Colors.white70`/`white54`（深底次要文字）、`Color(0x14FFFFFF)`（8% 白 hover 疊層）、`Color(0xFF8F4D63)`（卡片「進行中」狀態字）。

## 字體

- **英數** = Roboto Condensed，**中文** fallback Noto Sans TC（`app_theme.dart`）。
- **全站字距** `letterSpacing: 0.2`（app 根層 `DefaultTextStyle.merge`），kicker 例外用 2~3。
- **首頁大標「今天換誰？」** = **何某手寫體**（免費可商用，子集化 `assets/fonts/HeMouTitle.ttf`，family `HeMouTitle`），64px、「誰」粉色。**僅此一處**用手寫體。

## 字級（`lib/theme/app_tokens.dart` AppType）

| Token | px | 用途 |
|---|---|---|
| display | 40 | 保留 |
| heading | 26 | 保留（少用） |
| cardTitle | **16** | 卡片標題、任務詳情大標 |
| body | **16** | 一般字（分頁、清單、欄位標題、內文） |
| label | **14** | 次級標籤（發起人、appbar 標題） |
| kicker | 12 | 刊頭小標 |

> 一般文字一律 **16px**；不得再出現 15/17。次級用 14、caption/badge 用 12~13。

## 字重

以 **w500 / w600** 為主，**w800** 保留給數字強調（NO.xx、星星數、次數 `3/5` 的完成數）。避免 w400/w700/w900。

- 頁標題、卡片標題、欄位標題、通知標題 = **w600**
- 內文、分頁、發起人名、狀態字 = **w500**
- 完成數字、NO.xx、星星計數 = **w800**

## 間距 / 圓角

- **圓角**：按鈕/輸入框 = 6（theme `radius`）；卡片/資訊塊 = 8；獎勵標籤 = 膠囊(999)。
- **刊頭 → 內容 gap = 24px**（`AppSpacing.lg`，三頁一致）。
- **分頁 文字↔底線 = 8px**；底線高 **3px**（首頁與我的任務一致）。
- **任務卡內**：圖↔內容 12、標題↔發起人 4、發起人↔獎勵 8。
- **任務詳情資訊塊**：padding 16/12、label↔value **20px**、列間 8、標題↔星星同列。
- **通知卡**：標題↔body 4、body↔時間 2。

## Theme（`lib/theme/shad_theme.dart`）—— 深色化重點

- `colorScheme`：primary=**pink**（主要按鈕/日曆選中日）、secondary=**ink**（日曆今天）、accent=**8% 白**（hover）、popover=**diluteInk**（下拉/日曆底）、popoverForeground=white、border/input=lightGray。
- `inputTheme`：底 diluteInk、字白、placeholder white54、游標白 **1px**。
- `switchTheme`：開=pink、關=main、把手白。
- `outlineButtonTheme` 前景=**白**（日曆左右導覽箭頭）；**淺底上的 `ShadButton.outline` 必須個別指定 `foregroundColor: ink`**（邀請好友/取消/退回/回任務看板）。
- `calendarTheme`：日期字白、選中日 pink（primary）、今天 ink（secondary）、hover 8% 白、非本月 white38。
- `toast / dialog / alert` 邊框 = **pink**（popover 已改回無粉框）。

## 元件規範

- **刊頭 `AppMasthead`**：`WHOSE TURN TODAY`（白 w600 字距3）+ `NO.xx`（粉 w800）→ 粉色 2px 線 → 標題（20px w600，靠上對齊）+ 可選星星（粉色 icon + w800 數字，僅我的任務有）。通知/個人設定不帶星星。
- **分頁**：白字選中、`main` 未選，皆 w500；粉色 3px 底線滑動（240ms easeOutCubic）；文字↔底線 8px。
- **任務卡**：`main`/`white` 輪替（首頁與我的任務都輪替）、圓角 8、無框無影。標題 16px w600、發起人 14 灰（冒號 w800）、粉色獎勵藥丸、次數右上（大數字 w800 + 小 /N）。動作右下：**我要接 = ink 按鈕 + 白色 broken 箭頭 svg（8px gap、20px）**；狀態字：進行中=**#8F4D63**、已完成=ink、已被接走 w500、其餘 w600。
- **CTA 規則**：主要 CTA = **pink 底白字**（完成一次/我要接(詳情)/領取獎勵/用 LINE 綁定/離開）；次要 CTA = **ink 底白字**（放棄任務/取消任務/下次再說/取消）。**不得有透明底 CTA**；按鈕不加邊框。卡片上的「我要接」在淺卡上用 ink。
- **獎勵標籤**：白底膠囊 + `diluteInk` 1.5px 邊框 + 墨黑字（無 icon）。神秘獎勵在詳情顯示 `神秘禮物 + gift-slash icon + 完成才揭曉`（gap 4）。
- **進度**（`StarProgress`）：≤8 次 = 星星（完成=粉色星、未完成=淡藍帶斜線星，**不顯示計數**）；>8 次 = 進度條（寬 120、高 8、pink 填 / pinkSoft 底 + `完成數(w800 16)/總數(正常)`、gap 8）。
- **底部導覽**：`diluteInk` 底、圓弧 notch、`extendBody`；中央粉色圓形 FAB（broken 加號 svg）。四個 icon 皆 **broken/twotone 線稿 svg**（`AppSvgIcon`）：任務看板(ai-homepage)、我的任務(task)、通知(message-bubble)、個人設定(setting)；選中粉色、未選 white54。
- **通知卡**：diluteInk 底；未讀 = **pink 1px 邊框**、已讀 = inkSoft 1px 邊框（其餘相同）。標題 16 w600 白、body 13 白70（`taskCompleted` w600、其餘 w500）、時間 12 淡藍(main)。
- **發起任務表單**：欄位標題 16 w500 白、區塊間 16、標題↔內容 8。數量 stepper = diluteInk 底 + lightGray 框 + 白 svg(20) + hover 疊 8% 白。獎勵類型 = 分段控制（diluteInk + lightGray 框，選項距容器 4 / 間距 4，選中 = pink 填 radius6，hover 8% 白）。日期選擇器 = diluteInk 底白字 + 白 svg 日曆 leading（hover 維持 diluteInk）。指定給 select = 滿版、diluteInk、深色下拉。
- **圖示 SVG**：flutter 套件無 broken/twotone，一律內嵌官方 svg 於 `app_svg_icons.dart`，用 `AppSvgIcon(svg, color, size)`（colorFilter 上色）。關閉鈕 `AppCloseIcon`（broken 加號轉 45°）。
- **背景顆粒**：`NoiseBackground`（opacity 0.2 / density 0.1）。

## 修改 UI 檢查清單
- [ ] 顏色來自 `AppColors`（除白名單例外）？
- [ ] 一般字 16px、字重只用 w500/600/800？
- [ ] 圓角：按鈕 6、卡片 8？
- [ ] 深底頁面文字都是淺色（白 / white70 / white54 / main）？
- [ ] 主要 CTA pink、次要 CTA ink，**沒有透明底 CTA**？
- [ ] 改 shadcn 共用 colorScheme role（primary/secondary/accent/popover）前，先評估全站副作用？
- [ ] `flutter analyze` + `flutter build web` **綠燈**才提交/部署？
