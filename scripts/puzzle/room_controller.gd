extends Node2D

signal solved

const ART := "res://assets/art/"

@onready var lamp: Area2D = $World/Lamp
@onready var lamp_hint: Label = $World/Lamp/LampHint
@onready var lamp_sprite: Sprite2D = $World/Lamp/LampSprite
@onready var props_root: Node2D = $World/Props
@onready var shadows: Node2D = $World/Shadows
@onready var target_ghost: Node2D = $World/TargetGhost
@onready var bg: Sprite2D = $World/Background
@onready var vignette: Sprite2D = $World/Vignette
@onready var progress: ProgressBar = $UI/Progress
@onready var progress_label: Label = $UI/ProgressLabel
@onready var title_l: Label = $UI/Title
@onready var whisper_l: Label = $UI/Whisper
@onready var badge: Label = $UI/Badge
@onready var rotate_hint: Label = $UI/RotateHint
@onready var btn_back: Button = $UI/Top/BtnBack
@onready var btn_retry: Button = $UI/Top/BtnRetry
@onready var win_panel: PanelContainer = $UI/Win
@onready var btn_next: Button = $UI/Win/VBox/BtnNext
@onready var btn_menu: Button = $UI/Win/VBox/BtnMenu
@onready var how_to: PanelContainer = $UI/HowTo

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


func _ready() -> void:
	btn_back.pressed.connect(func() -> void: AudioBus.play_soft(); GameState.goto_menu())
	btn_retry.pressed.connect(func() -> void: AudioBus.play_soft(); _load_room(GameState.current_room))
	btn_next.pressed.connect(_on_next)
	btn_menu.pressed.connect(func() -> void: AudioBus.play_soft(); GameState.goto_menu())
	win_panel.visible = false
	lamp.input_event.connect(_on_lamp_input)
	_setup_art()
	_load_room(GameState.current_room)


func _setup_art() -> void:
	# Prefer dream atmosphere photo+paint, fallback Blender hall
	var dream := ART + "bg_dream.jpg"
	var hall := ART + "bg_room.png"
	if ResourceLoader.exists(dream):
		bg.texture = load(dream)
	elif ResourceLoader.exists(hall):
		bg.texture = load(hall)
	bg.centered = false
	bg.position = Vector2.ZERO
	bg.scale = Vector2(1280.0 / maxf(bg.texture.get_width(), 1), 720.0 / maxf(bg.texture.get_height(), 1))
	bg.modulate = Color(1, 1, 1, 0.92)

	if ResourceLoader.exists(ART + "vignette.png"):
		vignette.texture = load(ART + "vignette.png")
		vignette.centered = false
		vignette.position = Vector2.ZERO
		vignette.modulate = Color(1, 1, 1, 0.85)

	if ResourceLoader.exists(ART + "lamp.png"):
		lamp_sprite.texture = load(ART + "lamp.png")
		lamp_sprite.centered = true
		lamp_sprite.scale = Vector2(0.22, 0.22)
		# Hide procedural shapes if sprite present
		for n in ["Halo", "Body", "Glass", "Flame", "Base"]:
			var node := lamp.get_node_or_null(n)
			if node:
				node.visible = false


func _load_room(id: int) -> void:
	_solved = false
	win_panel.visible = false
	how_to.visible = id <= 2
	for c in props_root.get_children():
		c.queue_free()
	for c in shadows.get_children():
		c.queue_free()

	var data: Dictionary = RoomCatalog.get_room(id)
	title_l.text = RoomCatalog.title(id)
	whisper_l.text = RoomCatalog.whisper(id)
	badge.text = "Phòng %d / %d · Khó" % [id, GameState.TOTAL_ROOMS]
	lamp.position = data.lamp
	_samples = data.target_samples
	_anti = data.get("anti_samples", [])
	_shadow_len = float(data.get("shadow_length", 320.0))
	_threshold = float(data.get("threshold", 0.9))
	_rotatable = bool(data.get("rotatable", false))
	rotate_hint.visible = _rotatable
	rotate_hint.text = "Q / E — xoay vật" if _rotatable else ""

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
		var tex_path := ART + sprite_name + ".png"
		if sprite_name != "" and ResourceLoader.exists(tex_path):
			var spr := Sprite2D.new()
			spr.texture = load(tex_path)
			spr.centered = true
			spr.scale = p.get("sprite_scale", Vector2(0.7, 0.7))
			holder.add_child(spr)
		else:
			var poly := Polygon2D.new()
			poly.polygon = p.poly
			poly.color = Color(0.32, 0.26, 0.2, 1)
			holder.add_child(poly)

		# Invisible collision poly kept for shadow math
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
			how_to.visible = false
			AudioBus.play_soft()
		else:
			_dragging = false


func _unhandled_input(event: InputEvent) -> void:
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


func _process(delta: float) -> void:
	_hint_pulse += delta * 3.0
	if not _dragging and not _solved:
		var s := 1.0 + 0.05 * sin(_hint_pulse)
		lamp.scale = Vector2(s, s)
		lamp_hint.visible = true
		lamp_hint.modulate.a = 0.55 + 0.45 * absf(sin(_hint_pulse))
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
		var draw := Polygon2D.new()
		draw.polygon = _to_local_poly(sh)
		draw.color = Color(0.08, 0.09, 0.14, 0.58)
		shadows.add_child(draw)

	var result: Dictionary = ShadowMath.solve_score(_samples, _anti, shadow_polys)
	_coverage = float(result.score)
	progress.value = _coverage * 100.0
	progress_label.text = "Khớp bóng: %d%%  ·  phạt %d%%" % [
		int(float(result.good) * 100.0), int(float(result.bad) * 100.0)
	]

	var flags: Array = []
	for s in _samples:
		var ok := false
		for sh in shadow_polys:
			if ShadowMath.point_in_poly(s, sh):
				ok = true
				break
		flags.append(ok)
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

	if not _solved and _coverage >= _threshold and float(result.bad) <= 0.25:
		_on_solved()


func _to_local_poly(global_poly: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in global_poly:
		out.append(shadows.to_local(p))
	return out


func _on_solved() -> void:
	_solved = true
	_dragging = false
	lamp_hint.visible = false
	how_to.visible = false
	AudioBus.play_solve()
	GameState.mark_done(GameState.current_room)
	win_panel.visible = true
	win_panel.modulate.a = 0.0
	create_tween().tween_property(win_panel, "modulate:a", 1.0, 0.45)
	solved.emit()


func _on_next() -> void:
	AudioBus.play_soft()
	if GameState.current_room >= GameState.TOTAL_ROOMS:
		GameState.goto_menu()
		return
	GameState.current_room += 1
	GameState.save()
	_load_room(GameState.current_room)
