extends Node2D
## Vùng bóng cần phủ — đọc được ngay, không giống debug đỏ.

var outlines: Array = []
var samples: Array = []
var anti: Array = []
var covered: Array = []
var anti_hit: Array = []
var fill_alpha := 0.08
var pulse := 0.0
var hold_t := 0.0 # 0..1 while holding solve
var status := "" # short label above zone


func set_target(outline_list: Array, sample_pts: Array, anti_pts: Array = []) -> void:
	outlines = outline_list
	samples = sample_pts
	anti = anti_pts
	covered.clear()
	anti_hit.clear()
	for _i in samples.size():
		covered.append(false)
	for _i in anti.size():
		anti_hit.append(false)
	hold_t = 0.0
	status = ""
	queue_redraw()


func set_covered(sample_flags: Array, anti_flags: Array = []) -> void:
	covered = sample_flags
	anti_hit = anti_flags
	queue_redraw()


func set_progress(t: float) -> void:
	fill_alpha = lerpf(0.08, 0.32, t)
	queue_redraw()


func set_hold(t: float) -> void:
	hold_t = clampf(t, 0.0, 1.0)
	queue_redraw()


func set_status(text: String) -> void:
	status = text
	queue_redraw()


func _process(delta: float) -> void:
	pulse += delta * 1.6
	queue_redraw()


func _draw() -> void:
	for outline in outlines:
		if outline.size() < 3:
			continue
		# Readable wash + border
		draw_colored_polygon(outline, Color(0.95, 0.88, 0.7, fill_alpha * 0.55))
		draw_colored_polygon(outline, Color(0.12, 0.1, 0.09, fill_alpha))
		var col := Color(0.92, 0.82, 0.55, 0.55 + 0.2 * sin(pulse))
		if hold_t > 0.05:
			col = Color(0.85, 0.95, 0.75, 0.55 + 0.35 * hold_t)
		_dashed(outline, col, 2.0)
		# Hold ring progress on zone
		if hold_t > 0.02:
			var aabb := _aabb(outline)
			var c := aabb.get_center()
			draw_arc(c, mini(aabb.size.x, aabb.size.y) * 0.35, -PI * 0.5, -PI * 0.5 + TAU * hold_t, 48, Color(0.9, 0.95, 0.8, 0.85), 3.0, true)

	var filled := 0
	for i in samples.size():
		var p: Vector2 = samples[i]
		var ok: bool = i < covered.size() and covered[i]
		if ok:
			filled += 1
			draw_circle(p, 6.0, Color(0.9, 0.95, 0.8, 0.95))
			draw_circle(p, 2.5, Color(0.15, 0.2, 0.12, 1))
		else:
			var a := 0.45 + 0.25 * absf(sin(pulse + float(i) * 0.5))
			draw_arc(p, 6.0, 0.0, TAU, 20, Color(0.95, 0.85, 0.55, a), 2.0, true)
			draw_circle(p, 2.0, Color(0.95, 0.85, 0.55, a * 0.7))

	for i in anti.size():
		var p: Vector2 = anti[i]
		var hit: bool = i < anti_hit.size() and anti_hit[i]
		var col := Color(0.75, 0.2, 0.18, 0.85) if hit else Color(0.55, 0.25, 0.2, 0.35)
		draw_line(p + Vector2(-5, -5), p + Vector2(5, 5), col, 2.0, true)
		draw_line(p + Vector2(-5, 5), p + Vector2(5, -5), col, 2.0, true)

	if not outlines.is_empty() and status != "":
		var aabb := _aabb(outlines[0])
		var pos := Vector2(aabb.position.x + aabb.size.x * 0.5 - 70.0, aabb.position.y - 28.0)
		draw_string(ThemeDB.fallback_font, pos, status, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.95, 0.9, 0.8, 0.9))


func _aabb(poly: PackedVector2Array) -> Rect2:
	var r := Rect2(poly[0], Vector2.ZERO)
	for p in poly:
		r = r.expand(p)
	return r


func _dashed(poly: PackedVector2Array, color: Color, width: float) -> void:
	for i in poly.size():
		var a: Vector2 = poly[i]
		var b: Vector2 = poly[(i + 1) % poly.size()]
		var dir := b - a
		var length := dir.length()
		if length < 0.01:
			continue
		dir /= length
		var t := 0.0
		var on := true
		while t < length:
			var seg := 8.0 if on else 5.0
			var t2 := minf(t + seg, length)
			if on:
				draw_line(a + dir * t, a + dir * t2, color, width, true)
			on = not on
			t = t2
