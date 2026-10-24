class_name RoomCatalog
extends RefCounted

## Mỗi phòng: props (đa giác), lamp spawn, target silhouette (điểm mẫu).
## Cơ chế gốc: bóng đổ từ đèn phải phủ silhouette — không phải chữ/grid như HER TREES.


static func count() -> int:
	return 5


static func get_room(id: int) -> Dictionary:
	match id:
		1: return _r1()
		2: return _r2()
		3: return _r3()
		4: return _r4()
		5: return _r5()
		_: return _r1()


static func title(id: int) -> String:
	return str(get_room(id).get("title", "Room %d" % id))


static func whisper(id: int) -> String:
	return str(get_room(id).get("whisper", ""))


static func _poly(pts: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(p)
	return out


static func _r1() -> Dictionary:
	# Bóng cột + thanh ngang phủ silhouette chìa ở bên phải — đèn bắt đầu ở góc xa
	return {
		"title": "Đèn đầu tiên",
		"whisper": "Kéo đèn. Để bóng nhớ lại một hình không có trên bàn.",
		"lamp": Vector2(1000, 120),
		"props": [
			{"pos": Vector2(640, 420), "poly": _poly([Vector2(-18, -70), Vector2(18, -70), Vector2(22, 70), Vector2(-22, 70)])},
			{"pos": Vector2(640, 300), "poly": _poly([Vector2(-40, -8), Vector2(40, -8), Vector2(40, 8), Vector2(-40, 8)])},
		],
		"target_samples": [
			Vector2(900, 280), Vector2(940, 280), Vector2(980, 280),
			Vector2(920, 320), Vector2(960, 320), Vector2(1000, 320),
		],
		"target_outline": _poly([
			Vector2(880, 260), Vector2(1020, 260), Vector2(1020, 340), Vector2(880, 340),
		]),
		"hint_zone": Rect2(40, 480, 180, 140),
	}


static func _r2() -> Dictionary:
	return {
		"title": "Hai bóng một cánh",
		"whisper": "Hai vật. Một đèn. Bóng phải chạm nhau thành một cánh.",
		"lamp": Vector2(200, 200),
		"props": [
			{"pos": Vector2(520, 380), "poly": _poly([Vector2(0, -60), Vector2(50, 40), Vector2(-50, 40)])},
			{"pos": Vector2(760, 380), "poly": _poly([Vector2(0, -60), Vector2(50, 40), Vector2(-50, 40)])},
		],
		"target_samples": [
			Vector2(640, 520), Vector2(600, 560), Vector2(680, 560),
			Vector2(640, 600), Vector2(580, 540), Vector2(700, 540),
		],
		"target_outline": _poly([
			Vector2(560, 500), Vector2(720, 500), Vector2(740, 620), Vector2(540, 620),
		]),
		"hint_zone": Rect2(560, 160, 160, 80),
	}


static func _r3() -> Dictionary:
	return {
		"title": "Vòng nhớ",
		"whisper": "Đèn ở ngoài vòng. Bóng phải tô kín vùng nhớ bên phải.",
		"lamp": Vector2(1100, 100),
		"props": [
			{"pos": Vector2(640, 360), "poly": _poly([
				Vector2(-48, -48), Vector2(48, -48), Vector2(48, 48), Vector2(-48, 48)
			])},
		],
		"target_samples": [
			Vector2(780, 360), Vector2(820, 360), Vector2(860, 360), Vector2(880, 360),
			Vector2(800, 340), Vector2(800, 380), Vector2(840, 340), Vector2(840, 380),
		],
		"target_outline": _poly([
			Vector2(760, 320), Vector2(900, 320), Vector2(900, 400), Vector2(760, 400),
		]),
		"hint_zone": Rect2(40, 240, 160, 160),
	}


static func _r4() -> Dictionary:
	return {
		"title": "Chữ không chữ",
		"whisper": "Không có bảng chữ. Chỉ có bóng tạo một cổng.",
		"lamp": Vector2(1100, 560),
		"props": [
			{"pos": Vector2(500, 400), "poly": _poly([Vector2(-14, -90), Vector2(14, -90), Vector2(14, 90), Vector2(-14, 90)])},
			{"pos": Vector2(700, 400), "poly": _poly([Vector2(-14, -90), Vector2(14, -90), Vector2(14, 90), Vector2(-14, 90)])},
			{"pos": Vector2(600, 280), "poly": _poly([Vector2(-90, -14), Vector2(90, -14), Vector2(90, 14), Vector2(-90, 14)])},
		],
		"target_samples": [
			Vector2(600, 520), Vector2(560, 560), Vector2(640, 560),
			Vector2(600, 600), Vector2(520, 500), Vector2(680, 500),
		],
		"target_outline": _poly([
			Vector2(500, 480), Vector2(700, 480), Vector2(720, 640), Vector2(480, 640),
		]),
		"hint_zone": Rect2(980, 80, 140, 100),
	}


static func _r5() -> Dictionary:
	return {
		"title": "Bướm kính",
		"whisper": "Hình cuối: đôi cánh chỉ hiện khi bóng đối xứng đủ.",
		"lamp": Vector2(640, 120),
		"props": [
			{"pos": Vector2(520, 360), "poly": _poly([Vector2(-20, -40), Vector2(30, 0), Vector2(-20, 40), Vector2(-35, 0)])},
			{"pos": Vector2(760, 360), "poly": _poly([Vector2(20, -40), Vector2(-30, 0), Vector2(20, 40), Vector2(35, 0)])},
			{"pos": Vector2(640, 360), "poly": _poly([Vector2(-10, -50), Vector2(10, -50), Vector2(10, 50), Vector2(-10, 50)])},
		],
		"target_samples": [
			Vector2(640, 520), Vector2(560, 480), Vector2(720, 480),
			Vector2(520, 540), Vector2(760, 540), Vector2(640, 580),
			Vector2(580, 500), Vector2(700, 500),
		],
		"target_outline": _poly([
			Vector2(480, 450), Vector2(640, 490), Vector2(800, 450),
			Vector2(780, 600), Vector2(640, 560), Vector2(500, 600),
		]),
		"hint_zone": Rect2(580, 80, 120, 80),
	}


static func _circle_samples(c: Vector2, r: float, n: int) -> Array:
	var arr: Array = []
	for i in n:
		var a := TAU * float(i) / float(n)
		arr.append(c + Vector2(cos(a), sin(a)) * r)
	arr.append(c)
	return arr


static func _circle_outline(c: Vector2, r: float, n: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in n:
		var a := TAU * float(i) / float(n)
		out.append(c + Vector2(cos(a), sin(a)) * r)
	return out
