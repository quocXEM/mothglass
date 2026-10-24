extends Node2D

signal solved

@onready var lamp: Area2D = $World/Lamp
@onready var lamp_hint: Label = $World/Lamp/LampHint
@onready var props_root: Node2D = $World/Props
@onready var shadows: Node2D = $World/Shadows
@onready var target_ghost: Node2D = $World/TargetGhost
@onready var progress: ProgressBar = $UI/Progress
@onready var progress_label: Label = $UI/ProgressLabel
@onready var title_l: Label = $UI/Title
@onready var whisper_l: Label = $UI/Whisper
@onready var badge: Label = $UI/Badge
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
var _solved := false
var _coverage := 0.0
var _hint_pulse := 0.0


func _ready() -> void:
	btn_back.pressed.connect(func() -> void: AudioBus.play_soft(); GameState.goto_menu())
	btn_retry.pressed.connect(func() -> void: AudioBus.play_soft(); _load_room(GameState.current_room))
	btn_next.pressed.connect(_on_next)
	btn_menu.pressed.connect(func() -> void: AudioBus.play_soft(); GameState.goto_menu())
	win_panel.visible = false
	lamp.input_event.connect(_on_lamp_input)
	_load_room(GameState.current_room)


func _load_room(id: int) -> void:
	_solved = false
	win_panel.visible = false
	how_to.visible = true
	for c in props_root.get_children():
		c.queue_free()
	for c in shadows.get_children():
		c.queue_free()

	var data: Dictionary = RoomCatalog.get_room(id)
	title_l.text = RoomCatalog.title(id)
	whisper_l.text = RoomCatalog.whisper(id)
	badge.text = "Phòng %d / %d" % [id, GameState.TOTAL_ROOMS]
	lamp.position = data.lamp
	_samples = data.target_samples
	if target_ghost.has_method("set_target"):
		target_ghost.set_target(data.target_outline, _samples)

	_prop_data.clear()
	for p in data.props:
		var holder := Node2D.new()
		holder.position = p.pos
		props_root.add_child(holder)

		var base := Polygon2D.new()
		base.polygon = p.poly
		base.color = Color(0.62, 0.48, 0.32, 0.4)
		base.position = Vector2(5, 7)
		holder.add_child(base)

		var poly := Polygon2D.new()
		poly.polygon = p.poly
		poly.color = Color(0.42, 0.3, 0.18, 1)
		holder.add_child(poly)

		# Edge highlight so props read as solid objects
		var edge := Line2D.new()
		edge.width = 2.5
		edge.default_color = Color(0.22, 0.15, 0.1, 1)
		edge.closed = true
		for pt in p.poly:
			edge.add_point(pt)
		holder.add_child(edge)

		var tag := Label.new()
		var aabb := _poly_aabb(p.poly)
		tag.text = "VẬT"
		tag.position = Vector2(aabb.position.x, aabb.position.y - 22)
		tag.add_theme_font_size_override("font_size", 11)
		tag.add_theme_color_override("font_color", Color(0.35, 0.25, 0.15, 0.85))
		holder.add_child(tag)

		_prop_data.append({"node": holder, "local": p.poly})

	_rebuild_shadows()


func _poly_aabb(poly: PackedVector2Array) -> Rect2:
	var r := Rect2(poly[0], Vector2.ZERO)
	for pt in poly:
		r = r.expand(pt)
	return r


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


func _process(delta: float) -> void:
	_hint_pulse += delta * 3.0
	if not _dragging and not _solved:
		var s := 1.0 + 0.06 * sin(_hint_pulse)
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
		var global_poly := PackedVector2Array()
		for pt in local:
			global_poly.append(node.to_global(pt))
		var sh := ShadowMath.cast_shadow(global_poly, lamp_pos, 640.0)
		shadow_polys.append(sh)
		var draw := Polygon2D.new()
		draw.polygon = _to_local_poly(sh)
		draw.color = Color(0.12, 0.14, 0.22, 0.62)
		shadows.add_child(draw)
		# Soft second layer for depth
		var soft := Polygon2D.new()
		soft.polygon = _to_local_poly(sh)
		soft.color = Color(0.08, 0.1, 0.16, 0.22)
		soft.position = Vector2(6, 4)
		shadows.add_child(soft)

	var flags: Array = []
	var hit := 0
	for s in _samples:
		var ok := false
		for sh in shadow_polys:
			if ShadowMath.point_in_poly(s, sh):
				ok = true
				break
		flags.append(ok)
		if ok:
			hit += 1
	_coverage = 0.0 if _samples.is_empty() else float(hit) / float(_samples.size())
	progress.value = _coverage * 100.0
	progress_label.text = "Bóng khớp: %d%%" % int(_coverage * 100.0)
	if target_ghost.has_method("set_covered"):
		target_ghost.set_covered(flags)
	if target_ghost.has_method("set_progress"):
		target_ghost.set_progress(_coverage)

	if not _solved and _coverage >= 0.84:
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
