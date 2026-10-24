extends Node2D

signal solved

@onready var world: Node2D = $World
@onready var lamp: Area2D = $World/Lamp
@onready var props_root: Node2D = $World/Props
@onready var shadows: Node2D = $World/Shadows
@onready var target_draw: Polygon2D = $World/TargetGhost
@onready var progress: ProgressBar = $UI/Progress
@onready var title_l: Label = $UI/Title
@onready var whisper_l: Label = $UI/Whisper
@onready var badge: Label = $UI/Badge
@onready var btn_back: Button = $UI/Top/BtnBack
@onready var btn_retry: Button = $UI/Top/BtnRetry
@onready var win_panel: PanelContainer = $UI/Win
@onready var btn_next: Button = $UI/Win/VBox/BtnNext
@onready var btn_menu: Button = $UI/Win/VBox/BtnMenu

var _dragging := false
var _drag_off := Vector2.ZERO
var _prop_data: Array = []
var _samples: Array = []
var _solved := false
var _coverage := 0.0


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
	target_draw.polygon = data.target_outline
	target_draw.color = Color(0.15, 0.14, 0.12, 0.14)

	_prop_data.clear()
	for p in data.props:
		var poly := Polygon2D.new()
		poly.polygon = p.poly
		poly.color = Color(0.18, 0.17, 0.16, 1)
		props_root.add_child(poly)
		poly.position = p.pos
		_prop_data.append({"node": poly, "local": p.poly})
		# Soft base plate
		var base := Polygon2D.new()
		base.polygon = p.poly
		base.color = Color(0.55, 0.52, 0.48, 0.35)
		base.position = p.pos + Vector2(4, 6)
		props_root.add_child(base)
		props_root.move_child(base, 0)

	_rebuild_shadows()


func _on_lamp_input(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_off = lamp.global_position - get_global_mouse_position()
			AudioBus.play_soft()
		else:
			_dragging = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_dragging = false


func _process(_delta: float) -> void:
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
		var node: Polygon2D = item.node
		var local: PackedVector2Array = item.local
		var global_poly := PackedVector2Array()
		for pt in local:
			global_poly.append(node.to_global(pt))
		var sh := ShadowMath.cast_shadow(global_poly, lamp_pos, 640.0)
		shadow_polys.append(sh)
		var draw := Polygon2D.new()
		draw.polygon = _to_local_poly(sh)
		draw.color = Color(0.12, 0.11, 0.1, 0.55)
		shadows.add_child(draw)

	_coverage = ShadowMath.coverage(_samples, shadow_polys)
	progress.value = _coverage * 100.0
	# Ghost đậm dần khi gần đúng
	target_draw.color = Color(0.15, 0.14, 0.12, lerpf(0.1, 0.35, _coverage))

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
	AudioBus.play_solve()
	GameState.mark_done(GameState.current_room)
	win_panel.visible = true
	win_panel.modulate.a = 0.0
	create_tween().tween_property(win_panel, "modulate:a", 1.0, 0.5)
	# Moth pulse on target
	var tw := create_tween().set_loops(3)
	tw.tween_property(target_draw, "color", Color(0.12, 0.11, 0.1, 0.55), 0.25)
	tw.tween_property(target_draw, "color", Color(0.12, 0.11, 0.1, 0.2), 0.25)
	solved.emit()


func _on_next() -> void:
	AudioBus.play_soft()
	if GameState.current_room >= GameState.TOTAL_ROOMS:
		GameState.goto_menu()
		return
	GameState.current_room += 1
	GameState.save()
	_load_room(GameState.current_room)
