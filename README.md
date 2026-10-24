# Mothglass

Game puzzle **2D giấc mơ** — cơ chế gốc, không phải bản sao HER TREES / Monument Valley / Mirage Steps.

## Ý tưởng gốc (chưa thấy game nào làm đúng kiểu này)

> **Kéo đèn trong phòng đơn sắc. Bóng của các vật phải ghép thành một silhouette “nhớ lại”. Khi bóng phủ đủ hình ma, phòng mở.**

| Game khác | Họ làm gì | Mothglass khác chỗ nào |
|---|---|---|
| HER TREES | Kéo vật + tìm chữ → nhập lưới A–I | **Không chữ, không lưới** — chỉ bóng phủ hình |
| Monument Valley | Xoay kiến trúc 3D | **2D đổ bóng**, không xoay tượng đài |
| Match / hidden object | Tìm item | Không inventory |

## Chơi

```bash
open -a ~/Coder/Tools/Godot/Godot.app /Users/maidiepquoc/Coder/mothglass
```

F5 → **Vào giấc mơ** → kéo **đèn đen** → thanh dưới đầy khi bóng khớp silhouette mờ.

## 5 phòng

1. Đèn đầu tiên  
2. Hai bóng một cánh  
3. Vòng nhớ  
4. Chữ không chữ (cổng bóng)  
5. Bướm kính  

## Tech

- Godot **4.7** · 2D  
- Shadow cast giả lập hình học + điểm mẫu phủ silhouette  
