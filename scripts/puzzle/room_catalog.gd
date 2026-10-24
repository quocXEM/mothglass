class_name RoomCatalog
extends RefCounted

## Phòng khó: bóng ngắn, hai đảo mẫu, vùng phạt, một số phòng xoay vật (Q/E).


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
	return Loc.room_title(id)


static func whisper(id: int) -> String:
	return Loc.room_whisper(id)


static func _poly(pts: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(p)
	return out


static func _r1() -> Dictionary:
	# Tutorial rõ: 1 cột, kéo đèn SANG TRÁI → bóng phủ vùng PHẢI.
	return {
		"title": "Bóng đầu tiên",
		"whisper": "Kéo đèn. Phủ hết mọi chấm sáng.",
		"lamp": Vector2(1000, 120),
		"shadow_length": 420.0,
		"threshold": 0.88,
		"rotatable": false,
		"props": [
			{"pos": Vector2(520, 380), "poly": _poly([Vector2(-22, -80), Vector2(22, -80), Vector2(24, 80), Vector2(-24, 80)]), "sprite": "prop_pillar", "sprite_scale": Vector2(0.6, 0.85)},
		],
		"target_samples": [
			Vector2(720, 360), Vector2(760, 360), Vector2(800, 360), Vector2(840, 360),
			Vector2(740, 400), Vector2(780, 400), Vector2(820, 400), Vector2(860, 400),
		],
		# Phòng dạy — không dùng ✕ phạt (tránh báo sai khi chơi đúng)
		"anti_samples": [],
		"target_outline": _poly([
			Vector2(700, 330), Vector2(880, 330), Vector2(880, 430), Vector2(700, 430),
		]),
	}


static func _r2() -> Dictionary:
	# Hai nêm — bóng phải phủ vùng DƯỚI. Đèn đúng khoảng phía trên giữa-phải.
	return {
		"title": "Hai bóng",
		"whisper": "Hai vật. Một đèn. Phủ hình phía dưới.",
		"lamp": Vector2(80, 600),
		"shadow_length": 340.0,
		"threshold": 0.85,
		"rotatable": false,
		"props": [
			{"pos": Vector2(500, 340), "poly": _poly([Vector2(0, -70), Vector2(55, 45), Vector2(-55, 45)]), "sprite": "prop_wedge", "sprite_scale": Vector2(0.9, 0.9)},
			{"pos": Vector2(780, 340), "poly": _poly([Vector2(0, -70), Vector2(55, 45), Vector2(-55, 45)]), "sprite": "prop_wedge", "sprite_scale": Vector2(0.9, 0.9)},
		],
		"target_samples": [
			Vector2(640, 560), Vector2(610, 575), Vector2(670, 575), Vector2(640, 595),
			Vector2(590, 555), Vector2(690, 555), Vector2(620, 600), Vector2(660, 600),
		],
		"anti_samples": [
			Vector2(640, 420), Vector2(560, 400), Vector2(720, 400),
		],
		"target_outline": _poly([
			Vector2(560, 540), Vector2(720, 540), Vector2(730, 620), Vector2(550, 620),
		]),
	}


static func _r3() -> Dictionary:
	return {
		"title": "Xoay khối nhớ",
		"whisper": "Xoay. Rồi đặt đèn.",
		"lamp": Vector2(1100, 100),
		"shadow_length": 300.0,
		"threshold": 0.92,
		"rotatable": true,
		"props": [
			{"pos": Vector2(640, 360), "poly": _poly([Vector2(-42, -42), Vector2(42, -42), Vector2(42, 42), Vector2(-42, 42)]), "sprite": "prop_block", "sprite_scale": Vector2(0.95, 0.95), "can_rotate": true},
		],
		"target_samples": [
			Vector2(860, 200), Vector2(880, 195), Vector2(900, 200), Vector2(920, 210),
			Vector2(860, 230), Vector2(880, 235), Vector2(900, 230), Vector2(920, 220),
			Vector2(870, 250), Vector2(910, 250),
		],
		"anti_samples": [
			Vector2(860, 360), Vector2(900, 380), Vector2(800, 300), Vector2(980, 300), Vector2(640, 200),
		],
		"target_outline": _poly([
			Vector2(840, 180), Vector2(940, 180), Vector2(940, 265), Vector2(840, 265),
		]),
	}


static func _r4() -> Dictionary:
	return {
		"title": "Cổng lệch",
		"whisper": "Cổng không thẳng với mắt.",
		"lamp": Vector2(100, 600),
		"shadow_length": 360.0,
		"threshold": 0.9,
		"rotatable": true,
		"props": [
			{"pos": Vector2(480, 380), "poly": _poly([Vector2(-12, -100), Vector2(12, -100), Vector2(12, 100), Vector2(-12, 100)]), "sprite": "prop_pillar", "sprite_scale": Vector2(0.4, 0.85), "can_rotate": true},
			{"pos": Vector2(720, 380), "poly": _poly([Vector2(-12, -100), Vector2(12, -100), Vector2(12, 100), Vector2(-12, 100)]), "sprite": "prop_pillar", "sprite_scale": Vector2(0.4, 0.85), "can_rotate": true},
			{"pos": Vector2(600, 250), "poly": _poly([Vector2(-120, -12), Vector2(120, -12), Vector2(120, 12), Vector2(-120, 12)]), "sprite": "prop_beam", "sprite_scale": Vector2(0.9, 0.9)},
		],
		"target_samples": [
			Vector2(600, 560), Vector2(575, 575), Vector2(625, 575), Vector2(600, 595),
			Vector2(555, 555), Vector2(645, 555), Vector2(580, 600), Vector2(620, 600),
			Vector2(560, 580), Vector2(640, 580),
		],
		"anti_samples": [
			Vector2(400, 380), Vector2(800, 380), Vector2(600, 420), Vector2(500, 500), Vector2(700, 500), Vector2(600, 320),
		],
		"target_outline": _poly([
			Vector2(530, 540), Vector2(670, 540), Vector2(680, 620), Vector2(520, 620),
		]),
	}


static func _r5() -> Dictionary:
	# Đèn gần đỉnh lệch trái; bóng thân phủ cột chấm dưới — túi hẹp + xoay cánh tinh.
	return {
		"title": "Bướm kính",
		"whisper": "Đối xứng gần đúng vẫn sai.",
		"lamp": Vector2(80, 80),
		"shadow_length": 360.0,
		"threshold": 0.92,
		"rotatable": true,
		"props": [
			{"pos": Vector2(500, 340), "poly": _poly([Vector2(-25, -45), Vector2(35, 0), Vector2(-25, 45), Vector2(-40, 0)]), "sprite": "prop_wing_l", "sprite_scale": Vector2(0.9, 0.9), "can_rotate": true},
			{"pos": Vector2(780, 340), "poly": _poly([Vector2(25, -45), Vector2(-35, 0), Vector2(25, 45), Vector2(40, 0)]), "sprite": "prop_wing_r", "sprite_scale": Vector2(0.9, 0.9), "can_rotate": true},
			{"pos": Vector2(640, 340), "poly": _poly([Vector2(-8, -55), Vector2(8, -55), Vector2(8, 55), Vector2(-8, 55)]), "sprite": "prop_pillar", "sprite_scale": Vector2(0.28, 0.55)},
		],
		"target_samples": [
			Vector2(620, 540), Vector2(620, 555), Vector2(620, 570), Vector2(620, 585),
			Vector2(620, 600), Vector2(600, 560), Vector2(640, 560), Vector2(610, 590),
			Vector2(630, 590), Vector2(625, 575),
		],
		"anti_samples": [
			Vector2(640, 300), Vector2(500, 300), Vector2(780, 300), Vector2(400, 400), Vector2(880, 400),
		],
		"target_outline": _poly([
			Vector2(580, 520), Vector2(660, 520), Vector2(660, 620), Vector2(580, 620),
		]),
	}
