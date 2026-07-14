---
name: design-language
description: 「今天換誰？」的設計語言規範。任何 UI 修改（畫面、元件、theme）前必須先讀本檔並遵守。風格 = Prodigy 後台極簡 × 編輯排版式繽紛（非圓潤 App 風）。
---

# 今天換誰？設計語言（v2 — 編輯排版風）

參考基準：Prodigy admin dashboard（極簡留白＋細線）× Year-in-Review 手機稿（黑底編輯排版＋高彩色塊）。

## 核心原則

1. **編輯排版，不是 App 圓潤風**：像雜誌版面，不像 candy UI。
2. **黑白為骨，彩色為點綴**：頁面 95% 是 #F7F7F7 / 白 / 墨黑；橘與粉只出現在少數「值得強調」的地方（獎勵、進度、慶祝）。
3. **細線，不是陰影**：層次靠 1px 淺灰邊框與留白，禁用明顯 drop shadow。
4. **銳利，不是膠囊**：圓角統一 8px；禁止 999 全圓膠囊（badge 除外，radius 6）。
5. **文字即介面**：次要操作用文字連結（橘色或墨黑加底線），不是灰色按鈕。

## 色票（唯一來源：`lib/theme/app_colors.dart`）

| Token | Hex | 用法 |
|---|---|---|
| ink | #010101 | 文字、主要按鈕底色（白字）、FAB |
| main | #C2D1D3 | 選中狀態底、次要 surface、一般獎勵標籤 |
| orange | #FF8B04 | 文字連結、金額、星星、進度條 |
| pink | #CF729B | 神秘禮物、進行中狀態 |
| bg | #F7F7F7 | 頁面底色 |
| white | #FFFFFF | 卡片底色 |
| lightGray | #E7E7E7 | 1px 邊框 |

## 元件規則

- **卡片**：白底、1px lightGray 邊框、radius 8、無陰影、padding 16–20。
- **主要按鈕（我要接／確認／發佈）**：ink 底白字，radius 8。
- **次要操作（放棄、取消、下次再說、Skip 類）**：橘色文字連結（ShadButton.link 或 ghost），不是灰色按鈕。
- **Badge**：扁平色塊，radius 6，不加 icon 不加 emoji。
- **標題**：Roboto Condensed w800，比一般 App 大一級（首頁 28–32）；中文標題同樣加粗。
- **emoji**：直接裸放（不包圓形色底），尺寸放大當插圖用。
- **輸入框**：白底、1px 邊框、radius 8，focus ring 墨黑細線。
- **禁止**：漸層、明顯陰影、彩色大面積底色（除慶祝頁）、超過三種彩色同屏。

## 修改 UI 時的檢查清單

- [ ] 新增的顏色是否來自 AppColors？（禁止 hardcode hex）
- [ ] 是否遵守 shadcn theme，未做元件層客製色？
- [ ] 圓角是否 ≤ 8（badge 6）？
- [ ] 是否用邊框而非陰影做層次？
- [ ] 次要操作是否為文字連結而非按鈕？
