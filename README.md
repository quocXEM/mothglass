# Mothglass

Puzzle **ảo giác bóng đổ** gốc — không chữ/grid (HER TREES), không xoay kiến trúc 3D (Monument Valley).

## Chơi

```bash
open -a ~/Coder/Tools/Godot/Godot.app /Users/maidiepquoc/Coder/mothglass
```

Kéo đèn · bóng **ngắn** phải phủ chấm đỏ · tránh dấu **X** (phạt) · phòng sau: **Q/E** xoay vật.

## Art pipeline

- **Blender 4.5** (`tools/blender_render_pro.py`) — đèn, cột, nêm, cánh, hall  
- Nền giấc mơ + vignette trong `assets/art/`

## Tech

Godot **4.7** · shadow math + anti-samples · threshold ≥ 0.9  
