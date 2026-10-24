extends Node2D

signal solved

const ART := "res://assets/art/"
const STYLED := "res://assets/art/styled/"

@onready var lamp: Area2D = $World/Lamp
@onready var lamp_hint: Label = $World/Lamp/LampHint
@onready var lamp_sprite: Sprite2D = $World/Lamp/LampSprite
@onready var props_root: Node2D = $World/Props
@onready var shadows: Node2D = $World/Shadows
@onready var target_ghost: Node2D = $World/TargetGhost
@onready var bg: Sprite2D = $World/Background
@onready var vignette: Sprite2D = $World/Vignette
@onready var ink_track: ColorRect = %InkTrack
@onready var ink_fill: ColorRect = %InkFill
@onready var title_l: Label = $UI/Title
@onready var whisper_l: Label = $UI/Whisper
@onready var badge: Label = $UI/Badge
@onready var rotate_hint: Label = $UI/RotateHint
@onready var btn_back: Button = $UI/Top/BtnBack
@onready var btn_retry: Button = $UI/Top/BtnRetry
@onready var win_panel: PanelContainer = $UI/Win
@onready var win_title: Label = $UI/Win/VBox/WinTitle
@onready var win_body: Label = $UI/Win/VBox/WinBody
@onready var btn_next: Button = $UI/Win/VBox/BtnNext
@onready var btn_menu: Button = $UI/Win/VBox/BtnMenu
@onready var pause_panel: PanelContainer = $UI/Pause
@onready var pause_title: Label = $UI/Pause/VBox/PauseTitle
@onready var btn_resume: Button = $UI/Pause/VBox/BtnResume

var _dragging := false
var _drag_off := Vector2.ZERO
var _prop_data: Array = []
var _samples: Array = []
var _anti: Array = []
var _solved := false
var _coverage := 0.0
var _hint_pulse := 0.0
var _shadow_len := 320.0
var _threshold := 0.9
var _rotatable := false
var _whisper_shown := true
var _paused := false
var _solve_hold := 0.0
const SOLVE_HOLD_SEC := 0.7
var _rays: Node2D
var _stage: Polygon2D
var _last_bad := 0.0
var _dots_ok := 0
var _dots_total := 0


func _ready() -> void:
	btn_back.pressed.connect(func() -> void: AudioBus.play_ui(); GameState.goto_menu())
	btn_retry.pressed.connect(func() -> void: AudioBus.play_ui(); _load_room(GameState.current_room))
	btn_next.pressed.connect(_on_next)
	btn_menu.pressed.connect(func() -> void: AudioBus.play_ui(); GameState.goto_menu())
	btn_resume.pressed.connect(_toggle_pause)
	win_panel.visible = false
	pause_panel.visible = false
	lamp.input_event.connect(_on_lamp_input)
	_setup_art()
	_spawn_dust()
	_load_room(GameState.current_room)
	_refresh_chrome()
	Loc.language_changed.connect(func(_c): _refresh_chrome())
	if not GameState.coach_seen:
		var coach: CanvasLayer = (load("res://scripts/ui/coach_overlay.gd") as GDScript).new()
		add_child(coach)
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.55)


func _spawn_dust() -> void:
	var dust: Node2D = (load("res://scripts/fx/dust_motes.gd") as GDScript).new()
	$World.add_child(dust)


func _refresh_chrome() -> void:
	btn_back.text = Loc.tr_key("room.menu")
	btn_retry.text = Loc.tr_key("room.again")
	# Lamp hint only on tutorial rooms, fades after first drag
	lamp_hint.text = Loc.tr_key("room.drag") if GameState.current_room <= 2 else ""
	rotate_hint.text = Loc.tr_key("room.rotate")
	win_title.text = Loc.tr_key("win.title")
	win_body.text = Loc.tr_key("win.body")
	btn_next.text = Loc.tr_key("win.next")
	btn_menu.text = Loc.tr_key("win.menu")
	pause_title.text = Loc.tr_key("room.pause")
	btn_resume.text = Loc.tr_key("room.resume")
	if GameState.current_room >= 1:
		title_l.text = Loc.room_title(GameState.current_room)
		whisper_l.text = ""


func _tex(name: String) -> Texture2D:
	var styled := STYLED + name
	var raw := ART + name
	if ResourceLoader.exists(styled):
		return load(styled)
	if ResourceLoader.exists(raw):
		return load(raw)
	return null


func _setup_art() -> void:
	# Play rooms use hall WITHOUT wall-moth art (avoids confusing decoration with puzzle)
	var hall := ART + "bg_room.png"
	var dream := ART + "bg_dream.jpg"
	if ResourceLoader.exists(hall):
		bg.texture = load(hall)
	elif ResourceLoader.exists(dream):
		bg.texture = load(dream)
	bg.centered = false
	bg.position = Vector2.ZERO
	if bg.texture:
		bg.scale = Vector2(1280.0 / float(bg.texture.get_width()), 720.0 / float(bg.texture.get_height()))
	bg.modulate = Color(0.72, 0.68, 0.62, 1)

	if ResourceLoader.exists(ART + "vignette.png"):
		vignette.texture = load(ART + "vignette.png")
		vignette.centered = false
		vignette.position = Vector2.ZERO
		vignette.modulate = Color(1, 1, 1, 0.95)

	# Puzzle stage — separates play area from background moth decoration
	if _stage == null:
		_stage = Polygon2D.new()
		_stage.z_index = -2
		_stage.color = Color(0.12, 0.1, 0.09, 0.45)
		_stage.polygon = PackedVector2Array([
			Vector2(80, 120), Vector2(1200, 120), Vector2(1200, 660), Vector2(80, 660),
		])
		$World.add_child(_stage)
		$World.move_child(_stage, 1)
	if _rays == null:
		_rays = Node2D.new()
		_rays.z_index = 0
		$World.add_child(_rays)

	var lamp_tex := _tex("lamp.png")
	if lamp_tex:
		lamp_sprite.texture = lamp_tex
		lamp_sprite.centered = true
		lamp_sprite.scale = Vector2(0.2, 0.2)
		lamp_sprite.modulate = Color(1, 1, 1, 0.98)


func _roman(n: int) -> String:
	var map := {1: "I", 2: "II", 3: "III", 4: "IV", 5: "V"}
	return str(map.get(n, str(n)))


func _load_room(id: int) -> void:
	_solved = false
	_solve_hold = 0.0
	_whisper_shown = true
	win_panel.visible = false
	for c in props_root.get_children():
		c.queue_free()
	for c in shadows.get_children():
		c.queue_free()

	var data: Dictionary = RoomCatalog.get_room(id)
	title_l.text = Loc.room_title(id)
	whisper_l.text = Loc.room_whisper(id)
	whisper_l.modulate.a = 0.7
	badge.text = _roman(id)
	_refresh_chrome()
	lamp.position = data.lamp
	_samples = data.target_samples
	_anti = data.get("anti_samples", [])
	_shadow_len = float(data.get("shadow_length", 320.0))
	_threshold = float(data.get("threshold", 0.9))
	_rotatable = bool(data.get("rotatable", false))
	rotate_hint.visible = _rotatable

	var outlines: Array = [data.target_outline]
	if data.has("target_outline_b"):
		outlines.append(data.target_outline_b)
	if target_ghost.has_method("set_target"):
		target_ghost.set_target(outlines, _samples, _anti)

	_prop_data.clear()
	for p in data.props:
		var holder := Node2D.new()
		holder.position = p.pos
		props_root.add_child(holder)

		var sprite_name: String = str(p.get("sprite", ""))
		var tex := _tex(sprite_name + ".png") if sprite_name != "" else null
		if tex:
			var spr := Sprite2D.new()
			spr.texture = tex
			spr.centered = true
			spr.scale = p.get("sprite_scale", Vector2(0.7, 0.7))
			spr.modulate = Color(1, 0.98, 0.94, 1)
			holder.add_child(spr)
		else:
			var poly := Polygon2D.new()
			poly.polygon = p.poly
			poly.color = Color(0.28, 0.24, 0.2, 1)
			holder.add_child(poly)
		# Bright rim so props don't vanish into background
		var rim := Line2D.new()
		rim.width = 3.0
		rim.default_color = Color(0.95, 0.88, 0.7, 0.75)
		rim.closed = true
		for pt in p.poly:
			rim.add_point(pt)
		holder.add_child(rim)

		_prop_data.append({
			"node": holder,
			"local": p.poly,
			"can_rotate": bool(p.get("can_rotate", _rotatable)),
			"angle": 0.0,
		})

	_rebuild_shadows()


func _on_lamp_input(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_off = lamp.global_position - get_global_mouse_position()
			lamp_hint.visible = false
			AudioBus.play_soft()
		else:
			_dragging = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_toggle_pause()
		return
	if _paused:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_dragging = false
	if _solved or not _rotatable:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var delta := 0.0
		if event.keycode == KEY_Q:
			delta = -0.08
		elif event.keycode == KEY_E:
			delta = 0.08
		if delta != 0.0:
			for item in _prop_data:
				if item.can_rotate:
					item.angle += delta
					item.node.rotation = item.angle
			_rebuild_shadows()
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var d := -0.07 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.07
			for item in _prop_data:
				if item.can_rotate:
					item.angle += d
					item.node.rotation = item.angle
			_rebuild_shadows()


func _toggle_pause() -> void:
	if _solved:
		return
	_paused = not _paused
	pause_panel.visible = _paused
	_dragging = false
	AudioBus.play_ui()


func _process(delta: float) -> void:
	if _paused:
		return
	_hint_pulse += delta * 2.4
	if not _dragging and not _solved:
		var s := 1.0 + 0.035 * sin(_hint_pulse)
		lamp.scale = Vector2(s, s)
		lamp_hint.visible = true
		lamp_hint.modulate.a = 0.35 + 0.35 * absf(sin(_hint_pulse))
	else:
		lamp.scale = Vector2.ONE

	if _dragging and not _solved:
		lamp.global_position = get_global_mouse_position() + _drag_off
		lamp.global_position.x = clampf(lamp.global_position.x, 40, 1240)
		lamp.global_position.y = clampf(lamp.global_position.y, 40, 680)
		_rebuild_shadows()


func _rebuild_shadows() -> void:
	for c in shadows.get_children():
		c.queue_free()
	var lamp_pos := lamp.global_position
	var shadow_polys: Array = []
	for item in _prop_data:
		var node: Node2D = item.node
		var local: PackedVector2Array = item.local
		node.rotation = float(item.angle)
		var global_poly := PackedVector2Array()
		for pt in local:
			global_poly.append(node.to_global(pt))
		var sh := ShadowMath.cast_shadow(global_poly, lamp_pos, _shadow_len)
		shadow_polys.append(sh)
		_draw_soft_shadow(sh)

	var result: Dictionary = ShadowMath.solve_score(_samples, _anti, shadow_polys)
	_coverage = float(result.score)
	_last_bad = float(result.bad)
	_set_ink(_coverage)
	_update_feedback()
	_draw_rays(lamp_pos)

	var flags: Array = []
	_dots_ok = 0
	_dots_total = _samples.size()
	for s in _samples:
		var ok := false
		for sh in shadow_polys:
			if ShadowMath.point_in_poly(s, sh):
				ok = true
				break
		flags.append(ok)
		if ok:
			_dots_ok += 1
	var aflags: Array = []
	for s in _anti:
		var ok := false
		for sh in shadow_polys:
			if ShadowMath.point_in_poly(s, sh):
				ok = true
				break
		aflags.append(ok)
	if target_ghost.has_method("set_covered"):
		target_ghost.set_covered(flags, aflags)
	if target_ghost.has_method("set_progress"):
		target_ghost.set_progress(_coverage)

	# Must hold the match — không thắng khi kéo lướt qua túi hẹp
	var matching := (not _solved) and _coverage >= _threshold and float(result.bad) <= 0.25
	if matching:
		_solve_hold += get_process_delta_time()
		if target_ghost.has_method("set_hold"):
			target_ghost.set_hold(_solve_hold / SOLVE_HOLD_SEC)
		if _solve_hold >= SOLVE_HOLD_SEC:
			_on_solved()
	else:
		_solve_hold = 0.0
		if target_ghost.has_method("set_hold"):
			target_ghost.set_hold(0.0)


func _set_ink(t: float) -> void:
	var full := 128.0
	var w := full * clampf(t, 0.0, 1.0)
	ink_fill.offset_left = -64.0
	ink_fill.offset_right = -64.0 + w
	ink_fill.modulate.a = lerpf(0.35, 0.9, t)


func _update_feedback() -> void:
	# Quiet: only speak on error or hold — dots/ink teach the rest
	if _anti.size() > 0 and _last_bad > 0.25:
		whisper_l.text = Loc.tr_key("hint.anti")
		whisper_l.modulate.a = 0.75
	elif _solve_hold > 0.05:
		whisper_l.text = Loc.tr_key("hint.hold")
		whisper_l.modulate.a = 0.7
	else:
		whisper_l.text = ""
		whisper_l.modulate.a = 0.0
	if target_ghost.has_method("set_status"):
		target_ghost.set_status("")


func _draw_rays(lamp_pos: Vector2) -> void:
	if _rays == null:
		return
	for c in _rays.get_children():
		c.queue_free()
	for item in _prop_data:
		var node: Node2D = item.node
		var line := Line2D.new()
		line.width = 1.5
		line.default_color = Color(1.0, 0.9, 0.55, 0.18)
		line.add_point(_rays.to_local(lamp_pos))
		line.add_point(_rays.to_local(node.global_position))
		_rays.add_child(line)


func _draw_soft_shadow(sh: PackedVector2Array) -> void:
	# Darker, clearer shadows so cause→effect is obvious
	var layers := [
		{"scale": 1.08, "a": 0.14, "off": Vector2(12, 10)},
		{"scale": 1.03, "a": 0.22, "off": Vector2(6, 5)},
		{"scale": 1.0, "a": 0.48, "off": Vector2.ZERO},
	]
	var center := Vector2.ZERO
	for p in sh:
		center += p
	center /= float(maxi(sh.size(), 1))
	for layer in layers:
		var poly := PackedVector2Array()
		for p in sh:
			var q: Vector2 = center + (p - center) * float(layer.scale) + layer.off
			poly.append(shadows.to_local(q))
		var draw := Polygon2D.new()
		draw.polygon = poly
		draw.color = Color(0.06, 0.05, 0.07, float(layer.a))
		shadows.add_child(draw)


func _on_solved() -> void:
	_solved = true
	_dragging = false
	_paused = false
	pause_panel.visible = false
	lamp_hint.visible = false
	AudioBus.play_solve()
	SceneRouter.flash_white(0.4)
	GameState.mark_done(GameState.current_room)
	win_panel.visible = true
	win_panel.modulate.a = 0.0
	create_tween().tween_property(win_panel, "modulate:a", 1.0, 0.55)
	solved.emit()


func _on_next() -> void:
	AudioBus.play_soft()
	if GameState.current_room >= GameState.TOTAL_ROOMS:
		GameState.goto_menu()
		return
	GameState.current_room += 1
	GameState.save()
	_load_room(GameState.current_room)
