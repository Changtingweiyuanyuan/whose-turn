# 圖示插畫產生 Prompt（GPT / ChatGPT 生圖用）

> 備註：這是用 **GPT（ChatGPT 生圖）** 產任務圖示線稿的固定 prompt。
> 每次只要把最後的 `Object:` 換成要畫的物件（英文），其餘保持不變，
> 就能產出風格一致的手繪線稿。產完丟到 `~/Desktop/whoseTurn`，
> 再請 Claude 處理（裁切 + 縮到 220px + 保留透明）放進 `app/assets/images/`。

## 使用方式
1. 複製下方 prompt
2. 把結尾 `Object:` 後面填要畫的物件，例如 `Object: Washing machine`
3. 丟給 ChatGPT 生圖
4. 下載 PNG → 放到 `~/Desktop/whoseTurn`
5. 告訴 Claude 檔案對應哪個任務，會自動處理進專案

## Prompt

```
Create a single object illustration.

STYLE
Minimal ink illustration.
Vintage household manual illustration.
Editorial object drawing.
Inspired by Japanese lifestyle magazines and printed encyclopedia illustrations.
The illustration should feel timeless, calm, minimal, and handcrafted.
Do NOT make it look like an icon pack, emoji, cartoon, doodle, or clipart.

VISUAL STYLE
• Black ink only
• Fine pen lines
• Slightly imperfect hand-drawn strokes
• Consistent line weight (around 2.5–3px)
• No fill colors
• No gradients
• No shading
• No textures
• No shadows
• No background
• Transparent background
• High contrast
• Vector-friendly
• Clean silhouette
• Simple but recognizable
• Moderate detail only
• Lots of negative space

COMPOSITION
• Center the object.
• Object occupies about 70% of the canvas.
• Leave generous padding around it.
• Straight front view or slight isometric view only when appropriate.
• Avoid dramatic perspective.
• Keep proportions realistic.

CONSISTENCY
This illustration is part of a 60-piece illustration library.
Every illustration must look like it was drawn by the same illustrator.
Maintain identical:
• Line quality
• Stroke width
• Detail level
• Perspective
• Composition
• Visual weight

OUTPUT
PNG
Transparent background
1024×1024
Single object only.
No text.
No labels.
No border.
No decoration.
No extra objects.

Background requirements:
- Real transparent PNG with alpha channel.
- No checkerboard pattern.
- No white background.
- No gray background.
- No canvas.
- Export with transparency.

Object:
```
