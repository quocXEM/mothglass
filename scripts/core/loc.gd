extends Node
## Lightweight localization (EN default — international ship).

signal language_changed(code: String)

const SUPPORTED := ["en", "vi"]

var code: String = "en"

var _t := {
	"en": {
		"game.title": "Mothglass",
		"game.tagline": "Shadows that remember a shape.",
		"menu.enter": "Enter",
		"menu.chambers": "Chambers",
		"menu.settings": "Settings",
		"menu.credits": "Credits",
		"menu.leave": "Leave",
		"menu.continue": "Continue",
		"settings.title": "Settings",
		"settings.language": "Language",
		"settings.volume": "Volume",
		"settings.mute": "Mute",
		"settings.back": "Back",
		"credits.title": "Credits",
		"credits.body": "Design & code — Mothglass studio build\nArt pipeline — Blender + Godot 4\nFonts — Cormorant Garamond, Literata (OFL)",
		"credits.back": "Back",
		"chambers.title": "Chambers",
		"chambers.locked": "Sealed",
		"chambers.back": "Back",
		"room.menu": "Menu",
		"room.again": "Again",
		"room.pause": "Paused",
		"room.resume": "Resume",
		"room.drag": "drag lamp",
		"room.rotate": "Q  E  rotate",
		"win.title": "Remembered",
		"win.body": "The shadow holds.",
		"win.next": "Continue",
		"win.menu": "Menu",
		"hint.goal": "Drag the lamp until shadow covers every glowing dot.",
		"hint.low": "Drag the lamp — the dark shadow must move onto the dots.",
		"hint.mid": "Good — cover more glowing dots.",
		"hint.high": "Almost — nudge the lamp and hold.",
		"hint.hold": "Perfect — hold still…",
		"hint.anti": "Shadow is on a forbidden ✕ — move the lamp.",
		"hint.cover": "Dots covered: %d / %d",
		"zone.fill": "COVER THESE DOTS",
		"rule.bar": "GOAL: Cover the glowing dots with the object's shadow.",
		"legend.lamp": "Lamp (drag)",
		"legend.object": "Object (casts shadow)",
		"legend.target": "Dots (must be covered)",
		"coach.title": "How to play",
		"coach.1": "1. Drag the glowing lamp.",
		"coach.2": "2. Solid objects cast a dark shadow.",
		"coach.3": "3. Cover every glowing dot. Hold to finish.",
		"coach.ok": "Got it",
		"room.1.title": "First Shadow",
		"room.1.whisper": "Drag the lamp left of the pillar until dots light up.",
		"room.2.title": "Two Shadows",
		"room.2.whisper": "Place the lamp so both shadows cover the dots below.",
		"room.3.title": "Turning Memory",
		"room.3.whisper": "Rotate with Q/E, then place the lamp.",
		"room.4.title": "Skewed Gate",
		"room.4.whisper": "The gate is not true to the eye.",
		"room.5.title": "Glass Moth",
		"room.5.whisper": "Near-symmetry is still wrong.",
	},
	"vi": {
		"game.title": "Mothglass",
		"game.tagline": "Bóng nhớ lại một hình.",
		"menu.enter": "Vào",
		"menu.chambers": "Các phòng",
		"menu.settings": "Cài đặt",
		"menu.credits": "Credits",
		"menu.leave": "Thoát",
		"menu.continue": "Tiếp tục",
		"settings.title": "Cài đặt",
		"settings.language": "Ngôn ngữ",
		"settings.volume": "Âm lượng",
		"settings.mute": "Tắt tiếng",
		"settings.back": "Quay lại",
		"credits.title": "Credits",
		"credits.body": "Thiết kế & code — bản studio Mothglass\nArt — Blender + Godot 4\nFont — Cormorant Garamond, Literata (OFL)",
		"credits.back": "Quay lại",
		"chambers.title": "Các phòng",
		"chambers.locked": "Đóng",
		"chambers.back": "Quay lại",
		"room.menu": "Menu",
		"room.again": "Lại",
		"room.pause": "Tạm dừng",
		"room.resume": "Tiếp",
		"room.drag": "kéo đèn",
		"room.rotate": "Q  E  xoay",
		"win.title": "Đã nhớ",
		"win.body": "Bóng giữ hình.",
		"win.next": "Tiếp",
		"win.menu": "Menu",
		"hint.goal": "Kéo đèn đến khi bóng phủ hết mọi chấm sáng.",
		"hint.low": "Kéo đèn — bóng đen phải chạy lên các chấm.",
		"hint.mid": "Tốt — phủ thêm chấm sáng.",
		"hint.high": "Sắp xong — chỉnh nhẹ và giữ.",
		"hint.hold": "Đúng rồi — giữ yên…",
		"hint.anti": "Bóng đang đè lên ✕ cấm — kéo đèn chỗ khác.",
		"hint.cover": "Đã phủ: %d / %d chấm",
		"zone.fill": "PHỦ CÁC CHẤM NÀY",
		"rule.bar": "MỤC TIÊU: Phủ chấm sáng bằng bóng của vật.",
		"legend.lamp": "Đèn (kéo)",
		"legend.object": "Vật (tạo bóng)",
		"legend.target": "Chấm (cần phủ)",
		"coach.title": "Cách chơi",
		"coach.1": "1. Kéo đèn sáng.",
		"coach.2": "2. Vật đặc tạo bóng đen.",
		"coach.3": "3. Phủ hết chấm sáng. Giữ yên để xong.",
		"coach.ok": "Hiểu rồi",
		"room.1.title": "Bóng đầu tiên",
		"room.1.whisper": "Kéo đèn sang trái cột đến khi chấm sáng hết.",
		"room.2.title": "Hai bóng",
		"room.2.whisper": "Đặt đèn để hai bóng phủ hết chấm phía dưới.",
		"room.3.title": "Xoay khối nhớ",
		"room.3.whisper": "Xoay Q/E, rồi đặt đèn.",
		"room.4.title": "Cổng lệch",
		"room.4.whisper": "Cổng không thẳng với mắt.",
		"room.5.title": "Bướm kính",
		"room.5.whisper": "Đối xứng gần đúng vẫn sai.",
	},
}


func tr_key(key: String) -> String:
	var table: Dictionary = _t.get(code, _t["en"])
	if table.has(key):
		return str(table[key])
	return str(_t["en"].get(key, key))


func set_language(new_code: String) -> void:
	if new_code not in SUPPORTED:
		return
	code = new_code
	language_changed.emit(code)


func room_title(id: int) -> String:
	return tr_key("room.%d.title" % id)


func room_whisper(id: int) -> String:
	return tr_key("room.%d.whisper" % id)
