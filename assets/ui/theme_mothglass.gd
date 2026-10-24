extends Node
## Builds art-game Theme at runtime (Cormorant + quiet paper controls).


func _ready() -> void:
	var theme := _build()
	get_tree().root.theme = theme


func _load_font(path: String) -> FontFile:
	if not FileAccess.file_exists(path):
		return null
	var f := FontFile.new()
	var err := f.load_dynamic_font(path)
	if err != OK:
		push_warning("Font load failed: %s (%s)" % [path, err])
		return null
	return f


func _build() -> Theme:
	var theme := Theme.new()
	var font_reg: FontFile = _load_font("res://assets/fonts/CormorantGaramond-Regular.ttf")
	var font_bold: FontFile = _load_font("res://assets/fonts/CormorantGaramond-SemiBold.ttf")
	var font_body: FontFile = _load_font("res://assets/fonts/Literata-Regular.ttf")
	if font_reg == null:
		font_reg = _load_font("res://assets/fonts/EBGaramond-Regular.ttf")
	if font_body == null:
		font_body = font_reg
	if font_bold == null:
		font_bold = font_reg
	if font_reg:
		theme.default_font = font_reg
		theme.default_font_size = 18

	var ink := Color(0.16, 0.13, 0.11, 1)
	var mute := Color(0.35, 0.3, 0.26, 0.9)
	var paper := Color(0.96, 0.93, 0.88, 0.92)
	var line := Color(0.22, 0.18, 0.14, 0.55)

	# Buttons — hairline, no loud fill
	var btn_n := _style_box(paper, line, 1, 14, 18)
	var btn_h := _style_box(Color(0.98, 0.95, 0.9, 0.98), Color(0.18, 0.14, 0.1, 0.8), 1, 14, 18)
	var btn_p := _style_box(Color(0.9, 0.86, 0.8, 0.95), line, 1, 14, 18)
	theme.set_stylebox("normal", "Button", btn_n)
	theme.set_stylebox("hover", "Button", btn_h)
	theme.set_stylebox("pressed", "Button", btn_p)
	theme.set_stylebox("focus", "Button", btn_h)
	theme.set_color("font_color", "Button", ink)
	theme.set_color("font_hover_color", "Button", ink)
	theme.set_color("font_pressed_color", "Button", ink)
	theme.set_font_size("font_size", "Button", 17)
	if font_bold:
		theme.set_font("font", "Button", font_bold)
	elif font_reg:
		theme.set_font("font", "Button", font_reg)

	# Labels
	theme.set_color("font_color", "Label", ink)
	theme.set_font_size("font_size", "Label", 16)
	if font_body:
		theme.set_font("font", "Label", font_body)

	# Panels
	var panel := _style_box(Color(0.96, 0.93, 0.88, 0.55), Color(0.25, 0.2, 0.16, 0.25), 1, 16, 18)
	theme.set_stylebox("panel", "PanelContainer", panel)

	# ProgressBar
	var bg := _style_box(Color(0.2, 0.16, 0.12, 0.2), Color(0, 0, 0, 0), 0, 0, 0)
	var fill := _style_box(Color(0.22, 0.18, 0.14, 0.75), Color(0, 0, 0, 0), 0, 0, 0)
	bg.set_corner_radius_all(1)
	fill.set_corner_radius_all(1)
	theme.set_stylebox("background", "ProgressBar", bg)
	theme.set_stylebox("fill", "ProgressBar", fill)

	return theme


func _style_box(bg: Color, border: Color, border_w: int, pad_h: int, pad_v: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_w)
	s.set_corner_radius_all(2)
	s.content_margin_left = pad_h
	s.content_margin_right = pad_h
	s.content_margin_top = pad_v * 0.55
	s.content_margin_bottom = pad_v * 0.55
	return s
