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
		"room.drag": "drag",
		"room.rotate": "Q  E",
		"win.title": "Remembered",
		"win.body": "The shadow holds.",
		"win.next": "Continue",
		"win.menu": "Menu",
		"room.1.title": "Two Islands",
		"room.1.whisper": "One lamp. Two remembered spaces.",
		"room.2.title": "Narrow Angle",
		"room.2.whisper": "Narrower than it looks.",
		"room.3.title": "Turning Memory",
		"room.3.whisper": "Turn. Then place the lamp.",
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
		"room.drag": "kéo",
		"room.rotate": "Q  E",
		"win.title": "Đã nhớ",
		"win.body": "Bóng giữ hình.",
		"win.next": "Tiếp",
		"win.menu": "Menu",
		"room.1.title": "Hai đảo bóng",
		"room.1.whisper": "Một đèn. Hai khoảng nhớ.",
		"room.2.title": "Góc hẹp",
		"room.2.whisper": "Góc hẹp hơn bạn nghĩ.",
		"room.3.title": "Xoay khối nhớ",
		"room.3.whisper": "Xoay. Rồi đặt đèn.",
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
