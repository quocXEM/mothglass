extends Node2D
## Vẽ vùng mục tiêu: nền sọc, viền nét đứt, chấm cần tô, nhãn.

var outline: PackedVector2Array = PackedVector2Array()
var samples: Array = []
var covered: Array = [] # bool per sample
var fill_alpha := 0.12
var pulse := 0.0


func set_target(poly: PackedVector2Array, sample_pts: Array) -> void:
	outline = poly
	samples = sample_pts
	covered.clear()
	for _i in samples.size():
		covered.append(false)
	queue_redraw()


func set_covered(flags: Array) -> void:
	covered = flags
	queue_redraw()


func set_progress(t: float) -> void:
	fill_alpha = lerpf(0.08, 0.28, t)
	queue_redraw()


func _process(delta: float) -> void:
	pulse += delta * 2.2
	queue_redraw()


func _draw() -> void:
	if outline.size() < 3:
		return
	# Soft fill
	draw_colored_polygon(outline, Color(0.55, 0.22, 0.28, fill_alpha))
	# Hatch stripes so player reads "zone to fill"
	var aabb := _aabb(outline)
	var step := 14.0
	var x0 := aabb.position.x - 20.0
	var y0 := aabb.position.y - 20.0
	var x1 := aabb.end.x + 20.0
	var y1 := aabb.end.y + 20.0
	var c_hatch := Color(0.7, 0.25, 0.32, 0.22 + 0.06 * sin(pulse))
	var x := x0
	while x < x1 + (y1 - y0):
		var a := Vector2(x, y0)
		var b := Vector2(x - (y1 - y0), y1)
		_draw_clipped_line(a, b, c_hatch, 2.0)
		x += step
	# Dashed outline
	var dash_col := Color(0.75, 0.2, 0.3, 0.85)
	_draw_dashed_poly(outline, dash_col, 3.0, 10.0, 6.0)
	# Sample dots — empty ring until covered, then solid
	for i in samples.size():
		var p: Vector2 = samples[i]
		var ok: bool = i < covered.size() and covered[i]
		if ok:
			draw_circle(p, 9.0, Color(0.2, 0.55, 0.35, 0.9))
			draw_circle(p, 4.0, Color(0.95, 0.98, 0.92, 1))
		else:
			var wob := 1.0 + 0.12 * sin(pulse + float(i))
			draw_arc(p, 9.0 * wob, 0.0, TAU, 24, Color(0.75, 0.25, 0.32, 0.95), 2.5, true)
			draw_circle(p, 3.0, Color(0.75, 0.25, 0.32, 0.55))
	# Label above zone
	var mid := Vector2(aabb.position.x + aabb.size.x * 0.5, aabb.position.y - 28.0)
	var label := "← VÙNG CẦN TÔ BẰNG BÓNG"
	draw_string(ThemeDB.fallback_font, mid + Vector2(-130, 0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.55, 0.18, 0.25, 0.95))


func _aabb(poly: PackedVector2Array) -> Rect2:
	var r := Rect2(poly[0], Vector2.ZERO)
	for p in poly:
		r = r.expand(p)
	return r


func _draw_dashed_poly(poly: PackedVector2Array, color: Color, width: float, dash: float, gap: float) -> void:
	for i in poly.size():
		var a: Vector2 = poly[i]
		var b: Vector2 = poly[(i + 1) % poly.size()]
		_draw_dashed_segment(a, b, color, width, dash, gap)


func _draw_dashed_segment(a: Vector2, b: Vector2, color: Color, width: float, dash: float, gap: float) -> void:
	var dir := b - a
	var length := dir.length()
	if length < 0.01:
		return
	dir /= length
	var t := 0.0
	var draw_on := true
	while t < length:
		var seg := dash if draw_on else gap
		var t2 := minf(t + seg, length)
		if draw_on:
			draw_line(a + dir * t, a + dir * t2, color, width, true)
		draw_on = not draw_on
		t = t2


func _draw_clipped_line(a: Vector2, b: Vector2, color: Color, width: float) -> void:
	# Only draw segments that land inside outline (sample midpoints)
	var steps := 12
	var prev_inside := false
	var prev_pt := a
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var pt := a.lerp(b, t)
		var inside := Geometry2D.is_point_in_polygon(pt, outline)
		if inside and prev_inside:
			draw_line(prev_pt, pt, color, width, true)
		prev_inside = inside
		prev_pt = pt
