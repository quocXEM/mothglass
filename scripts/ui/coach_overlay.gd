extends CanvasLayer
## First-run coach — one clear screen, international UX standard.


func _ready() -> void:
	layer = 40
	if GameState.coach_seen:
		queue_free()
		return
	_build()


func _build() -> void:
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.05, 0.04, 0.03, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -260
	panel.offset_top = -170
	panel.offset_right = 260
	panel.offset_bottom = 170
	add_child(panel)

	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 12)
	panel.add_child(v)

	var title := Label.new()
	title.text = Loc.tr_key("coach.title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	v.add_child(title)

	for key in ["coach.1", "coach.2", "coach.3"]:
		var row := Label.new()
		row.text = Loc.tr_key(key)
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_theme_font_size_override("font_size", 16)
		v.add_child(row)

	var btn := Button.new()
	btn.text = Loc.tr_key("coach.ok")
	btn.custom_minimum_size = Vector2(180, 42)
	btn.pressed.connect(_dismiss)
	v.add_child(btn)


func _dismiss() -> void:
	AudioBus.play_ui()
	GameState.mark_coach_seen()
	queue_free()
