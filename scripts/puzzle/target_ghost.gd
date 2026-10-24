extends Node2D
## Vùng mục tiêu: sọc, viền đứt, chấm tô / chấm phạt.

var outlines: Array = [] # Array of PackedVector2Array
var samples: Array = []
var anti: Array = []
var covered: Array = []
var anti_hit: Array = []
var fill_alpha := 0.1
var pulse := 0.0


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
	queue_redraw()


func set_covered(sample_flags: Array, anti_flags: Array = []) -> void:
	covered = sample_flags
	anti_hit = anti_flags
	queue_redraw()


func set_progress(t: float) -> void:
	fill_alpha = lerpf(0.07, 0.26, t)
	queue_redraw()


func _process(delta: float) -> void:
	pulse += delta * 2.0
	queue_redraw()


func _draw() -> void:
	for outline in outlines:
		if outline.size() < 3:
			continue
		draw_colored_polygon(outline, Color(0.62, 0.18, 0.28, fill_alpha))
		_hatch(outline, Color(0.75, 0.22, 0.32, 0.2 + 0.05 * sin(pulse)))
		_dashed(outline, Color(0.8, 0.2, 0.3, 0.9), 3.0)

	for i in samples.size():
		var p: Vector2 = samples[i]
		var ok: bool = i < covered.size() and covered[i]
		if ok:
			draw_circle(p, 8.0, Color(0.18, 0.58, 0.38, 0.95))
			draw_circle(p, 3.5, Color(0.95, 0.98, 0.92, 1))
		else:
			var wob := 1.0 + 0.1 * sin(pulse + float(i) * 0.7)
			draw_arc(p, 8.0 * wob, 0.0, TAU, 20, Color(0.8, 0.22, 0.32, 0.95), 2.2, true)

	for i in anti.size():
		var p: Vector2 = anti[i]
		var hit: bool = i < anti_hit.size() and anti_hit[i]
		var col := Color(0.15, 0.15, 0.2, 0.85) if not hit else Color(0.9, 0.15, 0.1, 0.95)
		draw_line(p + Vector2(-7, -7), p + Vector2(7, 7), col, 2.0, true)
		draw_line(p + Vector2(-7, 7), p + Vector2(7, -7), col, 2.0, true)

	if not outlines.is_empty():
		var aabb := _aabb(outlines[0])
		var mid := Vector2(aabb.position.x + aabb.size.x * 0.5 - 90, aabb.position.y - 26)
		draw_string(ThemeDB.fallback_font, mid, "VÙNG CẦN TÔ", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.55, 0.15, 0.22, 0.95))


func _aabb(poly: PackedVector2Array) -> Rect2:
	var r := Rect2(poly[0], Vector2.ZERO)
	for p in poly:
		r = r.expand(p)
	return r


func _hatch(outline: PackedVector2Array, color: Color) -> void:
	var aabb := _aabb(outline)
	var step := 14.0
	var x := aabb.position.x - 30.0
	while x < aabb.end.x + aabb.size.y:
		var a := Vector2(x, aabb.position.y - 10)
		var b := Vector2(x - aabb.size.y - 20, aabb.end.y + 10)
		var prev_inside := false
		var prev := a
		for i in 14:
			var t := float(i) / 13.0
			var pt := a.lerp(b, t)
			var inside := Geometry2D.is_point_in_polygon(pt, outline)
			if inside and prev_inside:
				draw_line(prev, pt, color, 2.0, true)
			prev_inside = inside
			prev = pt
		x += step


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
			var seg := 10.0 if on else 6.0
			var t2 := minf(t + seg, length)
			if on:
				draw_line(a + dir * t, a + dir * t2, color, width, true)
			on = not on
			t = t2
